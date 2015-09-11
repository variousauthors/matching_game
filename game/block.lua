
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
    game.block_count = game.block_count + 1
    local cx, cy = block.cx, block.cy
    local below

    -- do not apply forces to grey blocks
    if (block.color == game.colors.grey) then
        -- remove it if it is broken
        if block.hp == 0 then
            block = nil
            board[cy][cx] = false
        end

        return
    end

    -- the block is at rest, at the bottom of the board
    if (not board[cy + 1]) then
        block.dy = 0
        table.insert(board.dirty, block)
        return
    end

    -- apply forces
    block.dy = block.dy + game.gravity*game.dt

    -- check the block below this one
    collision = block_collide(block, board[cy + 1][cx])

    if (collision) then
        -- this block has landed
        block.dy = 0
        table.insert(board.dirty, block)
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

