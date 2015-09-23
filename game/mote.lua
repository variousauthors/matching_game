
function build_mote (block)
    local mote = {}
    mote.color = block.color
    mote.primary = block.primary

    -- center the mote in the block
    mote.x = block.x + block.dim/2
    mote.y = block.y + block.dim/2
    mote.dim = block.dim/game.mote_ratio

    mote.halo_dim = block.dim/game.mote_ratio + (0.5 - math.random()) / game.scale

    mote.released = false

    mote.pulse_timer = 0
    mote.pulse_intensity = 0
    mote.pulse_period = math.pi

    return mote
end

function update_mote (mote)
    mote.pulse_timer = (mote.pulse_timer + game.dt + (0.05 - math.random() * 0.1)) % (mote.pulse_period)
    mote.pulse_intensity = 0.5 * math.sin(2 * mote.pulse_timer) + 0.5
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
