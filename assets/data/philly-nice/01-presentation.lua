local enabled = false
local baseX = {}
local lastPattern = -1
local logoStarted = false
local logoFinished = false
local ending = false

function onCreate()
    enabled = not getPropertyFromClass('MirrorMode', 'active')
    if not enabled then return end
    makeLuaSprite('logo', 'fahmix/week 3/philly-nice-logo', 320, -590)
    scaleObject('logo', 0.4, 0.4)
    setObjectCamera('logo', 'other')
    addLuaSprite('logo', false)
    makeLuaSprite('phillyEndingBlack', nil, 0, 0)
    makeGraphic('phillyEndingBlack', screenWidth, screenHeight, '000000')
    setObjectCamera('phillyEndingBlack', 'other')
    setProperty('phillyEndingBlack.visible', false)
    addLuaSprite('phillyEndingBlack', true)
end

function onCountdownStarted()
    if not enabled then return end
    for lane = 0, 3 do
        baseX[lane] = getPropertyFromGroup('playerStrums', lane, 'x')
    end
end

local function updatePresentation(step)
    if not enabled or ending then return end
    if step >= 160 and not logoStarted then
        logoStarted = true
        doTweenY('phillyLogoDrop', 'logo', (screenHeight - getProperty('logo.height')) * 0.5, 1, 'quartOut')
    end
    if step >= 186 and not logoFinished then
        logoFinished = true
        doTweenX('phillyLogoShrinkX', 'logo.scale', 0, 0.4, 'quintIn')
        doTweenY('phillyLogoShrinkY', 'logo.scale', 0, 0.4, 'quintIn')
    end
    local pattern = 0
    if step >= 416 and step < 800 then
        pattern = math.floor((step - 416) / 16) % 2 + 1
    end
    if pattern ~= lastPattern and baseX[0] ~= nil then
        lastPattern = pattern
        cancelTimer('phillyKnockOut')
        for lane = 0, 3 do
            noteTweenX('phillyLane' .. lane, lane + 4, baseX[lane], 0.16, 'quadIn')
        end
        if pattern ~= 0 then runTimer('phillyKnockOut', 0.20) end
    end
    if step >= 1312 then
        ending = true
        setProperty('phillyEndingBlack.visible', true)
        setObjectOrder('phillyEndingBlack', getProperty('members.length') - 1)
    end
end

function onStepHit()
    updatePresentation(curStep)
end

function onUpdatePost(elapsed)
    updatePresentation(curStep)
end

function onGameOverStart()
    enabled = false
    if luaSpriteExists('logo') then setProperty('logo.visible', false) end
    if luaSpriteExists('phillyEndingBlack') then setProperty('phillyEndingBlack.visible', false) end
end

function onTimerCompleted(tag)
    if tag ~= 'phillyKnockOut' or not enabled or ending or lastPattern == 0 then return end
    for lane = 0, 3 do
        if (lastPattern == 1 and lane < 2) or (lastPattern == 2 and lane >= 2) then
            local offset = lastPattern == 1 and -60 or 60
            noteTweenX('phillyLane' .. lane, lane + 4, baseX[lane] + offset, 0.4, 'bounceOut')
        end
    end
end