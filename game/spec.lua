
-- pass in something like
--
-- build_rows([[1, 2, 0, 2], [1, 1, 1, 1]])
--
-- to create rows: start with the bottom row
-- 1 = red, 2 = green, 3 = blue, 4 = grey, 0 = nothing
function build_rows (rows)
    local cells = game.state.board.cells
    for i = 1, #rows, 1 do
        local y = game.height - #rows + i

        for j = 1, #(rows[i]), 1 do
            local x = j
            local color = rows[i][j]

            if color ~= 0 then
                cells[y][x] = build_block({ x = x, y = y, color = color })
            end
        end
    end
end

function row_matches(row, blocks)
    print("--> assert", "row " .. row .. " matches " .. inspect(blocks))
    local cells = game.state.board.cells
    for i = 1, #blocks, 1 do
        local block = blocks[i]

        if block == 0 then
            if (cells[row][i] ~= EMPTY) then
                error("x: " .. i .. ", y: " .. row .. " did not match\n  expected: " .. "false\n" .. "  was: " .. inspect(block_color(cells[row][i])))
            end
        else
            if (cells[row][i] ~= EMPTY) then
                if (block_color(cells[row][i]) ~= game.colors[block]) then
                    error("x: " .. i .. ", y: " .. row .. " did not match\n  expected: " .. inspect(game.colors[block]) .. "\n" .. "  was: " .. inspect(block_color(cells[row][i])))
                end
            else
                print("row: ", inspect(cells[row]))
                error("expected a block but it was empty:\n  x: " .. i .. ", y: " .. row .. " did not match\n  expected: " .. inspect(game.colors[block]) .. "\n" .. "  was: " .. inspect(cells[row][i]))
            end
        end
    end
end

function player_block_exists ()
    print("--> assert", "player block exists")
    game.state.player.enabled = true

    if (game.state.block == nil) then
        error("FAILED: is nil!")
    end
end

function player_block_is_nil ()
    print("--> assert", "player block is nil")
    game.state.player.enabled = false

    if (game.state.block ~= nil) then
        error("FAILED: exists!\n  " .. inspect(game.state.block))
    end
end

function is_an_integer (x, subject)
    print("--> assert", subject .. " is an integer")

    if (math.abs(x)~= math.floor(math.abs(x))) then
        error("FAILED: " .. subject .. " = " .. x .. " is no integer!\n")
    end
end

function block_is_crumbling (y, x)
    local cells = game.state.board.cells
    print("--> assert", "block " .. tostring(cells[y][x]) .. " is crumbling")

    if (not cells[y][x]) then
        error("  there was no block at y: " .. y .. " x: " .. x)
    end

    if (cells[y][x].crumbling == -1) then
        error("  block was not crumbling!")
    end

end

function block_has_hp (y, x, hp)
    local cells = game.state.board.cells
    print("--> assert", "block " .. tostring(cells[y][x]) .. " has " .. hp .. " hp")
    if (not cells[y][x]) then
        error("  there was no block at y: " .. y .. " x: " .. x)
    end

    if (cells[y][x].hp ~= hp) then
        error("  expected: " .. hp .. "\n  was: " .. cells[y][x].hp)
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

    game.state.block = build_block({ x = 3, y = game.height - 1, color = RED })
    game.step = test.step

    love.update(game.step)

    player_block_exists()

    love.update(game.step)

    player_block_is_nil()

    row_matches(game.height - 0, { 1, 1, 1, 1 })

    run_update(game.animations.exploding + 2)

    row_matches(game.height - 0, { 0, 0, 0, 0 })
end

