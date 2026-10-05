
local minX = 0
local maxX = 1000
local groundY = 700
local jumpHeight = 350
local baseY = 0
local startedBop = false
local beatTime = 0
local skipNextBeat = false

local truckSpritesByTimer = {
  truck1 = 'trucker1',
  truck2 = 'trucker2',
  truck3 = 'trucker3',
  truck4 = 'trucker4'
}
local truckSpawnSteps = {929, 993, 1056, 1121}
local activeTrucks = {}
local activeTruckCount = 0
local truckAchievementLeewayMs = 1500
local truckAchievementEligibleUntil = -1
local truckAchievementWindowActive = false
local lastTruckWindowStep = -1
local upcomingTruck = false
local hiPopupSteps = {
  [647] = 'hi1',
  [664] = 'hi2',
  [681] = 'hi3',
  [696] = 'hi4',
  [712] = 'hi5',
  [729] = 'hi6',
  [746] = 'hi7',
  [761] = 'hi8',
  [776] = 'hi9',
  [793] = 'hi10',
  [810] = 'hi11',
  [825] = 'hi12',
  [841] = 'hi13',
  [857] = 'hi14',
  [872] = 'hi15',
  [889] = 'hi16'
}

local function setTruckAchievementWindow(active)
  if truckAchievementWindowActive == active then return end
  truckAchievementWindowActive = active
  setVar('whatTheFahTruckDistractionActive', active)
end

local function beginTruckDistraction(timerTag)
  if activeTrucks[timerTag] then return end
  activeTrucks[timerTag] = true
  activeTruckCount = activeTruckCount + 1
  setTruckAchievementWindow(true)
end


function onCreate()
  setVar('whatTheFahTruckDistractionActive', false)


  makeAnimatedLuaSprite('trucker1', 'Freeplay-Chrs/fah/distractions/trucker', 1220, -200)
  addAnimationByPrefix('trucker1', 'idle', 'trucker iidle', 3, true)
  setObjectCamera('trucker1', 'other')
  scaleObject('trucker1', 0.93, 0.93);
  setProperty('trucker1.angle', -20)



  makeAnimatedLuaSprite('trucker2', 'Freeplay-Chrs/fah/distractions/trucker', -730, 300)
  addAnimationByPrefix('trucker2', 'idle', 'trucker iidle', 3, true)
  setObjectCamera('trucker2', 'other')
  scaleObject('trucker2', 0.93, 0.93);
  setProperty('trucker2.flipX', true)
  setProperty('trucker2.angle', -7)


  makeAnimatedLuaSprite('trucker3', 'Freeplay-Chrs/fah/distractions/trucker', 1295, 350)
  addAnimationByPrefix('trucker3', 'idle', 'trucker iidle', 3, true)
  setObjectCamera('trucker3', 'other')
  scaleObject('trucker3', 0.93, 0.93);
  setProperty('trucker3.angle', 25)


  makeAnimatedLuaSprite('trucker4', 'Freeplay-Chrs/fah/distractions/trucker', -120, -580)
  addAnimationByPrefix('trucker4', 'idle', 'trucker iidle', 3, true)
  setObjectCamera('trucker4', 'other')
  scaleObject('trucker4', 0.93, 0.93);
  setProperty('trucker4.angle', 60)
  setProperty('trucker4.flipX', true)


  makeLuaSprite('spinny', 'Freeplay-Chrs/fah/distractions/spinny', -380, -380);
	addLuaSprite('spinny', false);
	scaleObject('spinny', 1, 1);
  setObjectCamera('spinny', 'other')
  setProperty('spinny.angularVelocity', 350)


  makeLuaSprite('spinny2', 'Freeplay-Chrs/fah/distractions/spinny', 1300, -380);
	addLuaSprite('spinny2', false);
	scaleObject('spinny2', 1, 1);
  setObjectCamera('spinny2', 'other')
  setProperty('spinny2.angularVelocity', 350)


  makeLuaSprite('spinny3', 'Freeplay-Chrs/fah/distractions/spinny', -230, 720);
  addLuaSprite('spinny3', false);
  scaleObject('spinny3', 1, 1);
  setObjectCamera('spinny3', 'other')
  setProperty('spinny3.angularVelocity', 350)




  makeAnimatedLuaSprite('roar', 'Freeplay-Chrs/fah/overlay/tiger-roar', -20, 0)
	addAnimationByPrefix('roar', 'idle', 'tiger-roar hi', 14, true)
	addLuaSprite('roar', false)
	scaleObject('roar', 0.88, 0.88);
	setObjectCamera('roar', 'other')
	setProperty('roar.visible', false)
	setProperty('roar.active', false)




  makeAnimatedLuaSprite('people-chain', 'Freeplay-Chrs/fah/people-chain', 555, 130)
	addAnimationByPrefix('people-chain', 'idle', 'people-chain idle', 6, true)
	addLuaSprite('people-chain', false)
	scaleObject('people-chain', 0.45, 0.45);

  baseY = getProperty('people-chain.y')
  beatTime = crochet / 1000



  setProperty('people-chain.y', baseY - 400)

end



