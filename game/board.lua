function build_board_row (board, y, options)
    local options = options or {}
    options.default = options.default or nil
    local default = options.default or EMPTY
    local cells = board.cells

    cells[y] = {}

    for x = 1, game.width, 1 do
        if (options.default) then
            cells[y][x] = default
        else
            cells[y][x] = build_block({ board = board, x = x, y = y, color = GREY })
        end
    end
end

function build_board (options)
    local options = options or {}
    options.default = options.default or nil
    local default = options.default or EMPTY
    local board = {}
    local i, j

    board.x = game.board_defaults.x
    board.y = game.board_defaults.y
    board.width = game.board_defaults.width
    board.height = game.board_defaults.height
    board.color = game.board_defaults.color
    board.border_alpha = game.board_defaults.border_alpha

    board.dirty = {}
    board.cells = {}

    for y = 1, game.height, 1 do
        board.cells[y] = {}

        for x = 1, game.width, 1 do
            board.cells[y][x] = default
        end
    end

    return board
end

function draw_board_background (board)
    love.graphics.push("all")
    local cells = board.cells

    -- TODO again, what is up with that 4
    love.graphics.setColor(board.color)
    love.graphics.rectangle('fill', board.x * game.scale - 2, board.y * game.scale - 2, board.width * game.scale + 4, (#cells) * game.scale + 4)

    love.graphics.pop()
end

function draw_board_border (board)
    love.graphics.push("all")
    local cells = board.cells

    -- TODO clean up these magic numbers already!
    -- a thin line of board color to pad the blocks in
    love.graphics.setLineWidth(4)

    if (game.next_block) then
        local n = block_color(game.next_block)
        love.graphics.setColor({ n[1], n[2], n[3], board.border_alpha })
        love.graphics.rectangle('line', board.x * game.scale - 4, board.y * game.scale - 4, board.width * game.scale + 8, (#cells) * game.scale + 8)
    end

    love.graphics.setLineWidth(2)

    -- TODO I've just added a flat 3 to the board height to make it run off the bottom
    love.graphics.setColor(board.color)
    love.graphics.rectangle('line', board.x * game.scale - 6, board.y * game.scale - 6, board.width * game.scale + 12, (#cells) * game.scale + 12)

    love.graphics.setLineWidth(1)

    love.graphics.pop()
end

function draw_board_preview_arrow (board)
    love.graphics.push("all")
    local next_block = game.next_block
    local offset = game.block_gap_width*game.block_border

    local x = next_block.x * game.scale + offset
    local d = next_block.dim * game.scale - 2*offset

    local n = next_block.color
    love.graphics.setColor({ n[1], n[2], n[3], board.border_alpha })
    tiny_triangle(x, game.scale/game.tiny_triangle_ratio, d, "down")

    love.graphics.pop()
end


function draw_board (board)
    love.graphics.push("all")

    local i, j
    local shadows = game.state.shadows.cells

    draw_board_border(board)
    draw_board_background(board)

    for y = 1, #(shadows) do
        for x = 1, #(shadows[y]) do

            if (shadows[y][x] > 0) then
                local offset = game.block_gap_width*game.block_border

                local n = {
                    game.colors.white[1],
                    game.colors.white[2],
                    game.colors.white[3]
                }

                love.graphics.setColor(n[1], n[2], n[3], 255 * shadows[y][x])
                love.graphics.rectangle('fill', (x + 1) * game.scale + offset, (y - 1) * game.scale + offset, 1 * game.scale - 2 * offset, 1 * game.scale - 2 * offset)
                love.graphics.setColor(game.colors.white)
            end
        end
    end

    local cells = board.cells
    for y = 1, #(cells) do
        for x = 1, #(cells[y]) do

            if (cells[y][x] ~= EMPTY) then

                draw_block(cells[y][x])
            end
        end
    end

    for i, mote in pairs(game.state.motes) do
        draw_mote(mote)
    end

    if (game.tiny_triangle == true) then
        draw_board_preview_arrow(board)
    end

    love.graphics.pop()
end

function update_board(board)
    local block
    local all_blocks_are_still = true
    local cells = board.cells
    local shadows = game.state.shadows.cells

    for i, mote in pairs(game.state.motes) do
        update_mote(mote, dt)
    end

    -- check each cell from bottom to top
    for y = #(cells), 1, -1 do
        for x = 1, board.width, 1 do
            if (cells[y][x] ~= EMPTY) then
                -- update each block
                block = cells[y][x]

                update_block(block, board)

                -- only check for matches when all blocks have settled
                if block.dy ~= 0 and block.grey == false then
                    all_blocks_are_still = false
                end

                if block.animating then
                    game.stable = false
                end
            end
        end
    end

    -- if a colour block is on any of the bottom rows, create a new
    -- row and shift the board
    local shift_down = false
    for x = 1, board.width, 1 do
        -- TODO do we actually need a loop here? If blocks are being
        -- cleared it is because there are blocks above them...
        -- couldn't we just use "2"
        for y = 0, 2 do
            local cell = cells[#cells - y][x]

            if (cell and cell.grey == false) then
                shift_down = true
            end
        end
    end

    if shift_down then
        game.state.shift = game.state.shift + 1
        move_camera(game.camera, 0, game.state.shift)

        build_board_row(board, #cells + 1)
        build_board_row(game.state.shadows, #(shadows) + 1, { default = 0.0 })
    end

    -- if no blocks are moving, look for matches otherwise
    -- discard the dirty list
    if (all_blocks_are_still) then

        while (#board.dirty > 0) do
            game.stable = false
            local block = table.remove(board.dirty, 1)

            clear_blocks(board, block)
        end
    else
        -- some blocks are moving, presumably falling
        game.stable = false
        board.dirty = {}
    end

    for y = 1, #(cells) do
        for x = 1, #(cells[y]) do

            if (shadows[y][x] > 0.1) then
                shadows[y][x] = shadows[y][x] - game.dt / 1
            end
        end
    end
end

function clear_blocks (board, block)
    if (block.grey == true) then
        return
    end

    if (block.exploding > -1) then
        return
    end

    local cy = block.cy
    local blocks = 0
    local Q = {}
    local marked = {}
    local damage = {}
    local index = 1
    local color = block.color
    local cells = board.cells

    -- sound controls
    local play_shatter = false
    local play_chip = false
    local play_harden = false
    local play_explode = false

    block.marked = true
    table.insert(marked, block) -- blocks in the chain
    table.insert(Q, block)

    while (#(Q) > 0) do
        local curr = table.remove(Q, 1)

        for i, v in ipairs({ 1, -1 }) do
            if (cells[curr.cy][curr.cx + v] ~= nil and cells[curr.cy][curr.cx + v] ~= EMPTY) then
                local adj = cells[curr.cy][curr.cx + v]

                if (not adj.marked and adj.color == block.color) then
                    adj.marked = true
                    table.insert(Q, adj)
                    table.insert(marked, adj)
                elseif (not adj.marked) then
                    if (game.all_block_get_damage == true or adj.grey == true) then
                        adj.marked = true
                        table.insert(damage, adj)
                    end
                end
            end

            if (cells[curr.cy + v] and cells[curr.cy + v][curr.cx] ~= nil and cells[curr.cy + v][curr.cx] ~= EMPTY) then
                local adj = cells[curr.cy + v][curr.cx]

                if (not adj.marked and adj.color == block.color) then
                    adj.marked = true
                    table.insert(Q, adj)
                    table.insert(marked, adj)
                elseif (not adj.marked) then
                    if (game.all_block_get_damage == true or adj.grey == true) then
                        adj.marked = true
                        table.insert(damage, adj)
                    end
                end
            end
        end
    end

    -- if we have at least 3 blocks marked for removal,
    -- remove all marked blocks
    for i,v in ipairs(marked) do
        v.marked = false

        if (#(marked) == game.match_target) then
            start_tween(cells[v.cy][v.cx], "hardening")
            play_harden = true

        elseif (#(marked) > game.match_target) then
            start_tween(cells[v.cy][v.cx], "exploding")
            play_explode = true
        end
    end

    while (#(damage) > 0) do
        local block = table.remove(damage, 1)
        block.marked = false

        if (#(marked) > game.match_target) then
            if (block.grey == true or block.hp > game.block_max_hp - 2) then
                block.hp = block.hp - 1

                play_chip = true

                if block.hp == 0 then
                    play_shatter = true
                end
            end
        end
    end

    if (play_chip) then
    end

    if (play_shatter) then
        love.soundman.run('shatter')
    end

    if (play_explode) then
        love.soundman.run('pop')
    end

    if (play_harden) then
        love.soundman.run('power_down')
    end
end

