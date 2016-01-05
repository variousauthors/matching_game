
function build_camera ()
    local camera = {
        cx = 0, cy = 0,
        tx = 0, ty = 0,
        rx = 0, ry = 0,
        x = 0, y = 0
    }

    return camera;
end

-- adjust the camera by the given amount, over time
function move_camera (camera, x, y)
    camera.tx = x
    camera.ty = y
end

function update_camera (camera, dt)
    local vx = camera.tx - camera.cx
    local vy = camera.ty - camera.cy

    local dx, dy = vx*dt, vy*dt

    if math.abs(dx) < EPSILON then
        camera.x = camera.tx
        dx = 0
    else
        camera.rx = camera.rx + dx
    end

    if math.abs(dy) < EPSILON then
        camera.y = camera.ty
        dy = 0
    else
        camera.ry = camera.ry + dy
    end

    -- if neither was significant, do nothing
    if (dx == 0 and dy == 0) then
        return
    end

    if math.abs(camera.rx) >= 1 then
        if (camera.rx > 0) then
            sign = 1
        else
            sign = -1
        end

        camera.cx = camera.cx + sign
        camera.rx = camera.rx - sign
    end

    if math.abs(camera.ry) >= 1 then
        if (camera.ry > 0) then
            sign = 1
        else
            sign = -1
        end

        camera.cy = camera.cy + sign
        camera.ry = camera.ry - sign
    end

    camera.x = camera.cx + camera.rx
    camera.y = camera.cy + camera.ry
end
