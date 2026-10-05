local entered = false
local finished = false
local centerX = 0
local exitX = 0
local shiftedStep = 0

function onCreate()
    makeAnimatedLuaSprite('phillyParvin', 'fahmix/week 3/parvin', 0, 0)
    addAnimationByPrefix('phillyParvin', 'idle', 'parvin idle', 3, true)
    playAnim('phillyParvin', 'idle', true)
    local scale = screenHeight * 0.8 / getProperty('phillyParvin.height')
    scaleObject('phillyParvin', scale, scale)
    centerX = (screenWidth - getProperty('phillyParvin.width')) * 0.5
    exitX = screenWidth + getProperty('phillyParvin.height')
    setProperty('phillyParvin.x', -getProperty('phillyParvin.width') - 20)
    setProperty('phillyParvin.y', (screenHeight - getProperty('phillyParvin.height')) * 0.5)
    setObjectCamera('phillyParvin', 'other')
    setProperty('phillyParvin.visible', false)
    setProperty('phillyParvin.active', false)
    addLuaSprite('phillyParvin', true)
end

local function updateParvin()
    if finished then return end
    shiftedStep = curDecStep - 1600 / stepCrochet
    if shiftedStep >= 155 then
        finished = true
        cancelTween('phillyParvinIn')
        setProperty('phillyParvin.angle', 360)
        setProperty('phillyParvin.x', exitX)
        setProperty('phillyParvin.visible', false)
        setProperty('phillyParvin.active', false)
        return
    end
    if shiftedStep >= 136 and not entered then
        entered = true
        setProperty('phillyParvin.visible', true)
        setProperty('phillyParvin.active', true)
        setObjectOrder('phillyParvin', getProperty('members.length') - 1)
        if luaSpriteExists('logo') then
            setObjectOrder('logo', getObjectOrder('phillyParvin') + 1)
        end
        setProperty('phillyParvin.angle', -14)
        doTweenAngle('phillyParvinLean', 'phillyParvin', 0, 0.3, 'quadOut')
        doTweenX('phillyParvinIn', 'phillyParvin', centerX, 0.23, 'quadOut')
    end
    if shiftedStep >= 151 then
        cancelTween('phillyParvinIn')
        local progress = math.max(0, math.min(1, (shiftedStep - 151) / 4))
        setProperty('phillyParvin.x', centerX + (exitX - centerX) * progress)
        setProperty('phillyParvin.angle', 360 * progress)
    end
end

function onStepHit()
    updateParvin()
end

function onUpdatePost(elapsed)
    updateParvin()
end

function onGameOverStart()
    finished = true
    cancelTween('phillyParvinIn')
    if luaSpriteExists('phillyParvin') then setProperty('phillyParvin.visible', false) end
end