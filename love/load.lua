
function love.load()

    require('game/controls')
    require('game/sounds')

    require('game/update')
    require('game/draw')

    require('game/block')
    require('game/board')

    game = {}
    game.player = {}
    game.player.has_input = false
    game.player.input = {
        up = {},
        down = {},
        left = {},
        right = {}
    }
    game.colors = {
        { 200, 55, 55 }, -- red
        { 55, 200, 55 }, -- green
        { 55, 55, 200 }, -- blue
        white = { 200, 200, 200 },
        grey = { 55, 55, 55 }
    }

    game.scale = 30
    game.height = 10
    game.width = 5
    game.board = build_board()
    game.gravity = 1
    game.dt = 0
    game.update_timer = 0
    game.match_target = 3
    game.input_timer = 4
    game.rate = 2
    game.step = 0.1 * game.rate
    game.input_rate = 8

end
