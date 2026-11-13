local cameraX = 1720
local cameraY = 1104
local scenery = {
    {tag = 'testSmog', prefix = 'botfah bg smog', x = 850, y = 570, scaleX = 1.4, scaleY = 1.4},
    {tag = 'testSun', prefix = 'botfah bg sun', x = 650, y = 600, scaleX = 1.1, scaleY = 1.1},
    {tag = 'testGrass', asset = 'norm floor', prefix = 'norm floor idle', x = 600, y = 1295, scaleX = 1.65, scaleY = 1.1}
}

local plants = {}
local growthStep = 0
local fahgerStep = 1059
local isSmash = false

local function plant(tag, asset, x, y, sx, sy, front, flip, grow, idle)
    makeAnimatedLuaSprite(tag, 'fahmix/test/' .. asset, x, y)
    local growPrefix = asset .. ' ' .. (grow or 'grow')
    addAnimationByPrefix(tag, 'grow', growPrefix, 14, false)
    addAnimationByPrefix(tag, 'idle', asset .. ' ' .. (idle or 'idle'), 6, true)
    if grow then addAnimationByIndices(tag, 'retract', growPrefix, '2,1,0', 14) end
    scaleObject(tag, sx, sy)
    setProperty(tag .. '.flipX', flip)
    addLuaSprite(tag, front)
    setProperty(tag .. '.visible', false)
    table.insert(plants, {tag = tag, flower = grow ~= nil})
end

local function makeSmashPlants()
    plant('smashLongFloor', 'long-floor', 688.45, 1135.68, 1.4421, 0.95095, false, false)
    setObjectOrder('smashLongFloor', getObjectOrder('testGrass') + 1)
    for i = 0, 6 do
        local tall = i % 2 == 0
        local grow = tall and 'tall-flower-intreo' or 'mini-flower-intro'
        local idle = tall and 'tall-flower-idle' or 'miniflower-idle'
        local height = tall and 605 or 271
        local foot = 1425 + 15 * (i - 3) ^ 2
        plant('smashFlower' .. i, 'fahlowers robor', 860 + i * 252, foot - height * 0.82, 0.82, 0.82, false, false, grow, idle)
        setObjectOrder('smashFlower' .. i, getObjectOrder('smashLongFloor'))
    end
    plant('smashGrassLeft', 'front-grass', 780, 1360, 0.784, 0.56, true, false)
    plant('smashGrassRight', 'front-grass', 2135, 1360, 0.784, 0.56, true, true)
end

local function updateSmashPlants()
    if curStep >= 52 and growthStep == 0 then
        growthStep = 52
        setProperty('testGrass.visible', false)
        for _, part in ipairs(plants) do
            setProperty(part.tag .. '.visible', true)
            playAnim(part.tag, 'grow', true)
            part.playing = 'grow'
        end
    end
    if curStep >= fahgerStep and growthStep == 52 then
        growthStep = fahgerStep
        for _, part in ipairs(plants) do
            if part.flower then
                playAnim(part.tag, 'retract', true)
                part.playing = 'retract'
            end
        end
    end
    for _, part in ipairs(plants) do
        if part.playing and getProperty(part.tag .. '.animation.curAnim.finished') then
            if part.playing == 'retract' then setProperty(part.tag .. '.visible', false)
            else playAnim(part.tag, 'idle', true) end
            part.playing = nil
        end
    end
end


local ridge = false
local pipePhase = 'waiting'
local mamaX, mamaFloor, mamaScale = 1710, 1473, 0.9
local glitches = {
    {tag = 'phoenix', bottoms = {660, 660, 645, 648}, ground = 0},
    {tag = 'raven', bottoms = {627, 625, 607, 625}, ground = -28}
}
local pipeBases = {2225, 2070, 1494, 1507, 2070, 2225}
local pipeCenters = {960, 1230, 1500, 1940, 2210, 2480}

local function makeRidgePipes()
    ridge = true
    for i, center in ipairs(pipeCenters) do
        local tag = 'ridgePipe' .. i
        makeAnimatedLuaSprite(tag, 'fahmix/test/pipe', center - 238, pipeBases[i] - 982 * 1.4)
        addAnimationByPrefix(tag, 'grow', 'pipe pipe-grow', 16, false)
        addAnimationByPrefix(tag, 'idle', 'pipe idle', 6, true)
        addAnimationByIndices(tag, 'down', 'pipe pipe-grow', '5,4,3,2,1,0', 16)
        scaleObject(tag, 1, 1.4)
        setProperty(tag .. '.flipX', i > 3)
        addLuaSprite(tag, false)
        setObjectOrder(tag, getObjectOrder('testGrass'))
        setProperty(tag .. '.visible', false)
    end
    for _, pose in ipairs(glitches) do
        local tag = 'ridgeGlitch' .. pose.tag
        makeAnimatedLuaSprite(tag, 'fahmix/test/mamas', mamaX - 341 * mamaScale, mamaFloor)
        addAnimationByPrefix(tag, 'glitch', 'mamas ' .. pose.tag .. '-glitch', 9, true)
        scaleObject(tag, mamaScale, mamaScale)
        addLuaSprite(tag, false)
        setProperty(tag .. '.visible', false)
    end
