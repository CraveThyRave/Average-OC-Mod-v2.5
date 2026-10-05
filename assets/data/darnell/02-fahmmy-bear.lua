local BEAR_TAG = 'darnellFahmmyBear'
local BEAR_ASSET = 'fahmix/weekend1/fahmmy-bear'
local ASH_TAG = 'darnellAshbaby'
local ASH_ASSET = 'fahmix/weekend1/ashbaby'
local YIPPEE_TAG = 'darnellYippee'
local YIPPEE_DROP_STEP = 1145
local YIPPEE_GROW_STEP = 1149
local YIPPEE_HIDE_STEP = 1153
local YIPPEE_START_STEP = 1211
local YIPPEE_END_STEP = 1215
local YIPPEE_BLINK_MS = 100
local YIPPEE_FADE_MS = 120
local BOUNCE_DURATION = 0.5
local ARC_HEIGHT = 260

local bearMoving = false
local bearElapsed = 0
local yippeeCreated = false
local yippeeBlinkStarted = false
local startX = 0
local startY = 0
local endX = 0
local endY = 0

function onCreate()
    makeAnimatedLuaSprite(BEAR_TAG, BEAR_ASSET, screenWidth, screenHeight + 20)
    addAnimationByPrefix(BEAR_TAG, 'idle', 'fahmmy-bear idle', 6, true)
    scaleObject(BEAR_TAG, 0.5, 0.5)
    setObjectCamera(BEAR_TAG, 'other')
    setProperty(BEAR_TAG .. '.visible', false)
    addLuaSprite(BEAR_TAG, true)

    makeAnimatedLuaSprite(ASH_TAG, ASH_ASSET, 0, screenHeight + 20)
    addAnimationByPrefix(ASH_TAG, 'idle', 'ashbaby idle', 6, true)
    scaleObject(ASH_TAG, 2.7, 2.7)
    setObjectCamera(ASH_TAG, 'other')
    setProperty(ASH_TAG .. '.visible', false)
    addLuaSprite(ASH_TAG, true)

end

local function createYippee()
    makeAnimatedLuaSprite(YIPPEE_TAG, 'fahmix/weekend1/yippee', 0, 0)
    addAnimationByPrefix(YIPPEE_TAG, 'idle', 'yippee idle', 6, true)
    setObjectCamera(YIPPEE_TAG, 'other')
    screenCenter(YIPPEE_TAG, 'xy')
    addLuaSprite(YIPPEE_TAG, true)
    objectPlayAnimation(YIPPEE_TAG, 'idle', true)
    yippeeCreated = true
end

local function resetYippeeScale()
    scaleObject(YIPPEE_TAG, 1, 1)
    screenCenter(YIPPEE_TAG, 'xy')
end

local function startYippeeBlink()
    if not yippeeCreated then createYippee() end

    cancelTween('darnellYippeeFall')
    cancelTween('darnellYippeeGrowX')
    cancelTween('darnellYippeeGrowY')
    removeLuaSprite(YIPPEE_TAG, false)
    addLuaSprite(YIPPEE_TAG, true)
    resetYippeeScale()
    setProperty(YIPPEE_TAG .. '.alpha', 1)
    setProperty(YIPPEE_TAG .. '.visible', true)
    objectPlayAnimation(YIPPEE_TAG, 'idle', true)
    yippeeBlinkStarted = true
end

