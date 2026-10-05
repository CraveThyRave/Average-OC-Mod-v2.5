-- Exact script replacement for Eggnog's former Biter events.json entries.
-- The dense 200 ms sequence is generated mathematically instead of storing
-- 279 event objects, and the former custom-event behavior is inlined here.

local GRID_FIRST_MS = 0
local GRID_LAST_MS = 63800
local GRID_INTERVAL_MS = 200
local STEP_INTERVAL_MS = 100
local GRID_SKIP_REMAINDER = 200
local GRID_PERIOD_MS = 1600
local EXTRA_GAP_FIRST_MS = 25000
local EXTRA_GAP_LAST_MS = 25400
local DOUBLE_SPAWN_MS = 51200
local FINAL_SPAWN_MS = 89100

local BITER_TYPES = {
    {
        asset = 'fahmix/week5/biters/fah-bite',
        bitePrefix = 'fah-bite bite',
        idlePrefix = 'fah-bite idle',
        biteFrames = 4
    },
    {
        asset = 'fahmix/week5/biters/dad-bite',
        bitePrefix = 'dad-bite eat',
        idlePrefix = 'dad-bite idle',
        biteFrames = 3
    },
    {
        asset = 'fahmix/week5/biters/mom-bite',
        bitePrefix = 'mom-bite bite',
        idlePrefix = 'mom-bite idle',
        biteFrames = 3
    }
}

local COPIES_PER_TYPE = 4
local BITER_SCALE = 0.30
local BITE_FPS = 8
local IDLE_FPS = 8
local FIRST_FRAME_HOLD = 0.20
local ENTER_DURATION = 0.06
local EXIT_DURATION = 0.22
local SCREEN_MARGIN_Y = 8
local SCREEN_EDGE_HIDDEN_RATIO = 0.18
local PLACEMENT_CANDIDATES_PER_SIDE = 8
local MAX_OVERLAP_RATIO = 0.10
local GOLDEN_RATIO_FRACTION = 0.61803398875

local nextGridTime = GRID_FIRST_MS
local finalSpawned = false
local noteOffset = 0
local biters = {}
local holdTimerIndices = {}
local biteTimerIndices = {}
local exitTweenIndices = {}

local function timerTag(kind, index)
    return 'biterEvent' .. kind .. index
end

local function tweenTag(kind, index)
    return 'biterEvent' .. kind .. index
end

local function cancelBiterMotion(index)
    cancelTimer(timerTag('Hold', index))
    cancelTimer(timerTag('BiteDone', index))
    cancelTween(tweenTag('Enter', index))
    cancelTween(tweenTag('Exit', index))
end

local function releaseBiter(index, cancelMotion)
    local biter = biters[index]
    if biter == nil then return end

    if cancelMotion ~= false then cancelBiterMotion(index) end
    biter.active = false
    biter.lane = 0
    setProperty(biter.tag .. '.active', false)
    setProperty(biter.tag .. '.visible', false)
    setProperty(biter.tag .. '.y', -9999)
end

local function overlapRatio(x, y, width, height, other)
    local overlapWidth = math.max(0, math.min(x + width, other.onscreenX + other.width)
        - math.max(x, other.onscreenX))
    local overlapHeight = math.max(0, math.min(y + height, other.y + other.height)
        - math.max(y, other.y))
    if overlapWidth <= 0 or overlapHeight <= 0 then return 0 end
    return (overlapWidth * overlapHeight) / math.min(width * height, other.width * other.height)
end

local function placementOverlap(fromRight, x, y, width, height)
    local worst = 0
    for _, other in ipairs(biters) do
        if other.active and other.fromRight == fromRight then
            worst = math.max(worst, overlapRatio(x, y, width, height, other))
        end
    end
    return worst
end