end

local pipeBottoms = {
    grow = {970, 965, 982, 979, 972, 957},
    down = {957, 972, 979, 982, 965, 970},
    idle = {1005, 1026, 1052}
}
local lastPipeFrame = -1

local function alignPipes()
    local frame = getProperty('ridgePipe1.animation.curAnim.curFrame')
    if frame == lastPipeFrame then return end
    lastPipeFrame = frame
    local bottom = pipeBottoms[pipePhase][frame + 1] * 1.4
    for i, base in ipairs(pipeBases) do setProperty('ridgePipe' .. i .. '.y', base - bottom) end
end

local function playPipes(anim)
    pipePhase = anim
    lastPipeFrame = -1
    for i, center in ipairs(pipeCenters) do
        local tag = 'ridgePipe' .. i
        playAnim(tag, anim, true)
        updateHitbox(tag)
        local idle = anim == 'idle'
        setProperty(tag .. '.x', center - (idle and 139.5 or 238.5))
        setProperty(tag .. '.visible', true)
    end
end

local function updateRidgePipes()
    if not ridge then return end
    if curStep >= 111 and pipePhase == 'waiting' then
        playPipes('grow')
        setProperty('testMamas.visible', false)
        for _, pose in ipairs(glitches) do
            local tag = 'ridgeGlitch' .. pose.tag
            playAnim(tag, 'glitch', true)
            setProperty(tag .. '.visible', true)
        end
    end
    if curStep >= 1008 and (pipePhase == 'grow' or pipePhase == 'idle') then
        playPipes('down')
        setProperty('testMamas.visible', true)
        for _, pose in ipairs(glitches) do setProperty('ridgeGlitch' .. pose.tag .. '.visible', false) end
    end
    if pipeBottoms[pipePhase] then alignPipes() end
    if pipePhase == 'grow' or pipePhase == 'idle' then
        for _, pose in ipairs(glitches) do
            local tag = 'ridgeGlitch' .. pose.tag
            local frame = getProperty(tag .. '.animation.curAnim.curFrame') + 1
            setProperty(tag .. '.y', mamaFloor + (pose.ground - pose.bottoms[frame]) * mamaScale)
        end
        if pipePhase == 'grow' and getProperty('ridgePipe1.animation.curAnim.finished') then playPipes('idle'); alignPipes() end
    elseif pipePhase == 'down' and getProperty('ridgePipe1.animation.curAnim.finished') then
        pipePhase = 'finished'
        for i in ipairs(pipeCenters) do setProperty('ridgePipe' .. i .. '.visible', false) end
    end
end

local smashStarted = false
local fahgerChanged = false
local smashRayIdle = false
local chainBopping = false
local chainY = 623
local rays = {{800, 713, 1.6}, {920, 858, 1.4}, {1030, 1028, 1.2}, {850, 1198, 1.5}, {850, 588, 0.5}, {2050, 588, 0.5}}

local function makeSmashCue()
    for i, ray in ipairs(rays) do
        local tag = 'smashRay' .. i
        makeAnimatedLuaSprite(tag, 'Freeplay-Chrs/fah/big-orange', ray[1], ray[2])
        addAnimationByPrefix(tag, 'enter', 'big-orange trans', 10, false)
        addAnimationByPrefix(tag, 'idle', 'big-orange idle', 6, true)
        scaleObject(tag, ray[3], 1)
        addLuaSprite(tag, false)
        setObjectOrder(tag, getObjectOrder('testSun'))
        setProperty(tag .. '.alpha', 0.7)
        setProperty(tag .. '.visible', false)
    end
    runHaxeCode([=[
        for (i in 1...7) game.getLuaObject('smashRay' + i).setColorTransform(0, 0, 0, 1, 75, 76, 74, 0);
    ]=])
    makeAnimatedLuaSprite('smashSun', 'fahmix/test/middle sun', 670, 470)
    addAnimationByPrefix('smashSun', 'enter', 'middle sun transition', 7, false)
    addAnimationByPrefix('smashSun', 'idle', 'middle sun idle', 6, true)
    scaleObject('smashSun', 1.1, 1.1)
    addLuaSprite('smashSun', false)
    setObjectOrder('smashSun', getObjectOrder('testGrass'))
    setProperty('smashSun.visible', false)

    for i = -3, 3 do
        local tag = 'smashChain' .. (i + 4)
        makeAnimatedLuaSprite(tag, 'fahmix/test/hang people', 1510 + i * 535 * 0.78, chainY - 400)
        addAnimationByPrefix(tag, 'idle', 'hang people idle', 6, true)
        scaleObject(tag, 0.78, 0.78)
        setProperty(tag .. '.flipX', i % 2 == 1)
        addLuaSprite(tag, false)
        setProperty(tag .. '.visible', false)
    end
    makeAnimatedLuaSprite('smashFog', 'fahmix/test/fog overlay', 0, 0)
    addAnimationByPrefix('smashFog', 'burst', 'fog overlay idle', 10, false)
    scaleObject('smashFog', 1.55, 1.55)
    addLuaSprite('smashFog', true)
    setProperty('smashFog.visible', false)
