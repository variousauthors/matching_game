
-- move the block discretely as far down as possible
function drop_block (block, board)
    local cx, cy = block.cx, block.cy + 1

    -- iterate over the current column from the block
    while (cy <= game.height and board[cy][cx] == false) do
        block.cy = cy
        cy = cy + 1
    end

    game.block = nil
    board[block.cy][block.cx] = block

    block.y = block.cy
end

-- move the block side to side
function move_block (block, board, direction)
    local cx = block.cx + direction

    -- clamp the move
    cx = math.max(math.min(game.width, cx), 0)

    -- if the block would move and the board contains the target space
    -- TODO this appears to be wrong since board[x] should be board[y][x]
    if (cx ~= block.cx) then

        -- check for collision
        if not (board[block.cy][cx] ~= false) then
            block.cx = cx
        end
    end

    block.x = block.cx
end

-- move the block discretely down one row
function step_block (block, board)
    -- check for a block in the next square
    if (block.cy + 1 > game.height or board[block.cy + 1][block.cx] ~= false) then
        -- remove the block and add to the board
        game.block = nil
        board[block.cy][block.cx] = block
    else
        block.cy = math.min(game.height, block.cy + 1)
    end

    block.y = block.cy
end
