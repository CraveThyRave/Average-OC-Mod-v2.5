local inGameOver = false
local botplayAlpha = 0.6
local normalTints = {}

local function clamp(value)
    return math.max(0, math.min(value, 1))
end

local function tintNormalSprites(amount)
    for tag, original in pairs(normalTints) do
        local multiplier = 1 - amount
        local red = math.floor((math.floor(original / 65536) % 256) * multiplier + 0.5)
        local green = math.floor((math.floor(original / 256) % 256) * multiplier + 0.5)
        local blue = math.floor((original % 256) * multiplier + 0.5)
        setProperty(tag .. '.color', getColorFromHex(string.format('%02X%02X%02X', red, green, blue)))
    end
end

local function makeCover(tag, color, camera)
    makeLuaSprite(tag, nil, -screenWidth / 2, -screenHeight / 2)
    makeGraphic(tag, 8, 8, color)
    scaleObject(tag, screenWidth / 4, screenHeight / 4, false)
    setProperty(tag .. '.origin.x', 0)
    setProperty(tag .. '.origin.y', 0)
    setProperty(tag .. '.offset.x', 0)
    setProperty(tag .. '.offset.y', 0)
    setProperty(tag .. '.antialiasing', false)
    setScrollFactor(tag, 0, 0)
    setObjectCamera(tag, camera)
    addLuaSprite(tag, true)
end

local function darknessAt(position)
    local cues = {
        {383 * stepCrochet, 200, 0},
        {896 * stepCrochet, 500, 0.25},
        {1019 * stepCrochet, 300, 0},
        {1273 * stepCrochet, 9 * stepCrochet, 0.65},
        {1343 * stepCrochet, 200, 0},
        {1599 * stepCrochet, 200, 0.20}
    }
    local value = 0.10
    for _, cue in ipairs(cues) do
        if position < cue[1] then return value end
        if position < cue[1] + cue[2] then
            return value + (cue[3] - value) * clamp((position - cue[1]) / cue[2])
        end
        value = cue[3]
    end
    return value
end

function onCreate()
    makeCover('southOutroBlack', '000000', 'other')
    setProperty('southOutroBlack.alpha', 0)
    makeCover('southDarkness', '000A26', 'other')
    setProperty('southDarkness.alpha', 0.10)
    makeCover('southIntroBlack', '000000', 'other')
    setProperty('southIntroBlack.alpha', 1)
end

function onCreatePost()
    for _, tag in ipairs({'paper', 'phoenix-spooky', 'raven-spooky', 'boyfriend', 'dad'}) do
        local original = getProperty(tag .. '.color')
        normalTints[tag] = original
    end
    tintNormalSprites(0.08)
    for _, tag in ipairs({'southDarkness', 'southIntroBlack', 'southOutroBlack'}) do
        setObjectOrder(tag, getProperty('members.length') - 1)
    end
    setProperty('camHUD.alpha', 0)
    botplayAlpha = getProperty('botplayTxt.alpha') or 0.6
    setProperty('botplayTxt.alpha', 0)
end

function onUpdatePost(elapsed)
    if inGameOver then return end
    local position = getSongPosition()
    local flashAlpha = math.max(getProperty('lightning-spookykids.alpha') or 0, getProperty('paper2.alpha') or 0)
    local lightningVisibility = 1 - clamp(flashAlpha)
    tintNormalSprites(0.08 * lightningVisibility)
    setProperty('southDarkness.alpha', darknessAt(position) * lightningVisibility)
    setProperty('southIntroBlack.alpha', 1 - clamp((position - 112 * stepCrochet) / (16 * stepCrochet)))
    setProperty('southOutroBlack.alpha', clamp((position - 1623 * stepCrochet) / (21 * stepCrochet)))

    local hudVisibility = clamp((position - 160 * stepCrochet) / 350)
    setProperty('camHUD.alpha', hudVisibility)
    setProperty('botplayTxt.alpha', botplayAlpha * hudVisibility)
end

function onGameOverStart()
    inGameOver = true
    for tag, color in pairs(normalTints) do setProperty(tag .. '.color', color) end
    for _, tag in ipairs({'southIntroBlack', 'southOutroBlack', 'southDarkness'}) do
        setProperty(tag .. '.visible', false)
    end
    setProperty('camHUD.alpha', 1)
    setProperty('botplayTxt.alpha', botplayAlpha)
end