function onStepHit()

    if curStep == 124 then
      characterPlayAnim('dad', 'yell', true)
    end


    if curStep == 1719 then
      doTweenY('introDrop', 'people-chain', baseY, 0.5, 'quadIn')
	  setProperty('roar.active', true)
      setProperty('roar.visible', true)
      setProperty('roar.animation.curAnim.curFrame', 0)
      runTimer('roar', 0.65)
    end



    if curStep == 1726 then
      triggerEvent('Change Character', 'dad', 'fah-tiger')
    end


    if curStep == 2240 then
        startedBop = false 
        cancelTween('pcUp')
        cancelTween('pcDown')
        doTweenY('chainBackUp', 'people-chain', baseY - 400, 0.6, 'quadOut')
    end


    if curStep == 929 then
      beginTruckDistraction('truck1')
      addLuaSprite('trucker1', false)
      doTweenX('trucker', 'trucker1', -530, 3.2, 'linear')
      doTweenY('truckerY', 'trucker1', 830, 3.2, 'linear')
      runTimer('truck1', 3.2)
    end

    if curStep == 993 then
      beginTruckDistraction('truck2')
      addLuaSprite('trucker2', false)
      doTweenX('trucker2', 'trucker2', 1300, 5.5, 'linear')
      doTweenY('trucker2Y', 'trucker2', -50, 5.5, 'linear')
      runTimer('truck2', 5.5)
    end

    if curStep == 1056 then
      beginTruckDistraction('truck3')
      addLuaSprite('trucker3', false)
      doTweenX('trucker3', 'trucker3', -730, 4, 'linear')
      doTweenY('trucker3Y', 'trucker3', -230, 4, 'linear')
      runTimer('truck3', 4)
    end


    if curStep == 1121 then
      beginTruckDistraction('truck4')
      addLuaSprite('trucker4', false)
      doTweenY('trucker4Y', 'trucker4', 940, 2.5, 'linear')
      doTweenX('trucker4', 'trucker4', 470, 2.5, 'linear')
      runTimer('truck4', 2.5)
      addLuaSprite('trucker4', false)

    end


    if curStep == 1151 then
      doTweenX('spinny2', 'spinny2', -1200, 1.2, 'quintOut')
      doTweenY('spinny2Y', 'spinny2', 1100, 1.2, 'quintOut')
      characterPlayAnim('dad', 'yell', true)
    end

    if curStep == 1152 then
      characterPlayAnim('dad', 'yell', true)
    end

    if curStep == 377 then
      doTweenX('spinny3', 'spinny3', 1300, 1.2, 'quintOut')
      doTweenY('spinny3Y', 'spinny3', -300, 1.2, 'quintOut')
    end

    if curStep == 375 then
      characterPlayAnim('dad', 'yell', true)
    end



    local hiTag = hiPopupSteps[curStep]
    if hiTag ~= nil then
        spawnHi(hiTag)
    end

end


function onUpdate(elapsed)
    local songPosition = getSongPosition()
    if curStep ~= lastTruckWindowStep then
      lastTruckWindowStep = curStep
      upcomingTruck = false
      local millisecondsPerStep = stepCrochet or 0
      if millisecondsPerStep > 0 then
        for _, spawnStep in ipairs(truckSpawnSteps) do
          local stepsUntilSpawn = spawnStep - curStep
          if stepsUntilSpawn >= 0 and stepsUntilSpawn * millisecondsPerStep <= truckAchievementLeewayMs then
            upcomingTruck = true
            break
          end
        end
      end
    end

    setTruckAchievementWindow(
      activeTruckCount > 0
      or songPosition <= truckAchievementEligibleUntil
      or upcomingTruck
    )
end

function spawnHi(tag)
    local randX = getRandomInt(minX, maxX)

    makeAnimatedLuaSprite(tag, 'Freeplay-Chrs/fah/distractions/hi', randX, groundY)

    addAnimationByPrefix(tag, 'idle', 'hi idle', 4, true)
    setObjectCamera(tag, 'other')
    addLuaSprite(tag, true)

    playAnim(tag, 'idle', true)

    
    doTweenY(tag..'_up', tag, groundY - jumpHeight, 0.3, 'quadOut')

end

function onBeatHit()
    if not startedBop then return end
    if skipNextBeat then
        skipNextBeat = false
        return
    end

    doTweenY('pcUp', 'people-chain', baseY - 100, beatTime * 0.25, 'quadOut')
end

function onTweenCompleted(tag)
    if string.find(tag, '_up') then
        local spr = string.gsub(tag, '_up', '')
        doTweenY(spr..'_down', spr, groundY, 0.4, 'quadIn')

    elseif string.find(tag, '_down') then
        local spr = string.gsub(tag, '_down', '')
        removeLuaSprite(spr, true)
    end

    if tag == 'introDrop' then
        startedBop = true

        
        doTweenY('pcUp', 'people-chain', baseY - 100, beatTime * 0.25, 'quadOut')

    elseif tag == 'pcUp' then
        doTweenY('pcDown', 'people-chain', baseY, beatTime * 0.75, 'quadIn')
    end
end

function onTimerCompleted(tag)
    local truckSprite = truckSpritesByTimer[tag]
    if truckSprite ~= nil then
        removeLuaSprite(truckSprite, true)
        if activeTrucks[tag] then
            activeTrucks[tag] = nil
            activeTruckCount = math.max(0, activeTruckCount - 1)
            if activeTruckCount == 0 then
                truckAchievementEligibleUntil = getSongPosition() + truckAchievementLeewayMs
            end
        end
    elseif tag == 'bounceDown' then
        doTweenY('bounceDownTween', 'blue-car', baseY, 0.1, 'quadIn')
    elseif tag == 'roar' then
        setProperty('roar.visible', false)
		setProperty('roar.active', false)
    end
end

function onDestroy()
    setVar('whatTheFahTruckDistractionActive', false)
end
