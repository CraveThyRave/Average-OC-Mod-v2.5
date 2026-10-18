

local inGameOver = false

local appliedTimeTxtStyle = false


local scaredMoving = false

local scaredStartStep = 32
local scaredStopStep = 59


local scared1StartY = -300
local scared2StartY = 720


local scared1EndY = 720
local scared2EndY = -300


local scaredMoveTime = 0.45
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


    setProperty('camHUD.zoom', 2.0)

    runTimer('applyTimeStyle', 0.1)

    runHaxeCode([[
        if (game != null && game.timeTxt != null)
            game.timeTxt.color = 0xFF000000;
    ]])
end

function onCreate()





  makeLuaSprite('logo', 'fahmix/week2/spookeez-logo', 320, -500);
  setProperty('logo.flipX', getPropertyFromClass('MirrorMode', 'active'))
	scaleObject('logo', 0.3, 0.3);
	setObjectCamera('logo', 'other')
	addLuaSprite('logo', false);






  makeAnimatedLuaSprite('haha', 'fahmix/week2/haha', 1200, 940)
	addAnimationByPrefix('haha', 'idle', 'haha idle', 3, true)
	addLuaSprite('haha', true)
  setProperty('haha.alpha', 0)
	scaleObject('haha', 0.7, 0.7);



  makeLuaSprite('dablack', 'dablack', 0, 0)
  setObjectCamera('dablack', 'other')
  setProperty('dablack.alpha', 1)
  addLuaSprite('dablack', true)


  makeAnimatedLuaSprite('tot', 'fahmix/week2/ToT', 450, 100)
  addAnimationByPrefix('tot', 'idle', 'idle', 3, true)
  addLuaSprite('tot', true)
  setObjectCamera('tot', 'other')
  scaleObject('tot', 1, 1);
  setProperty('tot.alpha', 0)


  makeAnimatedLuaSprite('scared', 'fahmix/week2/scared', 160, -300)
  addAnimationByPrefix('scared', 'idle', 'idle', 3, true)
  addLuaSprite('scared', true)
  setObjectCamera('scared', 'other')
  scaleObject('scared', 0.57, 0.57);

  makeAnimatedLuaSprite('scared2', 'fahmix/week2/scared', 930, 720)
  addAnimationByPrefix('scared2', 'idle', 'idle', 3, true)
  addLuaSprite('scared2', true)
  setObjectCamera('scared2', 'other')
  scaleObject('scared2', 0.57, 0.57);





  makeAnimatedLuaSprite('tot', 'fahmix/week2/ToT', 450, 100)
  addAnimationByPrefix('tot', 'idle', 'idle', 3, true)
  addLuaSprite('tot', true)
  setObjectCamera('tot', 'other')
  scaleObject('tot', 1, 1);
  setProperty('tot.alpha', 0)



  makeAnimatedLuaSprite('cat', 'fahmix/week2/cat', -200, -300)
  addAnimationByPrefix('cat', 'idle', 'idle', 3, true)
  addLuaSprite('cat', true)
  setObjectCamera('cat', 'other')
  scaleObject('cat', 0.57, 0.57);



  makeLuaSprite('dawhite', 'dawhite', 0, 0)
  setObjectCamera('dawhite', 'other')
  setProperty('dawhite.alpha', 0)
  addLuaSprite('dawhite', true)



  makeAnimatedLuaSprite('break', 'fahmix/week2/break', 100, -400)
  addAnimationByPrefix('break', 'idle', 'idle', 3, true)
  addLuaSprite('break', true)
  setObjectCamera('break', 'other')
  scaleObject('break', 0.7, 0.7);
  setProperty('break.alpha', 1)



  makeAnimatedLuaSprite('it', 'fahmix/week2/it', 100, 800)
  addAnimationByPrefix('it', 'idle', 'idle', 3, true)
  addLuaSprite('it', true)
  setObjectCamera('it', 'other')
  scaleObject('it', 0.7, 0.7);
  setProperty('it.alpha', 1)


  makeAnimatedLuaSprite('down', 'fahmix/week2/down', 100, -400)
  addAnimationByPrefix('down', 'idle', 'idle', 3, true)
  addLuaSprite('down', true)
  setObjectCamera('down', 'other')
  scaleObject('down', 0.7, 0.7);
  setProperty('down.alpha', 1)



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

    
    
    

    if scaredMoving then
        
        if tag == 'scared1Move' then
            
            setProperty('scared.y', scared1StartY)

            
            doTweenY(
                'scared2Move',
                'scared2',
                scared2EndY,
                scaredMoveTime,
                'linear'
            )
        end

        
        if tag == 'scared2Move' then
            
            setProperty('scared2.y', scared2StartY)

            
            doTweenY(
                'scared1Move',
                'scared',
                scared1EndY,
                scaredMoveTime,
                'linear'
            )
        end
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



