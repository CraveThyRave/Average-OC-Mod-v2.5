local EVENT_NAME = 'Biter'

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

local COPIES_PER_TYPE = 2
local BITER_SCALE = 0.30
local BITE_FPS = 8
local IDLE_FPS = 8
local FIRST_FRAME_HOLD = 0.20
local ENTER_DURATION = 0.10
local EXIT_DURATION = 0.22
local SCREEN_MARGIN_Y = 8
local SCREEN_EDGE_HIDDEN_RATIO = 0.18
local MAX_PLACEMENT_ATTEMPTS = 64
local MAX_OVERLAP_RATIO = 0.10

local biters = {}

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

local function releaseBiter(index)
    local biter = biters[index]
    if biter == nil then return end

    cancelBiterMotion(index)
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
    local bestSide, bestY, bestOverlap = false, SCREEN_MARGIN_Y, math.huge

    for attempt = 1, MAX_PLACEMENT_ATTEMPTS do
        local fromRight = getRandomBool()
        local y = getRandomFloat(SCREEN_MARGIN_Y, maxY)
        local x = fromRight
            and (screenWidth - width * (1 - SCREEN_EDGE_HIDDEN_RATIO))
            or (-width * SCREEN_EDGE_HIDDEN_RATIO)
        local overlap = placementOverlap(fromRight, x, y, width, height)
        if overlap < bestOverlap then
            bestSide, bestY, bestOverlap = fromRight, y, overlap
        end
        if overlap <= MAX_OVERLAP_RATIO then return fromRight, y end
    end

    -- A finite screen can be geometrically saturated. Returning the least
    -- overlapping sampled position keeps spawning uncapped while honoring the
    -- 10% target whenever any sampled valid position exists.
    return bestSide, bestY
end

local function createBiter(typeIndex)
    local biterType = BITER_TYPES[typeIndex]
    local index = #biters + 1
    local tag = 'biterEventSprite' .. index
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
        onscreenX = 0
    }
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

    cancelBiterMotion(poolIndex)
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
    runTimer(timerTag('Hold', poolIndex), FIRST_FRAME_HOLD)
    return true
end

local function clearBiters()
    for index = 1, #biters do releaseBiter(index) end
end

function onCreate()
    for _, biterType in ipairs(BITER_TYPES) do precacheImage(biterType.asset) end

    local poolIndex = 0
    for typeIndex, _ in ipairs(BITER_TYPES) do
        for copyIndex = 1, COPIES_PER_TYPE do
            poolIndex = createBiter(typeIndex)
        end
    end
end

function onEvent(name, value1, value2)
    if name ~= EVENT_NAME then return end

    -- The event is intentionally parameterless; both chart value fields are ignored.
    spawnBiter()
end

function onTimerCompleted(tag)
    local index = tonumber(string.match(tag, '^biterEventHold(%d+)$'))
    if index ~= nil then
        local biter = biters[index]
        if biter ~= nil and biter.active then
            -- The sprite is already at the edge after its 0.1s entrance; now
            -- release the authored first-frame hold and play the bite.
            playAnim(biter.tag, 'bite', true)
            runTimer(timerTag('BiteDone', index), biter.biteDuration)
        end
        return
    end

    index = tonumber(string.match(tag, '^biterEventBiteDone(%d+)$'))
    if index == nil then return end
    local biter = biters[index]
    if biter == nil or not biter.active then return end

    playAnim(biter.tag, 'idle', true)
    local offscreenX = biter.fromRight and (screenWidth + 24) or (-biter.width - 24)
    doTweenX(tweenTag('Exit', index), biter.tag, offscreenX, EXIT_DURATION, 'quadIn')
end

function onTweenCompleted(tag)
    local index = tonumber(string.match(tag, '^biterEventExit(%d+)$'))
    if index == nil then return end

    releaseBiter(index)
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
