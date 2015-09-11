
function build_game ()
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
        grey = { 55, 55, 55 },
        damage = { 29, 29, 29 }
    }

    game.scale = 30
    game.height = 10
    game.width = 5
    game.board = build_board()
    game.gravity = 1
    game.dt = 0
    game.update_timer = 0
    game.match_target = 3
    game.input_timer = 0
    game.rate = 2
    game.step = 0.1 * game.rate
    game.input_rate = 8
end

-- pass in something like
--
-- build_rows([[1, 2, 0, 2], [1, 1, 1, 1]])
--
-- to create rows: start with the bottom row
-- 1 = red, 2 = green, 3 = blue, 4 = grey, 0 = nothing
function build_rows(rows)
    for i = 1, #rows, 1 do
        local y = game.height - (i - 1)

        for j = 1, #(rows[i]), 1 do
            local x = j
            local color = rows[i][j]

            if color then
                game.board[y][x] = build_block({ x = x, y = y, color = color })
            end
        end
    end
end

function row_matches(row, blocks)
    print("--> assert", "row " .. row .. " matches " .. inspect(blocks))
    for i = 1, #blocks, 1 do
        local block = blocks[i]

        if block == false then
            if (game.board[row][i] ~= false) then
                error("x: " .. row .. ", y: " .. i .. " did not match\n  expected: " .. "false\n" .. "  was: " .. game.board[row][i])
            end
        else
            if (game.board[row][i].color ~= game.colors[block]) then
                error("x: " .. row .. ", y: " .. i .. " did not match\n  expected: " .. inspect(game.colors[block]) .. "\n" .. "  was: " .. inspect(game.board[row][i].color))
            end
        end
    end
end

function player_block_exists()
    print("--> assert", "player block exists")

    if (game.block == nil) then
        error("FAILED: is nil!")
    end
end

function player_block_is_nil()
    print("--> assert", "player block is nil")

    if (game.block ~= nil) then
        error("FAILED: exists!")
    end
end

function a_row_of_four_is_cleared ()
    -- context, when the player drops a piece
    build_game()

    -- [x][x][ ][x]
    build_rows({
        { 1, 1, false, 1 }
    })

    game.block = build_block({ x = 3, y = game.height - 1, color = 1 })
    game.step = 0.16

    print("ONE") -- the block steps into place
    love.update(0.16)

    player_block_exists()

    print("TWO") -- the block comes to rest
    love.update(0.16)

    player_block_is_nil()

    row_matches(game.height, { 1, 1, 1, 1 })

    print("THREE") -- the game checks for matches
    love.update(0.16)

    row_matches(game.height, { false, false, false, false })
end

function a_row_of_four_three_becomes_grey ()
    -- context, when the player drops a piece
    build_game()

    -- [x][x][ ][x]
    build_rows({
        { 1, 1, false, false }
    })

    game.block = build_block({ x = 3, y = game.height - 1, color = 1 })
    game.step = 0.16

    print("ONE") -- the block steps into place
    love.update(0.16)

    player_block_exists()

    print("TWO") -- the block comes to rest
    love.update(0.16)

    player_block_is_nil()

    row_matches(game.height, { 1, 1, 1, false })

    print("THREE") -- the game checks for matches
    love.update(0.16)

    row_matches(game.height, { "grey", "grey", "grey", false })
end
function run_tests ()
    -- build a board with some pieces and run update

    a_row_of_four_is_cleared()
    a_row_of_four_three_becomes_grey()

    print("PASSED")

    -- context, when the piece lands by stepping
    -- context, when the piece lands by gravity
    --
    -- three pieces should become grey
    -- four pieces should vanish (multiple configurations)

end

function love.load()

    require('game/controls')
    require('game/sounds')

    require('game/update')
    require('game/draw')

    require('game/block')
    require('game/board')
    require('game/player')

    run_tests()

    build_game()
end
