local atlas = 'Distractions/smash'
local distractionScale = 1.5
local ready = {name = 'ready', tag = 'smashReady'}
local ness = {name = 'ness', tag = 'smashNess'}
local kirby = {name = 'kirby', tag = 'smashKirby'}
local words = {
    {name = 'break', tag = 'smashBreak', step = 1059, row = 1 / 6},
    {name = 'the', tag = 'smashThe', step = 1064, row = 0.50},
    {name = 'targets', tag = 'smashTargets', step = 1067, row = 5 / 6}
}
local kirbySteps = {796, 850, 865, 874}
local longFlash = 0.8
local flashInterval = 0.2
local endingAlpha = 0
local gameOver = false

local function createCue(cue, widthLimit, heightLimit)
    local tag = cue.tag
    makeAnimatedLuaSprite(tag, atlas, 0, 0)
    addAnimationByPrefix(tag, 'idle', 'smash ' .. cue.name, 0, false)
    playAnim(tag, 'idle', true)
    local scale = math.min(screenWidth * widthLimit / getProperty(tag .. '.frameWidth'),
        screenHeight * heightLimit / getProperty(tag .. '.frameHeight')) * distractionScale
    scaleObject(tag, scale, scale)
    cue.width = getProperty(tag .. '.width')
    cue.height = getProperty(tag .. '.height')
    cue.visible = false
    setObjectCamera(tag, 'other')
    setProperty(tag .. '.visible', false)
    setProperty(tag .. '.active', false)
    addLuaSprite(tag, true)
end

local function show(cue, x, y, age, alpha)
    if not cue.visible then
        setProperty(cue.tag .. '.visible', true)
        cue.visible = true
    end
    setProperty(cue.tag .. '.x', x - cue.width / 2)
    setProperty(cue.tag .. '.y', y - cue.height / 2)
    setProperty(cue.tag .. '.alpha', alpha or 1)
    setProperty(cue.tag .. '.animation.curAnim.curFrame', math.floor(age * 8) % 2)
end

local function hide(cue)
    if cue.visible then
        setProperty(cue.tag .. '.visible', false)
        cue.visible = false
    end
end

local function secondsSince(step)
    return (curDecStep - step) * stepCrochet / 1000
end

local function randomFlash(cue, slot, age)
    local point = cue.points[slot]
    if not point then
        local insetX = cue.width / 2 + screenWidth * 0.02
        local insetY = cue.height / 2 + screenHeight * 0.02
        point = {getRandomFloat(insetX, screenWidth - insetX), getRandomFloat(insetY, screenHeight - insetY)}
        cue.points[slot] = point
    end
    show(cue, point[1], point[2], age)
end

local function updateReady()
    local start = curDecStep >= 877 and 877 or 47
    local age = secondsSince(start)
    local fadeAge = secondsSince(start + 10)
    if age < 0 or fadeAge >= 0.3 then
        hide(ready)
        return
    end
    local remaining = (1 - math.min(age / 0.42, 1)) ^ 3
    local y = screenHeight / 2 + (screenHeight + ready.height) / 2 * remaining
    show(ready, screenWidth / 2, y, age, 1 - math.max(fadeAge, 0) / 0.3)
end

local function updateNess()
    if curDecStep >= 748 and curDecStep < 874 then
        local start = curDecStep >= 797 and 797 or (curDecStep >= 764 and 764 or 748)
        local age = secondsSince(start)
        if start == 797 and age >= longFlash then
            local elapsed = age - longFlash
            local slot = math.floor(elapsed / flashInterval)
            randomFlash(ness, slot, elapsed - slot * flashInterval)
            return
        elseif age < (start == 797 and longFlash or 0.5) then
            show(ness, screenWidth / 2, screenHeight / 2, age)
            return
        end
    end
    hide(ness)
end

local function updateKirby()
    for i = #kirbySteps, 1, -1 do
        local age = secondsSince(kirbySteps[i])
        if age >= 0 then
            if age < longFlash then
                randomFlash(kirby, i, age)
                return
            end
            break
        end
    end
    hide(kirby)
end

local function updateWords()
    local fall = math.max(0, secondsSince(1075)) / 0.6
    for _, word in ipairs(words) do
        local age = secondsSince(word.step)
        if age >= 0 and fall < 1 then
            show(word, screenWidth / 2, screenHeight * (word.row + fall * fall), age)
        else
            hide(word)
        end
    end
end

function onCreatePost()
    createCue(ready, 0.52, 0.36)
    createCue(ness, 0.24, 0.29)
    createCue(kirby, 0.24, 0.29)
    ness.points = {}
    kirby.points = {}
    for _, word in ipairs(words) do
        createCue(word, 0.5, 0.22)
    end
    makeLuaSprite('blackOverlay', '', 0, 0)
    makeGraphic('blackOverlay', screenWidth, screenHeight, '000000')
    setObjectCamera('blackOverlay', 'other')
    setProperty('blackOverlay.themeScenePaper', false)
    setProperty('blackOverlay.alpha', 0)
    addLuaSprite('blackOverlay', true)
end

function onUpdatePost()
    if gameOver then return end
    updateReady()
    updateNess()
    updateKirby()
    updateWords()
    local alpha = math.max(0, math.min(secondsSince(1211) / 0.5, 1))
    if alpha ~= endingAlpha then
        setProperty('blackOverlay.alpha', alpha)
        endingAlpha = alpha
    end
end

function onGameOverStart()
    gameOver = true
    hide(ready)
    hide(ness)
    hide(kirby)
    for _, word in ipairs(words) do hide(word) end
    setProperty('blackOverlay.alpha', 0)
end
