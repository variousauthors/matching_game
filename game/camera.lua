
function build_camera ()
    local camera = {
        cx = 0, cy = 0,
        tx = 0, ty = 0,
        rx = 0, ry = 0,
        x = 0, y = 0
    }

    return camera;
end

function scroll_down_camera (camera)
    camera.ty = camera.cy + 1
end

function update_camera (camera)
    if camera.tx ~= camera.cx then
        local d = camera.tx - camera.cx
        camera.rx = camera.rx + d*game.dt
    end

    if camera.ty ~= camera.cy then
        local d = camera.ty - camera.cy
        camera.ry = camera.ry + d*game.dt
    end

    if camera.rx >= 1 then
        camera.rx = 0
        camera.cx = camera.tx
    end

    if camera.ry >= 1 then
        camera.ry = 0
        camera.cy = camera.ty
    end

    camera.x = camera.cx + camera.rx
    camera.y = camera.cy + camera.ry
end