end

local function moveChain(tag, y, duration, ease)
    for i = 1, 7 do
        doTweenY(i == 4 and tag or tag .. i, 'smashChain' .. i, y, duration, ease)
    end
end

function onBeatHit()
    if chainBopping then moveChain('smashChainUp', chainY - 100, crochet / 4000, 'quadOut') end
end

function onTweenCompleted(tag)
    if tag == 'smashChainEnter' then
        chainBopping = true
        onBeatHit()
    elseif tag == 'smashChainUp' then
        moveChain('smashChainDown', chainY, crochet * 0.00075, 'quadIn')
    elseif tag == 'smashFogClear' then
        setProperty('smashFog.visible', false)
    end
end

local function updateSmashCue()
    if smashRayIdle and fahgerChanged and not getProperty('smashFog.visible') then return end
    if not smashStarted then
        if curStep < fahgerStep then return end
        smashStarted = true
        setProperty('testSun.visible', false)
        setProperty('testSunFill.visible', false)
        setProperty('smashSun.visible', true)
        playAnim('smashSun', 'enter', true)
        doTweenX('smashSunCenter', 'smashSun', cameraX - 687 * 1.1, 0.42, 'quadInOut')
        doTweenY('smashSunRise', 'smashSun', 600, 0.42, 'quadInOut')
        for i in ipairs(rays) do
            local tag = 'smashRay' .. i
            setProperty(tag .. '.visible', true)
            playAnim(tag, 'enter', true)
        end
        for i = 1, 7 do
            local tag = 'smashChain' .. i
            setProperty(tag .. '.visible', true)
            playAnim(tag, 'idle', true)
        end
        moveChain('smashChainEnter', chainY, 0.5, 'quadIn')
        local fogX = getMidpointX('dad') - getProperty('dad.offset.x') - 461 * 1.55 / 2
        local fogY = getMidpointY('dad') - getProperty('dad.offset.y') - 380 * 1.55 / 2
        setProperty('smashFog.x', fogX)
        setProperty('smashFog.y', fogY)
        setProperty('smashFog.visible', true)
        playAnim('smashFog', 'burst', true)
    end
    if not fahgerChanged and getProperty('smashFog.animation.curAnim.curFrame') >= 2 then
        fahgerChanged = true
        triggerEvent('Change Character', 'dad', 'robot-fahger')
    end
    if getProperty('smashSun.animation.curAnim.finished') then playAnim('smashSun', 'idle', true) end
    if not smashRayIdle and getProperty('smashRay1.animation.curAnim.finished') then
        smashRayIdle = true
        for i in ipairs(rays) do playAnim('smashRay' .. i, 'idle', true) end
    end
    if getProperty('smashFog.animation.curAnim.finished') and getProperty('smashFog.active') then
        setProperty('smashFog.active', false)
        doTweenAlpha('smashFogClear', 'smashFog', 0, 0.22, 'quadOut')
    end
end

