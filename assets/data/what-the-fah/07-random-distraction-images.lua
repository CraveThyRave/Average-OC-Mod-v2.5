
local currentSprite = nil
local spriteData = {}
local usedImages = {}
local spriteTags = {}
local sets

local spawnSteps = {327, 445, 530, 625, 966, 1021, 1099, 1176, 1219, 1353, 1468, 1505, 1616, 1881, 1937, 2049}
if lowQuality then spawnSteps = {327, 966, 1616} end
local off = 200

local sw = screenWidth or 1280
local sh = screenHeight or 720

local runID = 0
local achievementLeewayMs = 1500
local achievementEligibleUntil = -1
local achievementWindowActive = false
local lastDistractionWindowStep = -1
local upcomingDistraction = false

local function setAchievementWindow(active)
    if achievementWindowActive == active then return end
    achievementWindowActive = active
    setVar('whatTheFahDistractionActive', active)
end

local function preloadDistractions()
    local index = 0

    for i = 1, #sets do
		local set = sets[i]
		local shouldLoad = not lowQuality
		if lowQuality then
			for _, step in ipairs(spawnSteps) do
				for _, range in ipairs(set.ranges) do
					if step >= range[1] and step <= range[2] then
						shouldLoad = true
						break
					end
				end
				if shouldLoad then break end
			end
		end
		local imageCount = lowQuality and 1 or #set.images
		if shouldLoad then for j = 1, imageCount do
            local path = set.images[j]
            local tag = 'img_' .. index
            local base = path:match('([^/]+)$')

            makeAnimatedLuaSprite(tag, path, 0, 0)
            addAnimationByPrefix(tag, 'idle', base .. ' idle', 8, true)
            setObjectCamera(tag, 'other')
            addLuaSprite(tag, true)
            setProperty(tag .. '.visible', false)
            setProperty(tag .. '.active', false)
            spriteTags[path] = tag
            index = index + 1
		end end
    end
end

local function hideCurrentSprite()
    if currentSprite == nil then return end

    cancelTween(currentSprite .. '_x')
    cancelTween(currentSprite .. '_y')
    cancelTimer(currentSprite .. '_move')
    cancelTimer(currentSprite .. '_pause')
    cancelTimer(currentSprite .. '_cleanup')
    setProperty(currentSprite .. '.visible', false)
    setProperty(currentSprite .. '.active', false)
    spriteData[currentSprite] = nil
    currentSprite = nil
end

function onCreate()
    addHaxeLibrary('Achievements')
    addHaxeLibrary('ClientPrefs')
    runID = runID + 1
    currentSprite = nil
    spriteData = {}
    usedImages = {}
    achievementEligibleUntil = -1
    achievementWindowActive = false
    lastDistractionWindowStep = -1
    upcomingDistraction = false
    setVar('whatTheFahDistractionActive', false)
    preloadDistractions()
end

sets = {
    {name='misc',ranges={{0,384},{640,890},{1288,1408}},images={
        'Freeplay-Chrs/fah/distractions/misc/misc1','Freeplay-Chrs/fah/distractions/misc/misc2','Freeplay-Chrs/fah/distractions/misc/misc3','Freeplay-Chrs/fah/distractions/misc/misc4','Freeplay-Chrs/fah/distractions/misc/misc5'}},
    {name='fairy',ranges={{384,640}},images={
        'Freeplay-Chrs/fah/distractions/fairy/fairy1','Freeplay-Chrs/fah/distractions/fairy/fairy2','Freeplay-Chrs/fah/distractions/fairy/fairy3','Freeplay-Chrs/fah/distractions/fairy/fairy4','Freeplay-Chrs/fah/distractions/fairy/fairy5'}},
    {name='timber',ranges={{890,1152}},images={
        'Freeplay-Chrs/fah/distractions/timber/timber1','Freeplay-Chrs/fah/distractions/timber/timber2','Freeplay-Chrs/fah/distractions/timber/timber3'}},
    {name='sunky',ranges={{1152,1288}},images={
        'Freeplay-Chrs/fah/distractions/sunky/sunky1','Freeplay-Chrs/fah/distractions/sunky/sunky2','Freeplay-Chrs/fah/distractions/sunky/sunky3','Freeplay-Chrs/fah/distractions/sunky/sunky4'}},
    {name='flowers',ranges={{1288,1664}},images={
        'Freeplay-Chrs/fah/distractions/flowers/flower1','Freeplay-Chrs/fah/distractions/flowers/flower2','Freeplay-Chrs/fah/distractions/flowers/flower3','Freeplay-Chrs/fah/distractions/flowers/flower4','Freeplay-Chrs/fah/distractions/flowers/flower5','Freeplay-Chrs/fah/distractions/flowers/flower6'}},
    {name='tiger',ranges={{1727,99999}},images={
        'Freeplay-Chrs/fah/distractions/tiger/tiger1','Freeplay-Chrs/fah/distractions/tiger/tiger2','Freeplay-Chrs/fah/distractions/tiger/tiger3','Freeplay-Chrs/fah/distractions/tiger/tiger4'}}
}

