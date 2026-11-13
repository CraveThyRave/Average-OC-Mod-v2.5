local appearanceTime = -1
local latestStartTime = -1
local startedAt = -1
local finished = false
local fadeTime = 3000
local holdTime = 3000
local lilaCenterX = 0
local lilaY = 730
local lilaScale = 0.55

local function setLilaScale(progress)
    local scale = lilaScale * (0.8 + 0.2 * progress)
    for _, tag in ipairs({'lila', 'lila-lightning'}) do
        scaleObject(tag, scale, scale)
        setProperty(tag .. '.x', lilaCenterX - getProperty(tag .. '.width') * 0.5)
        setProperty(tag .. '.y', lilaY + getProperty(tag .. '.frameHeight') * lilaScale - getProperty(tag .. '.height'))
    end
end

local function hideLila()
    setProperty('lila.alpha', 0)
    setProperty('lila-lightning.alpha', 0)
end

local function sceneVisible()
    for _, tag in ipairs({'dablack', 'dawhite'}) do
        if luaSpriteExists(tag) and getProperty(tag .. '.visible') and getProperty(tag .. '.alpha') > 0.01 then
            return false
        end
    end
    return getProperty('camGame.visible') and getProperty('camGame.alpha') > 0.01
end

function onCreate()
    makeAnimatedLuaSprite('lila', 'Stage/Background Characters/lila', 0, lilaY)
    addAnimationByPrefix('lila', 'idle', 'lila norm', 6, true)
    addLuaSprite('lila', false)

    makeAnimatedLuaSprite('lila-lightning', 'Stage/Background Characters/lila', 0, lilaY)
    addAnimationByPrefix('lila-lightning', 'idle', 'lila lightning', 6, true)
    addLuaSprite('lila-lightning', false)
    setLilaScale(0)
    hideLila()
end

function onCreatePost()
    lilaCenterX = getProperty('background.x') + 1600 * getProperty('background.scale.x')
    setLilaScale(0)
    setObjectOrder('lila', getObjectOrder('background') + 1)
    setObjectOrder('lila-lightning', getObjectOrder('lila') + 1)
end

function onSongStart()
    latestStartTime = 1308 * stepCrochet - fadeTime * 2 - holdTime - 500
    appearanceTime = getRandomFloat(64 * stepCrochet, latestStartTime - 1000)
    startedAt = -1
    finished = false
    setLilaScale(0)
    hideLila()
end

function onUpdatePost(elapsed)
    if finished or appearanceTime < 0 then return end
    if inGameOver or getProperty('isDead') then
        finished = true
        hideLila()
        return
    end

    local position = getSongPosition()
    if startedAt < 0 then
        if position < appearanceTime then return end
        if position > latestStartTime then
            finished = true
            return
        end
        if not sceneVisible() then return end
        startedAt = position
    end

    local age = position - startedAt
    setLilaScale(math.max(0, math.min(1, age / fadeTime)))
    local opacity = 0
    if age >= fadeTime * 2 + holdTime then
        finished = true
    elseif age >= fadeTime + holdTime then
        opacity = 1 - (age - fadeTime - holdTime) / fadeTime
    elseif age >= fadeTime then
        opacity = 1
    elseif age >= 0 then
        opacity = age / fadeTime
    end

    local flash = math.max(0, math.min(1, getProperty('paper2.alpha')))
    setProperty('lila.alpha', opacity)
    setProperty('lila-lightning.alpha', opacity * flash)
    setProperty('lila-lightning.animation.curAnim.curFrame', getProperty('lila.animation.curAnim.curFrame'))
end

function onGameOver()
    finished = true
    hideLila()
end

function onGameOverStart()
    onGameOver()
end
