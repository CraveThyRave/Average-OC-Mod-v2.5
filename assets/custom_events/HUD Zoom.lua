function onEvent(name, value1, value2)

    if name ~= 'HUD Zoom' then
        return
    end

    local zoom = tonumber(value1) or 1
    local speed = tonumber(value2) or 1

    doTweenZoom(
        'hudZoomTween',
        'camHUD',
        zoom,
        speed,
        'cubeInOut'
    )
end
