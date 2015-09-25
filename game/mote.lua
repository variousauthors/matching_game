
function build_mote (block)
    local mote = {}


    return {
        -- position in the grid
        cx = block.x + block.dim/2,
        cy = block.y + block.dim/2,

        -- real position relative to the grid (0..1)
        rx = 0,
        ry = 0,

        vx = 0,
        vy = 0,

        dx = 0,
        dy = 0,

        -- final position in each timestep fro graphics
        x = block.x + block.dim/2,
        y = block.y + block.dim/2,

        dim = block.dim/game.mote_ratio,
        color = block.color,
        primary = block.primary,

        halo_dim = block.dim/game.mote_ratio + (0.5 - math.random()) / game.scale,

        released = false,
        pulse_timer = 0,
        pulse_intensity = 0,
        pulse_period = math.pi
    }
end

function update_mote (mote)
    if (not mote.released) then
        return
    end

    mote.pulse_timer = (mote.pulse_timer + game.dt + (0.05 - math.random() * 0.1)) % (mote.pulse_period)
    mote.pulse_intensity = 0.5 * math.sin(2 * mote.pulse_timer) + 0.5

    -- apply forces
    mote.vy = mote.vy + game.gravity

    -- mote tries to stabilize
    if (mote.cx ~= mote.x) then
        mote.vx = mote.cx - mote.x
    end

    if (mote.cy ~= mote.y) then
        mote.vy = mote.cy - mote.y
    end

    mote.dy = mote.dy + mote.vy * game.dt
    mote.dx = mote.dx + mote.vx * game.dt

    mote.x = mote.x + mote.dx
    mote.y = mote.y + mote.dy
end

function draw_mote (mote)
    love.graphics.push("all")

    if (mote.released) then
        local n = {
            mote.color[1],
            mote.color[2],
            mote.color[3]
        }

        -- draw inner halo
        love.graphics.setColor(n[1], n[2], n[3], 50 + 55 * mote.pulse_intensity)
        love.graphics.circle("fill", mote.x * game.scale, mote.y * game.scale, mote.halo_dim * (3 + mote.pulse_intensity/2) * game.scale)

        -- draw outer halo
        love.graphics.setColor(n[1], n[2], n[3], 0 + 55 * mote.pulse_intensity)
        love.graphics.circle("fill", mote.x * game.scale, mote.y * game.scale, mote.halo_dim * (7+ mote.pulse_intensity/4) * game.scale)

        -- draw mote
        n[mote.primary] = n[mote.primary] + 55 * mote.pulse_intensity
        local w = { 
            game.colors.pale[1],
            game.colors.pale[2],
            game.colors.pale[3]
        }

        w[mote.primary] = w[mote.primary] + 55 * mote.pulse_intensity
        love.graphics.setColor(w[1], w[2], w[3], 150 + 50 * mote.pulse_intensity)
        love.graphics.circle("fill", mote.x * game.scale, mote.y * game.scale, mote.dim * game.scale)
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