function onSongStart()
    local recordedSteps = getRecordedSceneValue('fah.distractionSteps')
    if recordedSteps ~= nil then spawnSteps = recordedSteps end
    recordSceneValue('fah.distractionSteps', spawnSteps)
    for _, step in ipairs(spawnSteps) do
        local recorded = getRecordedSceneValue('fah.distraction.' .. step)
        if recorded ~= nil and spriteTags[recorded.path] == nil then
            local tag = 'img_' .. (1000 + step)
            local base = recorded.path:match('([^/]+)$')
            makeAnimatedLuaSprite(tag, recorded.path, 0, 0)
            addAnimationByPrefix(tag, 'idle', base .. ' idle', 8, true)
            setObjectCamera(tag, 'other')
            addLuaSprite(tag, true)
            setProperty(tag .. '.visible', false)
            setProperty(tag .. '.active', false)
            spriteTags[recorded.path] = tag
        end
    end
end

function shouldSpawn(step)
    for i=1,#spawnSteps do
        if step == spawnSteps[i] then return true end
    end
    return false
end

function getValidSets()
    local valid={}
    for i=1,#sets do
        for j=1,#sets[i].ranges do
            local r=sets[i].ranges[j]
            if curStep>=r[1] and curStep<=r[2] then
                table.insert(valid,sets[i])
                break
            end
        end
    end
    return valid
end

