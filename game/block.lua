
function draw_block_damage (block)
    local b = game.block_border
    love.graphics.push("all")

    love.graphics.setColor(game.colors.damage)

    love.graphics.setLineWidth(b)

    if (block.hp == game.block_max - 1) then
        -- one cross
        love.graphics.line(block.x * game.scale, block.y * game.scale, (block.x + block.dim) * game.scale, (block.y + block.dim) * game.scale)

    elseif (block.hp == game.block_max - 2) then
        -- two cross
        love.graphics.line(block.x * game.scale, block.y * game.scale, (block.x + block.dim) * game.scale, (block.y + block.dim) * game.scale)
        love.graphics.line((block.x + block.dim) * game.scale, block.y * game.scale, block.x * game.scale, (block.y + block.dim) * game.scale)
    end

    love.graphics.setLineWidth(1)
    love.graphics.pop()
end

function draw_block_border (block)
    local b = game.block_border -- border size
    local e = 0 -- explosion size

    love.graphics.push("all")

    if (game.flicker and game.draw_seed == 0 and block.color ~= game.colors.grey) then
        love.graphics.setColor({ block.color[1] * 2/3, block.color[2] * 2/3, block.color[3] * 2/3 })
    else
        love.graphics.setColor(block.color)
    end

    if block.exploding > -1 then
        e = game.animations.exploding - block.exploding
    elseif block.hardening > -1 then
        e = - (game.animations.hardening - block.hardening)
    end

    if (block.color ~= game.colors.grey) then
        love.graphics.setLineWidth(b)
        love.graphics.rectangle('line', block.x * game.scale + b - e/2, block.y * game.scale + b - e/2, block.dim * game.scale - 2*b + e, block.dim * game.scale - 2*b + e)
        love.graphics.setLineWidth(1)
    end

    love.graphics.pop()
end

function tiny_triangle (x, y, dim, dir)
    if dir == "down" then
        love.graphics.polygon('fill', x, y, x + dim, y, x + dim/2, y + dim/2)
    elseif dir == "right" then
        love.graphics.polygon('fill', x, y, x, y + dim, x + dim/2, y + dim/2)
    elseif dir == "left" then
        love.graphics.polygon('fill', x + dim, y, x + dim, y + dim, x + dim/2, y + dim/2)
    elseif dir == "up" then
        love.graphics.polygon('fill', x, y + dim, x + dim, y + dim, x + dim/2, y + dim/2)
    end
end

function draw_block (block)
    love.graphics.push("all")

    local offset = 3*game.block_border

    if (block.mote) then
        draw_mote(block.mote)
    end

    love.graphics.setColor(game.colors.grey)

    if (block.crumbling < 0) then
        love.graphics.rectangle('fill', block.x * game.scale + offset, block.y * game.scale + offset, block.dim * game.scale - 2 * offset, block.dim * game.scale - 2 * offset)

        draw_block_border(block)
    else

        -- four triangles expanding away
        local e = game.animations.crumbling - block.crumbling
        local d = block.dim * game.scale - 2*offset
        local x = block.x * game.scale + offset
        local y = block.y * game.scale + offset

        tiny_triangle(x, y + e, d, "up")
        tiny_triangle(x + e, y, d, "left")
        tiny_triangle(x - e, y, d, "right")
        tiny_triangle(x, y - e, d, "down")

    end

    if (block.color == game.colors.grey) then
        draw_block_damage(block)
    end

    love.graphics.pop()
end

function build_block (options)
    local options = options or {}
    local x = options.x or math.ceil(game.width/2)
    local y = options.y or 1
    local color = game.colors[options.color] or game.colors[math.random(1, 3)]

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
        x = x - 1 + game.board.x,
        y = y - 1 + game.board.y,

        dim = 1,
        color = color,
        marked = false,
        hp = game.block_max,

        -- animations
        animating = false,
        exploding = -1,
        crumbling = -1,
        hardening = -1
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
    if (block.color == game.colors.grey or block.animating) then
        -- remove it if it is broken
        if block.hp == 0 then
            block.hp = -1
            start_tween(board[cy][cx], "crumbling")
        end

        -- ANIMATIONS
        -- adjust the explosion
        if block.exploding > 0 then
            block.exploding = block.exploding - 1
        elseif block.exploding == 0 then
            block.exploding = -1
            board[cy][cx] = false
        end

        -- adjust the crumbling
        if block.crumbling > 0 then
            block.crumbling = block.crumbling - 1
        elseif block.crumbling == 0 then
            block.crumbling = -1
            board[cy][cx] = false
        end

        -- adjust the hardening
        if block.hardening > 0 then
            block.hardening = block.hardening - 1
        elseif block.hardening == 0 then
            block.hardening = -1
            block.mote = build_mote(block)
            board[cy][cx].color = game.colors.grey
        end

        -- TODO move this into the animation controller
        if block.crumbling == -1 and block.exploding == -1 and block.hardening == -1 then
            block.animating = false
        end

        return
    end

    -- the block is at rest, at the bottom of the board
    if (not board[cy + 1]) then
        if (block.dy ~= 0) then
            -- if the block was previously moving insert it
            table.insert(board.dirty, block)
        end

        block.dy = 0

        return
    end

    if (block.dy ~= 0) then
        -- if the block was previously moving it may collide
        table.insert(board.dirty, block)
    end

    -- apply forces
    block.dy = block.dy + game.gravity*game.dt

    -- check the block below this one
    collision = block_collide(block, board[cy + 1][cx])

    if (collision) then

        -- this block has landed
        block.dy = 0
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

    -- set the screen y position for the block
    block_set_y(block, board, math.min(block.cy + 1, block.cy + block.ry))
end

-- set the drawing coord relative to the board
function block_set_y (block, board, y)
    block.y = y - 1 + board.y
end

function block_set_x (block, board, x)
    block.x = x - 1 + board.x
end

