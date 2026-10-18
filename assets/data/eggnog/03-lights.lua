
local lightsTag = 'week5LightsChain'
local baseX = 180
local leftDistance = 50
local rightDistance = 30
local baseY = 50
local fallOvershootY = baseY + 42
local hiddenY = baseY - 400
local startedBounce = false
local beatPhase = 1
local visibleRangeActive = false

function onCreate()
    makeAnimatedLuaSprite(lightsTag, 'fahmix/week5/lights', baseX, baseY)
    addAnimationByPrefix(lightsTag, 'idle', 'idle', 6, true)
    objectPlayAnimation(lightsTag, 'idle', true)
    scaleObject(lightsTag, 1.1, 1.1)
    addLuaSprite(lightsTag, false)

    setProperty(lightsTag .. '.y', hiddenY)
end

local function updateLightsState()
    local shouldBeVisible = (curStep >= 512 and curStep < 638)
        or (curStep >= 771 and curStep < 902)

    if shouldBeVisible and not visibleRangeActive then
        visibleRangeActive = true
        startedBounce = false
        beatPhase = 1
        setProperty(lightsTag .. '.x', baseX)
        setProperty(lightsTag .. '.y', hiddenY)
        cancelTween('week5LightsHide')
        cancelTween('week5LightsUp')
        cancelTween('week5LightsDown')
        cancelTween('week5LightsSettle')
        cancelTween('week5LightsHorizontal')
        doTweenY('week5LightsAppear', lightsTag, baseY, 0.5, 'quadIn')
    elseif not shouldBeVisible and visibleRangeActive then
        visibleRangeActive = false
        startedBounce = false
        cancelTween('week5LightsAppear')
        cancelTween('week5LightsUp')
        cancelTween('week5LightsDown')
        cancelTween('week5LightsSettle')
        cancelTween('week5LightsHorizontal')
        doTweenY('week5LightsHide', lightsTag, hiddenY, 0.35, 'quadOut')
    end
end

function onStepHit()
    updateLightsState()
end

local function bounceDown()
    local beatTime = crochet / 1000
    cancelTween('week5LightsSettle')
    doTweenY('week5LightsDown', lightsTag, fallOvershootY,
        beatTime * 0.2, 'sineInOut')
end

function onBeatHit()
    if not startedBounce then return end

    local beatTime = crochet / 1000

    if beatPhase == 1 then
        doTweenX('week5LightsHorizontal', lightsTag,
            baseX - leftDistance, beatTime * 0.8, 'sineInOut')
    elseif beatPhase == 2 then
        bounceDown()
    elseif beatPhase == 3 then
        doTweenX('week5LightsHorizontal', lightsTag,
            baseX, beatTime * 0.8, 'sineInOut')
    elseif beatPhase == 4 then
        bounceDown()
    elseif beatPhase == 5 then
        doTweenX('week5LightsHorizontal', lightsTag,
            baseX + rightDistance, beatTime * 0.8, 'sineInOut')
    else
        bounceDown()
    end

    beatPhase = beatPhase + 1
    if beatPhase > 6 then beatPhase = 1 end
end

function onTweenCompleted(tag)
    if tag == 'week5LightsAppear' and visibleRangeActive then
        startedBounce = true
        beatPhase = 1
    elseif tag == 'week5LightsDown' and startedBounce then
        local beatTime = crochet / 1000
        doTweenY('week5LightsSettle', lightsTag, baseY,
            beatTime * 0.35, 'sineInOut')
    end
end
