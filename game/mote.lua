
function build_mote(block)
    local mote = {}
    mote.color = block.color

    -- center the mote in the block
    mote.x = block.x + block.dim/2
    mote.y = block.y + block.dim/2
    mote.dim = block.dim/game.mote_ratio

    return mote
end

function draw_mote(mote)
    love.graphics.push("all")

    love.graphics.setColor(mote.color)
    love.graphics.circle("fill", mote.x * game.scale, mote.y * game.scale, mote.dim * game.scale)

    love.graphics.pop()
end
