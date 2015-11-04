function next_block ()
    local block = game.next_block

    if (game.random_x_starting_position) then
        local x = math.ceil(math.random() * game.width)
        game.next_block = build_block({ x = x })
    else
        -- 1 - game.board.y puts the block at the top of the visible
        -- board
        game.next_block = build_block({ y = 1 + game.camera.cy })
    end

    return block
end

-- move the block discretely as far down as possible
function drop_block (block, board)
    local cx, cy = block.cx, block.cy + 1
    local cells = board.cells

    -- iterate over the current column from the block
    while (cy <= #cells and cells[cy][cx] == EMPTY) do
        block.cy = cy
        cy = cy + 1
    end

    game.block = nil

    -- set the blocks velocity to infinity
    -- to represent that it is moving discretely
    block.dy = game.infinity
    cells[block.cy][block.cx] = block

    block_set_y(block, board, block.cy)
end

-- move the block side to side
function move_block (block, board, direction)
    local cx = block.cx + direction
    local cells = board.cells

    -- clamp the move
    cx = math.max(math.min(game.width, cx), 0)

    -- if the block would move and the board contains the target space
    -- TODO this appears to be wrong since board[x] should be board[y][x]
    if (cx ~= block.cx) then

        -- check for collision
        if (cells[block.cy][cx] == EMPTY) then
            block.cx = cx
        end
    end

    block_set_x(block, board, block.cx)
end

-- move the block discretely down one row
function step_block (block, board)
    local cells = board.cells
    -- check for a block in the next square
    if (block.cy + 1 > #cells or cells[block.cy + 1][block.cx] ~= EMPTY) then
        -- remove the block and add to the cells
        game.block = nil

        -- set the blocks velocity to infinity
        -- to represent that it is moving discretely
        block.dy = game.infinity
        cells[block.cy][block.cx] = block
    else
        block.cy = math.min(#cells, block.cy + 1)
    end

    block_set_y(block, board, block.cy)
end

