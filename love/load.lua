local writeProfile = function (profile)
    local hfile = love.filesystem.newFile("profile.lua", "w")
    if hfile == nil then return end

    hfile:write(profile)

    hfile:close()
end

local findProfile = function ()
    return love.filesystem.isFile("profile.lua")
end

local recoverProfile = function ()
    local contents, size = love.filesystem.read("profile.lua")

    return contents
end

function build_statemachine()
    Menu = require('game/menu')
    menu          = Menu()
    state_machine = FSM()

    build_game()
    local save

    if (findProfile() == true) then
        save = recoverProfile()
        game.state = JSON.decode(save)
    end

    -- fade in from white
    state_machine.addState({
        name = "start",
        init       = function ()
            -- we have to load the save here to show the board on start
            save = JSON.encode(game.state)

            game.state.player.enabled = false

        end,
        draw = function ()
            draw_game()

            -- draw a curtain of white over the world
            draw_curtain()
        end,
        update = function (dt)
            if game.curtain.alpha > 0 then
                game.curtain.alpha = math.max(0, game.curtain.alpha - game.curtain.fade_rate * dt)
            end
        end
    })

    -- the menu/title screen state
    state_machine.addState({
        name       = "title",
        init       = function ()
            -- we have to load the save again here whenever we've transitioned back
            -- to the title. TODO this is happening because we have an "init"
            -- function for each state, but no exit function. These should just
            -- be called "enter" and "exit", non?
            save = JSON.encode(game.state)

            game.state.player.enabled = false
        end,
        draw = function ()
            draw_game()
        end,
        keypressed = function (key)
            if (key == "escape") then
                -- TODO transition to an "saving" state
                -- draw a black screen
                love.graphics.setColor(game.colors.black)
                love.graphics.rectangle("fill", 0, 0, love.viewport.getWidth(), love.viewport.getHeight())
                love.graphics.present()

                writeProfile(save)
                -- could pause for long enough to flash "saving" for 3 seconds
                love.event.quit()
            elseif(key == 'f11') then
                love.viewport.setFullscreen()
                love.viewport.setupScreen()
            end

            if key == "return" or key == " " then
                state_machine.set("setup")
            end
        end
    })

    state_machine.addState({
        name       = "setup",
        init       = function ()

            if (game.state.over == true) then
                build_game()
            end

            -- setup the camera
            if (game.camera.y < game.state.shift) then
                move_camera(game.camera, 0, game.state.shift)
            end
        end,
        draw       = function ()
            draw_game()
        end,
        update     = function (dt)
            update_camera(game.camera)
            game.depth = game.depth_rate*game.camera.y
        end
    })

    state_machine.addState({
        name       = "unwind",
        init       = function ()
            -- rewind the camera
            if (game.camera.y > 0) then
                move_camera(game.camera, 0, 0)
            end
        end,
        draw       = function ()
            draw_game()
        end,
        update     = function (dt)
            update_camera(game.camera)
            game.depth = game.depth_rate*game.camera.y
        end
    })

    state_machine.addState({
        name       = "play",
        init       = function ()
            game.state.player.enabled = true
        end,
        draw       = function ()
            draw_game()
        end,
        update     = function (dt)
            update_game(dt)
        end,
        keypressed = love.keypressed,
        inputpressed = function (state)
            if game.state.player.input[state] ~= nil then
                game.state.player.has_input = true
                table.insert(game.state.player.input[state], true)
            end
        end
    })

    state_machine.addState({
        name       = "ending",
        init       = function ()
            game.state.player.enabled = true
            game.curtain.color = { 0, 0, 0 }
            game.curtain.fade_rate = game.curtain.fade_rate / 20
        end,
        draw       = function ()
            draw_game()
            draw_curtain()
        end,
        update     = function (dt)
            update_game(dt)

            if game.curtain.alpha < 255 then
                game.curtain.alpha = math.min(255, game.curtain.alpha + game.curtain.fade_rate * dt)
            end
        end,
        inputpressed = function (state)
            if game.state.player.input[state] ~= nil then
                game.state.player.has_input = true
                table.insert(game.state.player.input[state], true)
            end
        end
    })

    state_machine.addState({
        name       = "lose",
        init = function ()
        end,
        draw = function ()
            draw_game()
        end
    })

    state_machine.addState({
        name = "end",
        init = function ()
            build_game()
            save = JSON.encode(game.state)
        end,
        draw = function ()
            game.curtain.color = { 0, 0, 0 }
            game.curtain.alpha = 255
            draw_curtain()
        end,
        keypressed = function (key)
            if (key == "escape") then
                -- TODO transition to an "saving" state
                -- draw a black screen
                love.graphics.setColor(game.colors.black)
                love.graphics.rectangle("fill", 0, 0, love.viewport.getWidth(), love.viewport.getHeight())
                love.graphics.present()

                writeProfile(save)
                -- could pause for long enough to flash "saving" for 3 seconds
                love.event.quit()
            elseif(key == 'f11') then
                love.viewport.setFullscreen()
                love.viewport.setupScreen()
            end
        end
    })

    -- start the game when the player chooses a menu option
    state_machine.addTransition({
        from      = "start",
        to        = "title",
        condition = function ()
            return game.curtain.alpha == 0
        end
    })

    -- start the game when the player chooses a menu option
    state_machine.addTransition({
        from      = "title",
        to        = "setup",
        condition = function ()
            return state_machine.isSet("setup")
        end
    })

    state_machine.addTransition({
        from      = "setup",
        to        = "play",
        condition = function ()
            return game.camera.y == game.state.shift
        end
    })

    state_machine.addTransition({
        from      = "play",
        to        = "lose",
        condition = function ()
            return game.state.over == true
        end
    })

    state_machine.addTransition({
        from      = "lose",
        to        = "unwind",
        condition = function ()
            return true
        end
    })

    -- return to the menu screen if any player presses escape
    state_machine.addTransition({
        from      = "play",
        to        = "unwind",
        condition = function ()
            return state_machine.isSet("escape")
        end
    })

    -- return to the menu screen if any player presses escape
    state_machine.addTransition({
        from      = "unwind",
        to        = "title",
        condition = function ()
            return game.camera.y == 0
        end
    })

    state_machine.addTransition({
        from      = "play",
        to        = "ending",
        condition = function ()
            return game.depth >= game.max_depth
        end
    })

    state_machine.addTransition({
        from      = "ending",
        to        = "end",
        condition = function ()
            return game.curtain.alpha == 255
        end
    })

    love.update     = state_machine.update
    love.keypressed = state_machine.keypressed
    love.keyreleased = state_machine.keyreleased
    love.inputpressed = state_machine.inputpressed
    love.mousepressed = state_machine.mousepressed
    love.mousereleased = state_machine.mousereleased
    love.textinput  = state_machine.textinput
    love.draw       = state_machine.draw

    state_machine.start()
