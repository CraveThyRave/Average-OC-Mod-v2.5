local bodyShown = false
local fireIntroFinished = false
local blinking = false
local angryEyes = false

local headTurnFinished = false
local headAnimationActive = false


local outroStarted = false
local outroHidden = false


local drainingHealth = false
local drainTimer = 0
local drainDuration = 0.25

local startHealth = 0
local targetHealth = 1



local initialCameraX = 500
local initialCameraY = 350

function onCreate()


    makeLuaSprite('stageback', 'Freeplay-Chrs/phoenix/stageback', -600, -200)
    setScrollFactor('stageback', 1.1, 1.1)
    addLuaSprite('stageback', false)


    makeLuaSprite('stagefront', 'Freeplay-Chrs/phoenix/stagefront', -650, 600)
    scaleObject('stagefront', 1.1, 1.1)
    addLuaSprite('stagefront', false)


    makeLuaSprite('stagefrontlight', 'Freeplay-Chrs/phoenix/stagefrontlights', -650, 600)
    scaleObject('stagefrontlight', 1.1, 1.1)
    setProperty('stagefrontlight.alpha', 0)
    addLuaSprite('stagefrontlight', false)


    makeLuaSprite('stage_light1', 'Freeplay-Chrs/phoenix/stage_light', -125, -100)
    setScrollFactor('stage_light1', 0.9, 0.9)
    scaleObject('stage_light1', 1.1, 1.1)
    addLuaSprite('stage_light1', false)


    makeLuaSprite('spotlightlight1', 'Freeplay-Chrs/phoenix/spotlightlight', -125, -100)
    setScrollFactor('spotlightlight1', 0.9, 0.9)
    scaleObject('spotlightlight1', 1.1, 1.1)
    setProperty('spotlightlight1.alpha', 0)
    addLuaSprite('spotlightlight1', false)


    makeLuaSprite('stage_light2', 'Freeplay-Chrs/phoenix/stage_light', 1225, -100)
    setScrollFactor('stage_light2', 0.9, 0.9)
    scaleObject('stage_light2', 1.1, 1.1)
    setProperty('stage_light2.flipX', true)
    addLuaSprite('stage_light2', false)


    makeLuaSprite('spotlightlight2', 'Freeplay-Chrs/phoenix/spotlightlight', 1225, -100)
    setScrollFactor('spotlightlight2', 0.9, 0.9)
    scaleObject('spotlightlight2', 1.1, 1.1)
    setProperty('spotlightlight2.flipX', true)
    setProperty('spotlightlight2.alpha', 0)
    addLuaSprite('spotlightlight2', false)


    makeAnimatedLuaSprite('burnmark1', 'Freeplay-Chrs/phoenix/burnmark1', 70, 740)
    addAnimationByPrefix('burnmark1', 'idle', 'burnmark1 idle', 8, false)
    addLuaSprite('burnmark1', false)
    scaleObject('burnmark1', 0.69, 0.9)


    makeAnimatedLuaSprite('burnmark2', 'Freeplay-Chrs/phoenix/burnmark2', 70, 740)
    addAnimationByPrefix('burnmark2', 'idle', 'burnmark2 idle', 8, false)
    addLuaSprite('burnmark2', false)
    scaleObject('burnmark2', 0.69, 0.9)


    makeAnimatedLuaSprite('phoenix-body', 'Freeplay-Chrs/phoenix/phoenix-body', 105, 98)
    addAnimationByPrefix('phoenix-body', 'idle', 'phoenix-body idle', 6, true)
    addLuaSprite('phoenix-body', false)
    setProperty('phoenix-body.alpha', 0)
    scaleObject('phoenix-body', 0.7, 0.7)


    makeAnimatedLuaSprite('phoenix-eyes', 'Freeplay-Chrs/phoenix/phoenix-eyes', 255, 225)
    addAnimationByPrefix('phoenix-eyes', 'idle', 'phoenix-eyes idle', 6, true)
    addAnimationByPrefix('phoenix-eyes', 'blink', 'phoenix-eyes blink', 10, false)
    addAnimationByPrefix('phoenix-eyes', 'angryIn', 'phoenix-eyes angry-eyes-transition-in', 8, false)
    addAnimationByIndices(
    'phoenix-eyes',
    'angryIdle',
    'phoenix-eyes angry-eyes',
    '0',
    0
    )
    addAnimationByPrefix('phoenix-eyes', 'angryOut', 'phoenix-eyes angry-eyes-transition-out', 8, false)
    addLuaSprite('phoenix-eyes', false)
    objectPlayAnimation('phoenix-eyes', 'idle', true)
    setProperty('phoenix-eyes.alpha', 0)
    scaleObject('phoenix-eyes', 0.7, 0.7)


    makeAnimatedLuaSprite('phoenix-head', 'Freeplay-Chrs/phoenix/phoenix-head', 210, 180)
    addAnimationByPrefix('phoenix-head', 'turn-back', 'phoenix-head turn-back', 12, false)
     
    addAnimationByPrefix('phoenix-head', 'turn', 'phoenix-head turn0', 12, false)
    addAnimationByPrefix('phoenix-head', 'eyeroll', 'phoenix-head eyeroll', 12, false)
    addLuaSprite('phoenix-head', true)
    setProperty('phoenix-head.alpha', 0)
    scaleObject('phoenix-head', 0.7, 0.7)


    makeAnimatedLuaSprite('fireintro', 'Freeplay-Chrs/phoenix/fire1', -135, -89)
    addAnimationByPrefix('fireintro', 'idle', 'fire1 idle', 8, true)
    addLuaSprite('fireintro', false)
    scaleObject('fireintro', 0.69, 0.69)



    makeAnimatedLuaSprite('fireoutro', 'Freeplay-Chrs/phoenix/fire2', -115, -60)
    addAnimationByPrefix('fireoutro', 'idle', 'fire2 idle', 8, false)
    addLuaSprite('fireoutro', true)
    scaleObject('fireoutro', 0.69, 0.69)
    objectPlayAnimation('fireoutro', 'idle', false)
    setProperty('fireoutro.animation.curAnim.paused', true)
    setProperty('fireoutro.animation.curAnim.curFrame', 0)

    setProperty('fireoutro.alpha', 0)
    setProperty('fireoutro.visible', false)



    makeLuaSprite('stagecurtains', 'Freeplay-Chrs/phoenix/stagecurtains', -400, -300)
    setScrollFactor('stagecurtains', 1.05, 1.05)
    scaleObject('stagecurtains', 0.9, 0.9)
    addLuaSprite('stagecurtains', true)


    runTimer('lightBlinkOff', 1.2)

