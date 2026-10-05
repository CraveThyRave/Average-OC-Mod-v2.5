local shown = false
local finished = false

function onCreate()
    makeAnimatedLuaSprite('litUpBurger', 'fahmix/weekend1/burger', 0, 0)
    addAnimationByPrefix('litUpBurger', 'idle', 'burger idle', 6, true)
    playAnim('litUpBurger', 'idle', true)
    local scale = screenHeight * 0.8 / getProperty('litUpBurger.height')
    scaleObject('litUpBurger', scale, scale)
    setProperty('litUpBurger.x', (screenWidth - getProperty('litUpBurger.width')) * 0.5)
    setProperty('litUpBurger.y', (screenHeight - getProperty('litUpBurger.height')) * 0.5)
    setObjectCamera('litUpBurger', 'other')
    setProperty('litUpBurger.visible', false)
    addLuaSprite('litUpBurger', true)
end

local function updateBurger()
    if finished then return end
    if curStep >= 313 then
        finished = true
        setProperty('litUpBurger.visible', false)
        return
    end
    if curStep >= 308 and not shown then
        shown = true
        setProperty('litUpBurger.visible', true)
        setObjectOrder('litUpBurger', getProperty('members.length') - 1)
        if luaSpriteExists('logo') then
            setObjectOrder('logo', getObjectOrder('litUpBurger') + 1)
        end
    end
end

function onStepHit()
    updateBurger()
end

function onUpdatePost(elapsed)
    updateBurger()
end

function onGameOverStart()
    finished = true
    if luaSpriteExists('litUpBurger') then setProperty('litUpBurger.visible', false) end
end