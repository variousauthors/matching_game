-- FOR THE TIME BEING, THIS FILE IS DEFUNCT
-- DEFER TO GAME/DRAW
-- HA HA I AM CODING HERE

love.viewport = require('libs/viewport').newSingleton()

function love.draw ()
    draw_game()
end

function draw_background ()
    love.graphics.push("all")

    love.graphics.setColor(game.colors.background)
    love.graphics.rectangle("fill", 0, 0, love.viewport.getWidth(), love.viewport.getHeight())

    love.graphics.pop()
end

function draw_game ()
    love.graphics.push("all")
    game.draw_seed = math.random(0, 2)

    draw_background()

    love.graphics.translate(-game.camera.x * game.scale, -game.camera.y * game.scale)
    draw_board(game.board)

    if (game.block ~= nil) then
        draw_block(game.block)
    end

    love.graphics.pop()
end

