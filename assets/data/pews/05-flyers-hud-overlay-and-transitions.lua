

local inGameOver = false

local appliedTimeTxtStyle = false
local isBleh = false
local baseTimeTxtX = 0
local baseTimeBarX = 0



local flyerWindows = {
    {startStep = 640,  endStep = 704,  beatInterval = 3},
    {startStep = 895,  endStep = 960,  beatInterval = 2},
    {startStep = 1151, endStep = 1183, beatInterval = 3},
    {startStep = 1183, endStep = 1216, beatInterval = 2},
    {startStep = 1279, endStep = 1663, beatInterval = 1}
}
local flyerScale = 0.5
local flyerCount = 0
local flyerTweens = {}
local flyerPool = {}
local flyerActive = {}

local function createFlyer()
    flyerCount = flyerCount + 1

    local spriteTag = 'pewsFlyer' .. flyerCount
    makeAnimatedLuaSprite(spriteTag, 'fahmix/week7/flyers', 0, -1000)
    addAnimationByPrefix(spriteTag, 'idle', 'idle', 6, true)
    setObjectCamera(spriteTag, 'hud')
    scaleObject(spriteTag, flyerScale, flyerScale)
    addLuaSprite(spriteTag, false)
    setObjectOrder(spriteTag, 0)
    setProperty(spriteTag .. '.alpha', 0)

    flyerPool[#flyerPool + 1] = spriteTag
    flyerActive[spriteTag] = false
    return spriteTag
end

local function prepareFlyerPool()
    
    
    for i = 1, 8 do
        createFlyer()
    end
end

local function spawnFlyer()
    local spriteTag = nil
    for _, pooledTag in ipairs(flyerPool) do
        if not flyerActive[pooledTag] then
            spriteTag = pooledTag
            break
        end
    end

    
    
    
    if spriteTag == nil then
        spriteTag = createFlyer()
    end

    local tweenTag = spriteTag .. 'Move'
    local screenW = getPropertyFromClass('flixel.FlxG', 'width')
    local screenH = getPropertyFromClass('flixel.FlxG', 'height')

    local flyerW = getProperty(spriteTag .. '.width')
    local flyerH = getProperty(spriteTag .. '.height')
    local maxX = math.max(0, screenW - flyerW)

    
    setProperty(spriteTag .. '.x', getRandomFloat(0, maxX))
    setProperty(spriteTag .. '.y', screenH)
    setProperty(spriteTag .. '.alpha', 1)
    objectPlayAnimation(spriteTag, 'idle', true)

    flyerActive[spriteTag] = true
    flyerTweens[tweenTag] = spriteTag
    doTweenY(tweenTag, spriteTag, -flyerH, getRandomFloat(0.7, 1.2), 'linear')
end


function onDestroy()
    debugPrint('SCRIPT DESTROYED')
end



function onSongStart()
    inGameOver = false

    local downscroll = getPropertyFromClass('ClientPrefs', 'downScroll')
        baseTimeTxtY = 20
    appliedTimeTxtStyle = false
end

function onCountdownStarted()
    

    local offset = 300


    runTimer('setHUDZoom', 0.05)
end

function onCreatePost()
    baseTimeTxtX = getProperty('timeTxt.x')
    if luaSpriteExists('fahclock') then
        baseTimeBarX = getProperty('fahclock.x')
    else
        baseTimeBarX = 0
    end
     
     
     
    if isBleh and shadersEnabled then
        runHaxeCode([[game.restorePersistentSongCameraFilters();]])
    end
end

function onCreate()

  isBleh = string.lower(songName or ''):gsub('[%s_]+', '-') == 'bleh'

   
   
  if not isBleh then
    precacheImage('fahmix/week7/flyers')
    prepareFlyerPool()
  end



  if not isBleh then
    makeLuaSprite('logo', 'fahmix/week7/pews-logo', 320, -800);
    setProperty('logo.flipX', getPropertyFromClass('MirrorMode', 'active'))
	scaleObject('logo', 0.47, 0.47);
	setObjectCamera('logo', 'other')
	addLuaSprite('logo', false);
  end


  makeLuaSprite('dablack', 'dablack', 0, 0)
  setObjectCamera('dablack', 'other')
  setProperty('dablack.alpha', 0)
  addLuaSprite('dablack', true)

  if not isBleh then
  end

  makeLuaSprite('dawhite', 'dawhite', 0, 0)
  setObjectCamera('dawhite', 'other')
  setProperty('dawhite.alpha', 0)
  addLuaSprite('dawhite', true)



  local downscroll = getPropertyFromClass('ClientPrefs', 'downScroll')
  if downscroll then
      setProperty('scoreTxt.y', getProperty('healthBar.y') + getProperty('healthBar.height') + 5)
  end
end


function onTweenCompleted(tag)
    
    
    if flyerTweens[tag] ~= nil then
        local spriteTag = flyerTweens[tag]
        setProperty(spriteTag .. '.alpha', 0)
        setProperty(spriteTag .. '.y', -1000)
        flyerActive[spriteTag] = false
        flyerTweens[tag] = nil
        return
    end

    if inGameOver then
        return
    end

    if tag == 'dawhite' then
        runTimer('dawhite', 0.12)
    end
end

function onBeatHit()
    if inGameOver then
        return
    end

    if isBleh then
        return
    end

    for _, window in ipairs(flyerWindows) do
        if curStep >= window.startStep and curStep < window.endStep then
            
            local firstBeat = math.ceil(window.startStep / 4)
            if (curBeat - firstBeat) % window.beatInterval == 0 then
                spawnFlyer()
            end
            return
        end
    end
end


local lastMiddleScroll = nil
local lastTimeText = ''
local hudPollElapsed = 0

local function alignTimeTxtToClock()
    if not luaSpriteExists('fahclock') then
        return
    end

    -- Center the rendered text bounds in the rendered clock bounds. This stays
    -- correct for both Pews and Bleh, middle scroll, and either scroll direction.
    setProperty('timeTxt.x', getProperty('fahclock.x')
        + (getProperty('fahclock.width') - getProperty('timeTxt.width')) * 0.5)
    setProperty('timeTxt.y', getProperty('fahclock.y')
        + (getProperty('fahclock.height') - getProperty('timeTxt.height')) * 0.5)
end

function onUpdatePost(elapsed)
    hudPollElapsed = hudPollElapsed + elapsed
    if hudPollElapsed < 0.1 then return end
    hudPollElapsed = 0
    if inGameOver then
        return
    end

    if not luaSpriteExists('fahclock') then
        return
    end

    local middleScroll = getPropertyFromClass('ClientPrefs', 'middleScroll')

    if middleScroll ~= lastMiddleScroll then
        lastMiddleScroll = middleScroll

        if middleScroll then
            setProperty('timeTxt.x', baseTimeTxtX - 285)
            setProperty('fahclock.x', baseTimeBarX - 320)
        else
            setProperty('timeTxt.x', baseTimeTxtX + 38)
            setProperty('fahclock.x', baseTimeBarX)
        end
    end

    alignTimeTxtToClock()

end


function onTimerCompleted(tag)
    if tag == 'dawhite' then
        if not inGameOver then
            if luaSpriteExists('dawhite') then
                doTweenAlpha('dawhite', 'dawhite', 0, 0.3, 'quadInOut')
            end

            if luaSpriteExists('dablack') then
                setProperty('dablack.alpha', 1)
            end
        end
    end

    if tag == 'setHUDZoom' then
        if not inGameOver then
        end
    end

end
function onGameOverStart()
    inGameOver = true

    setProperty('peepee.visible', false)
    setProperty('rayray.visible', false)
    setProperty('fahlace.visible', false)
    setProperty('fahlace2.visible', false)
    setProperty('dance.visible', false)
    setProperty('hello.visible', false)
    setProperty('trampoline.visible', false)
    setProperty('jumpyfah.visible', false)
    setProperty('jumpybf.visible', false)
    if luaSpriteExists('logo') then
        setProperty('logo.visible', false)
    end
    setProperty('dablack.visible', false)
    setProperty('dawhite.visible', false)

    cancelTimer('dawhite')
    cancelTween('dawhite')
    cancelTween('whiteIn')
    cancelTween('whiteOut')
    cancelTween('clock')
    cancelTween('timeUp')
    cancelTween('timeDown')
    cancelTween('hudMoveUp')
    cancelTimer('setHUDZoom')
    cancelTween('hudZoomTween')
end



function onStepHit()

     
     
    if isBleh then
      return
    end



    if curStep == 112 then
      doTweenY('logo', 'logo', (screenHeight - getProperty('logo.height')) * 0.5, 1, 'Quartout')
    end

    if curStep == 140 then
      doTweenX('logo2', 'logo.scale', 0, 0.4, 'quintIn')
      doTweenY('logo24', 'logo.scale', 0, 0.4, 'quintIn')
    end


    if curStep == 2047 then
        doTweenAlpha('dablack', 'dablack', 1, 0.2, 'quadIn')
    end
end
