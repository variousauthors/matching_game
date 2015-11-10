
function draw_block_heart (block)
    love.graphics.push("all")

    local offset = game.block_gap_width*game.block_border

    if (game.all_block_get_damage or block.grey == true) then

        if (block.hp == game.block_max_hp) then
            -- full square
            love.graphics.rectangle('fill', block.x * game.scale + offset, block.y * game.scale + offset, block.dim * game.scale - 2 * offset, block.dim * game.scale - 2 * offset)
        elseif (block.hp == game.block_max_hp - 1) then
            -- two triangles
            local e = game.block_gap_width/2 -- since we are dividing it between two triangles
            local d = block.dim * game.scale - 2*offset - e
            local x = block.x * game.scale + offset
            local y = block.y * game.scale + offset

            tiny_triangle(x + e, y, d, "top-right")
            tiny_triangle(x, y + e, d, "bottom-left")

        elseif (block.hp == game.block_max_hp - 2) then
            -- four triangles

            local e = game.block_gap_width/2 -- since we are dividing it between two triangles
            local d = block.dim * game.scale - 2*offset - 2*e
            local x = block.x * game.scale + offset
            local y = block.y * game.scale + offset

            tiny_triangle(x + e, y + 2*e, d, "bottom")
            tiny_triangle(x + 2*e, y + e, d, "right")
            tiny_triangle(x, y + e, d, "left")
            tiny_triangle(x + e, y, d, "top")

        end
    else
        local offset = game.block_gap_width*game.block_border
        love.graphics.rectangle('fill', block.x * game.scale + offset, block.y * game.scale + offset, block.dim * game.scale - 2 * offset, block.dim * game.scale - 2 * offset)
    end

    love.graphics.pop()
end

function draw_block_border (block)
    local b = game.block_border -- border size
    local e = 0 -- explosion size
    local border_color = block_color(block)

    love.graphics.push("all")

    if (game.flicker and game.draw_seed == 0 and block.grey == false) then
        love.graphics.setColor({ border_color[1] * 2/3, border_color[2] * 2/3, border_color[3] * 2/3 })
    else
        love.graphics.setColor(border_color)
    end

    if block.exploding > -1 then
        e = game.animations.exploding - block.exploding
    elseif block.hardening > -1 then
        e = - (game.animations.hardening - block.hardening)
    end

    if (block.grey == false) then
        love.graphics.setLineWidth(b)
        love.graphics.rectangle('line', block.x * game.scale + b - e/2, block.y * game.scale + b - e/2, block.dim * game.scale - 2*b + e, block.dim * game.scale - 2*b + e)
        love.graphics.setLineWidth(1)
    end

    love.graphics.pop()
end

function tiny_triangle (x, y, dim, dir)
    if dir == "top" then
        love.graphics.polygon('fill', x, y, x + dim, y, x + dim/2, y + dim/2)
    elseif dir == "left" then
        love.graphics.polygon('fill', x, y, x, y + dim, x + dim/2, y + dim/2)
    elseif dir == "right" then
        love.graphics.polygon('fill', x + dim, y, x + dim, y + dim, x + dim/2, y + dim/2)
    elseif dir == "bottom" then
        love.graphics.polygon('fill', x, y + dim, x + dim, y + dim, x + dim/2, y + dim/2)
    elseif dir == "bottom-right" then
        love.graphics.polygon('fill', x, y + dim, x + dim, y + dim, x + dim/2, y + dim/2)
        love.graphics.polygon('fill', x + dim, y, x + dim, y + dim, x + dim/2, y + dim/2)
    elseif dir == "bottom-left" then
        love.graphics.polygon('fill', x, y + dim, x + dim, y + dim, x + dim/2, y + dim/2)
        love.graphics.polygon('fill', x, y, x, y + dim, x + dim/2, y + dim/2)
    elseif dir == "top-right" then
        love.graphics.polygon('fill', x, y, x + dim, y, x + dim/2, y + dim/2)
        love.graphics.polygon('fill', x + dim, y, x + dim, y + dim, x + dim/2, y + dim/2)
    elseif dir == "top-left" then
        love.graphics.polygon('fill', x, y, x + dim, y, x + dim/2, y + dim/2)
        love.graphics.polygon('fill', x, y, x, y + dim, x + dim/2, y + dim/2)
    end
