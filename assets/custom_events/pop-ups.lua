local SLOT_COUNT = 6
local states = {}
local screenWidth = 1280
local screenHeight = 720
local MAX_VISIBLE_OVERLAP = 0.5

 
 
local bounds = {
    fah = {
        {x = 58, y = 25, width = 317, height = 454},
        {x = 16, y = 42, width = 315, height = 377},
        {x = 11, y = 39, width = 379, height = 366},
        {x = 17, y = 17, width = 299, height = 265},
        {x = 8,  y = 52, width = 264, height = 311},
        {x = 1,  y = 85, width = 350, height = 333}
    },
    senpai = {
        {x = 69, y = 47, width = 231, height = 510},
        {x = 44, y = 35, width = 266, height = 447},
        {x = 44, y = 22, width = 190, height = 515},
        {x = 25, y = 45, width = 328, height = 483},
        {x = 44, y = 48, width = 251, height = 471},
        {x = 49, y = 50, width = 267, height = 484}
    }
}

local function spriteTag(atlas, slot)
    return 'week6Popup_' .. atlas .. '_' .. slot
end

local function visibleOverlapRatio(a, b)
    local overlapWidth = math.max(0,
        math.min(a.x + a.width, b.x + b.width) - math.max(a.x, b.x))
    local overlapHeight = math.max(0,
        math.min(a.y + a.height, b.y + b.height) - math.max(a.y, b.y))
    local smallerArea = math.min(a.width * a.height, b.width * b.height)
    if smallerArea <= 0 then return 0 end
    return (overlapWidth * overlapHeight) / smallerArea
end

local function placementFits(candidate, placements)
    for _, placed in ipairs(placements) do
        if visibleOverlapRatio(candidate, placed) > MAX_VISIBLE_OVERLAP then
            return false
        end
    end
    return true
end

local function makeVisibleRect(config, x)
    return {
        x = x + config.visible.x,
        y = config.restY + config.visible.y,
        width = config.visible.width,
        height = config.visible.height
    }
end

local function buildRandomLayout(configs)
    for layoutAttempt = 1, 80 do
        local placements = {}
        local complete = true

        for slot = 1, SLOT_COUNT do
            local config = configs[slot]
            local minX = -config.visible.x + 4
            local maxX = screenWidth - config.visible.x - config.visible.width - 4
            local found = false

            for positionAttempt = 1, 120 do
                local x = getRandomFloat(minX, maxX)
                local candidate = makeVisibleRect(config, x)
                if placementFits(candidate, placements) then
                    config.x = x
                    placements[slot] = candidate
                    found = true
                    break
                end
            end

            if not found then
                complete = false
                break
            end
        end

        if complete then return placements end
    end

    return nil
end

 
 
 
local function buildSafeFallbackLayout(configs)
    local order = {}
    for slot = 1, SLOT_COUNT do order[slot] = slot end
    table.sort(order, function(a, b)
        return configs[a].visible.width > configs[b].visible.width
    end)

    local placements = {}
    local visibleLeft = 4
    local previous = nil
    for _, slot in ipairs(order) do
        local config = configs[slot]
        if previous ~= nil then
            visibleLeft = previous.x + previous.width - config.visible.width * 0.5
        end
        local x = visibleLeft - config.visible.x
        local rect = makeVisibleRect(config, x)
        config.x = x
        placements[slot] = rect
        previous = rect
    end

    local lastRight = previous.x + previous.width
    local offset = getRandomFloat(0, math.max(0, screenWidth - lastRight - 4))
    local mirror = getRandomInt(0, 1) == 1
    for slot = 1, SLOT_COUNT do
        local rect = placements[slot]
        rect.x = rect.x + offset
        if mirror then rect.x = screenWidth - rect.x - rect.width end
        configs[slot].x = rect.x - configs[slot].visible.x
    end
    return placements
end

