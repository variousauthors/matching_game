
function build_game ()
    game = {}
    game.stable = true
    game.infinity = 100
    game.player = {}
    game.player.has_input = false
    game.player.enabled = true
    game.player.input = {
        up = {},
        down = {},
        left = {},
        right = {}
    }

    game.scale = 32
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
    game.block_max = 3

    -- animation times
    game.animations = {}
    game.animations.exploding = 8
    game.animations.crumbling = 8

    -- visual choices
    game.flicker = false
    game.block_border = 2

    game.colors = {
        { 200, 55, 55 }, -- red
        { 55, 200, 55 }, -- green
        { 55, 55, 200 }, -- blue
        white = { 255, 255, 255 },
        black = { 29, 29, 29 },
        grey = { 155, 155, 155 },
        damage = { 29, 29, 29 }
    }

    game.board_border_alpha = 200 -- for coloured board border
    game.colors.background = game.colors.white
    game.colors.board = game.colors.black

    game.dark_colors = {
        grey = { 77, 77, 77 },
        { 55, 0, 0 }, -- red
        { 0, 55, 0 }, -- green
        { 0, 0, 55 }, -- blue
    }
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

            if color ~= 0 then
                if (color == 8) then
                    color = "grey"
                end

                game.board[y][x] = build_block({ x = x, y = y, color = color })
            end
        end
    end
end

function row_matches(row, blocks)
    print("--> assert", "row " .. row .. " matches " .. inspect(blocks))
    for i = 1, #blocks, 1 do
        local block = blocks[i]

        if block == 0 then
            if (game.board[row][i] ~= false) then
                error("x: " .. i .. ", y: " .. row .. " did not match\n  expected: " .. "false\n" .. "  was: " .. inspect(game.board[row][i].color))
            end
        else
            if (block == 8) then
                block = "grey"
            end

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
    game.player.enabled = true

    if (game.block == nil) then
        error("FAILED: is nil!")
    end
end

function player_block_is_nil()
    print("--> assert", "player block is nil")
    game.player.enabled = false

    if (game.block ~= nil) then
        error("FAILED: exists!\n  " .. inspect(game.block))
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

function run_update (steps)
    for i = 1, steps, 1 do
        love.update(game.step)
    end
end

function a_row_of_four_is_cleared ()
    print("a row of four is cleared")
    -- context, when the player drops a piece
    build_game()

    -- [x][x][ ][x]
    build_rows({
        { 1, 1, 0, 1 }
    })

    game.block = build_block({ x = 3, y = game.height - 1, color = 1 })
    game.step = test.step

    love.update(game.step)

    player_block_exists()

    love.update(game.step)

    player_block_is_nil()

    row_matches(game.height - 0, { 1, 1, 1, 1 })

    run_update(game.animations.exploding + 2)

    row_matches(game.height - 0, { 0, 0, 0, 0 })
end

function a_row_of_four_three_becomes_grey ()
    print("a row of three becomes grey")
    -- context, when the player drops a piece
    build_game()

    -- [x][x][ ][x]
    build_rows({
        { 1, 1, 0, 0 }
    })

    game.block = build_block({ x = 3, y = game.height - 1, color = 1 })
    game.step = test.step

    love.update(game.step)

    player_block_exists()

    love.update(game.step)

    player_block_is_nil()

    row_matches(game.height - 0, { 1, 1, 1, 0 })

    love.update(game.step)

    row_matches(game.height - 0, { 8, 8, 8, 0 })
end

function a_chain_of_two ()
    print("a chain of two is cleared")
    -- context, when the player drops a piece
    build_game()

    -- [x][x][ ][x]
    build_rows({
        { 2, 2, 0, 0 },
        { 1, 1, 0, 0 },
        { 2, 2, 1, 0 },
        { 3, 3, 1, 0 }
    })

    game.block = build_block({ x = 3, y = game.height - 3, color = 1 })
    game.step = test.step

    love.update(game.step)

    player_block_exists()

    love.update(game.step)

    player_block_is_nil()

    row_matches(game.height - 2, { 1, 1, 1, 0 })

    -- TODO WHY PLUS TWO???
    run_update(game.animations.exploding + 2)

    -- the blocks above have not fallen into place
    row_matches(game.height - 2, { 0, 0, 0, 0 })

    run_update(4) -- TODO it takes 4 frames for a block to fall one square

    row_matches(game.height - 2, { 2, 2, 0, 0 })

    run_update(game.animations.exploding + 2)

    -- the blocks above have not fallen into place
    row_matches(game.height - 2, { 0, 0, 0, 0 })
end

