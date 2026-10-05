local shown = false
local finished = false
local normalScale = 1
local centerX = 0
local centerY = 0
local lastSide = -1

function onCreate()
    makeAnimatedLuaSprite('phillyMorticco', 'fahmix/week 3/morticco', 0, screenHeight + 20)
    addAnimationByPrefix('phillyMorticco', 'idle', 'morticco idle', 3, true)
    playAnim('phillyMorticco', 'idle', true)
    normalScale = screenHeight * 0.8 / getProperty('phillyMorticco.height')
    scaleObject('phillyMorticco', normalScale, normalScale)
    centerX = (screenWidth - getProperty('phillyMorticco.width')) * 0.5
    centerY = (screenHeight - getProperty('phillyMorticco.height')) * 0.5
    setProperty('phillyMorticco.x', centerX)
    setObjectCamera('phillyMorticco', 'other')
    setProperty('phillyMorticco.visible', false)
    setProperty('phillyMorticco.active', false)
    addLuaSprite('phillyMorticco', true)
end

local function updateMorticco()
    if finished then return end
    if curStep >= 932 then
        finished = true
        setProperty('phillyMorticco.scale.x', 0)
        setProperty('phillyMorticco.scale.y', 0)
        setProperty('phillyMorticco.visible', false)
        setProperty('phillyMorticco.active', false)
        return
    end
    if curStep >= 910 and not shown then
        shown = true
        setProperty('phillyMorticco.visible', true)
        setProperty('phillyMorticco.active', true)
        setObjectOrder('phillyMorticco', getProperty('members.length') - 1)
        if luaSpriteExists('logo') then
            setObjectOrder('logo', getObjectOrder('phillyMorticco') + 1)
        end
        doTweenY('phillyMorticcoIn', 'phillyMorticco', centerY, 0.3, 'quadOut')
    end
    if not shown then return end
    local size = 1
    if curDecStep >= 928 then
        if curDecStep < 928.5 then
            size = 1 + 0.3 * (curDecStep - 928) / 0.5
        else
            size = 1.3 * math.max(0, (932 - curDecStep) / 3.5)
        end
    elseif curDecStep >= 915 and curDecStep < 917 then
        if curDecStep < 915.5 then
            size = 1 + 0.15 * (curDecStep - 915) / 0.5
        else
            size = 1 + 0.15 * (917 - curDecStep) / 1.5
        end
    end
    setProperty('phillyMorticco.scale.x', normalScale * size)
    setProperty('phillyMorticco.scale.y', normalScale * size)
    if curStep >= 920 then
        local side = math.floor((curStep - 920) / 8)
        if side ~= lastSide then
            lastSide = side
            local offset = side % 2 == 0 and -120 or 120
            setProperty('phillyMorticco.angle', offset < 0 and 14 or -14)
            doTweenAngle('phillyMorticcoLean', 'phillyMorticco', 0, 0.2, 'quadOut')
            doTweenX('phillyMorticcoSide', 'phillyMorticco', centerX + offset, 0.045, 'quadOut')
        end
    end
end

function onStepHit()
    updateMorticco()
end

function onUpdatePost(elapsed)
    updateMorticco()
end

function onGameOverStart()
    finished = true
    cancelTween('phillyMorticcoIn')
    cancelTween('phillyMorticcoSide')
    if luaSpriteExists('phillyMorticco') then setProperty('phillyMorticco.visible', false) end
end