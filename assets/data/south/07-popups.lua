local inGameOver = false
local spriteScale = 0.57
local sprites = {}
local skellySteps = {1120, 1123, 1127, 1131, 1135, 1141}

local function clamp(value)
    return math.max(0, math.min(1, value))
end

local function createSprite(tag, asset, frames, fps, loop)
    makeAnimatedLuaSprite(tag, 'fahmix/week2/south/' .. asset, 0, 0)
    addAnimationByPrefix(tag, 'idle', asset .. ' idle', fps, loop)
    playAnim(tag, 'idle', true)
    scaleObject(tag, spriteScale, spriteScale)
    setScrollFactor(tag, 0, 0)
    setObjectCamera(tag, 'other')
    setProperty(tag .. '.animation.curAnim.paused', true)
    setProperty(tag .. '.visible', false)
    addLuaSprite(tag, true)
    sprites[tag] = {
        width = getProperty(tag .. '.width'),
        height = getProperty(tag .. '.height'),
        frames = frames,
        fps = fps,
        loop = loop
    }
end

local function animate(tag, elapsed)
    local sprite = sprites[tag]
    local frame = math.floor(math.max(0, elapsed) * sprite.fps / 1000)
    if sprite.loop then
        frame = frame % sprite.frames
    else
        frame = math.min(sprite.frames - 1, frame)
    end
    setProperty(tag .. '.animation.curAnim.curFrame', frame)
end

local function barkAt(position, startStep)
    local elapsed = position - startStep * stepCrochet
    local fadeAt = 7 * stepCrochet
    if elapsed < 0 or elapsed >= fadeAt + 300 then return end
    local sprite = sprites.southBark
    local progress = clamp(elapsed / 200)
    local startY = screenHeight + 20
    local endY = screenHeight - sprite.height + 20
    setProperty('southBark.visible', true)
    setProperty('southBark.x', (screenWidth - sprite.width) * 0.5)
    setProperty('southBark.y', startY + (endY - startY) * (1 - (1 - progress) ^ 2))
    setProperty('southBark.alpha', 1 - clamp((elapsed - fadeAt) / 300))
    animate('southBark', elapsed)
end

local function laughAt(position, startStep)
    local elapsed = position - startStep * stepCrochet
    local fadeAt = 8 * stepCrochet
    if elapsed < 0 or elapsed >= fadeAt + 1200 then return end
    local sprite = sprites.southLaffatu
    local progress = clamp((elapsed - fadeAt) / 1200)
    local shrink = progress * progress
    local scale = spriteScale * (1 - 0.65 * shrink)
    setProperty('southLaffatu.visible', true)
    setProperty('southLaffatu.x', (screenWidth - sprite.width) * 0.5)
    setProperty('southLaffatu.y', (screenHeight - sprite.height) * 0.5)
    setProperty('southLaffatu.scale.x', scale)
    setProperty('southLaffatu.scale.y', scale)
    setProperty('southLaffatu.alpha', 1 - progress)
    setProperty('southLaffatu.angle', 25 * shrink)
    animate('southLaffatu', elapsed)
end

local function skellyAt(position, startStep, bottom)
    local elapsed = position - startStep * stepCrochet
    if elapsed < 0 or elapsed >= 450 then return end
    local tag = bottom and 'southSkellyBottom' or 'southSkellyTop'
    local sprite = sprites[tag]
    local startX = bottom and screenWidth + 20 or -sprite.width - 20
    local endX = bottom and -sprite.width - 20 or screenWidth + 20
    setProperty(tag .. '.visible', true)
    setProperty(tag .. '.x', startX + (endX - startX) * elapsed / 450)
    setProperty(tag .. '.y', bottom and screenHeight - sprite.height - 20 or 20)
    animate(tag, elapsed)
end

local function skiddryAt(position)
    local elapsed = position - 1144 * stepCrochet
    local fadeAt = 7 * stepCrochet
    if elapsed < 0 or elapsed >= fadeAt + 200 then return end
    local sprite = sprites.southSkiddry
    local startY = -sprite.height - 20
    local endY = (screenHeight - sprite.height) * 0.5
    local progress = clamp(elapsed / 200)
    setProperty('southSkiddry.visible', true)
    setProperty('southSkiddry.x', (screenWidth - sprite.width) * 0.5)
    setProperty('southSkiddry.y', startY + (endY - startY) * (1 - (1 - progress) ^ 2))
    setProperty('southSkiddry.angle', 360 * math.max(0, elapsed - 4 * stepCrochet) / (3 * stepCrochet))
    setProperty('southSkiddry.alpha', 1 - clamp((elapsed - fadeAt) / 200))
    animate('southSkiddry', elapsed)
end

function onCreate()
    createSprite('southBark', 'bark', 4, 12, true)
    createSprite('southLaffatu', 'laffatu', 2, 6, true)
    createSprite('southSkellyTop', 'skelly', 2, 3, true)
    createSprite('southSkellyBottom', 'skelly', 2, 3, true)
    createSprite('southSkiddry', 'skiddry', 5, 24, false)
    setProperty('southSkellyBottom.flipX', true)
end

function onCreatePost()
    for _, tag in ipairs({'southBark', 'southLaffatu', 'southSkellyTop', 'southSkellyBottom', 'southSkiddry'}) do
        local layer = getObjectOrder('southDarkness')
        if getObjectOrder(tag) < layer then layer = layer - 1 end
        setObjectOrder(tag, layer)
    end
end

function onUpdatePost(elapsed)
    if inGameOver then return end
    for tag in pairs(sprites) do setProperty(tag .. '.visible', false) end
    local position = getSongPosition()
    barkAt(position, 367)
    barkAt(position, 1017)
    laughAt(position, 632)
    laughAt(position, 1337)
    for index, step in ipairs(skellySteps) do skellyAt(position, step, index % 2 == 0) end
    skiddryAt(position)
end

function onGameOverStart()
    inGameOver = true
    for tag in pairs(sprites) do setProperty(tag .. '.visible', false) end
end
