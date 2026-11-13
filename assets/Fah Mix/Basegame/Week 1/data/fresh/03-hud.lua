

local inGameOver = false

local appliedTimeTxtStyle = false


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
    runTimer('applyTimeStyle', 0.1)

    runHaxeCode([[
        if (game != null && game.timeTxt != null)
            game.timeTxt.color = 0xFF000000;
    ]])
end

function onCreate()





  makeLuaSprite('logo', 'fahmix/week1/fresh-logo', 320, -500);
  setProperty('logo.flipX', getPropertyFromClass('MirrorMode', 'active'))
	scaleObject('logo', 0.47, 0.47);
	setObjectCamera('logo', 'other')
	addLuaSprite('logo', false);


  makeLuaSprite('dablack', 'dablack', 0, 0)
  setObjectCamera('dablack', 'other')
  setProperty('dablack.alpha', 0)
  addLuaSprite('dablack', true)

  makeLuaSprite('dawhite', 'dawhite', 0, 0)
  setObjectCamera('dawhite', 'other')
  setProperty('dawhite.alpha', 0)
  addLuaSprite('dawhite', true)



  local downscroll = getPropertyFromClass('ClientPrefs', 'downScroll')
  if downscroll then
      setProperty('scoreTxt.y', getProperty('healthBar.y') - 55)
  end
end


function onTweenCompleted(tag)
    if inGameOver then
        return
    end

    if tag == 'dawhite' then
        runTimer('dawhite', 0.12)
    end
end


function onStepHit()


    if curStep == 64 then
      doTweenY('logo', 'logo', (screenHeight - getProperty('logo.height')) * 0.5, 1, 'Quartout')
    end

    if curStep == 85 then
      doTweenX('logo2', 'logo.scale', 0, 0.4, 'quintIn')
      doTweenY('logo24', 'logo.scale', 0, 0.4, 'quintIn')
    end


    if curStep == 892 then
        doTweenAlpha('dablack', 'dablack', 1, 0.2, 'quadIn')
    end
end






local lastMiddleScroll = nil
local lastTimeText = ''
local hudPollElapsed = 0

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

    if getProperty('timeTxt') == nil then
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

    if tag == 'applyTimeStyle' then
        if not inGameOver then
            applyTimeTxtStyle()
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
    setProperty('logo.visible', false)
    setProperty('dablack.visible', false)
    setProperty('dawhite.visible', false)

    cancelTimer('dawhite')
    cancelTimer('applyTimeStyle')

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


local timeFontLoaded = false

function applyTimeTxtStyle()
    if inGameOver then
        return
    end

    if getProperty('timeTxt') == nil then
        return
    end

    setTextFont('timeTxt', 'fah.ttf')
    setProperty('timeTxt.borderSize', 0)
    setTextSize('timeTxt', 30)
end