local function chooseAvailablePlacement(width, height)
    local maxY = math.max(SCREEN_MARGIN_Y, screenHeight - SCREEN_MARGIN_Y - height)
    local availableHeight = maxY - SCREEN_MARGIN_Y
    local firstSide = getRandomBool()
    local phase = getRandomFloat(0, 1)
    local firstY = SCREEN_MARGIN_Y + availableHeight * phase
    local firstX = firstSide
        and (screenWidth - width * (1 - SCREEN_EDGE_HIDDEN_RATIO))
        or (-width * SCREEN_EDGE_HIDDEN_RATIO)
    local firstOverlap = placementOverlap(firstSide, firstX, firstY, width, height)
    if firstOverlap <= MAX_OVERLAP_RATIO then return firstSide, firstY end

    local bestSide, bestY, bestOverlap = firstSide, firstY, firstOverlap

    -- Crossing from Lua into Haxe for every random attempt was the expensive
    -- part of this dense sequence. Preserve the first uniformly-random choice,
    -- then score a bounded set of evenly-distributed local candidates.
    for sidePass = 0, 1 do
        local fromRight = sidePass == 0 and firstSide or not firstSide
        local x = fromRight
            and (screenWidth - width * (1 - SCREEN_EDGE_HIDDEN_RATIO))
            or (-width * SCREEN_EDGE_HIDDEN_RATIO)
        for candidate = 1, PLACEMENT_CANDIDATES_PER_SIDE do
            local fraction = (phase + candidate * GOLDEN_RATIO_FRACTION) % 1
            local y = SCREEN_MARGIN_Y + availableHeight * fraction
            local overlap = placementOverlap(fromRight, x, y, width, height)
            if overlap < bestOverlap then
                bestSide, bestY, bestOverlap = fromRight, y, overlap
            end
            if overlap <= MAX_OVERLAP_RATIO then return fromRight, y end
        end
    end

    return bestSide, bestY
end

local function createBiter(typeIndex)
    local biterType = BITER_TYPES[typeIndex]
    local index = #biters + 1
    local tag = 'biterEventSprite' .. index
    local holdTag = timerTag('Hold', index)
    local biteTag = timerTag('BiteDone', index)
    local exitTag = tweenTag('Exit', index)

    makeAnimatedLuaSprite(tag, biterType.asset, -9999, -9999)
    addAnimationByPrefix(tag, 'bite', biterType.bitePrefix, BITE_FPS, false)
    addAnimationByPrefix(tag, 'idle', biterType.idlePrefix, IDLE_FPS, true)
    scaleObject(tag, BITER_SCALE, BITER_SCALE)
    setObjectCamera(tag, 'other')
    setProperty(tag .. '.active', false)
    setProperty(tag .. '.visible', false)
    addLuaSprite(tag, true)

    biters[index] = {
        tag = tag,
        typeIndex = typeIndex,
        active = false,
        width = tonumber(getProperty(tag .. '.width')) or 1,
        height = tonumber(getProperty(tag .. '.height')) or 1,
        biteDuration = biterType.biteFrames / BITE_FPS,
        fromRight = false,
        y = -9999,
        onscreenX = 0,
        holdTag = holdTag,
        biteTag = biteTag,
        exitTag = exitTag
    }
    holdTimerIndices[holdTag] = index
    biteTimerIndices[biteTag] = index
    exitTweenIndices[exitTag] = index
    return index
end

local function acquireBiter(typeIndex)
    for index, biter in ipairs(biters) do
        if not biter.active and biter.typeIndex == typeIndex then return index end
    end
    return createBiter(typeIndex)
end