end

function draw_block (block)
    love.graphics.push("all")

    local offset = game.block_gap_width*game.block_border

    if (block.mote) then
        draw_mote(block.mote)
    end

    love.graphics.setColor(game.colors[GREY])

    if (block.crumbling < 0) then
        --love.graphics.rectangle('fill', block.x * game.scale + offset, block.y * game.scale + offset, block.dim * game.scale - 2 * offset, block.dim * game.scale - 2 * offset)

        draw_block_heart(block)
        draw_block_border(block)
    else

        -- four triangles expanding away
        local e = game.block_gap_width + game.animations.crumbling - block.crumbling
        local d = block.dim * game.scale - 2*offset
        local x = block.x * game.scale + offset
        local y = block.y * game.scale + offset

        tiny_triangle(x, y + e, d, "bottom")
        tiny_triangle(x + e, y, d, "right")
        tiny_triangle(x - e, y, d, "left")
        tiny_triangle(x, y - e, d, "top")
    end

    love.graphics.pop()
end

function build_block (options)
    local options = options or {}
    local board = options.board or game.state.board
    local x = options.x or math.ceil(game.width/2)
    local y = options.y or 1
    local primary = math.random(1, 3)
    local color = options.color or primary
    local grey = (color == GREY)

    return {
        -- position in the grid
        cx = x,
        cy = y,
        -- real position relative to the grid (0..1)
        rx = 0,
        ry = 0,

        dx = 0,
        dy = 0,

--      -- final position in each timestep from graphics
        x = x - 1 + board.x,
        y = y - 1 + board.y,

        dim = game.block_dim,
        color = color,
        grey = grey,
        primary = primary,
        marked = false,
        hp = game.block_max_hp,

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
    local cells = board.cells
    local shadows = game.state.shadows.cells

    -- do not apply forces to grey blocks
    if (block.grey == true or block.animating) then
        -- remove it if it is broken
        if block.hp == 0 then
            block.hp = -1
            start_tween(cells[cy][cx], "crumbling")
        end

        -- ANIMATIONS
        -- adjust the explosion
        if block.exploding > 0 then
            block.exploding = block.exploding - 1
        elseif block.exploding == 0 then
            block.exploding = -1
            cells[cy][cx] = EMPTY

            -- TODO shadows need to be an entity so that we can draw them
            -- using x and y, rather than cx and cy
            shadows[cy][cx] = shadows[cy][cx] + 0.33
        end

        -- adjust the crumbling
        if block.crumbling > 0 then
            block.crumbling = block.crumbling - 1
        elseif block.crumbling == 0 then
            block.crumbling = -1
            -- when we run the tests, we create grey blocks
            -- directly, and then don't have motes so...
            if (block.mote) then
                block.mote.released = true
            end
            cells[cy][cx] = EMPTY
        end

        -- adjust the hardening
        if block.hardening > 0 then
            block.hardening = block.hardening - 1
        elseif block.hardening == 0 then
            block.hardening = -1
            block.mote = build_mote(block)
            table.insert(game.state.motes, block.mote)
            cells[cy][cx].color = GREY
            cells[cy][cx].grey = true
            shadows[cy][cx] = 0.0
        end

        -- TODO move this into the animation controller
        if block.crumbling == -1 and block.exploding == -1 and block.hardening == -1 then
            block.animating = false
        end

        block_set_y(block, board, block.cy)

        return
    end

    -- the block is at rest, at the bottom of the board
    if (not cells[cy + 1]) then
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
    collision = block_collide(block, cells[cy + 1][cx])

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

        cells[cy][cx] = EMPTY
        cells[cy + 1][cx] = block
    end

    -- set the screen y position for the block
    block_set_y(block, board, math.min(block.cy + 1, block.cy + block.ry))
end

-- set the drawing coord relative to the board
-- these set the logical x and y and needn't be
-- adjusted as the board moves
function block_set_y (block, board, y)
    block.y = y - 1 + board.y
end

function block_set_x (block, board, x)
    block.x = x - 1 + board.x
end

function block_color(block)
    return game.colors[block.color]
end

