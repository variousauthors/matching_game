-- FOR THE TIME BEING, THIS FILE IS DEFUNCT
-- DEFER TO GAME/DRAW

love.viewport = require('libs/viewport').newSingleton()

function love.draw()

    if (game.block ~= nil) then
        draw_block(game.block)
    end

    draw_board(game.board)
end