end

function onCreatePost()

    setProperty('dad.visible', false)
    setProperty('phoenix-body.alpha', 0)

    setProperty('isCameraOnForcedPos', true)
    setProperty('camFollow.x', initialCameraX)
    setProperty('camFollow.y', initialCameraY)
    setProperty('camFollowPos.x', initialCameraX)
    setProperty('camFollowPos.y', initialCameraY)

    doTweenAlpha('hudFade', 'camHUD', 0, 0.01, 'quadOut')

end

function onTimerCompleted(tag)

    if tag == 'angryEyesIdle' then
        objectPlayAnimation('phoenix-eyes', 'angryIdle', false)
    end

    if tag == 'angryEyesEnd' then
        angryEyes = false

        setProperty('phoenix-eyes.y', 225)

        objectPlayAnimation('phoenix-eyes', 'idle', true)
    end

    if tag == 'lightBlinkOff' then


        doTweenAlpha('frontLightOff', 'stagefrontlight', 0, 2.5, 'sineInOut')
        doTweenAlpha('spot1Off', 'spotlightlight1', 0, 2.5, 'sineInOut')
        doTweenAlpha('spot2Off', 'spotlightlight2', 0, 2.5, 'sineInOut')

        runTimer('lightBlinkOn', 2.4)

    end

    if tag == 'lightBlinkOn' then


        doTweenAlpha('frontLightOn', 'stagefrontlight', 1, 2.5, 'sineInOut')
        doTweenAlpha('spot1On', 'spotlightlight1', 1, 2.5, 'sineInOut')
        doTweenAlpha('spot2On', 'spotlightlight2', 1, 2.5, 'sineInOut')

        runTimer('lightBlinkOff', 3.5)

    end

    if tag == 'phoenixBlink' then

        startPhoenixBlink()


        runTimer('phoenixBlink', getRandomFloat(2.5, 5))

    end

    if tag == 'phoenixBlinkEnd' then

        blinking = false

        if not angryEyes then
            objectPlayAnimation('phoenix-eyes', 'idle', true)
        end

    end

end