local function cancelSlotMotion(slot)
    local suffixes = {
        'Rise_', 'BounceDown_', 'BounceUp_', 'CheerAngle_', 'CheerX_',
        'CheerY_', 'Fall_', 'Fade_', 'Straight_', 'Center_'
    }
	for _, suffix in ipairs(suffixes) do cancelTween('popups' .. suffix .. slot) end
	cancelTimer('popupsCheer_' .. slot)
	cancelTimer('popupsCheerEnd_' .. slot)
end

local function hideSlot(slot)
    setProperty(spriteTag('fah', slot) .. '.visible', false)
    setProperty(spriteTag('senpai', slot) .. '.visible', false)
end

local function cheerStep(slot)
    local state = states[slot]
    if state == nil or state.phase ~= 'cheering' then return end
    state.cheerDirection = -state.cheerDirection
    local direction = state.cheerDirection
	doTweenAngle('popupsCheerAngle_' .. slot, state.tag,
		direction * state.cheerAngle, state.cheerTweenDuration, 'sineInOut')
	doTweenX('popupsCheerX_' .. slot, state.tag,
		state.baseX + direction * state.cheerX, state.cheerTweenDuration, 'sineInOut')
	doTweenY('popupsCheerY_' .. slot, state.tag,
		state.restY - direction * state.cheerY, state.cheerTweenDuration, 'sineInOut')
end

local function beginCheer(slot)
    local state = states[slot]
    if state == nil then return end
	state.phase = 'cheering'
	state.cheerDirection = (getRandomInt(0, 1) == 0) and -1 or 1
	cheerStep(slot)
	runTimer('popupsCheer_' .. slot, state.cheerInterval, 0)
	runTimer('popupsCheerEnd_' .. slot, 1.8)
end

local function beginFall(slot)
    local state = states[slot]
    if state == nil then return end
    state.phase = 'falling'
    cancelTween('popupsCheerAngle_' .. slot)
    cancelTween('popupsCheerX_' .. slot)
    cancelTween('popupsCheerY_' .. slot)
    doTweenY('popupsFall_' .. slot, state.tag, state.startY, 0.2, 'quadIn')
    doTweenAlpha('popupsFade_' .. slot, state.tag, 0, 0.2, 'quadIn')
    doTweenAngle('popupsStraight_' .. slot, state.tag, 0, 0.2, 'quadIn')
    doTweenX('popupsCenter_' .. slot, state.tag, state.baseX, 0.2, 'quadIn')
end

function onCreate()
    screenWidth = getPropertyFromClass('flixel.FlxG', 'width')
    screenHeight = getPropertyFromClass('flixel.FlxG', 'height')

    for slot = 1, SLOT_COUNT do
        for _, atlas in ipairs({'fah', 'senpai'}) do
            local tag = spriteTag(atlas, slot)
            makeAnimatedLuaSprite(tag, 'fahmix/week6/popups/' .. atlas, 0, screenHeight + 10)
            for animation = 1, 6 do
                addAnimationByPrefix(tag, tostring(animation), tostring(animation), 4, true)
            end
            setObjectCamera(tag, 'other')
            setProperty(tag .. '.antialiasing', false)
            setProperty(tag .. '.visible', false)
            addLuaSprite(tag, true)
        end
    end
end

