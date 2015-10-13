-- FOR THE TIME BEING, THIS FILE IS DEFUNCT
-- DEFER TO GAME/DRAW

love.viewport = require('libs/viewport').newSingleton()

function draw_background ()
    love.graphics.push("all")

    love.graphics.setColor(game.colors.background)
    love.graphics.rectangle("fill", 0, 0, love.viewport.getWidth(), love.viewport.getHeight())

    love.graphics.pop()
end

function love.draw()
    game.draw_seed = math.random(0, 2)

    draw_background()

    love.graphics.translate(-game.camera.x * game.scale, -game.camera.y * game.scale)
    draw_board(game.board)

    if (game.block ~= nil) then
        draw_block(game.block)
    end
end
