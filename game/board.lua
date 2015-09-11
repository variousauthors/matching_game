
function build_board ()
    local board = {}
    local i, j

    board.dirty = {}

    for y = 1, game.height, 1 do
        board[y] = {}

        for x = 1, game.width, 1 do
            board[y][x] = false
        end
    end

    return board
end

function draw_board (board)
    local i, j

    for y = 1, #(board) do
        for x = 1, #(board[y]) do
            if (board[y][x] ~= false) then
                -- set the color to the block's color
                draw_block(board[y][x])
            end
        end
    end

    love.graphics.rectangle('line', game.scale, game.scale, game.width * game.scale, game.height * game.scale)
end

function update_board(board)
    print("in update_board")
    local block
    local check_for_matches = true

    -- check each cell from bottom to top
    for y = game.height, 1, -1 do
        for x = 1, game.width, 1 do
            if (board[y][x]) then
                -- update each block
                block = board[y][x]

                update_block(block, board)

                if block.dy ~= 0 and block.color ~= game.colors.grey then
                    check_for_matches = false
                end
            end
        end
    end

    -- if no blocks are moving, look for matches otherwise
    -- discard the dirty list
    if (check_for_matches) then
        while (#board.dirty > 0) do
            local block = table.remove(board.dirty, 1)

            clear_blocks(board, block)
        end
    else
        board.dirty = {}
    end
end

function clear_blocks (board, block)
    print("in clear_blocks")
    if (block.color == game.colors.grey) then
        print("  was grey")
        return
    end

    local cy = block.cy
    local blocks = 0
    local Q = {}
    local marked = {}
    local damage = {}
    local index = 1
    local color = block.color

    block.marked = true
    table.insert(marked, block) -- blocks in the chain
    table.insert(damage, block) -- grey blocks near the chain
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
        end
    end

    -- if we have at least 3 blocks marked for removal,
    -- remove all marked blocks
    for i,v in ipairs(marked) do
        v.marked = false

        if (#(marked) == game.match_target) then
            board[v.cy][v.cx].color = game.colors.grey

        elseif (#(marked) > game.match_target) then
            board[v.cy][v.cx] = false

        end
    end

end

