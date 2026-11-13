local nene, giggle, spring, burger, far = {}, {}, {}, {}, {}

do
local dropped = false
local groundY = 0
local centerX = 0

function nene.onCreate()
    precacheSound('nene-arrival')
    precacheSound('nene-boing')
    makeAnimatedLuaSprite('litUpNene', 'fahmix/weekend1/nene', 0, 0)
    addAnimationByPrefix('litUpNene', 'fall', 'nene fall', 12, true)
    addAnimationByPrefix('litUpNene', 'idle', 'nene idle', 6, true)
    playAnim('litUpNene', 'fall', true)
    setObjectCamera('litUpNene', 'game')
    setProperty('litUpNene.visible', false)
    addLuaSprite('litUpNene', true)
end

function nene.onCreatePost()
    addHaxeLibrary('CoolUtil')
    runHaxeCode([[
        var sprite = game.modchartSprites.get('litUpNene');
        var bounds = CoolUtil.opaqueSpriteBounds(game.dad);
        var ground = game.dad.y - game.dad.offset.y + game.dad.origin.y
            + (bounds.y + bounds.height - game.dad.origin.y) * game.dad.scale.y - 85;
        var center = game.dad.x - game.dad.offset.x + game.dad.origin.x
            + (bounds.x + bounds.width * 0.5 - game.dad.origin.x) * game.dad.scale.x;
        var bfBounds = CoolUtil.opaqueSpriteBounds(game.boyfriend);
        var bfCenter = game.boyfriend.x - game.boyfriend.offset.x + game.boyfriend.origin.x
            + (bfBounds.x + bfBounds.width * 0.5 - game.boyfriend.origin.x) * game.boyfriend.scale.x;
        center = (center + bfCenter) * 0.5;
        var scale = bounds.height * game.dad.scale.y / 332 * 0.6;
        sprite.scale.set(scale, scale);
        sprite.updateHitbox();
        game.variables.set('litUpNeneGround', ground);
        game.variables.set('litUpNeneCenter', center);
    ]])
    groundY = getVar('litUpNeneGround')
    centerX = getVar('litUpNeneCenter')
    setObjectOrder('litUpNene', getObjectOrder('dadGroup') + 1)
end

local function dropNene()
    if dropped or curStep < 717 then return end
    dropped = true
    playSound('nene-arrival', 1)
    setProperty('litUpNene.x', centerX - getProperty('litUpNene.width') * 0.5)
    setProperty('litUpNene.y', getProperty('camGame.scroll.y') - getProperty('litUpNene.height') - screenHeight)
    setProperty('litUpNene.visible', true)
    doTweenY('litUpNeneFall', 'litUpNene', groundY - getProperty('litUpNene.height'), 0.55, 'quadIn')
end

function nene.onStepHit()
    dropNene()
end

function nene.onUpdatePost(elapsed)
    dropNene()
end

function nene.onTweenCompleted(tag)
    if tag == 'litUpNeneFall' then
        playSound('nene-boing', 0.8)
        doTweenY('litUpNeneBounceUp', 'litUpNene', groundY - getProperty('litUpNene.height') * 1.7, 0.3, 'quadOut')
    elseif tag == 'litUpNeneBounceUp' then
        doTweenY('litUpNeneSettle', 'litUpNene', groundY - getProperty('litUpNene.height'), 0.38, 'quadIn')
    elseif tag == 'litUpNeneSettle' then
        playAnim('litUpNene', 'idle', true)
        updateHitbox('litUpNene')
        setProperty('litUpNene.x', centerX - getProperty('litUpNene.width') * 0.5)
        setProperty('litUpNene.y', groundY - getProperty('litUpNene.height'))
    end
end
end

do
local starts = {0, 128, 256, 1024, 1152}
local nextStart = 1
local active = false
local fading = false
local fadeStep = 0
local centerX = 0

function giggle.onCreate()
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

function giggle.onStepHit()
    updateGiggle()
end

function giggle.onUpdatePost(elapsed)
    updateGiggle()
end

function giggle.onTweenCompleted(tag)
    if tag == 'litUpGiggleFade' then
        active = false
        setProperty('litUpGiggle.visible', false)
    end
end

function giggle.onGameOverStart()
    nextStart = #starts + 1
    active = false
    cancelTween('litUpGiggleIn')
    cancelTween('litUpGiggleLean')
    cancelTween('litUpGiggleFade')
    if luaSpriteExists('litUpGiggle') then setProperty('litUpGiggle.visible', false) end
end
end

do
local shown = false
local finished = false
local startY = 0
local endY = 0

function spring.onCreate()
    makeAnimatedLuaSprite('litUpSpring', 'fahmix/weekend1/spring', 0, 0)
    addAnimationByPrefix('litUpSpring', 'idle', 'spring idle', 6, true)
    playAnim('litUpSpring', 'idle', true)
    local scale = screenHeight * 0.8 / getProperty('litUpSpring.height')
    scaleObject('litUpSpring', scale, scale)
    setProperty('litUpSpring.x', (screenWidth - getProperty('litUpSpring.width')) * 0.5)
    startY = screenHeight + 20
    endY = -getProperty('litUpSpring.height') - 20
    setProperty('litUpSpring.y', startY)
    setObjectCamera('litUpSpring', 'other')
    setProperty('litUpSpring.visible', false)
    addLuaSprite('litUpSpring', true)
end