end

function configure_game ()
    game = {}
    game.title = ""
    game.subtitle = ""
    game.prompt = ""
    game.infinity = 100


    game.colors = {
        white = { 255, 255, 255 },
        pale = { 200, 200, 200 },
        black = { 255, 255, 255, 29 }, -- black is with with low alpha so that we can fade into it
        damage = { 29, 29, 29 }
    }

    game.curtain = {}
    game.curtain.alpha = 255
    game.curtain.color = game.colors.white
    game.curtain.fade_rate = 100

    -- current color palette
    -- http://paletton.com/#uid=3000G0kotpMeNzijUsDrxl0vTg5
    game.colors[RED] = { 205, 48, 48 }
    game.colors[GREEN] = { 101, 123, 0 }
    game.colors[BLUE] = { 37, 94, 131 }
    game.colors[GREY] = { 200, 200, 200 }

    game.dt = 0
    game.input_timer = 0
    game.update_timer = 0
    game.did_step_block = false

    game.scale = 32
    game.height = 10
    game.width = 5
    game.gravity = 1
    game.match_target = 3
    game.rate = 4
    game.step = 0.1 * game.rate
    game.input_rate = 8
    game.block_max_hp = 3

    game.depth = 0 -- how far down the camera has gone in pixels
    game.depth_rate = 4*game.scale -- in chunks
    game.max_depth = 255 -- depth is applied as an alpha

    -- defaults for the board
    game.board_defaults = {
        x = 2,
        y = 0,
        width = game.width,
        height = game.height,
        color = game.colors.black,
        border_alpha = 200
    }

    -- animation times
    game.animations = {}
    game.animations.exploding = 8
    game.animations.crumbling = 8
    game.animations.hardening = 8
    -- while not really an animation, this
    -- is useful for testing
    game.animations.block_fall = 3

    -- visual choices
    -- all_block_get_damage makes the game easier: blocks are pre-damaged
    -- so when they turn grey they brake more easily... still not sure
    -- which I prefer. Design suggestion by Chris Hamilton! ^o^//
    game.all_block_get_damage = false
    game.mote_ratio = 9
    game.tiny_triangle_ratio = 3
    game.tiny_triangle = false
    game.flicker = false
    game.block_border = 4
    game.block_gap_width = 2
    game.block_damage_ratio = 2
    game.block_dim = 1

    game.colors.background = game.colors.white

    game.dark_colors = { }

    game.dark_colors[RED] = { 55, 0, 0 }
    game.dark_colors[GREEN] = { 0, 55, 0 }
    game.dark_colors[BLUE] = { 0, 0, 55 }
    game.dark_colors[GREY] = { 77, 77, 77 }

    game.camera = build_camera();
end

function build_game_state ()
    local state = {}

    state.motes = {}
    state.shift = 0 -- the game starts with three extra rows

    state.stable = true
    state.ending = false
    state.over = false

    state.block = nil
    state.next_block = nil

    state.player = {}
    state.player.has_input = false
    state.player.enabled = true
    state.player.input = {
        up = {},
        down = {},
        left = {},
        right = {}
    }

    state.board = build_board()
    build_board_row(state.board, game.height + 1)
    build_board_row(state.board, game.height + 2)
    build_board_row(state.board, game.height + 3)
    state.shadows = build_board({ default = 0.0 })
    build_board_row(state.shadows, game.height + 1, { default = 0.0 })
    build_board_row(state.shadows, game.height + 2, { default = 0.0 })
    build_board_row(state.shadows, game.height + 3, { default = 0.0 })

    return state
end

function build_game ()
    configure_game()
    game.state = build_game_state()
end

function love.load()
    EMPTY = 'x'
    RED = 1
    GREEN = 2
    BLUE = 3
    GREY = 8

    require('game/spec')

    require('libs/fsm')
    require('game/controls')
    require('game/sounds')

    require('game/update')
    require('game/draw')
    require('game/animation')

    require('game/player')
    require('game/camera')
    require('game/board')
    require('game/block')
    require('game/mote')

    -- global variables for integration with dp menus
    W_HEIGHT = love.viewport.getHeight()
    SCORE_FONT     = love.graphics.newFont("assets/Audiowide-Regular.ttf", 14)
    SPACE_FONT     = love.graphics.newFont("assets/Audiowide-Regular.ttf", 64)
    EPSILON = 0.0001

--    run_tests()
    -- TODO move_block in player is untested
    -- should have a test that moves a block
    -- and one that moves a block against obstructions

    build_statemachine()
end
