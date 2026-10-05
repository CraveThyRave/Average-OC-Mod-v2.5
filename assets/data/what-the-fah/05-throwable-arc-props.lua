

local arcTimeblue = 0
local arcDurationblue = 0.45
local startXblue = 0
local startYblue = 0
local movingblue = false
local spinAngleBlue = 0


local arcTimered = 0
local arcDurationred = 0.4
local startXred = 0
local startYred = 0
local movingred = false
local spinAngleRed = 0


local arcTimegreen = 0
local arcDurationgreen = 0.55
local startXgreen = 0
local startYgreen = 0
local movinggreen = false
local spinAngleGreen = 0


local arcTimesweater = 0
local arcDurationsweater = 0.67
local startXsweater = 0
local startYsweater = 0
local movingsweater = false
local spinAngleSweater = 0



function onCreate()
	makeAnimatedLuaSprite('blue-car', 'Freeplay-Chrs/fah/blue-car', 1200, 1200)
	addAnimationByPrefix('blue-car', 'idle', 'blue-car idle', 6, true)
	addLuaSprite('blue-car', true)
	scaleObject('blue-car', 0.5, 0.5);
	setProperty('blue-car.alpha', 1)
	setProperty('blue-car.active', false)

  makeAnimatedLuaSprite('red-car', 'Freeplay-Chrs/fah/red-car', 1200, 1200)
  addAnimationByPrefix('red-car', 'idle', 'red-car idle', 6, true)
  addLuaSprite('red-car', true)
  scaleObject('red-car', 0.5, 0.5);
  setProperty('red-car.alpha', 1)
  setProperty('red-car.active', false)

  makeAnimatedLuaSprite('green-car', 'Freeplay-Chrs/fah/green-car', 1200, 1200)
  addAnimationByPrefix('green-car', 'idle', 'green-car idle', 6, true)
  addLuaSprite('green-car', true)
  scaleObject('green-car', 0.5, 0.5);
  setProperty('green-car.alpha', 1)
  setProperty('green-car.active', false)


  makeAnimatedLuaSprite('sweater', 'Freeplay-Chrs/fah/sweater', 1200, 1200)
  addAnimationByPrefix('sweater', 'idle', 'sweater idle', 6, true)
  addLuaSprite('sweater', true)
  scaleObject('sweater', 0.5, 0.5);
  setProperty('sweater.alpha', 1)
  setProperty('sweater.active', false)


end

function startArcBlue()
	setProperty('blue-car.active', true)
    startXblue = getProperty('blue-car.x')
    startYblue = getProperty('blue-car.y')
    arcTimeblue = 0
    movingblue = true
end

function startArcRed()
	setProperty('red-car.active', true)
    startXred = getProperty('red-car.x')
    startYred = getProperty('red-car.y')
    arcTimered = 0
    movingred = true
end

function startArcGreen()
	setProperty('green-car.active', true)
    startXgreen = getProperty('green-car.x')
    startYgreen = getProperty('green-car.y')
    arcTimegreen = 0
    movinggreen = true
end

function startArcSweater()
	setProperty('sweater.active', true)
    startXsweater = getProperty('sweater.x')
    startYsweater = getProperty('sweater.y')
    arcTimesweater = 0
    movingsweater = true
end


function onStepHit()
    if curStep == 1701 then
        startArcBlue()
    end
    if curStep == 1708 then
        startArcSweater()
    end
    if curStep == 1710 then
        startArcRed()
    end
    if curStep == 1712 then
        startArcGreen()
    end
end

function onUpdate(elapsed)

    
    spinAngleBlue = spinAngleBlue + (600 * elapsed)
    spinAngleRed = spinAngleRed + (500 * elapsed)
    spinAngleGreen = spinAngleGreen + (1000 * elapsed)
    spinAngleSweater = spinAngleSweater + (200 * elapsed)

    
    if movingblue then
        arcTimeblue = arcTimeblue + elapsed
        local t = arcTimeblue / arcDurationblue

        if t >= 1 then
            movingblue = false
			setProperty('blue-car.active', false)
        else
            setProperty('blue-car.x', startXblue - (430 * t))
            local height = math.sin(t * math.pi) * 400
            setProperty('blue-car.y', startYblue - height)

            local tilt = t * 50
            setProperty('blue-car.angle', spinAngleBlue + tilt)
        end
    end

    
    if movingred then
        arcTimered = arcTimered + elapsed
        local t = arcTimered / arcDurationred

        if t >= 1 then
            movingred = false
			setProperty('red-car.active', false)
        else
            setProperty('red-car.x', startXred - (400 * t))
            local height = math.sin(t * math.pi) * 480
            setProperty('red-car.y', startYred - height)

            local tilt = t * 50
            setProperty('red-car.angle', spinAngleRed + tilt)
        end
    end

    
    if movinggreen then
        arcTimegreen = arcTimegreen + elapsed
        local t = arcTimegreen / arcDurationgreen

        if t >= 1 then
            movinggreen = false
			setProperty('green-car.active', false)
        else
            setProperty('green-car.x', startXgreen - (500 * t))
            local height = math.sin(t * math.pi) * 500
            setProperty('green-car.y', startYgreen - height)

            local tilt = t * 50
            setProperty('green-car.angle', spinAngleGreen + tilt)
        end
    end

    
    if movingsweater then
        arcTimesweater = arcTimesweater + elapsed
        local t = arcTimesweater / arcDurationsweater

        if t >= 1 then
            movingsweater = false
			setProperty('sweater.active', false)
        else
            setProperty('sweater.x', startXsweater - (370 * t))
            local height = math.sin(t * math.pi) * 350
            setProperty('sweater.y', startYsweater - height)

            local tilt = t * 50
            setProperty('sweater.angle', spinAngleSweater + tilt)
        end
    end
end
