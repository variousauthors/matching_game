
function draw_block (block)
    love.graphics.setColor(block.color)
    love.graphics.rectangle('fill', block.x * game.scale, block.y * game.scale, block.dim, block.dim)
    love.graphics.setColor(game.colors.white)
end

function update_block (block, board)
    local x, y = block.x, block.y
    local block = board[y][x]

    if (board[y + 1]) and (not board[y + 1][x]) then
        block.y = y + 1
        board[y][x] = false
        board[block.y][block.x] = block

        if (block.color ~= game.colors.grey) then
            table.insert(board.moved, block)
        end
    end
end

function drop_block (block, board)
    local x, y = block.x, block.y + 1

    -- iterate over the current column from the block
    while (y <= game.height and board[y][x] == false) do
        block.y = y
        y = y + 1
    end

    game.block = nil
    board[block.y][block.x] = block
    clear_blocks(board, block)
end

-- move the block side to side
function move_block (block, board, direction)
    local x = block.x + direction

    -- clamp the move
    x = math.max(math.min(game.width, x), 0)

    -- if the block would move and the board contains the target space
    -- TODO this appears to be wrong since board[x] should be board[y][x]
    if (x ~= block.x and board[x]) then

        -- check for collision
        if not (board[block.y][x] ~= false) then
            block.x = x
        end
    end
end

-- move the block down one row
function step_block (block, board)
    -- check for a block in the next square
    if (block.y + 1 > game.height or board[block.y + 1][block.x] ~= false) then
        -- remove the block and add to the board
        game.block = nil
        board[block.y][block.x] = block
        clear_blocks(board, block)
    else
        block.y = math.min(game.height, block.y + 1)
    end
end

function build_block ()
    local index = math.random(1, 3)

    return {
        x = math.ceil(game.width/2),
        y = 1,
        dim = game.scale,
        color = game.colors[index],
        marked = false
    }
end

