local currentMode = 0

local basePlayerY = {}
local baseOpponentY = {}
local basePlayerX = {}
local basePlayerAngle = {}

local basePlayerScale = {}
local basePlayerAlpha = {}
local fakeMiddlePlayerX = {[0] = 412, [1] = 532, [2] = 628, [3] = 748}


 
 
local targetScale = 0.85
local scaleLerpSpeed = 14


 
 
local whatTheFahRestOffsetY = 50

local function whatTheFahRestY(lane)
    local downscroll = getPropertyFromClass('ClientPrefs', 'downScroll')
    if downscroll then
        return _G['defaultPlayerStrumY' .. lane] or (screenHeight - 150)
    end
    return 50 + whatTheFahRestOffsetY
end


local bounceTime = 0
local bounceActive = false


local bounceFade = 0
local bounceFadeSpeed = 8


local angleDir = 1
local strumAngleStrength = 16
local noteAngleStrength = 10
local angleTime = 0.12

local function captureFahFieldBaseline()
    for i = 0,3 do
        basePlayerY[i] = whatTheFahRestY(i)
        baseOpponentY[i] = getPropertyFromGroup('opponentStrums', i, 'y')

        basePlayerX[i] = getPropertyFromGroup('playerStrums', i, 'x')
        basePlayerAngle[i] = getPropertyFromGroup('playerStrums', i, 'angle')

        basePlayerScale[i] = getPropertyFromGroup('playerStrums', i, 'scale.x')
        basePlayerAlpha[i] = getPropertyFromGroup('playerStrums', i, 'alpha')
    end
end

function onCountdownStarted()
     
     
     
    captureFahFieldBaseline()
end

function onEvent(name, value1, value2)
    if name ~= 'strumbounces' then return end
    if lowQuality then return end
    local previousMode = currentMode

    if value1 == '1' then
        currentMode = 1
        bounceActive = true

    elseif value1 == '2' then
        currentMode = 2
        bounceActive = false

    elseif value1 == '3' then
          if previousMode == 5 then
              setVar('whatTheFahClockXManagedByLua', true)
          end
          currentMode = 0
          bounceActive = false
          targetScale = 0.85
          setVar('whatTheFahFakeMiddle', false)

          
          if getPropertyFromClass('ClientPrefs', 'middleScroll') then
              for i = 0,3 do
                  local noteIndex = i + 4

                  
                  doTweenAngle('resetAngle'..i, 'playerStrums.members['..i..']', basePlayerAngle[i], 0.3, 'quadOut')
                  noteTweenAlpha('resetAlpha'..i, noteIndex, basePlayerAlpha[i], 0.15, 'quadOut')
              end
              return
          end

          
          for i = 0,3 do
              local noteIndex = i + 4

              setPropertyFromGroup('playerStrums', i, 'y', basePlayerY[i])
              setPropertyFromGroup('opponentStrums', i, 'y', baseOpponentY[i])

              if previousMode == 5 then
                  noteTweenX('resetX'..i, noteIndex, basePlayerX[i], 0.5, 'quadInOut')
              end
              doTweenAngle('resetAngle'..i, 'playerStrums.members['..i..']', basePlayerAngle[i], 0.3, 'quadOut')

              noteTweenAlpha('resetAlpha'..i, noteIndex, basePlayerAlpha[i], 0.15, 'quadOut')
        end

    elseif value1 == '4' then
        currentMode = 4
        bounceActive = false
        targetScale = 0.70

        for i = 0,3 do
            local noteIndex = i + 4
            noteTweenAlpha('bfFade'..i, noteIndex, 0.5, 0.15, 'quadOut')
        end

    elseif value1 == '5' then
        if songName == 'what-the-fah' and getPropertyFromClass('MirrorMode', 'active') then return end

        
        if getPropertyFromClass('ClientPrefs', 'middleScroll') then
            return
        end

        currentMode = 5
        bounceActive = false
        setVar('whatTheFahClockXManagedByLua', true)
        setVar('whatTheFahFakeMiddle', true)

        local moveTime = 0.5

        for i = 0,3 do
            local noteIndex = i + 4
            local targetX = fakeMiddlePlayerX[i]

            local curX = getPropertyFromGroup('playerStrums', i, 'x')
            local direction = (targetX > curX) and 1 or -1

            local overshoot = targetX + (direction * 40)

            setPropertyFromGroup('playerStrums', i, 'angle', -direction * 8)

            noteTweenX('bfMoveOut'..i, noteIndex, overshoot, moveTime, 'quadOut')
            runTimer('bfReturn'..i, moveTime)
        end
    end
