-- Set-up global Input objects.
love.inputman = require('libs/inputman').newSingleton()

-- Screw the literally zillions of input callbacks, we're going to use two
-- custom events instead.
--
function love.inputpressed(state)

    if game.state.player.input[state] ~= nil then
        game.state.player.has_input = true
        table.insert(game.state.player.input[state], true)
    end

    -- An example of input/sound
    -- if(state == 'select') then love.soundman.run('select') end
end

function love.inputreleased(state)

end

-- Maybe we want to use keypressed as well for a few global
--
function love.keypressed(key)
    if(key == 'f10' or key == 'escape') then
        -- love.event.quit()
    elseif(key == 'f11') then
        love.viewport.setFullscreen()
        love.viewport.setupScreen()
    elseif(key == 'f12') then
        love.inputman.threadStatus()
        love.soundman.threadStatus()
    end
end

function love.joystickadded(j)
    love.inputman.updateJoysticks()
end

function love.joystickremoved(j)
    love.inputman.updateJoysticks()
end
