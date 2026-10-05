local shown = false
local finished = false

function onCreate()
    makeAnimatedLuaSprite('phillyMad', 'fahmix/week 3/mad', 0, 0)
    addAnimationByPrefix('phillyMad', 'idle', 'mad idle', 3, true)
    playAnim('phillyMad', 'idle', true)
    local scale = screenHeight * 0.8 / getProperty('phillyMad.height')
    scaleObject('phillyMad', scale, scale)
    setProperty('phillyMad.x', (screenWidth - getProperty('phillyMad.width')) * 0.5)
    setProperty('phillyMad.y', (screenHeight - getProperty('phillyMad.height')) * 0.5)
    setObjectCamera('phillyMad', 'other')
    setProperty('phillyMad.visible', false)
    setProperty('phillyMad.active', false)
    addLuaSprite('phillyMad', true)
end

local function updateMad()
    if finished then return end
    if curStep >= 735 then
        finished = true
        setProperty('phillyMad.alpha', 0)
        setProperty('phillyMad.visible', false)
        setProperty('phillyMad.active', false)
        return
    end
    if curStep >= 724 and not shown then
        shown = true
        setProperty('phillyMad.visible', true)
        setProperty('phillyMad.active', true)
        setObjectOrder('phillyMad', getProperty('members.length') - 1)
        if luaSpriteExists('logo') then
            setObjectOrder('logo', getObjectOrder('phillyMad') + 1)
        end
    end
    if shown and curStep >= 730 then
        setProperty('phillyMad.alpha', math.max(0, math.min(1, (735 - curDecStep) / 5)))
    end
end

function onStepHit()
    updateMad()
end

function onUpdatePost(elapsed)
    updateMad()
end

function onGameOverStart()
    finished = true
    if luaSpriteExists('phillyMad') then setProperty('phillyMad.visible', false) end
end