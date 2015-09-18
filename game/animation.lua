
function start_tween (animatable, animation)
    animatable.animating = true
    animatable[animation] = game.animations[animation]
end

