local START_STEP = 143
local END_STEP = 399
local RESET_STEP = END_STEP + 1
local STEPS_PER_TILT = 4  
local ANGLE_AMOUNT = 8

local BLACKOUT_TAG = 'blehGunsBlackout'
local LOGO_TAG = 'blehSongLogo'
local SWAY_TWEEN_PREFIX = 'blehStrumSway'
local RESET_TWEEN_PREFIX = 'blehStrumReset'

local swayActive = false
local currentTargetAngle = 0
local nextSide = -1
local strumCount = 0
local defaultAngles = {}
local pullerControlled = {}
local baseTimeTxtX = 0
local baseClockX = 0
local lastMiddleScroll = nil

local function alignTimeTxtToClock()
    if not luaSpriteExists('fahclock') then
        return
    end

    setProperty('timeTxt.x', getProperty('fahclock.x')
        + (getProperty('fahclock.width') - getProperty('timeTxt.width')) * 0.5)
    setProperty('timeTxt.y', getProperty('fahclock.y')
        + (getProperty('fahclock.height') - getProperty('timeTxt.height')) * 0.5)
end

function onCreatePost()
    -- Bleh loads Pews' shared file dynamically, so that file's later callbacks
    -- are not retained by this engine build. Capture and own the same standard
    -- FAH layout here without adding a song-specific horizontal correction.
    baseTimeTxtX = getProperty('timeTxt.x')
    baseClockX = getProperty('fahclock.x')
end

local function playerLaneForStrum(index)
    if index < 4 or index > 7 then return nil end
    return index - 4
end

local function isPullerControlled(index)
    local lane = playerLaneForStrum(index)
    if lane == nil then return false end

    local controlled = getVar('pewStrumControlled' .. lane)
    if controlled ~= nil then return controlled == true end

     
    local defaultY = _G['defaultPlayerStrumY' .. lane]
    if defaultY == nil then return false end
    return math.abs(getPropertyFromGroup('strumLineNotes', index, 'y') - defaultY) > 0.5
end

local function tweenDuration()
    return math.max(0.08, (crochet / 1000) * 0.45)
end

local function tweenStrum(index, angle, easing, prefix)
    cancelTween(SWAY_TWEEN_PREFIX .. index)
    cancelTween(RESET_TWEEN_PREFIX .. index)
    noteTweenAngle(prefix .. index, index, angle, tweenDuration(), easing)
end

local function tiltToNextSide()
    currentTargetAngle = ANGLE_AMOUNT * nextSide
    nextSide = -nextSide

    for index = 0, strumCount - 1 do
        if not isPullerControlled(index) then
             
             
            tweenStrum(index, currentTargetAngle, 'backOut', SWAY_TWEEN_PREFIX)
        end
    end
end

function onCreate()
    makeLuaSprite(LOGO_TAG, 'fahmix/week7/bleh-logo', 320, -800)
    setProperty(LOGO_TAG .. '.flipX', getPropertyFromClass('MirrorMode', 'active'))
    scaleObject(LOGO_TAG, 0.47, 0.47)
    setObjectCamera(LOGO_TAG, 'other')
    addLuaSprite(LOGO_TAG, false)


    makeLuaSprite(BLACKOUT_TAG, 'dablack', 0, 0)
    setObjectCamera(BLACKOUT_TAG, 'other')
    setProperty(BLACKOUT_TAG .. '.scrollFactor.x', 0)
    setProperty(BLACKOUT_TAG .. '.scrollFactor.y', 0)
    setProperty(BLACKOUT_TAG .. '.alpha', 0)
    addLuaSprite(BLACKOUT_TAG, true)
end

function onSongStart()
     
     
    setProperty(LOGO_TAG .. '.visible', true)
    setProperty(LOGO_TAG .. '.y', -800)
    doTweenY('blehLogoIn', LOGO_TAG, (screenHeight - getProperty(LOGO_TAG .. '.height')) * 0.5, 1, 'Quartout')
end

function onCountdownStarted()
    strumCount = getProperty('strumLineNotes.length') or 8
    for index = 0, strumCount - 1 do
        defaultAngles[index] = getPropertyFromGroup('strumLineNotes', index, 'angle')
        pullerControlled[index] = isPullerControlled(index)
    end
end

function onStepHit()
    if curStep == 44 then
        doTweenX('blehLogoScaleX', LOGO_TAG .. '.scale', 0, 0.4, 'quintIn')
        doTweenY('blehLogoScaleY', LOGO_TAG .. '.scale', 0, 0.4, 'quintIn')
    end

    if curStep == START_STEP then
        swayActive = true
        nextSide = -1
        tiltToNextSide()
    elseif swayActive and curStep <= END_STEP
        and (curStep - START_STEP) % STEPS_PER_TILT == 0 then
        tiltToNextSide()
    elseif curStep == RESET_STEP then
        swayActive = false
        currentTargetAngle = 0
        for index = 0, strumCount - 1 do
            cancelTween(SWAY_TWEEN_PREFIX .. index)
            if not isPullerControlled(index) then
                tweenStrum(index, defaultAngles[index] or 0, 'quadOut', RESET_TWEEN_PREFIX)
            end
        end
    end

    if curStep == 908 then
        setProperty(BLACKOUT_TAG .. '.visible', true)
        setProperty(BLACKOUT_TAG .. '.alpha', 1)
    end
end

function onUpdatePost()
    local middleScroll = getPropertyFromClass('ClientPrefs', 'middleScroll')
    if middleScroll ~= lastMiddleScroll then
        lastMiddleScroll = middleScroll
        setProperty('timeTxt.x', baseTimeTxtX + (middleScroll and -285 or 38))
        setProperty('fahclock.x', baseClockX + (middleScroll and -320 or 0))
    end
    alignTimeTxtToClock()

    for index = 4, math.min(7, strumCount - 1) do
        local controlledNow = isPullerControlled(index)
        local controlledBefore = pullerControlled[index] == true

        if controlledNow and not controlledBefore then
             
             
            cancelTween(SWAY_TWEEN_PREFIX .. index)
            cancelTween(RESET_TWEEN_PREFIX .. index)
        elseif not controlledNow and controlledBefore then
            local returnAngle = swayActive and currentTargetAngle
                or (defaultAngles[index] or 0)
            tweenStrum(index, returnAngle, swayActive and 'backOut' or 'quadOut',
                swayActive and SWAY_TWEEN_PREFIX or RESET_TWEEN_PREFIX)
        end

        pullerControlled[index] = controlledNow
    end
end

function onGameOverStart()
    setProperty(BLACKOUT_TAG .. '.visible', false)
    setProperty(LOGO_TAG .. '.visible', false)
end
