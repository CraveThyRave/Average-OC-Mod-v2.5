

local inGameOver = false

local appliedTimeTxtStyle = false

local tutorialCameraZoom = 0.8


function onSongStart()
    inGameOver = false

    local downscroll = getPropertyFromClass('ClientPrefs', 'downScroll')
        baseTimeTxtY = 20 
    appliedTimeTxtStyle = false
end

function onCountdownStarted()
    

    local offset = 300


end

function onCreatePost()
    setProperty('defaultCamZoom', tutorialCameraZoom)
    setProperty('camGame.zoom', tutorialCameraZoom)
    baseTimeTxtX = getProperty('timeTxt.x')

    if luaSpriteExists('fahclock') then
        baseTimeBarX = getProperty('fahclock.x')
    else
        baseTimeBarX = 0
    end
    runHaxeCode([[
        if (game != null && game.timeTxt != null)
            game.timeTxt.color = 0xFF000000;
    ]])

    applyTimeTxtStyle()

    
    
    if getPropertyFromClass('ClientPrefs', 'middleScroll') then
        setProperty('timeTxt.x', baseTimeTxtX - 285)
        setProperty('fahclock.x', baseTimeBarX - 320)
    else
        setProperty('timeTxt.x', baseTimeTxtX + 38)
        setProperty('fahclock.x', baseTimeBarX)
    end
end

function onCreate()



  makeLuaSprite('logo', 'fahmix/week0/logo', 320, -500);
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
      setProperty('scoreTxt.y', getProperty('healthBar.y') + getProperty('healthBar.height') + 5)
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
    setProperty('logo.visible', false)
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

local function alignTimeTxtToClock()
    if not luaSpriteExists('fahclock') or getProperty('timeTxt') == nil then
        return
    end

    -- Other HUD scripts move and scale these independently. Use their final
    -- rendered bounds so the digits stay centered in the bow in every layout.
    setProperty('timeTxt.x', getProperty('fahclock.x')
        + (getProperty('fahclock.width') - getProperty('timeTxt.width')) * 0.5)
    setProperty('timeTxt.y', getProperty('fahclock.y')
        + (getProperty('fahclock.height') - getProperty('timeTxt.height')) * 0.5)
end

function onUpdatePost(elapsed)
    alignTimeTxtToClock()
end



function onStepHit()

    if curStep == 15 then
      doTweenY('logo', 'logo', (screenHeight - getProperty('logo.height')) * 0.5, 1, 'Quartout')
    end

    if curStep == 47 then
      doTweenX('logo2', 'logo.scale', 0, 0.9, 'quintIn')
      doTweenY('logo24', 'logo.scale', 0, 0.9, 'quintIn')
    end


end
