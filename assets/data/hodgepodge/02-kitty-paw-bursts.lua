
local settings = {
    startStep = 1318,
    endStep = 1551,
    spawnEverySteps = 1,
    image = 'Freeplay-Chrs/raven/paw',
    minX = -50,
    maxX = 2600,
    minY = 400,
    maxY = 1300,
    scale = 0.25,
    riseDistance = 40,
    fallDistance = 70,
    fadeInTime = 0.10,
    holdTime = 0.50,
    fadeOutTime = 0.45,
    maxAlpha = 0.75,
    minDistance = 140,
    positionAttempts = 50,
    poolSize = 20
}

local pool = {}
local nextPoolIndex = 1
local minimumDistanceSquared = settings.minDistance * settings.minDistance

local function pawTag(index)
    return 'hodgePawBurst' .. index
end

local function acquirePaw()
    for offset = 0, settings.poolSize - 1 do
        local index = ((nextPoolIndex + offset - 1) % settings.poolSize) + 1
        if not pool[index].active then
            nextPoolIndex = (index % settings.poolSize) + 1
            return index, pool[index]
        end
    end
    return nil, nil
end

local function getSafePosition()
    for _ = 1, settings.positionAttempts do
        local x = getRandomFloat(settings.minX, settings.maxX)
        local y = getRandomFloat(settings.minY, settings.maxY)
        local overlapping = false

        for index = 1, settings.poolSize do
            local paw = pool[index]
            if paw.active then
                local dx = x - paw.x
                local dy = y - paw.y
                if dx * dx + dy * dy < minimumDistanceSquared then
                    overlapping = true
                    break
                end
            end
        end

        if not overlapping then
            return x, y
        end
    end
    return nil, nil
end

local function spawnRandomBurst()
    local index, paw = acquirePaw()
    if index == nil then return end

    local x, y = getSafePosition()
    if x == nil then return end

    local tag = paw.tag
    paw.active = true
    paw.x = x
    paw.y = y

    cancelTween(tag .. '_rise')
    cancelTween(tag .. '_fall')
    cancelTween(tag .. '_fadein')
    cancelTween(tag .. '_fadeout')
    cancelTimer(tag .. '_hold')

    setProperty(tag .. '.x', x)
    setProperty(tag .. '.y', y + settings.riseDistance)
    setProperty(tag .. '.alpha', 0)
    setProperty(tag .. '.visible', true)

    doTweenY(tag .. '_rise', tag, y, settings.fadeInTime, 'quadOut')
    doTweenAlpha(tag .. '_fadein', tag, settings.maxAlpha, settings.fadeInTime, 'linear')
    runTimer(tag .. '_hold', settings.fadeInTime + settings.holdTime)
end

function onCreate()
    if lowQuality then return end
    local particleOrder = getObjectOrder('black1') + 1
    for index = 1, settings.poolSize do
        local tag = pawTag(index)
        makeLuaSprite(tag, settings.image, settings.minX, settings.minY)
        setObjectCamera(tag, 'game')
        scaleObject(tag, settings.scale, settings.scale)
        setProperty(tag .. '.alpha', 0)
        setProperty(tag .. '.visible', false)
        addLuaSprite(tag, false)
        setObjectOrder(tag, particleOrder)
        pool[index] = {tag = tag, active = false, x = 0, y = 0}
    end
end

function onStepHit()
    if lowQuality then return end
    if curStep >= settings.startStep
        and curStep <= settings.endStep
        and curStep % settings.spawnEverySteps == 0 then
        spawnRandomBurst()
    end
end

function onTimerCompleted(timerTag)
    local indexText = string.match(timerTag, '^hodgePawBurst(%d+)_hold$')
    if indexText == nil then return end

    local index = tonumber(indexText)
    local paw = pool[index]
    if paw == nil or not paw.active then return end

    doTweenY(paw.tag .. '_fall', paw.tag, paw.y + settings.fallDistance,
        settings.fadeOutTime, 'quadIn')
    doTweenAlpha(paw.tag .. '_fadeout', paw.tag, 0,
        settings.fadeOutTime, 'linear')
end

function onTweenCompleted(tweenTag)
    local indexText = string.match(tweenTag, '^hodgePawBurst(%d+)_fadeout$')
    if indexText == nil then return end

    local paw = pool[tonumber(indexText)]
    if paw ~= nil then
        paw.active = false
        setProperty(paw.tag .. '.visible', false)
    end
end
