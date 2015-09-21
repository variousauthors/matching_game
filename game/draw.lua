-- FOR THE TIME BEING, THIS FILE IS DEFUNCT
-- DEFER TO GAME/DRAW

love.viewport = require('libs/viewport').newSingleton()

function draw_preview_arrow ()
    love.graphics.push("all")
    local offset = 3*game.block_border
    local d = game.next_block.dim * game.scale - 2*offset

    love.graphics.setColor(game.next_block.color)
    tiny_triangle(game.preview * game.scale, game.scale/4, d, "down")

    love.graphics.pop()
end

function love.draw()
    game.draw_seed = math.random(0, 2)

    love.graphics.setBackgroundColor(game.colors.background)

    draw_board(game.board)
    draw_preview_arrow()

    if (game.block ~= nil) then
        draw_block(game.block)
    end
end
