local shown = false
local finished = false
local normalScale = 1

function onCreate()
    makeAnimatedLuaSprite('phillyFahreddy', 'fahmix/week 3/fahreddy', 0, 0)
    addAnimationByPrefix('phillyFahreddy', 'idle', 'fahreddy idle', 3, true)
    playAnim('phillyFahreddy', 'idle', true)
    normalScale = screenHeight * 0.8 / getProperty('phillyFahreddy.height')
    scaleObject('phillyFahreddy', normalScale, normalScale)
    setProperty('phillyFahreddy.x', (screenWidth - getProperty('phillyFahreddy.width')) * 0.5)
    setObjectCamera('phillyFahreddy', 'other')
    anchorSpriteToScreenBottom('phillyFahreddy')
    setProperty('phillyFahreddy.bottomAnchor.y', screenHeight)
    setProperty('phillyFahreddy.visible', false)
    setProperty('phillyFahreddy.active', false)
    addLuaSprite('phillyFahreddy', true)
end

local function updateFahreddy()
    if finished then return end
    if curStep >= 504 then
        finished = true
        setProperty('phillyFahreddy.alpha', 0)
        setProperty('phillyFahreddy.visible', false)
        setProperty('phillyFahreddy.active', false)
        return
    end
    if curStep >= 447 and not shown then
        shown = true
        setProperty('phillyFahreddy.visible', true)
        setProperty('phillyFahreddy.active', true)
        setObjectOrder('phillyFahreddy', getProperty('members.length') - 1)
        if luaSpriteExists('logo') then
            setObjectOrder('logo', getObjectOrder('phillyFahreddy') + 1)
        end
        doTweenY('phillyFahreddyIn', 'phillyFahreddy.bottomAnchor', 0, 0.2, 'quadOut')
    end
    if shown then
        local phase = (curDecStep / 4) % 1
        local scale = normalScale * (1 + 0.1 * (1 - phase) ^ 3)
        setProperty('phillyFahreddy.scale.x', scale)
        setProperty('phillyFahreddy.scale.y', scale)
        if curStep >= 461 then
            setProperty('phillyFahreddy.alpha', math.max(0, math.min(1, (504 - curDecStep) / 43)))
        end
    end
end

function onStepHit()
    updateFahreddy()
end

function onUpdatePost(elapsed)
    updateFahreddy()
end

function onGameOverStart()
    finished = true
    cancelTween('phillyFahreddyIn')
    if luaSpriteExists('phillyFahreddy') then setProperty('phillyFahreddy.visible', false) end
end