local function spawnBiter()
    local poolIndex = acquireBiter(getRandomInt(1, #BITER_TYPES))
    local biter = biters[poolIndex]
    local fromRight, y = chooseAvailablePlacement(biter.width, biter.height)

    local offscreenX = fromRight and (screenWidth + 24) or (-biter.width - 24)
    local onscreenX = fromRight
        and (screenWidth - biter.width * (1 - SCREEN_EDGE_HIDDEN_RATIO))
        or (-biter.width * SCREEN_EDGE_HIDDEN_RATIO)

    biter.active = true
    biter.fromRight = fromRight
    biter.y = y
    biter.onscreenX = onscreenX
    setProperty(biter.tag .. '.active', true)
    setProperty(biter.tag .. '.visible', true)
    setProperty(biter.tag .. '.flipX', fromRight)
    setProperty(biter.tag .. '.x', offscreenX)
    setProperty(biter.tag .. '.y', y)

    playAnim(biter.tag, 'bite', true)
    setProperty(biter.tag .. '.animation.curAnim.curFrame', 0)
    setProperty(biter.tag .. '.animation.curAnim.paused', true)
    doTweenX(tweenTag('Enter', poolIndex), biter.tag, biter.onscreenX,
        ENTER_DURATION, 'quadOut')
    runTimer(biter.holdTag, FIRST_FRAME_HOLD)
end

local function isScheduledGridTime(time)
    return time % GRID_PERIOD_MS ~= GRID_SKIP_REMAINDER
        and (time < EXTRA_GAP_FIRST_MS or time > EXTRA_GAP_LAST_MS)
end

local function processTimeline(songTime)
    if songTime == nil then songTime = getSongPosition() end

    -- checkEventNote() also drains every crossed timestamp in one frame. This
    -- loop preserves that behavior after a lag spike or an intentional seek.
    while nextGridTime <= GRID_LAST_MS
        and songTime >= nextGridTime + noteOffset do
        local eventTime = nextGridTime
        nextGridTime = nextGridTime + GRID_INTERVAL_MS
        if isScheduledGridTime(eventTime) then
            spawnBiter()
            if eventTime == DOUBLE_SPAWN_MS then spawnBiter() end
        end
    end

    if not finalSpawned and songTime >= FINAL_SPAWN_MS + noteOffset then
        finalSpawned = true
        spawnBiter()
    end
end

local function processOffsetTimeline()
    processTimeline()
end

local function clearBiters()
    for index = 1, #biters do releaseBiter(index) end
end

function onCreate()
    noteOffset = tonumber(getPropertyFromClass('ClientPrefs', 'noteOffset')) or 0
    if noteOffset ~= 0 then _G.onUpdatePost = processOffsetTimeline end
    for _, biterType in ipairs(BITER_TYPES) do precacheImage(biterType.asset) end
    for typeIndex = 1, #BITER_TYPES do
        for copyIndex = 1, COPIES_PER_TYPE do createBiter(typeIndex) end
    end
end

function onStepHit()
    -- Eggnog is a fixed 150 BPM chart, so every step is exactly 100 ms and
    -- every authored Biter timestamp falls on a step. Avoid polling across
    -- the Lua/Haxe boundary every rendered frame when no note offset is used.
    if noteOffset == 0 then processTimeline(curStep * STEP_INTERVAL_MS) end
end

function onSongStart()
    -- The removed 1.6-second section placed the first authored spawn at the
    -- new zero point. Fire it at audio start rather than one step late.
    if noteOffset == 0 then processTimeline(0) end
end

function onTimerCompleted(tag)
    local index = holdTimerIndices[tag]
    if index ~= nil then
        local biter = biters[index]
        if biter ~= nil and biter.active then
            playAnim(biter.tag, 'bite', true)
            runTimer(biter.biteTag, biter.biteDuration)
        end
        return
    end

    index = biteTimerIndices[tag]
    if index == nil then return end
    local biter = biters[index]
    if biter == nil or not biter.active then return end

    playAnim(biter.tag, 'idle', true)
    local offscreenX = biter.fromRight and (screenWidth + 24) or (-biter.width - 24)
    doTweenX(biter.exitTag, biter.tag, offscreenX, EXIT_DURATION, 'quadIn')
end

function onTweenCompleted(tag)
    local index = exitTweenIndices[tag]
    -- The entrance and both timers have already removed themselves before the
    -- exit can complete. Avoid four redundant engine cancellation callbacks.
    if index ~= nil then releaseBiter(index, false) end
end

function onGameOverStart()
    clearBiters()
end

function onDestroy()
    clearBiters()
    for _, biter in ipairs(biters) do
        if luaSpriteExists(biter.tag) then removeLuaSprite(biter.tag, true) end
    end
end
