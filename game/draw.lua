-- FOR THE TIME BEING, THIS FILE IS DEFUNCT
-- DEFER TO GAME/DRAW
-- HA HA I AM CODING HERE

love.viewport = require('libs/viewport').newSingleton()

function love.draw ()
    draw_game()
end

function draw_background ()
    love.graphics.push("all")

    -- fade to black, but bottom out at board color
    local r, g, b = unpack(game.colors.background)
    local a = math.max(game.colors.black[4], 255 - game.depth)

    love.graphics.setColor({ r, g, b, a })
    love.graphics.rectangle("fill", 0, 0, love.viewport.getWidth(), love.viewport.getHeight())

    love.graphics.pop()
end

function draw_curtain ()
    love.graphics.push("all")

    -- fade to black, but bottom out at board color
    local r, g, b = unpack(game.curtain.color)
    local a = game.curtain.alpha

    love.graphics.setColor({ r, g, b, a })
    love.graphics.rectangle("fill", 0, 0, love.viewport.getWidth(), love.viewport.getHeight())

    love.graphics.pop()
end

function draw_game ()
    love.graphics.push("all")
    game.draw_seed = math.random(0, 2)

    draw_background()

    love.graphics.translate(-game.camera.x * game.scale, -game.camera.y * game.scale)
    draw_board(game.state.board)

    if (game.state.block ~= nil) then
        draw_block(game.state.block)
    end

    love.graphics.pop()
end

