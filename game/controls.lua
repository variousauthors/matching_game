-- Just an example to help

local controls = {
    up = {'k_up', 'k_w'},
    down = {'k_down', 'k_s'},
    left = {'k_left', 'k_a'},
    right = {'k_right', 'k_d'}
}

love.inputman.setStateMap(controls)
