local lockX = 1750
local lockY = 750

local fogSpeed = 120
local carMoveTime = 6

local carStarts = {
    car1 = 400,
    car2 = -400,
    car3 = -900
}

function onCreate()
    makeAnimatedLuaSprite('paper', 'Freeplay-Chrs/fah/BG', 350, 50)
    addAnimationByPrefix('paper', 'idle', 'BG idle', 3, true)
    addLuaSprite('paper', false)
    scaleObject('paper', 1, 1)

    makeAnimatedLuaSprite('bg', 'fahmix/weekend1/bg', -200, -600)
    addAnimationByPrefix('bg', 'idle', 'idle', 6, true)
    addLuaSprite('bg', false)
    scaleObject('bg', 1.1, 1.1)

    makeAnimatedLuaSprite('fog1', 'fahmix/weekend1/fog', -200, 700)
    addAnimationByPrefix('fog1', 'idle', 'idle', 6, true)
    addLuaSprite('fog1', false)
    scaleObject('fog1', 0.9, 0.9)

    makeAnimatedLuaSprite('fog2', 'fahmix/weekend1/fog', -200, 700)
    addAnimationByPrefix('fog2', 'idle', 'idle', 6, true)
    addLuaSprite('fog2', false)
    scaleObject('fog2', 0.9, 0.9)

    updateHitbox('fog1')
    updateHitbox('fog2')

    local fogWidth = 3200
    local fogOverlap = 250
    setProperty('fog2.x', getProperty('fog1.x') + fogWidth - fogOverlap)

    makeAnimatedLuaSprite('car1', 'fahmix/weekend1/car1', 400, 650)
    addAnimationByPrefix('car1', 'idle', 'idle', 6, true)
    addLuaSprite('car1', false)
    scaleObject('car1', 1.1, 1.1)

    makeAnimatedLuaSprite('car2', 'fahmix/weekend1/car2', -400, 350)
    addAnimationByPrefix('car2', 'idle', 'idle', 6, true)
    addLuaSprite('car2', false)
    scaleObject('car2', 1.1, 1.1)

    makeAnimatedLuaSprite('car3', 'fahmix/weekend1/car3', -900, 400)
    addAnimationByPrefix('car3', 'idle', 'idle', 6, true)
    addLuaSprite('car3', false)
    scaleObject('car3', 1.1, 1.1)

    makeAnimatedLuaSprite('fore', 'fahmix/weekend1/fore', -200, -600)
    addAnimationByPrefix('fore', 'idle', 'idle', 6, true)
    addLuaSprite('fore', false)
    scaleObject('fore', 1.1, 1.1)

    makeAnimatedLuaSprite('rain', 'fahmix/weekend1/rain', -200, -200)
    addAnimationByPrefix('rain', 'idle', 'idle', 8, true)
    addLuaSprite('rain', true)
    scaleObject('rain', 1.2, 1.2)
    setObjectCamera('rain', 'camGame')

    runTimer('randomCar', 2)
end

function onCreatePost()
    setProperty('isCameraOnForcedPos', true)
    setProperty('camFollow.x', lockX)
    setProperty('camFollow.y', lockY)
    setProperty('camFollowPos.x', lockX)
    setProperty('camFollowPos.y', lockY)
end

function onUpdate(elapsed)
    local fogWidth = 3200
    local fogOverlap = 250

    setProperty('fog1.x', getProperty('fog1.x') - fogSpeed * elapsed)
    setProperty('fog2.x', getProperty('fog2.x') - fogSpeed * elapsed)

    if getProperty('fog1.x') + fogWidth <= 0 then
        setProperty('fog1.x', getProperty('fog2.x') + fogWidth - fogOverlap)
    end

    if getProperty('fog2.x') + fogWidth <= 0 then
        setProperty('fog2.x', getProperty('fog1.x') + fogWidth - fogOverlap)
    end
end

function startRandomCarTimer()
    runTimer('randomCar', getRandomFloat(10, 20))
end

function onTimerCompleted(tag)
    if tag == 'randomCar' then
        local cars = {'car1', 'car2', 'car3'}
        local chosen = cars[getRandomInt(1, #cars)]

        setProperty(chosen .. '.x', carStarts[chosen])
        doTweenX(chosen .. 'Drive', chosen, 2900, carMoveTime, 'linear')
        startRandomCarTimer()
    end
end
