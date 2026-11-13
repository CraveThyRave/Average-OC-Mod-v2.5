

local inGameOver = false
local baseTimeTxtX = 0
local baseClockX = 0
local lastMiddleScroll = nil
local hudPollElapsed = 0
local popperLeftBaseY = 0
local popperRightBaseY = 0
local popperStartStep = 27
local popperOffsets = {0, 33, 64, 96, 128}

local function shouldPop(step)
    if step < popperStartStep then return false end
    local cycleStep = (step - popperStartStep) % 160
    for _, offset in ipairs(popperOffsets) do
        if cycleStep == offset then return true end
    end
    return false
end

function onCreate()

    makeAnimatedLuaSprite('popperLeft', 'fahmix/week1/popper', 100, 600)
    addAnimationByPrefix('popperLeft', 'idle', 'popper idle', 3, true)
    setObjectCamera('popperLeft', 'other')
    scaleObject('popperLeft', 0.7, 0.7)
    scaleObject('popperLeft', 0.01, 0.01)
    addLuaSprite('popperLeft', false)
    popperLeftBaseY = getProperty('popperLeft.y')

    makeAnimatedLuaSprite('popperRight', 'fahmix/week1/popper', 1180, 600)
    addAnimationByPrefix('popperRight', 'idle', 'popper idle', 3, true)
    setObjectCamera('popperRight', 'other')
    setProperty('popperRight.flipX', true)
    scaleObject('popperRight', 0.7, 0.7)
    scaleObject('popperRight', 0.01, 0.01)
    addLuaSprite('popperRight', false)
    popperRightBaseY = getProperty('popperRight.y')
    makeLuaSprite('logo', 'fahmix/week1/bopeebo-logo', 320, -500);
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

    if getPropertyFromClass('ClientPrefs', 'downScroll') then
        setProperty('scoreTxt.y', getProperty('healthBar.y') - 55)
    end
end

function onCreatePost()
    baseTimeTxtX = getProperty('timeTxt.x')
    baseClockX = getProperty('fahclock.x')
    runHaxeCode([[if (game != null && game.timeTxt != null) game.timeTxt.color = 0xFF000000;]])
    setTextFont('timeTxt', 'fah.ttf')
    setProperty('timeTxt.borderSize', 0)
    setTextSize('timeTxt', 30)
end

function onUpdatePost(elapsed)
    hudPollElapsed = hudPollElapsed + elapsed
    if hudPollElapsed < 0.1 or inGameOver then return end
    hudPollElapsed = 0

    local middleScroll = getPropertyFromClass('ClientPrefs', 'middleScroll')
    if middleScroll ~= lastMiddleScroll then
        lastMiddleScroll = middleScroll
        setProperty('timeTxt.x', baseTimeTxtX + (middleScroll and -285 or 38))
        setProperty('fahclock.x', baseClockX + (middleScroll and -320 or 0))
    end



end

function onStepHit()

    if curStep == 384 then
      doTweenY('logo', 'logo', (screenHeight - getProperty('logo.height')) * 0.5, 1, 'Quartout')
    end

    if curStep == 400 then
      doTweenX('logo2', 'logo.scale', 0, 0.4, 'quintIn')
      doTweenY('logo24', 'logo.scale', 0, 0.4, 'quintIn')
    end
    if not shouldPop(curStep) then return end

    cancelTimer('hidePoppers')
    cancelTween('popperLeftOutScaleX')
    cancelTween('popperLeftOutScaleY')
    cancelTween('popperRightOutScaleX')
    cancelTween('popperRightOutScaleY')
    cancelTween('popperLeftOutY')
    cancelTween('popperRightOutY')

    setProperty('popperLeft.y', popperLeftBaseY)
    setProperty('popperRight.y', popperRightBaseY)

    doTweenX('popperLeftInScaleX', 'popperLeft.scale', 0.7, 0.18, 'backOut')
    doTweenY('popperLeftInScaleY', 'popperLeft.scale', 0.7, 0.18, 'backOut')
    doTweenX('popperRightInScaleX', 'popperRight.scale', 0.7, 0.18, 'backOut')
    doTweenY('popperRightInScaleY', 'popperRight.scale', 0.7, 0.18, 'backOut')
    runTimer('hidePoppers', 0.5)

end

function onTimerCompleted(tag)
    if tag ~= 'hidePoppers' then return end

    doTweenX('popperLeftOutScaleX', 'popperLeft.scale', 0.01, 0.32, 'backIn')
    doTweenY('popperLeftOutScaleY', 'popperLeft.scale', 0.01, 0.32, 'backIn')
    doTweenX('popperRightOutScaleX', 'popperRight.scale', 0.01, 0.32, 'backIn')
    doTweenY('popperRightOutScaleY', 'popperRight.scale', 0.01, 0.32, 'backIn')
    doTweenY('popperLeftOutY', 'popperLeft', popperLeftBaseY + 200, 0.32, 'quadIn')
    doTweenY('popperRightOutY', 'popperRight', popperRightBaseY + 200, 0.32, 'quadIn')
end

function onGameOverStart()
    inGameOver = true
    setProperty('fahclock.visible', false)
    setProperty('dablack.visible', false)
    setProperty('dawhite.visible', false)
end
