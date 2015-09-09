
function build_board ()
    local board = {}
    local i, j

    board.moved = {}

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
    -- check each cell from bottom to top

    -- update each block
    for y = game.height, 1, -1 do
        for x = 1, game.width, 1 do
            if (board[y][x]) then
                update_block(board[y][x], board)
            end
        end
    end

    while ((#board.moved) > 0) do
        clear_blocks(board, table.remove(board.moved, 1))
    end
end

function clear_blocks (board, block)
    local y = block.y
    local blocks = 0
    local Q = {}
    local marked = {}
    local index = 1
    local color = block.color

    block.marked = true
    table.insert(marked, block)
    table.insert(Q, block)

    while (#(Q) > 0) do
        local curr = table.remove(Q, 1)

        for i, v in ipairs({ 1, -1 }) do
            if (board[curr.y][curr.x + v]) then
                local adj = board[curr.y][curr.x + v]

                if (not adj.marked and adj.color == block.color) then
                    adj.marked = true
                    table.insert(Q, adj)
                    table.insert(marked, adj)
                end
            end

            if (board[curr.y + v] and board[curr.y + v][curr.x]) then
                local adj = board[curr.y + v][curr.x]

                if (not adj.marked and adj.color == block.color) then
                    adj.marked = true
                    table.insert(Q, adj)
                    table.insert(marked, adj)
                end
            end
        end
    end

    -- if we have at least 3 blocks marked for removal,
    -- remove all marked blocks
    for i,v in ipairs(marked) do
        v.marked = false

        if (#(marked) == game.match_target) then
            board[v.y][v.x].color = game.colors.grey

        elseif (#(marked) > game.match_target) then
            board[v.y][v.x] = false

        end
    end

end

