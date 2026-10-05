local inGameOver = false
local baseTimeTxtX = 0
local baseTimeBarX = 0
local lastMiddleScroll = nil

local LOGO_IN_STEP = 31
local LOGO_OUT_STEP = 46
local logoEntered = false
local logoExited = false

local function createTitleCards()

    makeLuaSprite('logo', 'fahmix/week4/undies-logo', 430, -500)
    setProperty('logo.flipX', getPropertyFromClass('MirrorMode', 'active'))
    scaleObject('logo', 0.47, 0.47)
    setObjectCamera('logo', 'other')
    setProperty('logo.visible', false)
    addLuaSprite('logo', true)
end

local function updateTitleCards()


    if not logoEntered and curStep >= LOGO_IN_STEP then
        logoEntered = true
        setProperty('logo.y', -500)
        setProperty('logo.alpha', 1)
        setProperty('logo.visible', true)
        scaleObject('logo', 0.47, 0.47)
        doTweenY('undiesLogoIn', 'logo', (screenHeight - getProperty('logo.height')) * 0.5, 1, 'quartOut')
    end

    if not logoExited and curStep >= LOGO_OUT_STEP then
        logoExited = true
        doTweenX('undiesLogoScaleX', 'logo.scale', 0, 0.4, 'quintIn')
        doTweenY('undiesLogoScaleY', 'logo.scale', 0, 0.4, 'quintIn')
    end
end

function onCreate()
    createTitleCards()

    makeLuaSprite('dablack', 'dablack', 0, 0)
    setObjectCamera('dablack', 'other')
    setProperty('dablack.alpha', 0)
    addLuaSprite('dablack', true)

    makeLuaSprite('dawhite', 'dawhite', 0, 0)
    setObjectCamera('dawhite', 'other')
    setProperty('dawhite.alpha', 0)
    addLuaSprite('dawhite', true)

    if getPropertyFromClass('ClientPrefs', 'downScroll') then
        setProperty('scoreTxt.y', getProperty('healthBar.y') - 55)
    end
end

function onCreatePost()
    baseTimeTxtX = getProperty('timeTxt.x')
    baseTimeBarX = getProperty('fahclock.x')
    runTimer('undiesApplyTimeStyle', 0.1)

    runHaxeCode([[
        if (game != null && game.timeTxt != null)
            game.timeTxt.color = 0xFF000000;
    ]])
end

function onCountdownStarted()
    runTimer('undiesApplyTimeStyle', 0.05)
end

function onSongStart()
    inGameOver = false
    lastMiddleScroll = nil
    updateTitleCards()
end

function onStepHit()
    updateTitleCards()
end

function onUpdatePost(elapsed)
    if inGameOver or not luaSpriteExists('fahclock') then return end
    updateTitleCards()

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
    if tag ~= 'undiesApplyTimeStyle' or inGameOver then return end
    setTextFont('timeTxt', 'fah.ttf')
    setProperty('timeTxt.borderSize', 0)
    setTextSize('timeTxt', 30)
end

function onGameOverStart()
    inGameOver = true
    for _, tag in ipairs({'logo', 'dablack', 'dawhite'}) do
        if luaSpriteExists(tag) then setProperty(tag .. '.visible', false) end
    end
    cancelTimer('undiesApplyTimeStyle')
    cancelTween('undiesLogoIn')
    cancelTween('undiesLogoScaleX')
    cancelTween('undiesLogoScaleY')
end
