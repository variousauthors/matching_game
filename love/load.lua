
function init_board ()
    local board = {}
    local i, j

    for y = 1, game.height, 1 do
        board[y] = {}

        for x = 1, game.width, 1 do
            board[y][x] = false

        end
    end

    return board
end

function love.load()
    love.debug.setFlag("input")

    require('game/controls')
    require('game/sounds')
    require('game/update')
    require('game/draw')

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
    game.board = init_board()
    game.update_timer = 0
    game.match_target = 3
    game.input_timer = 4
    game.rate = 2
    game.step = 0.1 * game.rate
    game.input_rate = 8

end
