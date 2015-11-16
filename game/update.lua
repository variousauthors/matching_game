function love.update (dt)
    update_game(dt)
end

function update_game (dt)
    local cells = game.state.board.cells
    local player = game.state.player
    local board = game.state.board

    local direction = 0

    game.dt = dt

    game.block_count = 0
    game.state.stable = true -- optimism
    update_board(board)
    update_camera(game.camera)

    -- the game only ends when everything has settled down
    if (game.state.stable == true) then
        if (game.state.ending == true) then
            game.state.over = true
            return
        else
            -- board height - game height - 2 means the game ends
            -- whenever anything is blocking the spawn
            if cells[#(cells) - game.height - 2][math.ceil(game.width/2)] ~= EMPTY then
                -- every block should be made to harden before the end

                -- mark all cells for hardening
                for y = #(cells), 1, -1 do
                    for x = 1, board.width, 1 do
                        if (cells[y][x] ~= EMPTY) then
                            local block = cells[y][x]
                            start_tween(cells[block.cy][block.cx], "hardening")
                            play_harden = true
                        end
                    end
                end

                -- this adds that extra element of hopelessness
                game.state.next_block = nil
                game.state.ending = true
                game.state.stable = false
            end
        end
    end

    if (player.enabled and game.state.stable) then
        game.update_timer = game.update_timer + dt
        game.input_timer = game.input_timer + dt

        -- there should be a block
        if (game.state.block == nil and not player.disabled) then
            game.state.block = next_block()
        end

        -- process one set of inputs then cooldown
        if (game.input_timer < game.step/game.input_rate) then
            player.has_input = false
            player.input.left = {}
            player.input.right = {}

        elseif (player.has_input) then
            player.has_input = false
            game.input_timer = 0

            -- consume an input from the buffer
            if #(player.input.left) > 0 then player.left = table.remove(player.input.left, 1) end
            if #(player.input.right) > 0 then player.right = table.remove(player.input.right, 1) end

            if (player.left) then direction = -1 end
            if (player.right) then direction = 1 end

            move_block(game.state.block, board, direction)

            player.left = false
            player.right = false
            player.input.left = {}
            player.input.right = {}
        else
            if #(player.input.up) > 0 then player.up = table.remove(player.input.up, 1) end
            if #(player.input.down) > 0 then player.down = table.remove(player.input.down, 1) end

            if (player.up or player.down) then
                drop_block(game.state.block, board)
                game.update_timer = 0
            end

            player.up = false
            player.down = false

            player.input.up = {}
            player.input.down = {}
        end

        -- move the piece down every step
        if (game.update_timer >= game.step) then
            game.update_timer = 0
            step_block(game.state.block, board)
        end
    else
        game.update_timer = 0
        game.input_timer = 0
    end

end
