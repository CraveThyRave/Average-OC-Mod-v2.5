
local sway = false
local bounce = false

local angleAmount = 8
local bounceAmount = 20

local defaultY = {}
local defaultAngle = {}


function onCountdownStarted()
    for i = 0, 7 do
        defaultY[i] = getPropertyFromGroup('strumLineNotes', i, 'y')
        defaultAngle[i] = getPropertyFromGroup('strumLineNotes', i, 'angle')
    end
end

function onStepHit()
    
    
    
    if curStep == 271 then
        sway = true
    end

    
    
    
    if curStep == 400 then
        sway = false

        for i = 0, 7 do
            cancelTween('angle'..i)
            noteTweenAngle('resetAngle'..i, i, defaultAngle[i], 0.15, 'quadOut')
        end
    end

    
    
    
    if curStep == 527 then
        bounce = true

        
        for i = 0, 7 do
            defaultY[i] = getPropertyFromGroup('strumLineNotes', i, 'y')
        end
    end

    
    
    
    if curStep == 655 then
        bounce = false

        for i = 0, 7 do
            cancelTween('down'..i)
            cancelTween('up'..i)
            noteTweenY('resetY'..i, i, defaultY[i], 0.15, 'quadOut')
        end
    end

    
    
    
    if curStep == 799 then
        bounce = true

        
        for i = 0, 7 do
            defaultY[i] = getPropertyFromGroup('strumLineNotes', i, 'y')
        end
    end

    
    
    
    if curStep == 927 then
        bounce = false

        for i = 0, 7 do
            cancelTween('down'..i)
            cancelTween('up'..i)
            noteTweenY('resetY'..i, i, defaultY[i], 0.15, 'quadOut')
        end
    end
end

function onBeatHit()
    
    
    
    if sway then
        local ang = (curBeat % 2 == 0) and angleAmount or -angleAmount

        for i = 0, 7 do
            cancelTween('resetAngle'..i)
            noteTweenAngle('angle'..i, i, ang, 0.15, 'quadOut')
        end
    end

    
    
    
    if bounce and not lowQuality then
        for i = 0, 7 do
            cancelTween('down'..i)
            cancelTween('up'..i)

            noteTweenY('down'..i, i, defaultY[i] + bounceAmount, 0.08, 'quadOut')
        end

        runTimer('bounceBack', 0.08)
    end
end

function onTimerCompleted(tag)
    if tag == 'bounceBack' and bounce and not lowQuality then
        for i = 0, 7 do
            cancelTween('down'..i)
            noteTweenY('up'..i, i, defaultY[i], 0.08, 'quadIn')
        end
    end
end
