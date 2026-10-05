local shown = false
local finished = false
local normalScale = 1

function onCreate()
    makeAnimatedLuaSprite('phillyFoo', 'fahmix/week 3/foo', 0, 0)
    addAnimationByPrefix('phillyFoo', 'idle', 'foo idle', 3, true)
    playAnim('phillyFoo', 'idle', true)
    normalScale = screenHeight * 0.8 / getProperty('phillyFoo.height')
    scaleObject('phillyFoo', normalScale, normalScale)
    setProperty('phillyFoo.x', (screenWidth - getProperty('phillyFoo.width')) * 0.5)
    setProperty('phillyFoo.y', (screenHeight - getProperty('phillyFoo.height')) * 0.5)
    setProperty('phillyFoo.scale.x', normalScale * 0.01)
    setProperty('phillyFoo.scale.y', normalScale * 0.01)
    setObjectCamera('phillyFoo', 'other')
    setProperty('phillyFoo.visible', false)
    setProperty('phillyFoo.active', false)
    addLuaSprite('phillyFoo', true)
end

local function updateFoo()
    if finished then return end
    if curStep >= 288 then
        finished = true
        setProperty('phillyFoo.alpha', 0)
        setProperty('phillyFoo.visible', false)
        setProperty('phillyFoo.active', false)
        return
    end
    if curStep >= 275 and not shown then
        shown = true
        setProperty('phillyFoo.visible', true)
        setProperty('phillyFoo.active', true)
        setObjectOrder('phillyFoo', getProperty('members.length') - 1)
        if luaSpriteExists('logo') then
            setObjectOrder('logo', getObjectOrder('phillyFoo') + 1)
        end
        doTweenX('phillyFooGrowX', 'phillyFoo.scale', normalScale, 0.23, 'backOut')
        doTweenY('phillyFooGrowY', 'phillyFoo.scale', normalScale, 0.23, 'backOut')
    end
    if shown then
        setProperty('phillyFoo.angle', 12 * math.cos(curDecStep * math.pi / 4))
        if curStep >= 281 then
            setProperty('phillyFoo.alpha', math.max(0, math.min(1, (288 - curDecStep) / 7)))
        end
    end
end

function onStepHit()
    updateFoo()
end

function onUpdatePost(elapsed)
    updateFoo()
end

function onGameOverStart()
    finished = true
    cancelTween('phillyFooGrowX')
    cancelTween('phillyFooGrowY')
    if luaSpriteExists('phillyFoo') then setProperty('phillyFoo.visible', false) end
end