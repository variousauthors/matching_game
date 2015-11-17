Component = require('libs/component')

return function ()
    local showing       = false
    local hide_callback = function () end
    local cursor_pos    = 0
    local choice        = "launch"
    local mode          = "dynamic"
    local menu_index    = 0
    local time, flash   = 0, 0

    local inputs = {
        {   -- language_select
            clear      = function ()
            end,
            keypressed = function (key)
                choice = "launch"
                cursor_pos = 0
            end
        },
        {   -- language_select
            clear      = function ()
            end,
            keypressed = function (key)
                choice = "settings"
                cursor_pos = 90
            end
        },
    }

    local drawCursor = function (x, y)
        local icon = ">"

        love.graphics.setFont(SCORE_FONT)
        love.graphics.print(icon, x, y + cursor_pos)
    end

    local drawSubtitle = function (x, y)
        love.graphics.setFont(SCORE_FONT)
        love.graphics.setColor({ 55, 55, 55, 100 })
        love.graphics.printf(game.subtitle, x, y, 576, "right")
        love.graphics.setColor({ 200, 200, 200, 100 })
        love.graphics.printf(game.subtitle, x, y, 576, "right")
        love.graphics.setColor(game.colors.white)
    end

    local drawTitle = function (x, y)
        love.graphics.setFont(SPACE_FONT)
        love.graphics.setColor({ 55, 55, 55, 100 })
        love.graphics.print(game.title, x, y)
        love.graphics.setColor({ 200, 200, 200, 100 })
        love.graphics.print(game.title, x, y)
        love.graphics.setColor(game.colors.white)
    end

    local drawPrompt = function (x, y)
        if (flash < 0) then
            return
        end

        love.graphics.setFont(SCORE_FONT)
        love.graphics.setColor({ 55, 55, 55, 100 })
        love.graphics.print(game.prompt, x, y)
        love.graphics.setColor({ 200, 200, 200, 100 })
        love.graphics.print(game.prompt, x, y)
        love.graphics.setColor(game.colors.white)
    end

    local title_part    = Component(0, 0, drawTitle)
    local subtitle_part = Component(0, 80, drawSubtitle)
    local prompt_part = Component(200, 300, drawPrompt)

    local component = Component(100, W_HEIGHT/2 - 200, title_part, subtitle_part, prompt_part)

    local draw = function ()
        local r, g, b = love.graphics.getColor()
        love.graphics.setColor({ 255, 255, 255 })

        component.draw(0, 0)

        love.graphics.setColor({ r, g, b })
    end

    local update = function (dt)
        time  = (time + 4*dt) % (2*math.pi)
        flash = math.sin(time)
    end

    local show = function (callback)
        hide_callback = callback
        showing = true

        if not showing then
            if callback then callback() end
        end
    end

    local hide = function ()
        if hide_callback then hide_callback({ arity = choice, mode = mode }) end
        showing = false
    end

    local isShowing = function ()
        return showing
    end

    local mousepressed = function (x, y, button)
        choice = "launch"
        hide()
    end

    -- any key quits the menu
    local keypressed = hide

    local textinput = function (key)
        if inputs[menu_index + 1].textinput then
            inputs[menu_index + 1].textinput(key)
        end
    end

    local reset = function ()
        play_together = false
    end

    return {
        draw           = draw,
        update         = update,
        keypressed     = keypressed,
        mousepressed   = mousepressed,
        textinput      = textinput,
        show           = show,
        hide           = hide,
        isShowing      = isShowing,
        reset          = reset,

        TOGETHER       = "together"
    }

end