function getRandomSet()
    local valid=getValidSets()
    if #valid == 0 then return sets[1] end
    if lowQuality then return valid[1] end
    return valid[getRandomInt(1,#valid)]
end

function getRandomImage(set)
    if lowQuality then return set.images[1] end
    if not usedImages[set.name] then
        usedImages[set.name] = {}
    end

    local used = usedImages[set.name]

    if #used >= #set.images then
        usedImages[set.name] = {}
        used = usedImages[set.name]
    end

    local available = {}
    for i=1,#set.images do
        local img = set.images[i]
        local found = false

        for j=1,#used do
            if used[j] == img then
                found = true
                break
            end
        end

        if not found then
            table.insert(available, img)
        end
    end

    local unseen = {}
    for i=1,#available do
        local img = available[i]
        local escaped = string.gsub(img, '\\', '\\\\')
        escaped = string.gsub(escaped, '"', '\\"')
        local seen = runHaxeCode([[return ClientPrefs.seenFahDistractions != null && ClientPrefs.seenFahDistractions.contains("]] .. escaped .. [[");]])
        if not seen then table.insert(unseen, img) end
    end
    local pool = (#unseen > 0 and getRandomInt(1,100) <= 90) and unseen or available
    local choice = pool[getRandomInt(1,#pool)]
    table.insert(used, choice)

    return choice
end

function getCrossPositions(w, h)
    if lowQuality then return -w-off, (sh-h)/2, sw+w+off, (sh-h)/2 end
    local mode = getRandomInt(1,6)

    if mode == 1 then return -w-off, getRandomInt(0, sh-h), sw+w+off, getRandomInt(0, sh-h)
    elseif mode == 2 then return sw+w+off, getRandomInt(0, sh-h), -w-off, getRandomInt(0, sh-h)
    elseif mode == 3 then return getRandomInt(0, sw-w), -h-off, getRandomInt(0, sw-w), sh+h+off
    elseif mode == 4 then return getRandomInt(0, sw-w), sh+h+off, getRandomInt(0, sw-w), -h-off
    elseif mode == 5 then return -w-off, -h-off, sw+w+off, sh+h+off
    else return sw+w+off, sh+h+off, -w-off, -h-off end
end

function spawnImage()
    
    
    hideCurrentSprite()

    local recorded = getRecordedSceneValue('fah.distraction.' .. curStep)
    local path
    if recorded ~= nil then
        path = recorded.path
    else
        path = getRandomImage(getRandomSet())
    end
    if not path then return end

    local tag = spriteTags[path]
    if tag == nil then return end
    local myRun = runID
    currentSprite = tag
    setProperty(tag .. '.active', true)
    setProperty(tag .. '.visible', true)
    playAnim(tag, 'idle', true)
    local escaped = string.gsub(path, '\\', '\\\\')
    escaped = string.gsub(escaped, '"', '\\"')
    runHaxeCode([[Achievements.recordFahDistraction("]] .. escaped .. [[", game.camOther);]])
    setAchievementWindow(true)

    if recorded == nil then
        local w = getProperty(tag..'.width') or 100
        local h = getProperty(tag..'.height') or 100
        local sx,sy,ex,ey = getCrossPositions(w,h)
        local dur = lowQuality and 6 or math.max(1, getRandomFloat(3,7))
        local doReturn = not lowQuality and (getRandomInt(1,100) <= 15)
        recorded = {
            path=path,
            sx=sx, sy=sy,
            mx=(sx + ex) / 2, my=(sy + ey) / 2,
            ex=ex, ey=ey,
            dur=dur,
            step=1,
            total=12,
            type=lowQuality and 1 or getRandomInt(1,3),
            strength=lowQuality and 40 or getRandomInt(40,120),
            phase=doReturn and "toMid" or "toEnd",
            pauseDur=lowQuality and 1 or getRandomFloat(1,3),
            willReturn=doReturn
        }
    end
    recordSceneValue('fah.distraction.' .. curStep, recorded)
    recorded.run = myRun
    spriteData[tag] = recorded
    setProperty(tag..'.x', recorded.sx)
    setProperty(tag..'.y', recorded.sy)

    runTimer(tag..'_move', 0.001)
end

function onTimerCompleted(tag)
    local spr = tag and tag:match('^(img_%d+)')
    if not spr or not spriteData[spr] then return end

    local d = spriteData[spr]
    if d.run ~= runID then return end
    if not luaSpriteExists(spr) then return end

    if string.find(tag,'_move') then
        local progress = d.step/d.total

        local tx, ty, startX, startY

        if d.phase == "toMid" then
            tx, ty = d.mx, d.my
            startX, startY = d.sx, d.sy
        elseif d.phase == "toEnd" then
            tx, ty = d.ex, d.ey
            startX, startY = d.sx, d.sy
        elseif d.phase == "return" then
            tx, ty = d.sx, d.sy
            startX, startY = d.mx, d.my
        end

        local x = startX + (tx - startX) * progress
        local y = startY + (ty - startY) * progress

        if d.type == 1 then
            y = y + math.sin(progress * math.pi * 2) * d.strength
        elseif d.type == 2 then
            y = y + (d.step % 2 == 0 and d.strength or -d.strength)
        end

        doTweenX(spr..'_x', spr, x, d.dur/d.total, 'linear')
        doTweenY(spr..'_y', spr, y, d.dur/d.total, 'linear')

        if d.step < d.total then
            d.step = d.step + 1
            runTimer(spr..'_move', d.dur/d.total)
        else
            if d.phase == "toMid" and d.willReturn then
                runTimer(spr..'_pause', d.pauseDur)
            else
                runTimer(spr..'_cleanup', 0.1)
            end
        end

    elseif string.find(tag,'_pause') then
        d.phase = "return"
        d.step = 1
        runTimer(spr..'_move', 0.001)

    elseif string.find(tag,'_cleanup') then
        if luaSpriteExists(spr) then
            setProperty(spr .. '.visible', false)
            setProperty(spr .. '.active', false)
        end
        spriteData[spr] = nil
        currentSprite = nil
        achievementEligibleUntil = getSongPosition() + achievementLeewayMs
    end
end

function onUpdate(elapsed)
    local songPosition = getSongPosition()
    if curStep ~= lastDistractionWindowStep then
        lastDistractionWindowStep = curStep
        upcomingDistraction = false
        local millisecondsPerStep = stepCrochet or 0
        if millisecondsPerStep > 0 then
            for i = 1, #spawnSteps do
                local stepsUntilSpawn = spawnSteps[i] - curStep
                if stepsUntilSpawn >= 0 and stepsUntilSpawn * millisecondsPerStep <= achievementLeewayMs then
                    upcomingDistraction = true
                    break
                end
            end
        end
    end

    setAchievementWindow(
        currentSprite ~= nil
        or songPosition <= achievementEligibleUntil
        or upcomingDistraction
    )
end

function onDestroy()
    setAchievementWindow(false)
end

function onStepHit()
    if shouldSpawn(curStep) then
        spawnImage()
    end
end
