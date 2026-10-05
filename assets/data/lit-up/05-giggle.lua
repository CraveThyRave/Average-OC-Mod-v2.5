local starts = {0, 128, 256, 1024, 1152}
local nextStart = 1
local active = false
local fading = false
local fadeStep = 0
local centerX = 0

function onCreate()
    makeAnimatedLuaSprite('litUpGiggle', 'fahmix/weekend1/giggle', 0, 0)
    addAnimationByPrefix('litUpGiggle', 'entrance', 'giggle into', 12, false)
    addAnimationByPrefix('litUpGiggle', 'idle', 'giggle idlle', 6, true)
    playAnim('litUpGiggle', 'entrance', true)
    local scale = screenHeight * 0.8 / getProperty('litUpGiggle.height')
    scaleObject('litUpGiggle', scale, scale)
    centerX = (screenWidth - getProperty('litUpGiggle.width')) * 0.5
    setObjectCamera('litUpGiggle', 'other')
    anchorSpriteToScreenBottom('litUpGiggle')
    setProperty('litUpGiggle.bottomAnchor.y', 20)
    setProperty('litUpGiggle.visible', false)
    addLuaSprite('litUpGiggle', true)
end

local function updateGiggle()
    while nextStart <= #starts and curStep >= starts[nextStart] do
        local start = starts[nextStart]
        nextStart = nextStart + 1
        if curStep < start + 10 then
            active = true
            fading = false
            fadeStep = start + 10
            cancelTween('litUpGiggleFade')
            setProperty('litUpGiggle.alpha', 1)
            setProperty('litUpGiggle.x', -getProperty('litUpGiggle.width') - 20)
            setProperty('litUpGiggle.angle', -14)
            setProperty('litUpGiggle.visible', true)
            playAnim('litUpGiggle', 'entrance', true)
            setObjectOrder('litUpGiggle', getProperty('members.length') - 1)
            if luaSpriteExists('logo') then
                setObjectOrder('logo', getObjectOrder('litUpGiggle') + 1)
            end
            doTweenX('litUpGiggleIn', 'litUpGiggle', centerX, 0.3, 'quadOut')
            doTweenAngle('litUpGiggleLean', 'litUpGiggle', 0, 0.3, 'quadOut')
        end
    end
    if not active then return end
    if getProperty('litUpGiggle.animation.curAnim.name') == 'entrance' and getProperty('litUpGiggle.animation.curAnim.finished') then
        playAnim('litUpGiggle', 'idle', true)
    end
    if not fading and curStep >= fadeStep then
        fading = true
        doTweenAlpha('litUpGiggleFade', 'litUpGiggle', 0, 0.3, 'linear')
    end
end

function onStepHit()
    updateGiggle()
end

function onUpdatePost(elapsed)
    updateGiggle()
end

function onTweenCompleted(tag)
    if tag == 'litUpGiggleFade' then
        active = false
        setProperty('litUpGiggle.visible', false)
    end
end

function onGameOverStart()
    nextStart = #starts + 1
    active = false
    cancelTween('litUpGiggleIn')
    cancelTween('litUpGiggleLean')
    cancelTween('litUpGiggleFade')
    if luaSpriteExists('litUpGiggle') then setProperty('litUpGiggle.visible', false) end
end