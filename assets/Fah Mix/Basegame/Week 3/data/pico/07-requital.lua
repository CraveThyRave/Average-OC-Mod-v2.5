local active = false
local triggered = {}
local fromLeft = true
local lastCenter = nil
local jumpAge = -1
local jumped = {}
local roofHeights = {556, 536, 544}
local jumpDuration = 0.24
local jumpHeight = 200

function onCreate()
    makeAnimatedLuaSprite('requital', 'fahmix/week3/requital', -4000, 0)
    addAnimationByPrefix('requital', 'idle', 'requital idle', 6, true)
    addAnimationByPrefix('requital', 'jump', 'requital jump', 12, true)
    scaleObject('requital', 0.78, 0.78)
    setProperty('requital.visible', false)
    addLuaSprite('requital', false)
end

function onCreatePost()
    setObjectOrder('requital', getObjectOrder('train') + 1)
end

local function attachToCar(elapsed)
    local trainX = getProperty('train.x')
    local trainScale = getProperty('train.scale.x')
    local carX = fromLeft and 3373 - 1950 or 1950
    local center = trainX - getProperty('train.offset.x') + getProperty('train.origin.x')
        + (carX - getProperty('train.origin.x')) * trainScale
    local direction = fromLeft and 1 or -1
    local poles = {getProperty('front poles.x') + 355, getProperty('front poles.x') + 2200}
    for index, pole in ipairs(poles) do
        local contact = pole - direction * 250
        if not jumped[index] and lastCenter ~= nil and (lastCenter - contact) * direction < 0
            and (center - contact) * direction >= 0 and jumpAge < 0 then
            jumped[index] = true
            jumpAge = 0
            playAnim('requital', 'jump', true)
        end
    end
    lastCenter = center
    local rise = 0
    if jumpAge >= 0 then
        jumpAge = jumpAge + elapsed * playbackRate
        local progress = math.min(1, jumpAge / jumpDuration)
        rise = 4 * jumpHeight * progress * (1 - progress)
        if progress >= 1 then
            jumpAge = -1
            playAnim('requital', 'idle', true)
        end
    end
    local frame = getProperty('train.animation.curAnim.curFrame') + 1
    local roof = roofHeights[frame] or roofHeights[1]
    local foot = getProperty('train.y') - getProperty('train.offset.y') + getProperty('train.origin.y')
        + (roof - getProperty('train.origin.y')) * getProperty('train.scale.y') + 12 - rise
    local originX = getProperty('requital.origin.x')
    local originY = getProperty('requital.origin.y')
    local width = getProperty('requital.frame.sourceSize.x')
    local bottom = getProperty('requital.frame.offset.y') + getProperty('requital.frame.frame.height')
    setProperty('requital.x', center + getProperty('requital.offset.x') - originX
        - (width * 0.5 - originX) * getProperty('requital.scale.x'))
    setProperty('requital.y', foot + getProperty('requital.offset.y') - originY
        - (bottom - originY) * getProperty('requital.scale.y'))
end

function onStepHit()
    if (curStep ~= 982 and curStep ~= 1174) or triggered[curStep] then return end
    triggered[curStep] = true
    cancelTimer('trainMove')
    cancelTimer('trainStartPass')
    cancelTimer('trainStopSound')
    cancelTween('trainTween')
    cancelTween('requitalTrainPass')
    stopSound('week3TrainPass')
    local directionKey = 'pico.requitalFromLeft.' .. curStep
    fromLeft = getRecordedSceneValue(directionKey)
    if fromLeft == nil then fromLeft = getRandomBool(50) end
    recordSceneValue(directionKey, fromLeft)
    setProperty('train.flipX', fromLeft)
    setProperty('train.x', fromLeft and -3600 or 3600)
    setProperty('requital.flipX', fromLeft)
    setProperty('requital.visible', true)
    playAnim('requital', 'idle', true)
    active = true
    lastCenter = nil
    jumpAge = -1
    jumped = {}
    attachToCar(0)
    playSound('week3-train-pass', 0, 'week3TrainPass', true)
    soundFadeIn('week3TrainPass', 0.18, 0, 1)
    doTweenX('requitalTrainPass', 'train', fromLeft and 3600 or -3600, 1.8 / playbackRate, 'linear')
end

function onUpdatePost(elapsed)
    if active then attachToCar(elapsed) end
end

function onTweenCompleted(tag)
    if tag == 'trainTween' then
        active = false
        setProperty('requital.visible', false)
        return
    end
    if tag ~= 'requitalTrainPass' then return end
    active = false
    setProperty('requital.visible', false)
    setProperty('train.flipX', true)
    setProperty('train.x', -3000)
    soundFadeOut('week3TrainPass', 0.18, 0)
    runTimer('trainStopSound', 0.18)
    runTimer('trainMove', getRandomFloat(8, 18))
end

function onTimerCompleted(tag)
    if tag ~= 'trainStartPass' or curStep < 982 or curStep > 1174 then return end
    fromLeft = getProperty('train.flipX')
    setProperty('requital.flipX', fromLeft)
    setProperty('requital.visible', true)
    playAnim('requital', 'idle', true)
    active = true
    lastCenter = nil
    jumpAge = -1
    jumped = {}
    attachToCar(0)
end

function onGameOverStart()
    active = false
    cancelTween('requitalTrainPass')
    setProperty('requital.visible', false)
end
