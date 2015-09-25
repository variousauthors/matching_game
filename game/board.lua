
function build_board ()
    local board = {}
    local i, j

    board.x = game.board_defaults.x
    board.y = game.board_defaults.y
    board.width = game.board_defaults.width
    board.height = game.board_defaults.height
    board.color = game.board_defaults.color
    board.border_alpha = game.board_defaults.border_alpha

    board.dirty = {}

    for y = 1, game.height, 1 do
        board[y] = {}

        for x = 1, game.width, 1 do
            board[y][x] = false
        end
    end

    return board
end

function draw_board_background (board)
    love.graphics.push("all")

    love.graphics.setColor(board.color)
    love.graphics.rectangle('fill', board.x * game.scale - 2, board.y * game.scale - 2, board.width * game.scale + 4, board.height * game.scale + 4)

    love.graphics.pop()
end

function draw_board_border (board)
    love.graphics.push("all")

    -- a thin line of board color to pad the blocks in
    love.graphics.setLineWidth(4)

    local n = game.next_block.color
    love.graphics.setColor({ n[1], n[2], n[3], board.border_alpha })
    love.graphics.rectangle('line', board.x * game.scale - 4, board.y * game.scale - 4, board.width * game.scale + 8, board.height * game.scale + 8)

    love.graphics.setLineWidth(2)

    love.graphics.setColor(board.color)
    love.graphics.rectangle('line', board.x * game.scale - 6, board.y * game.scale - 6, board.width * game.scale + 12, board.height * game.scale + 12)

    love.graphics.setLineWidth(1)

    love.graphics.pop()
end

function draw_board_preview_arrow (board)
    love.graphics.push("all")
    local next_block = game.next_block
    local offset = 3 * game.block_border

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

    draw_board_border(board)
    draw_board_background(board)

    for y = 1, #(board) do
        for x = 1, #(board[y]) do
            if (board[y][x] ~= false) then

                draw_block(board[y][x])
            end
        end
    end

    for i, mote in pairs(game.motes) do
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

    for i, mote in pairs(game.motes) do
        update_mote(mote, dt)
    end

    -- check each cell from bottom to top
    for y = game.height, 1, -1 do
        for x = 1, game.width, 1 do
            if (board[y][x]) then
                -- update each block
                block = board[y][x]

                update_block(block, board)

                -- only check for matches when all blocks have settled
                if block.dy ~= 0 and block.color ~= game.colors.grey then
                    all_blocks_are_still = false
                end

                if block.animating then
                    game.stable = false
                end
            end
        end
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
end

function clear_blocks (board, block)
    if (block.color == game.colors.grey) then
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
            if (board[curr.cy][curr.cx + v]) then
                local adj = board[curr.cy][curr.cx + v]

                if (not adj.marked and adj.color == block.color) then
                    adj.marked = true
                    table.insert(Q, adj)
                    table.insert(marked, adj)
                elseif (not adj.marked and adj.color == game.colors.grey) then
                    adj.marked = true
                    table.insert(damage, adj)
                end
            end

            if (board[curr.cy + v] and board[curr.cy + v][curr.cx]) then
                local adj = board[curr.cy + v][curr.cx]

                if (not adj.marked and adj.color == block.color) then
                    adj.marked = true
                    table.insert(Q, adj)
                    table.insert(marked, adj)
                elseif (not adj.marked and adj.color == game.colors.grey) then
                    adj.marked = true
                    table.insert(damage, adj)
                end
            end
        end
    end

    while (#(damage) > 0) do
        local block = table.remove(damage, 1)
        block.marked = false

        if (#(marked) > game.match_target) then
            block.hp = block.hp - 1

            play_chip = true

            if block.hp == 0 then
                play_shatter = true
            end
        end
    end

    -- if we have at least 3 blocks marked for removal,
    -- remove all marked blocks
    for i,v in ipairs(marked) do
        v.marked = false

        if (#(marked) == game.match_target) then
            start_tween(board[v.cy][v.cx], "hardening")
            play_harden = true

        elseif (#(marked) > game.match_target) then
            start_tween(board[v.cy][v.cx], "exploding")
            play_explode = true
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