function onCreate()
    makeAnimatedLuaSprite('paper', 'Freeplay-Chrs/fah/BG', 50, 50)
    addAnimationByPrefix('paper', 'idle', 'BG idle', 3, true)
    scaleObject('paper', 1.5, 1.5)
    addLuaSprite('paper', false)

    for _, part in ipairs(scenery) do
        makeAnimatedLuaSprite(part.tag, 'fahmix/test/' .. (part.asset or 'background'), part.x, part.y)
        addAnimationByPrefix(part.tag, 'idle', part.prefix, 6, true)
        scaleObject(part.tag, part.scaleX, part.scaleY)
        addLuaSprite(part.tag, false)
    end

    isSmash = string.lower(songName) == 'smash'
    makeAnimatedLuaSprite('testMamas', 'fahmix/test/mamas', mamaX - 245.5 * mamaScale, mamaFloor - 625 * mamaScale)
    addAnimationByPrefix('testMamas', 'idle', 'mamas idles', 6, true)
    scaleObject('testMamas', mamaScale, mamaScale)
    addLuaSprite('testMamas', false)
    playAnim('testMamas', 'idle', true)
    if string.lower(songName) == 'ridge' then makeRidgePipes() end

    makeLuaSprite('testSunFill', '', getProperty('testSun.x'), getProperty('testSun.y'))
    addHaxeLibrary('Shape', 'openfl.display')
    addHaxeLibrary('BitmapData', 'openfl.display')
    addHaxeLibrary('Matrix', 'openfl.geom')
    addHaxeLibrary('ThemeSurfaces')
    addHaxeLibrary('ClientPrefs')
    runHaxeCode([=[
        var masks = game.createTestSunFill();
        var paper = game.getLuaObject('paper');
        var sun = game.getLuaObject('testSun');
        var paperFrames = paper.animation.getByName('idle').frames;
        var pixels = new BitmapData(1686, 493 * paperFrames.length, true, 0);
        var shape = new Shape();
        var ratioX = paper.scale.x / sun.scale.x;
        var ratioY = paper.scale.y / sun.scale.y;
        var indices = [];
        for (p in 0...paperFrames.length) {
            var paperFrame = paper.frames.frames[paperFrames[p]];
            for (i in 0...masks.length) {
                var matrix = new Matrix(ratioX, 0, 0, ratioY,
                    i * 562 + (paper.x - sun.x) / sun.scale.x - paperFrame.frame.x * ratioX,
                    p * 493 + (paper.y - sun.y) / sun.scale.y - paperFrame.frame.y * ratioY);
                shape.graphics.beginBitmapFill(paper.graphic.bitmap, matrix, false, true);
                var mask = masks[i];
                for (y in 0...mask.rows.length) {
                    var row = mask.rows[y];
                    if (row[1] > 0) shape.graphics.drawRect(i * 562 + row[0], p * 493 + mask.top + y, row[1], 1);
                }
                shape.graphics.endFill();
                indices.push(p * 3 + i);
            }
        }
        pixels.draw(shape);
        var backing = game.getLuaObject('testSunFill');
        backing.loadGraphic(pixels, true, 562, 493);
        backing.animation.add('idle', indices, 0, false);
        backing.animation.play('idle');
        backing.shader = ClientPrefs.themeSongColoring ? ThemeSurfaces.maskShader() : null;
    ]=])
    scaleObject('testSunFill', getProperty('testSun.scale.x'), getProperty('testSun.scale.y'))
    addLuaSprite('testSunFill', false)
    setObjectOrder('testSunFill', getObjectOrder('testSun'))
end

local logoCues = {
    ridge = {step = 496, duration = 4000},
    smash = {step = 404, duration = 5000}
}
local logoCue
local logoWidth
local logoHeight
local logoVisible = false
local logoScale = 0.735

local function updateSongLogo()
    if not logoCue then return end
    local age = (curDecStep - logoCue.step) * stepCrochet
    local visible = age >= 0 and age < logoCue.duration
    if visible ~= logoVisible then
        setProperty('betaSongLogo.visible', visible)
        logoVisible = visible
    end
    if not visible then return end
    local enter = 1 - (1 - math.min(age / 700, 1)) ^ 4
    local exit = math.max(0, (age - logoCue.duration + 400) / 400) ^ 5
    local scale = logoScale * (1 - exit)
    local top = -logoHeight * logoScale / 2 - 24
    scaleObject('betaSongLogo', scale, scale)
    setProperty('betaSongLogo.x', (screenWidth - logoWidth * scale) / 2)
    setProperty('betaSongLogo.y', top + (screenHeight / 2 - top) * enter - logoHeight * scale / 2)
end

function onUpdatePost()
    updateSongLogo()
    if ridge then updateRidgePipes() end
    if isSmash then
        updateSmashPlants()
        updateSmashCue()
    end
    local frame = getProperty('paper.animation.curAnim.curFrame') * 3 + getProperty('testSun.animation.curAnim.curFrame')
    setProperty('testSunFill.animation.curAnim.curFrame', frame)
end

function onCreatePost()
    local song = string.lower(songName)
    logoCue = logoCues[song]
    if logoCue then
        makeLuaSprite('betaSongLogo', 'fahmix/test/' .. song .. '-logo', 0, 0)
        setObjectCamera('betaSongLogo', 'other')
        setProperty('betaSongLogo.visible', false)
        addLuaSprite('betaSongLogo', true)
        logoWidth = getProperty('betaSongLogo.width')
        logoHeight = getProperty('betaSongLogo.height')
    end
    if isSmash then
        addCharacterToList('robot-fahger', 'dad')
        makeSmashPlants()
        makeSmashCue()
    end
    setProperty('isCameraOnForcedPos', true)
    setProperty('camFollow.x', cameraX)
    setProperty('camFollow.y', cameraY)
    setProperty('camFollowPos.x', cameraX)
    setProperty('camFollowPos.y', cameraY)
end
