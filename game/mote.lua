
function build_mote (block)
    local mote = {}
    mote.color = block.color

    -- center the mote in the block
    mote.x = block.x + block.dim/2
    mote.y = block.y + block.dim/2
    mote.dim = block.dim/game.mote_ratio

    mote.released = false

    mote.pulse_timer = 0
    mote.pulse_intensity = 0

    return mote
end

function update_mote (mote)
    mote.pulse_timer = (mote.pulse_timer + game.dt) % (2 * math.pi)
    mote.pulse_intensity = 0.5 * math.sin(mote.pulse_timer) + 0.5

end

function draw_mote (mote)
    love.graphics.push("all")

    if (mote.released) then
        local n = mote.color
        love.graphics.setColor(n[1], n[2], n[3], 100 + 55 * mote.pulse_intensity)
        love.graphics.circle("fill", mote.x * game.scale, mote.y * game.scale, mote.dim * (2 + mote.pulse_intensity/4) * game.scale)

        love.graphics.setColor(n[1] + 55 * mote.pulse_intensity, n[2], n[3], game.board_defaults.border_alpha + 55 * mote.pulse_intensity)
        love.graphics.circle("fill", mote.x * game.scale, mote.y * game.scale, mote.dim * game.scale)
    end

    love.graphics.pop()
end
