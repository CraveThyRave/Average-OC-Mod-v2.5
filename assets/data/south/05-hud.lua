local inGameOver = false
local lastMiddleScroll = nil
local hudPollElapsed = 0
local baseTimeTxtX = 0
local baseTimeBarX = 0
local songStarted = false
local titleStartY = 0
local titleEndY = 0

function onCreate()
    makeLuaSprite('logo', 'fahmix/week2/south-logo', 0, 0)
    setProperty('logo.flipX', getPropertyFromClass('MirrorMode', 'active'))
    scaleObject('logo', 0.3, 0.3)
    setProperty('logo.x', (screenWidth - getProperty('logo.width')) * 0.5)
    titleStartY = -getProperty('logo.height') - 20
    titleEndY = (screenHeight - getProperty('logo.height')) * 0.5
    setProperty('logo.y', titleStartY)
    setObjectCamera('logo', 'other')
    addLuaSprite('logo', false)

    if getPropertyFromClass('ClientPrefs', 'downScroll') then
        setProperty('scoreTxt.y', getProperty('healthBar.y') - 55)
    end
end

function onCreatePost()
    baseTimeTxtX = getProperty('timeTxt.x')
    if luaSpriteExists('fahclock') then
        baseTimeBarX = getProperty('fahclock.x')
    end
    runTimer('applyTimeStyle', 0.1)
    runHaxeCode([[
        if (game != null && game.timeTxt != null)
            game.timeTxt.color = 0xFF000000;
    ]])
end

function onSongStart()
    inGameOver = false
    songStarted = true
end

function onTimerCompleted(tag)
    if inGameOver then return end
    if tag == 'applyTimeStyle' then
        if getProperty('timeTxt') ~= nil then
            setTextFont('timeTxt', 'fah.ttf')
            setProperty('timeTxt.borderSize', 0)
            setTextSize('timeTxt', 30)
        end
    end
end

function onUpdatePost(elapsed)
    if inGameOver then return end
    if songStarted then
        local position = getSongPosition()
        local titleAt = 383 * stepCrochet
        local entrance = math.max(0, math.min((position - titleAt) / 1000, 1))
        local exit = math.max(0, math.min((position - titleAt - 7600) / 400, 1))
        setProperty('logo.y', titleStartY + (titleEndY - titleStartY) * (1 - (1 - entrance) ^ 4))
        setProperty('logo.scale.x', 0.3 * (1 - exit ^ 5))
        setProperty('logo.scale.y', 0.3 * (1 - exit ^ 5))
        setProperty('logo.visible', position >= titleAt and position < titleAt + 8000)
    end
    hudPollElapsed = hudPollElapsed + elapsed
    if hudPollElapsed < 0.1 then return end
    hudPollElapsed = 0
    if not luaSpriteExists('fahclock') or getProperty('timeTxt') == nil then return end

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

function onGameOverStart()
    inGameOver = true
    setProperty('logo.visible', false)
    cancelTimer('applyTimeStyle')
end
