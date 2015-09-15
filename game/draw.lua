-- FOR THE TIME BEING, THIS FILE IS DEFUNCT
-- DEFER TO GAME/DRAW

love.viewport = require('libs/viewport').newSingleton()

function love.draw()
    game.draw_seed = math.random(0, 2)

    love.graphics.setBackgroundColor(game.colors.background)

    draw_board(game.board)

    if (game.block ~= nil) then
        draw_block(game.block)
    end
end