function onStepHit()
    if curStep == YIPPEE_DROP_STEP then
        if not yippeeCreated then createYippee() end

        cancelTween('darnellYippeeFall')
        cancelTween('darnellYippeeGrowX')
        cancelTween('darnellYippeeGrowY')
        resetYippeeScale()

        local height = getProperty(YIPPEE_TAG .. '.height')
        local restingY = (screenHeight - height) * 0.5
        setProperty(YIPPEE_TAG .. '.y', -height)
        setProperty(YIPPEE_TAG .. '.alpha', 1)
        setProperty(YIPPEE_TAG .. '.visible', true)
        objectPlayAnimation(YIPPEE_TAG, 'idle', true)
        doTweenY('darnellYippeeFall', YIPPEE_TAG, restingY,
            math.max(0.05, stepCrochet * 4 / 1000), 'quartOut')
        return
    end

    if curStep == YIPPEE_GROW_STEP and yippeeCreated then
        cancelTween('darnellYippeeFall')
        screenCenter(YIPPEE_TAG, 'y')
        local growTime = math.max(0.05, stepCrochet * 8 / 1000)
        doTweenX('darnellYippeeGrowX', YIPPEE_TAG .. '.scale', 1.05, growTime, 'linear')
        doTweenY('darnellYippeeGrowY', YIPPEE_TAG .. '.scale', 1.05, growTime, 'linear')
        return
    end

    if curStep == YIPPEE_HIDE_STEP and yippeeCreated then
        cancelTween('darnellYippeeGrowX')
        cancelTween('darnellYippeeGrowY')
        setProperty(YIPPEE_TAG .. '.visible', false)
        return
    end

    if curStep == YIPPEE_START_STEP then
        startYippeeBlink()
        return
    end

    if curStep == 811 then
        local width = getProperty(ASH_TAG .. '.width')
        local height = getProperty(ASH_TAG .. '.height')
        setProperty(ASH_TAG .. '.x', (screenWidth - width) * 0.5 - 30)
        setProperty(ASH_TAG .. '.y', screenHeight + 20)
        setProperty(ASH_TAG .. '.visible', true)
        objectPlayAnimation(ASH_TAG, 'idle', true)
        doTweenY('darnellAshbabyEnter', ASH_TAG, screenHeight - height + 32,
            math.max(0.05, (stepCrochet or 96.774) * 5 / 1000), 'quartOut')
        return
    end

    if curStep == 816 then
        cancelTween('darnellAshbabyEnter')
        doTweenY('darnellAshbabyFall', ASH_TAG, screenHeight + 20, 0.16, 'quadIn')
        return
    end

    if curStep ~= 441 then return end

    local width = getProperty(BEAR_TAG .. '.width')
    startX = screenWidth + 20
    startY = screenHeight + 20
    endX = -width - 20
    endY = 80
    bearElapsed = 0
    bearMoving = true

    setProperty(BEAR_TAG .. '.x', startX)
    setProperty(BEAR_TAG .. '.y', startY)
    setProperty(BEAR_TAG .. '.angle', 8)
    setProperty(BEAR_TAG .. '.visible', true)
    objectPlayAnimation(BEAR_TAG, 'idle', true)
end

function onUpdate(elapsed)
    if not bearMoving then return end

    bearElapsed = bearElapsed + elapsed
    local rawProgress = math.min(1, bearElapsed / BOUNCE_DURATION)
    local progress = 1 - (1 - rawProgress) * (1 - rawProgress)
    local arc = math.sin(progress * math.pi) * ARC_HEIGHT

    setProperty(BEAR_TAG .. '.x', startX + (endX - startX) * progress)
    setProperty(BEAR_TAG .. '.y', startY + (endY - startY) * progress - arc)
    setProperty(BEAR_TAG .. '.angle', 8 - 16 * progress)

    if rawProgress >= 1 then
        bearMoving = false
        setProperty(BEAR_TAG .. '.visible', false)
    end
end

function onUpdatePost()
    local step = curDecStep
    local fadeEndStep = YIPPEE_END_STEP + (YIPPEE_FADE_MS / stepCrochet)

    if step >= YIPPEE_START_STEP and step < fadeEndStep and not yippeeBlinkStarted then
        startYippeeBlink()
    end

    if not yippeeBlinkStarted then return end

    if step >= YIPPEE_START_STEP and step < YIPPEE_END_STEP then
        local elapsedMs = (step - YIPPEE_START_STEP) * stepCrochet
        local visibleBlink = math.floor(elapsedMs / YIPPEE_BLINK_MS) % 2 == 0
        setProperty(YIPPEE_TAG .. '.visible', visibleBlink)
        setProperty(YIPPEE_TAG .. '.alpha', 1)
    elseif step >= YIPPEE_END_STEP and step < fadeEndStep then
        local fadeProgress = ((step - YIPPEE_END_STEP) * stepCrochet) / YIPPEE_FADE_MS
        setProperty(YIPPEE_TAG .. '.visible', true)
        setProperty(YIPPEE_TAG .. '.alpha', 1 - fadeProgress)
    else
        setProperty(YIPPEE_TAG .. '.visible', false)
        setProperty(YIPPEE_TAG .. '.alpha', 0)
    end
end

function onTweenCompleted(tag)
    if tag == 'darnellAshbabyFall' then
        setProperty(ASH_TAG .. '.visible', false)
    end
end

function onGameOverStart()
    bearMoving = false
    cancelTween('darnellAshbabyEnter')
    cancelTween('darnellAshbabyFall')
    setProperty(BEAR_TAG .. '.visible', false)
    setProperty(ASH_TAG .. '.visible', false)
    if yippeeCreated then
        setProperty(YIPPEE_TAG .. '.visible', false)
    end
end
