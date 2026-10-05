

local inGameOver = false

local appliedTimeTxtStyle = false
local isSenpai = false
local logoEnterStep = 928
local logoExitStep = 987
local logoEntered = false
local logoExited = false
local HUD_START_ZOOM = 2.00
local HUD_ZOOM_IN_DURATION = 0.50


function onDestroy()
    debugPrint('SCRIPT DESTROYED')
end



function onSongStart()
    inGameOver = false

    doTweenZoom('hudZoomTween', 'camHUD', 1, HUD_ZOOM_IN_DURATION, 'quadOut')

    local downscroll = getPropertyFromClass('ClientPrefs', 'downScroll')
        baseTimeTxtY = 20 
    appliedTimeTxtStyle = false


    runHaxeCode([[
        if (game.timeTxt != null)
        {
            game.remove(game.timeTxt);
            game.insert(game.members.indexOf(game.getLuaObject("fahclock")) + 1, game.timeTxt);
        }
    ]]);
end

function onCountdownStarted()
    

    local offset = 350


    runTimer('setHUDZoom', 0.05)
end

function onCreatePost()
    setProperty('camHUD.zoom', HUD_START_ZOOM)
    baseTimeTxtX = getProperty('timeTxt.x')

    if luaSpriteExists('fahclock') then
        baseTimeBarX = getProperty('fahclock.x')
    else
        baseTimeBarX = 0
    end
    runTimer('applyTimeStyle', 0.1)

    runHaxeCode([[
        if (game != null && game.timeTxt != null)
        {
            game.timeTxt.color = 0xFF000000;
            game.timeTxt.antialiasing = true;
        }
    ]])

    if luaSpriteExists('dablack') then
        setObjectOrder('dablack', 0)
    end
end

function onCreate()

  local currentSong = string.lower(songPath or songName or ''):gsub('[%s_]+', '-')
  isSenpai = currentSong == 'senpai'
  if isSenpai then
    logoEnterStep = 1
    logoExitStep = 37
  end

  local logoAsset = isSenpai and 'fahmix/week6/senpai-logo'
    or 'fahmix/week6/roses-logo'



  makeLuaSprite('logo', logoAsset, 320, -550);
  setProperty('logo.flipX', getPropertyFromClass('MirrorMode', 'active'))
  scaleObject('logo', 0.6, 0.6);
  setObjectCamera('logo', 'other')
  addLuaSprite('logo', false);
  setProperty('fahclock.antialiasing', true)



   
   
  if not isSenpai then
    makeLuaSprite('dablack', 'dablack', 0, 0)
    setObjectCamera('dablack', 'hud')
    setProperty('dablack.alpha', 0)
    addLuaSprite('dablack', true)
  end

  makeLuaSprite('dawhite', 'dawhite', 0, 0)
  setObjectCamera('dawhite', 'other')
  setProperty('dawhite.alpha', 0)
  addLuaSprite('dawhite', true)



  local downscroll = getPropertyFromClass('ClientPrefs', 'downScroll')
  if downscroll then
        setProperty('scoreTxt.y', getProperty('healthBar.y') + 22)
  end
end

function onStepHit()


    if curStep >= logoEnterStep and not logoEntered then
      logoEntered = true
      doTweenY('logo', 'logo', (screenHeight - getProperty('logo.height')) * 0.5, 1, 'Quartout')
    end

    if curStep >= logoExitStep and not logoExited then
      logoExited = true
      doTweenX('logo2', 'logo.scale', 0, 0.4, 'quintIn')
      doTweenY('logo24', 'logo.scale', 0, 0.4, 'quintIn')
    end





    if not isSenpai and curStep == 782 then
        doTweenAlpha('dablack1', 'dablack', 1, 0.4, 'quadOut')
    end

    if not isSenpai and curStep == 789 then
        doTweenAlpha('dablack', 'dablack', 0, 0.2, 'quadIn')
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

     
     
     
    local gameOverSprites = {
        'peepee', 'rayray', 'fahlace', 'fahlace2', 'dance', 'hello',
        'trampoline', 'jumpyfah', 'jumpybf', 'logo',
        'dablack', 'dawhite'
    }

    for _, tag in ipairs(gameOverSprites) do
        if luaSpriteExists(tag) then
            setProperty(tag .. '.visible', false)
        end
    end

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

    setTextFont('timeTxt', 'pixfah.ttf')
    setProperty('timeTxt.borderSize', 0)
    setTextSize('timeTxt', 30)
end
