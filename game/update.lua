function love.update (dt)
    for i = 1, game.width, 1 do
        -- board height - game height - 2 means the game ends
        -- whenever anything is blocking the spawn
        if game.board[#(game.board) - game.height - 2][math.ceil(game.width/2)] then
            build_game()
        end
    end

    local player = game.player
    local direction = 0

    game.dt = dt

    game.block_count = 0
    game.stable = true -- optimism
    update_board(game.board)
    update_camera(game.camera)

    if (player.enabled and game.stable) then
        game.update_timer = game.update_timer + dt
        game.input_timer = game.input_timer + dt

        -- there should be a block
        if (game.block == nil and not game.player.disabled) then
            game.block = next_block()
        end

        -- process one set of inputs then cooldown
        if (game.input_timer < game.step/game.input_rate) then
            game.player.has_input = false
            player.input.left = {}
            player.input.right = {}

        elseif (game.player.has_input) then
            game.player.has_input = false
            game.input_timer = 0

            -- consume an input from the buffer
            if #(player.input.left) > 0 then player.left = table.remove(player.input.left, 1) end
            if #(player.input.right) > 0 then player.right = table.remove(player.input.right, 1) end

            if (player.left) then direction = -1 end
            if (player.right) then direction = 1 end

            move_block(game.block, game.board, direction)

            player.left = false
            player.right = false
            player.input.left = {}
            player.input.right = {}
        else
            if #(player.input.up) > 0 then player.up = table.remove(player.input.up, 1) end

            if (player.up) then
                drop_block(game.block, game.board)
                game.update_timer = 0
            end

            player.up = false

            player.input.up = {}
        end

        -- move the piece down every step
        if (game.update_timer >= game.step) then
            game.update_timer = 0
            step_block(game.block, game.board)
        end
    else
        game.update_timer = 0
        game.input_timer = 0
    end

end
