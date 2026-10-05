
local pulseNotes = false


local normalScale = 0.65
local pulseScale = 0.75


local scaleSpeed = 12

local targetScale = {}

function onCreatePost()
    for i = 0, 7 do
        
        local currentScale = getPropertyFromGroup(
            'strumLineNotes',
            i,
            'scale.x'
        )

        targetScale[i] = currentScale
    end
end

function onStepHit()
    if curStep == 383 then
        pulseNotes = true
    end

    if curStep == 510 then
        pulseNotes = false

        
        for i = 0, 7 do
            targetScale[i] = normalScale
        end
    end

    if curStep == 800 then
        pulseNotes = true
    end

    if curStep == 510 then
        pulseNotes = false

        
        for i = 0, 7 do
            targetScale[i] = normalScale
        end
    end
end

function onBeatHit()
    if not pulseNotes then
        return
    end

    
    
    local pulseLeftUp = curBeat % 2 == 0

    for i = 0, 7 do
        local lane = i % 4
        local shouldGrow = false

        if pulseLeftUp then
            shouldGrow = lane == 0 or lane == 2
        else
            shouldGrow = lane == 1 or lane == 3
        end

        if shouldGrow then
            targetScale[i] = pulseScale
        else
            targetScale[i] = normalScale
        end
    end
end

function onUpdatePost(elapsed)
    local lerpAmount = math.min(elapsed * scaleSpeed, 1)

    for i = 0, 7 do
        local currentX = getPropertyFromGroup(
            'strumLineNotes',
            i,
            'scale.x'
        )

        local currentY = getPropertyFromGroup(
            'strumLineNotes',
            i,
            'scale.y'
        )

        local newX = currentX +
            (targetScale[i] - currentX) * lerpAmount

        local newY = currentY +
            (targetScale[i] - currentY) * lerpAmount

        setPropertyFromGroup(
            'strumLineNotes',
            i,
            'scale.x',
            newX
        )

        setPropertyFromGroup(
            'strumLineNotes',
            i,
            'scale.y',
            newY
        )
    end
end
