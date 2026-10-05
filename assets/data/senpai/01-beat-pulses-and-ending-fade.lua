local STRONG_PULSE_START = 288
local STRONG_PULSE_END = 416
local SMALL_PULSE_START = 960
local SMALL_PULSE_END = 1055
local FADE_START = 1456
local FADE_END = 1472

local STRONG_NOTE_MULTIPLIER = 1.06
local SMALL_NOTE_MULTIPLIER = 1.035
local BLACK_TAG = 'senpaiEndingBlack'
local BLACK_TWEEN_TAG = 'senpaiEndingBlackFade'
local RECEPTOR_TEXTURE = 'Hud/senpai-fah-notes'
local RECEPTOR_FPS = 4
local RECEPTOR_PREFIXES = {
    {static = 'arrowLEFT', pressed = 'left press', confirm = 'left confirm'},
    {static = 'arrowDOWN', pressed = 'down press', confirm = 'down confirm'},
    {static = 'arrowUP', pressed = 'up press', confirm = 'up confirm'},
    {static = 'arrowRIGHT', pressed = 'right press', confirm = 'right confirm'}
}

local endingFadeStarted = false
local endingFadeFinished = false
local receptorCloneTags = {}
local receptorCloneAnimations = {}
local receptorOriginalVisibility = {}
local receptorClonesCreated = false
local receptorClonesActive = false
local pulseStartMultiplier = 1
local pulseDuration = 0
local pulseElapsed = 0
local pulseActive = false
local inGameOver = false

local function pulseMultiplierForStep(step)
    if step >= STRONG_PULSE_START and step <= STRONG_PULSE_END then
        return STRONG_NOTE_MULTIPLIER
    end
    if step >= SMALL_PULSE_START and step <= SMALL_PULSE_END then
        return SMALL_NOTE_MULTIPLIER
    end
    return nil
end

function onCreate()
     
    makeLuaSprite(BLACK_TAG, 'dablack', 0, 0)
    setObjectCamera(BLACK_TAG, 'other')
    setProperty(BLACK_TAG .. '.scrollFactor.x', 0)
    setProperty(BLACK_TAG .. '.scrollFactor.y', 0)
    setProperty(BLACK_TAG .. '.alpha', 0)
    addLuaSprite(BLACK_TAG, true)
end

local function placeReceptorClonesAtStrumLayer()
    local strumLayer = getObjectOrder('strumLineNotes')
    if strumLayer < 0 then return end

     
     
     
    local cloneLayer = strumLayer + 1
    for index = 0, 7 do
        if receptorCloneTags[index] ~= nil then
            setObjectOrder(receptorCloneTags[index], cloneLayer)
            cloneLayer = cloneLayer + 1
        end
    end
end

function onCountdownStarted()
    local receptorCount = getProperty('strumLineNotes.length')
    for index = 0, receptorCount - 1 do
        local lane = (index % 4) + 1
        local tag = 'senpaiPulseStrum' .. index
        local prefixes = RECEPTOR_PREFIXES[lane]
        receptorCloneTags[index] = tag

        makeAnimatedLuaSprite(tag, RECEPTOR_TEXTURE, 0, 0)
        addAnimationByPrefix(tag, 'static', prefixes.static, RECEPTOR_FPS, true)
        addAnimationByPrefix(tag, 'pressed', prefixes.pressed, RECEPTOR_FPS, false)
        addAnimationByPrefix(tag, 'confirm', prefixes.confirm, RECEPTOR_FPS, false)
        objectPlayAnimation(tag, 'static', true)
        setObjectCamera(tag, 'hud')
        setProperty(tag .. '.scrollFactor.x', 0)
        setProperty(tag .. '.scrollFactor.y', 0)
        setProperty(tag .. '.antialiasing', true)
        setProperty(tag .. '.visible', false)
        addLuaSprite(tag, true)
    end

    placeReceptorClonesAtStrumLayer()
    receptorClonesCreated = true
end

local function setReceptorCloneMode(active)
    if active == receptorClonesActive or not receptorClonesCreated then return end
    receptorClonesActive = active

    if active then placeReceptorClonesAtStrumLayer() end

    local receptorCount = getProperty('strumLineNotes.length')
    for index = 0, receptorCount - 1 do
        local tag = receptorCloneTags[index]
        if active then
            receptorOriginalVisibility[index] =
                getPropertyFromGroup('strumLineNotes', index, 'visible')
            setProperty(tag .. '.visible', receptorOriginalVisibility[index])
            setPropertyFromGroup('strumLineNotes', index, 'visible', false)
        else
            setProperty(tag .. '.visible', false)
            setPropertyFromGroup('strumLineNotes', index, 'visible',
                receptorOriginalVisibility[index] ~= false)
        end
    end
end

local function syncReceptorClones(multiplier)
    syncSenpaiReceptorClones(multiplier)
end

function onBeatHit()
    if inGameOver then return end
    local pulseMultiplier = pulseMultiplierForStep(curStep)
    if pulseMultiplier == nil then return end

    pulseStartMultiplier = pulseMultiplier
    pulseDuration = math.max(0.08, crochet * 0.00072)
    pulseElapsed = 0
    pulseActive = true
    setReceptorCloneMode(true)
    syncReceptorClones(pulseStartMultiplier)
end

function onUpdatePost(elapsed)
    if inGameOver then return end
    local inPulseSection = pulseMultiplierForStep(curStep) ~= nil
    if not inPulseSection then
        pulseActive = false
        setReceptorCloneMode(false)
        return
    end

    setReceptorCloneMode(true)

    local multiplier = 1
    if pulseActive then
        pulseElapsed = math.min(pulseDuration, pulseElapsed + elapsed)
        local progress = pulseElapsed / pulseDuration
        local easedProgress = 1 - (1 - progress) * (1 - progress)
        multiplier = pulseStartMultiplier
            + (1 - pulseStartMultiplier) * easedProgress

        if pulseElapsed >= pulseDuration then pulseActive = false end
    end
    syncReceptorClones(multiplier)
end

function onStepHit()
    if inGameOver then return end
    if curStep >= FADE_START and not endingFadeStarted then
        endingFadeStarted = true
        cancelTween(BLACK_TWEEN_TAG)
        setProperty(BLACK_TAG .. '.alpha', 0)
        setObjectOrder(BLACK_TAG, 99999)
        local fadeDuration = math.max(0.01,
            (FADE_END - FADE_START) * stepCrochet / 1000)
        doTweenAlpha(BLACK_TWEEN_TAG, BLACK_TAG, 1, fadeDuration, 'linear')
    end
    if curStep >= FADE_END and endingFadeStarted and not endingFadeFinished then
        endingFadeFinished = true
        cancelTween(BLACK_TWEEN_TAG)
        setProperty(BLACK_TAG .. '.alpha', 1)
    end
end

function onGameOverStart()
    inGameOver = true
    pulseActive = false
    receptorClonesActive = false
    for _, tag in pairs(receptorCloneTags) do
        if luaSpriteExists(tag) then
            setProperty(tag .. '.visible', false)
        end
    end
    cancelTween(BLACK_TWEEN_TAG)
    if luaSpriteExists(BLACK_TAG) then
        setProperty(BLACK_TAG .. '.visible', false)
    end
end

function onDestroy()
    if not inGameOver then
        setReceptorCloneMode(false)
    end
    cancelTween(BLACK_TWEEN_TAG)
end