end

function onBeatHit()

    
    if currentMode == 2 then
        for i = 0,3 do
            doTweenAngle('beatAngleStrum'..i,
                'playerStrums.members['..i..']',
                angleDir * strumAngleStrength,
                angleTime,
                'quadOut'
            )

            noteTweenAngle('beatAngleNote'..i,
                i + 4,
                angleDir * noteAngleStrength,
                angleTime,
                'quadOut'
            )
        end

        runTimer('angleReturn', angleTime)
        angleDir = -angleDir
    end

    
    if currentMode == 1 then
        bounceTime = 0
        bounceActive = true
    end
end

function onTimerCompleted(tag)

    if tag == 'angleReturn' then
        for i = 0,3 do
            doTweenAngle('angleBackStrum'..i,
                'playerStrums.members['..i..']',
                0,
                angleTime,
                'quadIn'
            )

            noteTweenAngle('angleBackNote'..i,
                i + 4,
                0,
                angleTime,
                'quadIn'
            )
        end
    end

    if string.sub(tag, 1, 8) == 'bfReturn' then
        local i = tonumber(string.sub(tag, 9))
        local noteIndex = i + 4
        local targetX = fakeMiddlePlayerX[i]

        noteTweenX('bfMoveBack'..i, noteIndex, targetX, 0.45, 'cubeOut')
        doTweenAngle('bfAngleReset'..i, 'playerStrums.members['..i..']', 0, 0.45, 'cubeOut')
    end
end

function onUpdatePost(elapsed)
    if lowQuality then
         
         
        for i = 0, 3 do
            setPropertyFromGroup('playerStrums', i, 'scale.x', 0.85)
            setPropertyFromGroup('playerStrums', i, 'scale.y', 0.85)
        end
        setPlayerNoteScale(0.85)
        return
    end

    
    local targetFade = (currentMode == 1) and 1 or 0
    bounceFade = bounceFade + (targetFade - bounceFade) * math.min(elapsed * bounceFadeSpeed, 1)

    
    
    
    if not getProperty('birthdayMode') and (bounceActive or math.abs(bounceFade - targetFade) > 0.001) then

        if bounceActive then
            bounceTime = bounceTime + elapsed
        end

        local duration = 0.35
        local t = bounceTime / duration

        if t >= 1 then
            bounceActive = false
            t = 1
        end

        local height = 26
        local offset = 0

        if t < 0.4 then
            local p = t / 0.4
            offset = -height * (p * (2 - p))
        else
            local p = (t - 0.4) / 0.6
            offset = -height * (1 - (p * p))
        end

        offset = offset * bounceFade

        for i = 0,3 do
            setPropertyFromGroup('playerStrums', i, 'y', basePlayerY[i] + offset)
            setPropertyFromGroup('opponentStrums', i, 'y', baseOpponentY[i] + offset)
        end
    end

    
    for i = 0,3 do
        local curScale = getPropertyFromGroup('playerStrums', i, 'scale.x')
        if math.abs(targetScale - curScale) > 0.0001 then
            local newScale = curScale + (targetScale - curScale) * math.min(elapsed * scaleLerpSpeed, 1)
            setPropertyFromGroup('playerStrums', i, 'scale.x', newScale)
            setPropertyFromGroup('playerStrums', i, 'scale.y', newScale)
        end
    end

    
    setPlayerNoteScale(targetScale, true, 0.0001)

    
    
    
end