function a_chain_of_two_with_grey_three_in_a_row ()
    print("  three in a row")
    -- context, when the player drops a piece
    build_game()

    -- [x][x][ ][x]
    build_rows({
        { 0, 0, 0, 0 },
        { 0, 0, 3, 0 },
        { 1, 0, 1, 0 },
        { 3, 3, 1, 0 }
    })

    game.block = build_block({ x = 2, y = game.height - 2, color = 1 })
    game.step = test.step

    love.update(game.step)

    player_block_exists()

    love.update(game.step)

    player_block_is_nil()

    row_matches(game.height - 1, { 1, 1, 1, 0 })
    row_matches(game.height - 0, { 3, 3, 1, 0 })

    run_update(game.animations.exploding + 2)

    -- the blocks above have not fallen into place
    row_matches(game.height - 2, { 0, 0, 3, 0 })
    row_matches(game.height - 1, { 0, 0, 0, 0 })
    row_matches(game.height - 0, { 3, 3, 0, 0 })

    love.update(game.step)
    love.update(game.step)
    love.update(game.step)
    love.update(game.step)

    love.update(game.step)
    love.update(game.step)
    love.update(game.step)
    love.update(game.step)

    row_matches(game.height - 0, { 8, 8, 8, 0 })
end

function a_chain_of_two_with_grey_three_in_an_L ()
    print("  three in an L")
    -- context, when the player drops a piece
    build_game()

    -- [x][x][ ][x]
    build_rows({
        { 0, 3, 0, 0 },
        { 0, 1, 0, 0 },
        { 0, 1, 0, 0 },
        { 3, 3, 1, 0 }
    })

    game.block = build_block({ x = 3, y = game.height - 2, color = 1 })
    game.step = test.step

    love.update(game.step)

    player_block_exists()

    love.update(game.step)

    player_block_is_nil()

    row_matches(game.height - 2, { 0, 1, 0, 0 })
    row_matches(game.height - 1, { 0, 1, 1, 0 })
    row_matches(game.height - 0, { 3, 3, 1, 0 })

    run_update(game.animations.exploding + 2)

    -- the blocks above have not fallen into place
    row_matches(game.height - 3, { 0, 3, 0, 0 })
    row_matches(game.height - 2, { 0, 0, 0, 0 })
    row_matches(game.height - 1, { 0, 0, 0, 0 })
    row_matches(game.height - 0, { 3, 3, 0, 0 })

    love.update(game.step)
    love.update(game.step)
    love.update(game.step)
    love.update(game.step)

    love.update(game.step)
    love.update(game.step)
    love.update(game.step)
    love.update(game.step)

    row_matches(game.height - 1, { 0, 8, 0, 0 })
    row_matches(game.height - 0, { 8, 8, 0, 0 })
end

function a_chain_of_two_with_grey ()
    print("a chain of two with grey")

    a_chain_of_two_with_grey_three_in_a_row()
    a_chain_of_two_with_grey_three_in_an_L()
end


function a_chain_of_three_with_grey ()
    print("a chain of three with grey")
    -- context, when the player drops a piece
    build_game()

    -- [x][x][ ][x]
    build_rows({
        { 3, 0, 0, 0 },
        { 2, 2, 0, 0 },
        { 1, 1, 0, 0 },
        { 2, 2, 1, 0 },
        { 3, 3, 1, 0 }
    })

    game.block = build_block({ x = 3, y = game.height - 3, color = 1 })
    game.step = test.step

    love.update(game.step)

    player_block_exists()

    love.update(game.step)

    player_block_is_nil()

    row_matches(game.height - 2, { 1, 1, 1, 0 })
    row_matches(game.height - 0, { 3, 3, 1, 0 })

    run_update(game.animations.exploding + 2)

    -- the blocks above have not fallen into place
    row_matches(game.height - 2, { 0, 0, 0, 0 })
    row_matches(game.height - 0, { 3, 3, 0, 0 })

    -- give the blocks time to fall
    love.update(game.step)
    love.update(game.step)
    love.update(game.step)
    love.update(game.step)

    row_matches(game.height - 1, { 2, 2, 0, 0 })
    row_matches(game.height - 2, { 2, 2, 0, 0 })
    row_matches(game.height - 0, { 3, 3, 0, 0 })

    run_update(game.animations.exploding + 2)

    row_matches(game.height - 2, { 0, 0, 0, 0 })
    row_matches(game.height - 0, { 3, 3, 0, 0 })

    -- give the blocks time to fall two rows
    love.update(game.step)
    love.update(game.step)
    love.update(game.step)
    love.update(game.step)

    love.update(game.step)
    love.update(game.step)
    love.update(game.step)
    love.update(game.step)

    row_matches(game.height - 3, { 0, 0, 0, 0 })
    row_matches(game.height - 2, { 0, 0, 0, 0 })
    row_matches(game.height - 1, { 8, 0, 0, 0 })
    row_matches(game.height - 0, { 8, 8, 0, 0 })
