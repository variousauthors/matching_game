
function build_mote (block)
    local mote = {}
    local x = block.x + block.dim/2
    local y = block.y + block.dim/2


    return {
        -- position in the grid
        cx = x,
        cy = y,

        -- real position relative to the grid (0..1)
        rx = 0,
        ry = 0,

        -- draw position combines c and r
        x = x,
        y = y,

        -- hover target
        hx = 0,
        hy = 0,

        ax = 0,
        ay = -1,

        vx = 0,
        vy = 0,

        dx = 0,
        dy = 0,

        dim = block.dim/game.mote_ratio,
        color = block.color,
        primary = block.primary,

        halo_dim = block.dim/game.mote_ratio + (0.5 - math.random()) / game.scale,

        released = false,
        life_timer = math.random() * 2 * game.step,
        pulse_timer = 0,
        pulse_intensity = 0,
        pulse_period = math.pi
    }
end

function update_mote (mote)
    if (not mote.released) then
        return
    end

    mote.life_timer = mote.life_timer + game.dt

    mote.pulse_timer = (mote.pulse_timer + game.dt + (0.05 - math.random() * 0.1)) % (mote.pulse_period)
    mote.pulse_intensity = 0.5 * math.sin(2 * mote.pulse_timer) + 0.5

    -- float in place
    -- TODO the value 1 has been chosen arbitrarily, it shouldn't be
    -- TODO I feel strongly that rx should have a value from 0 to 1 all the time
    -- and be scaled as well...
    if (math.abs(mote.rx - mote.hx) < 2 and math.abs(mote.ry - mote.hy) < 2) then
        -- pick a spot on the unit circle as the new hover target
        local spot = 2 * math.pi * math.random()
        local x = math.cos(spot)
        local y = math.sin(spot)

        mote.hx = x * game.scale / 4
        mote.hy = y * game.scale / 4
    else
        mote.rx = mote.rx + 3 * (mote.hx - mote.rx) * game.dt
        mote.ry = mote.ry + 3 * (mote.hy - mote.ry) * game.dt
    end

    -- after a momentary pause, the mote leaves!
    if (mote.life_timer > 8 * game.step) then
        mote.vy = mote.vy + mote.ay * game.dt
        mote.dy = mote.vy

        mote.cy = mote.cy + mote.dy

        mote.y = mote.cy
        mote.x = mote.cx
    end
end

function draw_mote (mote)
    love.graphics.push("all")

    mote.x = mote.cx * game.scale + mote.rx
    mote.y = mote.cy * game.scale + mote.ry

    if (mote.released) then
        local n = {
            mote.color[1],
            mote.color[2],
            mote.color[3]
        }

        -- draw inner halo
        love.graphics.setColor(n[1], n[2], n[3], 50 + 55 * mote.pulse_intensity)
        love.graphics.circle("fill", mote.x, mote.y, mote.halo_dim * (3 + mote.pulse_intensity/2) * game.scale)

        -- draw outer halo
        love.graphics.setColor(n[1], n[2], n[3], 0 + 55 * mote.pulse_intensity)
        love.graphics.circle("fill", mote.x, mote.y, mote.halo_dim * (7+ mote.pulse_intensity/4) * game.scale)

        -- draw mote
        n[mote.primary] = n[mote.primary] + 55 * mote.pulse_intensity
        local w = { 
            game.colors.pale[1],
            game.colors.pale[2],
            game.colors.pale[3]
        }

        w[mote.primary] = w[mote.primary] + 55 * mote.pulse_intensity
        love.graphics.setColor(w[1], w[2], w[3], 150 + 50 * mote.pulse_intensity)
        love.graphics.circle("fill", mote.x, mote.y, mote.dim * game.scale)
    end

    love.graphics.pop()
end

-- set the drawing coord relative to the board
function mote_set_y (mote, board, y)
    -- -1 because cx is a table index
    mote.y = y
end

function mote_set_x (mote, board, x)
    -- -1 because cx is a table index
    mote.x = x
end