function a_row_of_three_becomes_grey ()
    print("a row of three becomes grey")
    -- context, when the player drops a piece
    build_game()

    -- [x][x][ ][x]
    build_rows({
        { 1, 1, 0, 0 }
    })

    game.state.block = build_block({ x = 3, y = game.height - 1, color = RED })
    game.step = test.step

    love.update(game.step)

    player_block_exists()

    love.update(game.step)

    player_block_is_nil()

    row_matches(game.height - 0, { 1, 1, 1, 0 })

    run_update(game.animations.hardening + 2)

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

    game.state.block = build_block({ x = 3, y = game.height - 3, color = RED })
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

    game.state.block = build_block({ x = 2, y = game.height - 2, color = RED })
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

    -- drop the block twice
    run_update(4)

    run_update(4)

    -- run the hardening animation
    run_update(game.animations.hardening + 2)

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

    game.state.block = build_block({ x = 3, y = game.height - 2, color = RED })
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

    -- drop the block twice
    run_update(4)

    run_update(4)

    -- run the hardening animation
    run_update(game.animations.hardening + 2)

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

    game.state.block = build_block({ x = 3, y = game.height - 3, color = RED })
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
    run_update(4)

    run_update(4)

    run_update(game.animations.hardening + 2)

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

    game.state.block = build_block({ x = 3, y = game.height - 2, color = RED })
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

    block_has_hp(game.height, 1, game.block_max_hp)
    block_has_hp(game.height, 2, game.block_max_hp - 1)

    -- the green blocks need to fall two cells
    run_update(4)

    run_update(4)

    block_has_hp(game.height, 1, game.block_max_hp - 1)
    block_has_hp(game.height, 2, game.block_max_hp - 2)

    row_matches(game.height - 4, { 0, 3, 0, 0 })
    row_matches(game.height - 3, { 0, 3, 0, 0 })
    row_matches(game.height - 2, { 2, 2, 0, 0 })
    row_matches(game.height - 1, { 2, 2, 0, 0 })
    row_matches(game.height - 0, { 8, 8, 0, 0 })

    -- the blue blocks need to fall two cells
    run_update(game.animations.exploding)

    row_matches(game.height - 4, { 0, 3, 0, 0 })
    row_matches(game.height - 3, { 0, 3, 0, 0 })
    row_matches(game.height - 2, { 0, 0, 0, 0 })
    row_matches(game.height - 1, { 0, 0, 0, 0 })
    row_matches(game.height - 0, { 8, 8, 0, 0 })

    love.update(4)

    love.update(4)

    -- they are not in position
    row_matches(game.height - 2, { 0, 3, 0, 0 })
    row_matches(game.height - 1, { 0, 3, 0, 0 })
    row_matches(game.height - 0, { 8, 8, 0, 0 })

    game.state.block = build_block({ x = 3, y = game.height - 1, color = BLUE })
    love.update(game.step)

    player_block_exists()

    love.update(game.step)

    player_block_exists()

    love.update(game.step)

    player_block_is_nil()

    row_matches(game.height - 2, { 0, 3, 0, 0 })
    row_matches(game.height - 1, { 0, 3, 0, 0 })
    row_matches(game.height - 0, { 8, 8, 3, 0 })

    game.state.block = build_block({ x = 3, y = game.height - 2, color = BLUE })
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

    run_update(1)

    block_has_hp(game.height, 2, 0)

    run_update(1)

    block_is_crumbling(game.height, 2)

    run_update(game.animations.exploding)

    -- after clearing
    row_matches(game.height - 2, { 0, 0, 0, 0 })
    row_matches(game.height - 1, { 0, 0, 0, 0 })
    row_matches(game.height - 0, { 8, 0, 0, 0 })
end

function camera_cy_is_always_an_interger ()
    print("camera.cy is always an integer")
    -- context, when the player drops a piece
    configure_game()
    game.block_max_hp = 1
    game.state = build_game_state()

    -- [x][x][ ][x]
    build_rows({
        { 1, 1, 0, 1 }
    })

    game.state.block = build_block({ x = 3, y = game.height - 3, color = RED })
    game.step = test.step

    run_update(3)

    player_block_exists()

    love.update(game.step)

    player_block_is_nil()

    row_matches(game.height - 0, { 1, 1, 1, 1 })

    run_update(game.animations.exploding + 2)

    row_matches(game.height - 0, { 0, 0, 0, 0 })
    row_matches(game.height + 1, { 0, 0, 0, 0 })

    game.state.block = build_block({ x = 3, y = game.height - 0, color = RED })

    player_block_exists()

    run_update(2)

    player_block_is_nil()

    row_matches(game.height + 1, { 0, 0, 1, 0 })

    -- now let the camera scroll down
    run_update(7)

    is_an_integer(game.camera.cy, "camera.cy")
end

function run_tests ()
    -- build a board with some pieces and run update

    test = {}
    test.step = 0.16

    a_row_of_four_is_cleared()
    a_row_of_three_becomes_grey()
    a_chain_of_two()
    a_chain_of_two_with_grey()
    a_chain_of_three_with_grey()
    a_grey_block_is_destroyed()
    camera_cy_is_always_an_interger()

    player_can_move_a_block()
    an_obstructed_block_cannot_move()
    player_can_drop_a_block()

    print("PASSED")

    -- context, when the piece lands by stepping
    -- context, when the piece lands by gravity
    --
    -- three pieces should become grey
    -- four pieces should vanish (multiple configurations)

end
