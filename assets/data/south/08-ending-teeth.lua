local inGameOver = false
local laughStart = 149550
local laughDuration = 2900
local sampleTime = 40
local envelope = {
    0.063, 0.083, 0.143, 0.330, 0.399, 0.363, 0.379, 0.176, 0.241, 0.309,
    1.000, 1.000, 0.379, 0.463, 0.722, 1.000, 0.512, 0.280, 0.416, 1.000,
    0.887, 0.273, 0.343, 0.868, 0.874, 0.238, 0.238, 0.631, 0.929, 0.664,
    0.270, 0.274, 0.755, 0.849, 0.341, 0.286, 0.409, 0.542, 0.616, 0.161,
    0.095, 0.312, 0.411, 0.224, 0.000, 0.000, 0.214, 0.236, 0.108, 0.100,
    0.157, 0.196, 0.054, 0.000, 0.000, 0.078, 0.118, 0.000, 0.000, 0.000,
    0.035, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000,
    0.000
}
local teeth = {}
local baseScale = 1

local function clamp(value)
    return math.max(0, math.min(1, value))
end

local function hideTeeth()
    for tag in pairs(teeth) do setProperty(tag .. '.visible', false) end
end

local function laughAmount(elapsed)
    if elapsed < 0 then return 0 end
    local sample = elapsed / sampleTime
    local index = math.floor(sample) + 1
    local blend = sample - math.floor(sample)
    blend = blend * blend * (3 - 2 * blend)
    local first = envelope[index] or 0
    return first + ((envelope[index + 1] or 0) - first) * blend
end

function onCreate()
    baseScale = math.min(screenWidth * 0.48, screenHeight * 0.90) / 1037
    for _, part in ipairs({'top', 'bottom'}) do
        local tag = 'southTeeth' .. (part == 'top' and 'Top' or 'Bottom')
        makeAnimatedLuaSprite(tag, 'fahmix/week2/south/teeth', 0, 0)
        addAnimationByPrefix(tag, 'laugh', 'teeth ' .. part, 8, true)
        playAnim(tag, 'laugh', true)
        setProperty(tag .. '.animation.curAnim.paused', true)
        scaleObject(tag, baseScale, baseScale)
        setScrollFactor(tag, 0, 0)
        setObjectCamera(tag, 'other')
        setProperty(tag .. '.themeScenePaper', false)
        setProperty(tag .. '.visible', false)
        addLuaSprite(tag, true)
        teeth[tag] = {
            width = getProperty(tag .. '.width'),
            height = getProperty(tag .. '.height'),
            sourceHeight = part == 'top' and 417 or 361,
            outerY = part == 'top' and {0, 4} or {360, 361}
        }
    end
end

function onCreatePost()
    for _, tag in ipairs({'southTeethTop', 'southTeethBottom'}) do
        setObjectOrder(tag, getProperty('members.length') - 1)
    end
end

function onUpdatePost(elapsed)
    hideTeeth()
    if inGameOver then return end
    local time = getSongPosition() - laughStart
    if time < 0 or time >= laughDuration then return end
    local amount = laughAmount(time)
    local sway = math.sin(time * 0.021) * amount
    local stretch = (laughAmount(time - 45) - amount) * 0.50
    local bounce = math.sin(time * 0.027) * amount * 12 - amount * 24 + stretch * 52
    local alpha = clamp(time / 300) * (1 - clamp((time - 2200) / 700))
    local overlap = 300 * baseScale
    local opening = amount ^ 0.8
    local frame = math.floor(time * 0.008) % 2
    local scaleX = baseScale * math.max(0.78, math.min(1.42, 1 + amount * 0.22 - stretch * 0.65))
    local scaleY = baseScale * math.max(0.58, math.min(1.35, 1 - amount * 0.24 + stretch))
    for _, tag in ipairs({'southTeethTop', 'southTeethBottom'}) do
        local top = tag == 'southTeethTop'
        local sprite = teeth[tag]
        local other = teeth[top and 'southTeethBottom' or 'southTeethTop']
        local direction = top and -1 or 1
        local closedY = screenHeight * 0.5 + direction * (other.height - overlap) * 0.5
        local edgeY = (top and 0 or screenHeight) - (sprite.outerY[frame + 1] - sprite.sourceHeight * 0.5) * scaleY
        local centerY = closedY + (edgeY - closedY) * opening + bounce * (1 - opening)
        setProperty(tag .. '.visible', true)
        setProperty(tag .. '.alpha', alpha)
        setProperty(tag .. '.x', (screenWidth - sprite.width) * 0.5 + sway * 3)
        setProperty(tag .. '.y', centerY - sprite.height * 0.5)
        setProperty(tag .. '.scale.x', scaleX)
        setProperty(tag .. '.scale.y', scaleY)
        setProperty(tag .. '.angle', direction * sway * 6.2 * (1 - clamp((opening - 0.92) / 0.08)))
        setProperty(tag .. '.animation.curAnim.curFrame', frame)
    end
end

function onGameOverStart()
    inGameOver = true
    hideTeeth()
end

function onEndSong()
    hideTeeth()
    return Function_Continue
end
