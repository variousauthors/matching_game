
function draw_block (block)
    love.graphics.setColor(block.color)
    love.graphics.rectangle('fill', block.x * game.scale, block.y * game.scale, block.dim * game.scale, block.dim * game.scale)
    love.graphics.setColor(game.colors.white)

    if (block.color == game.colors.grey) then
        if (block.hp == 2) then
            -- one cross
            love.graphics.setColor(game.colors.damage)
            love.graphics.line(block.cx * game.scale, block.cy * game.scale, (block.cx + block.dim) * game.scale, (block.cy + block.dim) * game.scale)
            love.graphics.setColor(game.colors.white)

        elseif (block.hp == 1) then
            -- two cross
            love.graphics.setColor(game.colors.damage)
            love.graphics.line(block.cx * game.scale, block.cy * game.scale, (block.cx + block.dim) * game.scale, (block.cy + block.dim) * game.scale)
            love.graphics.line((block.cx + block.dim) * game.scale, block.cy * game.scale, block.cx * game.scale, (block.cy + block.dim) * game.scale)
            love.graphics.setColor(game.colors.white)
        end
    end
end

function build_block ()
    local index = math.random(1, 3)
    local x = math.ceil(game.width/2)
    local y = 1

    return {
        -- position in the grid
        cx = x,
        cy = y,
        -- real position relative to the grid (0..1)
        rx = 0,
        ry = 0,

        dx = 0,
        dy = 0,

        -- final position in each timestep fro graphics
        x = math.ceil(game.width/2),
        y = 1,

        dim = 1,
        color = game.colors[index],
        marked = false,
        hp = 3
    }
end

function block_collide(block, other)
    return other and other.dy == 0
end

function update_block (block, board)
    local cx, cy = block.cx, block.cy
    local below

    -- the block is at rest, at the bottom of the board
    if (not board[cy + 1]) then
        block.dy = 0
        return
    end

    -- apply forces
    block.dy = block.dy + game.gravity*game.dt

    -- check the block below this one
    collision = block_collide(block, board[cy + 1][cx])

    if (collision) then
        -- this block has landed
        block.dy = 0

        if (block.color ~= game.colors.grey) then
            table.insert(board.dirty, block)
        end
    end

    block.ry = block.ry + block.dy

    -- if the block passes into a new square
    -- adjust the board
    if (block.ry > 1) then
        block.cy = block.cy + 1
        block.ry = 0

        board[cy][cx] = false
        board[cy + 1][cx] = block
    end

    block.y = math.min(block.cy + 1, block.cy + block.ry)
end

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
    clear_blocks(board, block)

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
        clear_blocks(board, block)
    else
        block.cy = math.min(game.height, block.cy + 1)
    end

    block.y = block.cy
end

