
function build_game ()
    game = {}
    game.player = {}
    game.player.has_input = false
    game.player.enabled = true
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
        local y = game.height - #rows + i

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
                error("x: " .. i .. ", y: " .. row .. " did not match\n  expected: " .. "false\n" .. "  was: " .. inspect(game.board[row][i].color))
            end
        else
            if (game.board[row][i]) then
                if (game.board[row][i].color ~= game.colors[block]) then
                    error("x: " .. i .. ", y: " .. row .. " did not match\n  expected: " .. inspect(game.colors[block]) .. "\n" .. "  was: " .. inspect(game.board[row][i].color))
                end
            else
                print("row: ", inspect(game.board[row]))
                error("expected a block but it was empty:\n  x: " .. i .. ", y: " .. row .. " did not match\n  expected: " .. inspect(game.colors[block]) .. "\n" .. "  was: " .. inspect(game.board[row][i]))
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

function block_has_hp(y, x, hp)
    print("--> assert", "block has " .. hp .. " hp")
    if (not game.board[y][x]) then
        error("  there was no block at y: " .. y .. " x: " .. x)
    end

    if (game.board[y][x].hp ~= hp) then
        error("  expected: " .. hp .. "\n  was: " .. game.board[y][x].hp)
    end
end

function a_row_of_four_is_cleared ()
    print("a row of four is cleared")
    -- context, when the player drops a piece
    build_game()

    -- [x][x][ ][x]
    build_rows({
        { 1, 1, false, 1 }
    })

    game.block = build_block({ x = 3, y = game.height - 1, color = 1 })
    game.step = 0.16

    love.update(0.16)

    player_block_exists()

    love.update(0.16)

    player_block_is_nil()

    row_matches(game.height, { 1, 1, 1, 1 })

    love.update(0.16)

    row_matches(game.height, { false, false, false, false })
end

function a_row_of_four_three_becomes_grey ()
    print("a row of three becomes grey")
    -- context, when the player drops a piece
    build_game()

    -- [x][x][ ][x]
    build_rows({
        { 1, 1, false, false }
    })

    game.block = build_block({ x = 3, y = game.height - 1, color = 1 })
    game.step = 0.16

    love.update(0.16)

    player_block_exists()

    love.update(0.16)

    player_block_is_nil()

    row_matches(game.height, { 1, 1, 1, false })

    love.update(0.16)

    row_matches(game.height, { "grey", "grey", "grey", false })
end

function a_chain_of_two ()
    print("a chain of two is cleared")
    -- context, when the player drops a piece
    build_game()

    -- [x][x][ ][x]
    build_rows({
        { 2, 2, false, false },
        { 1, 1, false, false },
        { 2, 2, 1, false },
        { 3, 3, 1, false }
    })

    game.block = build_block({ x = 3, y = game.height - 3, color = 1 })
    game.step = 0.16

    love.update(0.16)

    player_block_exists()

    love.update(0.16)

    player_block_is_nil()

    row_matches(game.height - 2, { 1, 1, 1, false })

    love.update(0.16)

    -- the blocks above have not fallen into place
    row_matches(game.height - 2, { false, false, false, false })

    love.update(0.16)
    love.update(0.16)
    love.update(0.16)
    love.update(0.16)

    row_matches(game.height - 2, { 2, 2, false, false })

    love.update(0.16) -- the game makes the second match

    -- the blocks above have not fallen into place
    row_matches(game.height - 2, { false, false, false, false })
end

function a_chain_of_three_with_grey ()
    print("a chain of three with grey")
    -- context, when the player drops a piece
    build_game()

    -- [x][x][ ][x]
    build_rows({
        { 3, false, false, false },
        { 2, 2, false, false },
        { 1, 1, false, false },
        { 2, 2, 1, false },
        { 3, 3, 1, false }
    })

    game.block = build_block({ x = 3, y = game.height - 3, color = 1 })
    game.step = 0.16

    love.update(0.16)

    player_block_exists()

    love.update(0.16)

    player_block_is_nil()
    game.player.enabled = false

    row_matches(game.height, { 3, 3, 1, false })
    row_matches(game.height - 2, { 1, 1, 1, false })

    love.update(0.16)

    -- the blocks above have not fallen into place
    row_matches(game.height, { 3, 3, false, false })
    row_matches(game.height - 2, { false, false, false, false })

    -- give the blocks time to fall
    love.update(0.16)
    love.update(0.16)
    love.update(0.16)
    love.update(0.16)

    row_matches(game.height, { 3, 3, false, false })
    row_matches(game.height - 2, { 2, 2, false, false })

    love.update(0.16) -- the game makes the second match

    row_matches(game.height, { 3, 3, false, false })
    row_matches(game.height - 2, { false, false, false, false })

    -- give the blocks time to fall two rows
    love.update(0.16)
    love.update(0.16)
    love.update(0.16)
    love.update(0.16)

    love.update(0.16)
    love.update(0.16)
    love.update(0.16)
    love.update(0.16)

    row_matches(game.height - 3, { false, false, false, false })
    row_matches(game.height - 2, { false, false, false, false })
    row_matches(game.height - 1, { "grey", false, false, false })
    row_matches(game.height, { "grey", "grey", false, false })