function onStepHit()


    
    if curStep == 378 then
        doTweenX('catMoveX', 'cat', 1210, 0.5, 'quadOut')
        doTweenY('catMoveY', 'cat', 630, 0.5, 'quadOut')
    end

    
    if curStep == 666 then
        doTweenX('catBackX', 'cat', -200, 0.2, 'quadIn')
        doTweenY('catBackY', 'cat', -300, 0.2, 'quadIn')
    end


    if curStep == 790 then
        doTweenY('break', 'break', 200, 0.2, 'quadIn')
    end

    if curStep == 793 then
        doTweenY('it', 'it', 200, 0.2, 'quadIn')
    end

    if curStep == 796 then
        doTweenY('down', 'down', 200, 0.2, 'quadIn')
    end


    if curStep == 799 then
        doTweenAlpha('break', 'break', 0, 0.3, 'quadIn')
        doTweenAlpha('it', 'it', 0, 0.3, 'quadIn')
        doTweenAlpha('down', 'down', 0, 0.3, 'quadIn')
    end


    if curStep == 667 then
        doTweenX('catMoveX', 'cat', 1210, 0.5, 'quadOut')
        doTweenY('catMoveY', 'cat', 630, 0.5, 'quadOut')
    end


    if curStep == 1305 then
      doTweenX('catBackX', 'cat', -200, 0.2, 'quadIn')
      doTweenY('catBackY', 'cat', -300, 0.2, 'quadIn')
    end



    if curStep == 32 then
        doTweenAlpha('dablack', 'dablack', 0.8, 0.2, 'quadIn')
    end

    if curStep == 41 then
        doTweenAlpha('dablack', 'dablack', 0.6, 0.2, 'quadIn')
    end

    if curStep == 48 then
        doTweenAlpha('dablack', 'dablack', 0.6, 0.2, 'quadIn')
    end

    if curStep == 52 then
        doTweenAlpha('dablack', 'dablack', 0.4, 0.2, 'quadIn')
    end


    if curStep == 59 then
        doTweenAlpha('dablack', 'dablack', 0, 0.2, 'quadIn')
        doTweenZoom('hudZoomBack', 'camHUD', 1.0, 0.5, 'quadOut')
    end



    if curStep == scaredStartStep then
        startScaredMovement()
    end

    if curStep == scaredStopStep then
        stopScaredMovement()
    end


    if curStep == 58 then
      doTweenY('tot', 'tot', 700, 0.5, 'Quartout')
    end


    if curStep == 15 then
        doTweenAlpha('tot', 'tot', 1, 0.4, 'quintIn')
    end


    if curStep == 512 then
      doTweenY('logo', 'logo', (screenHeight - getProperty('logo.height')) * 0.5, 1, 'Quartout')
    end

    if curStep == 543 then
      doTweenX('logo2', 'logo.scale', 0, 0.4, 'quintIn')
      doTweenY('logo24', 'logo.scale', 0, 0.4, 'quintIn')
    end


    if curStep == 155 then
      doTweenAlpha('haha1', 'haha', 1, 0.01, 'quadOut')
    end

    if curStep == 159 then
      doTweenAlpha('haha', 'haha', 0, 0.2, 'quadOut')
    end

    if curStep == 572 then
      doTweenAlpha('haha1', 'haha', 1, 0.01, 'quadOut')
    end

    if curStep == 575 then
      doTweenAlpha('haha', 'haha', 0, 0.2, 'quadOut')
    end



    if curStep == 1308 then
        doTweenAlpha('dablack', 'dablack', 1, 0.2, 'quadIn')
    end
end


function startScaredMovement()
    scaredMoving = true

    cancelTween('scared1Move')
    cancelTween('scared2Move')

    
    setProperty('scared.y', scared1StartY)
    setProperty('scared2.y', scared2StartY)

    
    doTweenY(
        'scared1Move',
        'scared',
        scared1EndY,
        scaredMoveTime,
        'linear'
    )
end

function stopScaredMovement()
    scaredMoving = false

    cancelTween('scared1Move')
    cancelTween('scared2Move')

    
    setProperty('scared.y', scared1StartY)
    setProperty('scared2.y', scared2StartY)
end