end

function a_grey_block_is_destroyed ()
    print("a grey block is destroyed")
    -- context, when the player drops a piece
    build_game()

    -- [x][x][ ][x]
    build_rows({
        { 0, 3, 0, 0 },
        { 0, 3, 0, 0 },
        { 0, 2, 0, 0 },
        { 0, 2, 0, 0 },
        { 2, 1, 0, 0 },
        { 2, 1, 0, 0},
        { 8, 8, 1, 1 }
    })

    game.block = build_block({ x = 3, y = game.height - 2, color = 1 })
    game.step = test.step

    love.update(game.step)

    player_block_exists()

    love.update(game.step)

    player_block_is_nil()

    -- before clearing the red blocks
    row_matches(game.height - 2, { 2, 1, 0, 0 })
    row_matches(game.height - 1, { 2, 1, 1, 0 })
    row_matches(game.height - 0, { 8, 8, 1, 1 })

    run_update(game.animations.exploding + 2)

    -- after clearing the red blocks
    row_matches(game.height - 4, { 0, 2, 0, 0 })
    row_matches(game.height - 3, { 0, 2, 0, 0 })
    row_matches(game.height - 2, { 2, 0, 0, 0 })
    row_matches(game.height - 1, { 2, 0, 0, 0 })
    row_matches(game.height - 0, { 8, 8, 0, 0 })

    block_has_hp(game.height, 1, game.block_max)
    block_has_hp(game.height, 2, game.block_max - 1)

    -- the green blocks need to fall two cells
    run_update(4)

    run_update(4)

    -- TODO this is a real bug
    block_has_hp(game.height, 1, game.block_max - 1)
    block_has_hp(game.height, 2, game.block_max - 2)

    row_matches(game.height - 4, { 0, 3, 0, 0 })
    row_matches(game.height - 3, { 0, 3, 0, 0 })
    row_matches(game.height - 2, { 0, 0, 0, 0 })
    row_matches(game.height - 1, { 0, 0, 0, 0 })
    row_matches(game.height - 0, { 8, 8, 0, 0 })

    -- the blue blocks need to fall two cells
    love.update(game.step)
    love.update(game.step)
    love.update(game.step)
    love.update(game.step)

    love.update(game.step)
    love.update(game.step)
    love.update(game.step)
    love.update(game.step)

    -- they are not in position
    row_matches(game.height - 2, { 0, 3, 0, 0 })
    row_matches(game.height - 1, { 0, 3, 0, 0 })
    row_matches(game.height - 0, { 8, 8, 0, 0 })

    game.block = build_block({ x = 3, y = game.height - 1, color = 3 })
    player_block_exists()

    love.update(game.step)

    player_block_exists()

    love.update(game.step)

    player_block_is_nil()

    row_matches(game.height - 2, { 0, 3, 0, 0 })
    row_matches(game.height - 1, { 0, 3, 0, 0 })
    row_matches(game.height - 0, { 8, 8, 3, 0 })

    game.block = build_block({ x = 3, y = game.height - 2, color = 3 })
    -- we must update once between disabling and enabling the player
    -- so that the update timer gets reset
    love.update(game.step)

    player_block_exists()
    love.update(game.step)

    player_block_exists()

    love.update(game.step)

    player_block_is_nil()

    -- before clearing
    row_matches(game.height - 2, { 0, 3, 0, 0 })
    row_matches(game.height - 1, { 0, 3, 3, 0 })
    row_matches(game.height - 0, { 8, 8, 3, 0 })

    love.update(game.step)

    -- after clearing
    row_matches(game.height - 2, { 0, 0, 0, 0 })
    row_matches(game.height - 1, { 0, 0, 0, 0 })
    row_matches(game.height - 0, { 8, 8, 0, 0 })

    block_has_hp(game.height, 2, 0)

    -- after breaking the block
    love.update(game.step)

    row_matches(game.height - 0, { 8, 0, 0, 0 })
end

function run_tests ()
    -- build a board with some pieces and run update

    test = {}
    test.step = 0.16

    a_row_of_four_is_cleared()
    a_row_of_four_three_becomes_grey()
    a_chain_of_two()
    a_chain_of_two_with_grey()
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

--    run_tests()

    build_game()
end