end

function a_grey_block_is_destroyed ()
    print("a chain of three with grey")
    -- context, when the player drops a piece
    build_game()

    -- [x][x][ ][x]
    build_rows({
        { false, 3, false, false },
        { false, 3, false, false },
        { false, 2, false, false },
        { false, 2, false, false },
        { 2, 1, false, false },
        { 2, 1, false, false},
        { "grey", "grey", 1, 1 }
    })

    game.block = build_block({ x = 3, y = game.height - 2, color = 1 })
    game.step = 0.16

    love.update(0.16)

    player_block_exists()

    love.update(0.16)

    player_block_is_nil()
    game.player.enabled = false

    -- before clearing the red blocks
    row_matches(game.height - 1, { 2, 1, 1, false })
    row_matches(game.height, { "grey", "grey", 1, 1 })

    love.update(0.16)

    -- after clearing the red blocks
    row_matches(game.height - 4, { false, 2, false, false })
    row_matches(game.height - 3, { false, 2, false, false })
    row_matches(game.height - 2, { 2, false, false, false })
    row_matches(game.height - 1, { 2, false, false, false })
    row_matches(game.height, { "grey", "grey", false, false })

    block_has_hp(game.height, 1, 3)
    block_has_hp(game.height, 2, 2)

    -- the green blocks need to fall two cells
    love.update(0.16)
    love.update(0.16)
    love.update(0.16)
    love.update(0.16)

    love.update(0.16)
    love.update(0.16)
    love.update(0.16)
    love.update(0.16)

    row_matches(game.height - 4, { false, 3, false, false })
    row_matches(game.height - 3, { false, 3, false, false })
    row_matches(game.height - 2, { false, false, false, false })
    row_matches(game.height - 1, { false, false, false, false })
    row_matches(game.height, { "grey", "grey", false, false })

    block_has_hp(game.height, 1, 2)
    block_has_hp(game.height, 2, 1)

    -- the blue blocks need to fall two cells
    love.update(0.16)
    love.update(0.16)
    love.update(0.16)
    love.update(0.16)

    love.update(0.16)
    love.update(0.16)
    love.update(0.16)
    love.update(0.16)

    -- they are not in position
    row_matches(game.height - 2, { false, 3, false, false })
    row_matches(game.height - 1, { false, 3, false, false })
    row_matches(game.height, { "grey", "grey", false, false })

    game.block = build_block({ x = 3, y = game.height - 1, color = 3 })
    game.player.enabled = true

    love.update(0.16)

    player_block_exists()

    love.update(0.16)

    player_block_is_nil()
    game.player.enabled = false

    row_matches(game.height - 2, { false, 3, false, false })
    row_matches(game.height - 1, { false, 3, false, false })
    row_matches(game.height, { "grey", "grey", 3, false })

    game.block = build_block({ x = 3, y = game.height - 2, color = 3 })
    game.player.enabled = true

    love.update(0.16)

    player_block_exists()

    love.update(0.16)

    player_block_is_nil()
    game.player.enabled = false

    -- before clearing
    row_matches(game.height - 2, { false, 3, false, false })
    row_matches(game.height - 1, { false, 3, 3, false })
    row_matches(game.height, { "grey", "grey", 3, false })

    love.update(0.16)

    -- after clearing
    row_matches(game.height - 2, { false, false, false, false })
    row_matches(game.height - 1, { false, false, false, false })
    row_matches(game.height, { "grey", "grey", false, false })

    block_has_hp(game.height, 2, 0)

    -- after breaking the block
    love.update(0.16)

    row_matches(game.height, { "grey", false, false, false })
end

function run_tests ()
    -- build a board with some pieces and run update

    a_row_of_four_is_cleared()
    a_row_of_four_three_becomes_grey()
    a_chain_of_two()
    a_chain_of_three_with_grey()
    a_grey_block_is_destroyed()

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
