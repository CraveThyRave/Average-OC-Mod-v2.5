local shown = false
local finished = false
local startY = 0
local endY = 0

function onCreate()
    makeAnimatedLuaSprite('litUpSpring', 'fahmix/weekend1/spring', 0, 0)
    addAnimationByPrefix('litUpSpring', 'idle', 'spring idle', 6, true)
    playAnim('litUpSpring', 'idle', true)
    local scale = screenHeight * 0.8 / getProperty('litUpSpring.height')
    scaleObject('litUpSpring', scale, scale)
    setProperty('litUpSpring.x', (screenWidth - getProperty('litUpSpring.width')) * 0.5)
    startY = screenHeight + 20
    endY = -getProperty('litUpSpring.height') - 20
    setProperty('litUpSpring.y', startY)
    setObjectCamera('litUpSpring', 'other')
    setProperty('litUpSpring.visible', false)
    addLuaSprite('litUpSpring', true)
end

local function updateSpring()
    if finished then return end
    if curStep >= 308 then
        finished = true
        setProperty('litUpSpring.y', endY)
        setProperty('litUpSpring.visible', false)
        return
    end
    if curStep < 304 then return end
    if not shown then
        shown = true
        setProperty('litUpSpring.visible', true)
        setObjectOrder('litUpSpring', getProperty('members.length') - 1)
        if luaSpriteExists('logo') then
            setObjectOrder('logo', getObjectOrder('litUpSpring') + 1)
        end
    end
    local progress = math.max(0, math.min(1, (curDecStep - 304) / 4))
    setProperty('litUpSpring.y', startY + (endY - startY) * progress)
end

function onStepHit()
    updateSpring()
end

function onUpdatePost(elapsed)
    updateSpring()
end

function onGameOverStart()
    finished = true
    if luaSpriteExists('litUpSpring') then setProperty('litUpSpring.visible', false) end
end