function onUpdate(elapsed)


    if not fireIntroFinished and luaSpriteExists('fireintro') then

        local curFrame = getProperty('fireintro.animation.curAnim.curFrame')


        if curFrame >= 6 and not bodyShown then

            runTimer('phoenixBlink', 3)

            objectPlayAnimation('phoenix-eyes', 'idle', true)

            bodyShown = true

            setProperty('phoenix-body.alpha', 1)
            setProperty('phoenix-eyes.alpha', 1)
            setProperty('dad.visible', true)


        end


        if curFrame >= 9 then
            setProperty('fireintro.alpha', 0)
            fireIntroFinished = true
        end

    end


    if drainingHealth then

        drainTimer = drainTimer + elapsed

        local progress = drainTimer / drainDuration

        if progress >= 1 then
            progress = 1
            drainingHealth = false
        end


        local newHealth = startHealth + ((targetHealth - startHealth) * progress)


        setProperty('health', newHealth)

    end

    local curAnim = headAnimationActive
        and getProperty('phoenix-head.animation.curAnim')
        or nil

    if curAnim ~= nil then

        local anim = getProperty('phoenix-head.animation.curAnim.name')
        local frame = getProperty('phoenix-head.animation.curAnim.curFrame')

        if anim == 'turn' and not headTurnFinished then

            local lastFrame =
                getProperty('phoenix-head.animation.curAnim.numFrames') - 1

            if frame >= lastFrame and lastFrame > 0 then

                headTurnFinished = true


                setProperty('phoenix-head.animation.curAnim.paused', true)

            end
        end


        if anim == 'turn-back' then

            local lastFrame =
                getProperty('phoenix-head.animation.curAnim.numFrames') - 1

            if frame >= lastFrame and lastFrame > 0 then

                setProperty('phoenix-head.alpha', 0)

                headTurnFinished = false
                headAnimationActive = false

            end
        end

    end

    if outroStarted then

        local curFrame = getProperty('fireoutro.animation.curAnim.curFrame')

        if curFrame == 4 and not outroHidden then

            outroHidden = true

            setProperty('phoenix-body.alpha', 0)
            setProperty('phoenix-eyes.alpha', 0)
            setProperty('dad.visible', false)

        end

        local lastFrame =
            getProperty('fireoutro.animation.curAnim.numFrames') - 1

        if curFrame >= lastFrame then

            outroStarted = false

            setProperty('fireoutro.alpha', 0)
            setProperty('fireoutro.visible', false)

        end

    end
end


function goodNoteHit(id, direction, noteType, isSustainNote)


    if drainingHealth then


        local progress = drainTimer / drainDuration

        if progress > 1 then
            progress = 1
        end

        local forcedHealth = startHealth + ((targetHealth - startHealth) * progress)

        setProperty('health', forcedHealth)

    end

end

function startPhoenixBlink()

    if angryEyes then
        return
    end

    if getProperty('phoenix-eyes.alpha') > 0 then

        blinking = true

        objectPlayAnimation('phoenix-eyes', 'blink', true)

        runTimer('phoenixBlinkEnd', 0.35)

    end

end

local healthDrainSteps = {
    [248] = true,
    [455] = true,
    [580] = true,
    [1025] = true,
    [1316] = true
}

local hudFadeTimeline = {
    {step = 96, alpha = 1, duration = 3},
    {step = 301, alpha = 0.5, duration = 0.25},
    {step = 320, alpha = 1, duration = 0.25},
    {step = 463, alpha = 0.5, duration = 0.25},
    {step = 511, alpha = 1, duration = 0.25},
    {step = 587, alpha = 0.5, duration = 0.25},
    {step = 617, alpha = 1, duration = 0.25},
    {step = 1316, alpha = 0.5, duration = 2},
    {step = 1378, alpha = 0, duration = 0.4}
}
local nextHudFadeIndex = 1

local angryEyesInSteps = {[19] = true, [311] = true, [589] = true}
local angryEyesOutSteps = {[128] = true, [385] = true, [624] = true}

function onStepHit()
    if healthDrainSteps[curStep] then
        startHealthDrain()
    end



    while nextHudFadeIndex <= #hudFadeTimeline
        and curStep >= hudFadeTimeline[nextHudFadeIndex].step do
        local hudFade = hudFadeTimeline[nextHudFadeIndex]
        doTweenAlpha('hudFade', 'camHUD', hudFade.alpha, hudFade.duration, 'quadOut')
        nextHudFadeIndex = nextHudFadeIndex + 1
    end

    if angryEyesInSteps[curStep] then
        angryEyes = true

        setProperty('phoenix-eyes.y', 222)

        objectPlayAnimation('phoenix-eyes', 'angryIn', true)

        runTimer('angryEyesIdle', 7 / 8)
    elseif angryEyesOutSteps[curStep] then
        objectPlayAnimation('phoenix-eyes', 'angryOut', true)

        runTimer('angryEyesEnd', 8 / 8)
    end

    if curStep == 479 then
        headTurnFinished = false
        headAnimationActive = true

        setProperty('phoenix-head.alpha', 1)

        objectPlayAnimation('phoenix-head', 'turn', false)
    end

    if curStep == 495 then
        setProperty('phoenix-head.animation.curAnim.paused', false)
        objectPlayAnimation('phoenix-head', 'eyeroll', false)
    end

    if curStep == 501 then
        objectPlayAnimation('phoenix-head', 'turn-back', false)
    end

    if curStep == 1364 then

        outroStarted = true
        outroHidden = false

        setProperty('fireoutro.visible', true)
        setProperty('fireoutro.alpha', 1)

        objectPlayAnimation('fireoutro', 'idle', true)

        setProperty('fireoutro.animation.curAnim.curFrame', 0)
        setProperty('fireoutro.animation.curAnim.paused', false)

    end

end

function startHealthDrain()

    local currentHealth = getProperty('health')


    if currentHealth <= targetHealth then
        return
    end

    drainingHealth = true
    drainTimer = 0
    startHealth = currentHealth

end