function onEvent(name, value1, value2)
    if string.lower(tostring(name or '')) ~= 'pop-ups' then return end

     
     
     
    local choices = {}
    local usedChoices = {}
    local function addRandomChoice(atlas)
        local animation = getRandomInt(1, 6)
        local key = atlas .. ':' .. animation
        while usedChoices[key] do
            animation = getRandomInt(1, 6)
            key = atlas .. ':' .. animation
        end
        usedChoices[key] = true
        table.insert(choices, {atlas = atlas, animation = animation})
    end

    addRandomChoice('fah')
    addRandomChoice('senpai')
    while #choices < SLOT_COUNT do
        addRandomChoice(getRandomBool(50) and 'fah' or 'senpai')
    end
    for index = #choices, 2, -1 do
        local swapIndex = getRandomInt(1, index)
        choices[index], choices[swapIndex] = choices[swapIndex], choices[index]
    end

    local configs = {}
    for slot = 1, SLOT_COUNT do
        local choice = choices[slot]
        local visible = bounds[choice.atlas][choice.animation]
        local startY = screenHeight - visible.y + 4
		 
		 
		local senpaiPeakOffset = choice.atlas == 'senpai' and 100 or 0
		local restY = screenHeight - visible.y - visible.height + 70
			+ senpaiPeakOffset + getRandomInt(-8, 18)
		local cheerInterval = getRandomFloat(0.085, 0.115)

		configs[slot] = {
            choice = choice,
            visible = visible,
            tag = spriteTag(choice.atlas, slot),
            startY = startY,
			restY = restY,
			cheerAngle = getRandomFloat(5.5, 8.5),
			cheerX = getRandomFloat(3.5, 6.5),
			cheerY = getRandomFloat(2, 4.5),
			cheerInterval = cheerInterval,
			cheerTweenDuration = cheerInterval * getRandomFloat(0.78, 0.92),
			bounceAmount = getRandomFloat(10, 16),
			bounceDownDuration = getRandomFloat(0.05, 0.075),
			bounceUpDuration = getRandomFloat(0.06, 0.09)
        }
    end

    local placements = buildRandomLayout(configs)
    if placements == nil then placements = buildSafeFallbackLayout(configs) end

    for slot = 1, SLOT_COUNT do
        cancelSlotMotion(slot)
        hideSlot(slot)

        local config = configs[slot]
        local tag = config.tag
        local x = config.x
        objectPlayAnimation(tag, tostring(config.choice.animation), true)

		states[slot] = {
            tag = tag,
            baseX = x,
            startY = config.startY,
			restY = config.restY,
			phase = 'rising',
			cheerDirection = 1,
			cheerAngle = config.cheerAngle,
			cheerX = config.cheerX,
			cheerY = config.cheerY,
			cheerInterval = config.cheerInterval,
			cheerTweenDuration = config.cheerTweenDuration,
			bounceAmount = config.bounceAmount,
			bounceDownDuration = config.bounceDownDuration,
			bounceUpDuration = config.bounceUpDuration
        }
        setProperty(tag .. '.x', x)
        setProperty(tag .. '.y', config.startY)
        setProperty(tag .. '.angle', 0)
        setProperty(tag .. '.alpha', 1)
        setProperty(tag .. '.visible', true)
        doTweenY('popupsRise_' .. slot, tag, config.restY, 0.4, 'backOut')
    end
end

function onTweenCompleted(tag)
    local slot = tonumber(string.match(tag, '^popupsRise_(%d+)$'))
    if slot ~= nil and states[slot] ~= nil then
		states[slot].phase = 'bounceDown'
		doTweenY('popupsBounceDown_' .. slot, states[slot].tag,
			states[slot].restY + states[slot].bounceAmount,
			states[slot].bounceDownDuration, 'quadIn')
        return
    end

    slot = tonumber(string.match(tag, '^popupsBounceDown_(%d+)$'))
    if slot ~= nil and states[slot] ~= nil then
		states[slot].phase = 'bounceUp'
		doTweenY('popupsBounceUp_' .. slot, states[slot].tag,
			states[slot].restY, states[slot].bounceUpDuration, 'quadOut')
        return
    end

    slot = tonumber(string.match(tag, '^popupsBounceUp_(%d+)$'))
    if slot ~= nil then
        beginCheer(slot)
        return
    end

    slot = tonumber(string.match(tag, '^popupsFall_(%d+)$'))
    if slot ~= nil then
        hideSlot(slot)
        states[slot] = nil
    end
end

function onTimerCompleted(tag, loops, loopsLeft)
	local slot = tonumber(string.match(tag, '^popupsCheer_(%d+)$'))
	if slot ~= nil and states[slot] ~= nil then
		cheerStep(slot)
		return
	end

	slot = tonumber(string.match(tag, '^popupsCheerEnd_(%d+)$'))
	if slot ~= nil and states[slot] ~= nil then
		cancelTimer('popupsCheer_' .. slot)
		beginFall(slot)
	end
end

function onDestroy()
    for slot = 1, SLOT_COUNT do
        cancelSlotMotion(slot)
        hideSlot(slot)
    end
end