local function updateSpring()
    if finished then return end
    if curStep >= 308 then
        finished = true
        setProperty('litUpSpring.y', endY)
        setProperty('litUpSpring.visible', false)
        return
    end
    if curStep < 304 then return end
    if not shown then
        shown = true
        setProperty('litUpSpring.visible', true)
        setObjectOrder('litUpSpring', getProperty('members.length') - 1)
        if luaSpriteExists('logo') then
            setObjectOrder('logo', getObjectOrder('litUpSpring') + 1)
        end
    end
    local progress = math.max(0, math.min(1, (curDecStep - 304) / 4))
    setProperty('litUpSpring.y', startY + (endY - startY) * progress)
end

function spring.onStepHit()
    updateSpring()
end

function spring.onUpdatePost(elapsed)
    updateSpring()
end

function spring.onGameOverStart()
    finished = true
    if luaSpriteExists('litUpSpring') then setProperty('litUpSpring.visible', false) end
end
end

do
local shown = false
local finished = false

function burger.onCreate()
    makeAnimatedLuaSprite('litUpBurger', 'fahmix/weekend1/burger', 0, 0)
    addAnimationByPrefix('litUpBurger', 'idle', 'burger idle', 6, true)
    playAnim('litUpBurger', 'idle', true)
    local scale = screenHeight * 0.8 / getProperty('litUpBurger.height')
    scaleObject('litUpBurger', scale, scale)
    setProperty('litUpBurger.x', (screenWidth - getProperty('litUpBurger.width')) * 0.5)
    setProperty('litUpBurger.y', (screenHeight - getProperty('litUpBurger.height')) * 0.5)
    setObjectCamera('litUpBurger', 'other')
    setProperty('litUpBurger.visible', false)
    addLuaSprite('litUpBurger', true)
end

local function updateBurger()
    if finished then return end
    if curStep >= 313 then
        finished = true
        setProperty('litUpBurger.visible', false)
        return
    end
    if curStep >= 308 and not shown then
        shown = true
        setProperty('litUpBurger.visible', true)
        setObjectOrder('litUpBurger', getProperty('members.length') - 1)
        if luaSpriteExists('logo') then
            setObjectOrder('logo', getObjectOrder('litUpBurger') + 1)
        end
    end
end

function burger.onStepHit()
    updateBurger()
end

function burger.onUpdatePost(elapsed)
    updateBurger()
end

function burger.onGameOverStart()
    finished = true
    if luaSpriteExists('litUpBurger') then setProperty('litUpBurger.visible', false) end
end
end

do
local steps = {375, 444}
local nextPass = 1
local stopped = false
local margin = 0

function far.onCreate()
    makeAnimatedLuaSprite('litUpFar', 'fahmix/weekend1/far', 0, 0)
    addAnimationByPrefix('litUpFar', 'idle', 'far idle', 6, true)
    playAnim('litUpFar', 'idle', true)
    local scale = screenHeight * 0.8 * 0.4 / getProperty('litUpFar.height')
    scaleObject('litUpFar', scale, scale)
    margin = math.max(getProperty('litUpFar.width'), getProperty('litUpFar.height')) + 20
    setObjectCamera('litUpFar', 'other')
    setProperty('litUpFar.visible', false)
    addLuaSprite('litUpFar', true)
end

local function updateFar()
    if stopped then return end
    while nextPass <= #steps and curStep >= steps[nextPass] do
        local pass = nextPass
        nextPass = nextPass + 1
        if curStep < steps[pass] + 4 then
            local reverse = pass == 2
            setProperty('litUpFar.x', reverse and screenWidth + margin or -margin)
            setProperty('litUpFar.y', reverse and screenHeight + margin or -margin)
            setProperty('litUpFar.angle', 0)
            setProperty('litUpFar.visible', true)
            setObjectOrder('litUpFar', getProperty('members.length') - 1)
            if luaSpriteExists('logo') then
                setObjectOrder('logo', getObjectOrder('litUpFar') + 1)
            end
            doTweenX('litUpFarX', 'litUpFar', reverse and -margin or screenWidth + margin, 0.6, 'linear')
            doTweenY('litUpFarY', 'litUpFar', reverse and -margin or screenHeight + margin, 0.6, 'linear')
            doTweenAngle('litUpFarSpin', 'litUpFar', reverse and -360 or 360, 0.6, 'linear')
        end
    end
end

function far.onStepHit()
    updateFar()
end

function far.onUpdatePost(elapsed)
    updateFar()
end

function far.onTweenCompleted(tag)
    if tag == 'litUpFarSpin' then setProperty('litUpFar.visible', false) end
end

function far.onGameOverStart()
    stopped = true
    cancelTween('litUpFarX')
    cancelTween('litUpFarY')
    cancelTween('litUpFarSpin')
    if luaSpriteExists('litUpFar') then setProperty('litUpFar.visible', false) end
end
end

function onCreate()
    nene.onCreate()
    giggle.onCreate()
    spring.onCreate()
    burger.onCreate()
    far.onCreate()
end

function onCreatePost()
    nene.onCreatePost()
end

function onStepHit()
    nene.onStepHit()
    giggle.onStepHit()
    spring.onStepHit()
    burger.onStepHit()
    far.onStepHit()
end

function onUpdatePost(elapsed)
    nene.onUpdatePost(elapsed)
    giggle.onUpdatePost(elapsed)
    spring.onUpdatePost(elapsed)
    burger.onUpdatePost(elapsed)
    far.onUpdatePost(elapsed)
end

function onTweenCompleted(tag)
    nene.onTweenCompleted(tag)
    giggle.onTweenCompleted(tag)
    far.onTweenCompleted(tag)
end

function onGameOverStart()
    giggle.onGameOverStart()
    spring.onGameOverStart()
    burger.onGameOverStart()
    far.onGameOverStart()
end
