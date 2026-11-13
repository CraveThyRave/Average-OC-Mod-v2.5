local RUNNER_TAG = 'undiesFahRunner'
local RUNNER_ASSET = 'fahmix/week4/fahrunner'
local MANY_TAG = 'undiesManyWalker'
local MANY_ASSET = 'fahmix/week4/many'
local FAHNY_TAG = 'undiesFahnyWalker'
local FAHNY_ASSET = 'fahmix/week4/fahny'
local MANY_BOUNCE_SPEED = 8
local MANY_BOUNCE_AMOUNT = 50
local WALKER_Y_OFFSET = 20
local TRIGGER_STEPS = {
    [92] = true,
    [219] = true,
    [283] = true,
    [348] = true,
    [476] = true,
    [539] = true,
    [669] = true,
    [733] = true,
    [829] = true
}

local activeStartStep = -1
local floorY = 0
local bounceY = 0
local manyWalking = false
local manyBounceTimer = 0
local manyLowestY = 0
local activeWalkerTag = MANY_TAG

local function stepDuration()
    return math.max(0.01, (stepCrochet or 125) / 1000)
end

local function beginBounce()
    cancelTween('undiesFahRunnerY')

    local width = getProperty(RUNNER_TAG .. '.width')
    local minX = -math.floor(width * 0.08)
    local maxX = math.floor(screenWidth - width * 0.92)
    local x = getRandomInt(minX, math.max(minX, maxX))
    local visibleHeight = getRandomInt(220, 430)

    floorY = screenHeight + 8
    bounceY = screenHeight - visibleHeight
    activeStartStep = curStep

    setProperty(RUNNER_TAG .. '.x', x)
    setProperty(RUNNER_TAG .. '.y', floorY)
    setProperty(RUNNER_TAG .. '.flipX', x + width * 0.5 >= screenWidth * 0.5)
    setProperty(RUNNER_TAG .. '.visible', true)
    objectPlayAnimation(RUNNER_TAG, 'idle', true)
    doTweenY('undiesFahRunnerY', RUNNER_TAG, bounceY, stepDuration(), 'quadOut')
end

local function beginWalkerCrossing(walkerTag, tweenTag, fromLeft, stepCount)
    cancelTween('undiesManyAcrossRight')
    cancelTween('undiesFahnyAcrossLeft')
    setProperty(MANY_TAG .. '.visible', false)
    setProperty(FAHNY_TAG .. '.visible', false)

    local width = getProperty(walkerTag .. '.width')
    local height = getProperty(walkerTag .. '.height')
    local startX = fromLeft and -width or screenWidth
    local endX = fromLeft and screenWidth or -width

    manyLowestY = screenHeight - height * 0.9 + WALKER_Y_OFFSET
    manyBounceTimer = 0
    manyWalking = true
    activeWalkerTag = walkerTag

    setProperty(walkerTag .. '.x', startX)
    setProperty(walkerTag .. '.y', manyLowestY)
    setProperty(walkerTag .. '.flipX', not fromLeft)
    setProperty(walkerTag .. '.visible', true)
    objectPlayAnimation(walkerTag, 'idle', true)
    doTweenX(tweenTag, walkerTag, endX, stepDuration() * stepCount, 'linear')
end

function onCreate()
    makeAnimatedLuaSprite(RUNNER_TAG, RUNNER_ASSET, 0, screenHeight + 8)
    addAnimationByPrefix(RUNNER_TAG, 'idle', 'fahrunner idle', 12, true)
    setObjectCamera(RUNNER_TAG, 'other')
    setProperty(RUNNER_TAG .. '.visible', false)
    addLuaSprite(RUNNER_TAG, true)

    makeAnimatedLuaSprite(MANY_TAG, MANY_ASSET, 0, screenHeight)
    addAnimationByPrefix(MANY_TAG, 'idle', 'many idle', 6, true)
    setObjectCamera(MANY_TAG, 'other')
    setProperty(MANY_TAG .. '.visible', false)
    addLuaSprite(MANY_TAG, true)

    makeAnimatedLuaSprite(FAHNY_TAG, FAHNY_ASSET, 0, screenHeight)
    addAnimationByPrefix(FAHNY_TAG, 'idle', 'fahny idle', 6, true)
    setObjectCamera(FAHNY_TAG, 'other')
    setProperty(FAHNY_TAG .. '.visible', false)
    addLuaSprite(FAHNY_TAG, true)
end

function onStepHit()
    if curStep == 351 then
        beginWalkerCrossing(MANY_TAG, 'undiesManyAcrossRight', true, 416 - 351)
    elseif curStep == 416 then
        beginWalkerCrossing(FAHNY_TAG, 'undiesFahnyAcrossLeft', false, 480 - 416)
        setProperty(FAHNY_TAG .. '.flipX', false)
    elseif curStep == 480 then
        cancelTween('undiesFahnyAcrossLeft')
        setProperty(FAHNY_TAG .. '.visible', false)
        manyWalking = false
    end

    if TRIGGER_STEPS[curStep] then
        beginBounce()
        return
    end

    if activeStartStep < 0 then return end
    local phase = curStep - activeStartStep

    if phase == 1 then
        doTweenY('undiesFahRunnerY', RUNNER_TAG, floorY, stepDuration(), 'quadIn')
    elseif phase == 2 then
        doTweenY('undiesFahRunnerY', RUNNER_TAG, bounceY, stepDuration(), 'quadOut')
    elseif phase == 3 then
        doTweenY('undiesFahRunnerY', RUNNER_TAG, floorY, stepDuration(), 'quadIn')
    end
end

function onUpdate(elapsed)
    if not manyWalking then return end
    manyBounceTimer = manyBounceTimer + elapsed
    setProperty(activeWalkerTag .. '.y', manyLowestY
        - math.abs(math.sin(manyBounceTimer * MANY_BOUNCE_SPEED)) * MANY_BOUNCE_AMOUNT)
end

function onTweenCompleted(tag)
    if tag == 'undiesFahRunnerY' and activeStartStep >= 0 and curStep >= activeStartStep + 3 then
        setProperty(RUNNER_TAG .. '.visible', false)
        activeStartStep = -1
    elseif tag == 'undiesFahnyAcrossLeft' then
        setProperty(FAHNY_TAG .. '.visible', false)
        manyWalking = false
    end
end

function onGameOverStart()
    cancelTween('undiesFahRunnerY')
    cancelTween('undiesManyAcrossRight')
    cancelTween('undiesFahnyAcrossLeft')
    setProperty(RUNNER_TAG .. '.visible', false)
    setProperty(MANY_TAG .. '.visible', false)
    setProperty(FAHNY_TAG .. '.visible', false)
    activeStartStep = -1
    manyWalking = false
end
