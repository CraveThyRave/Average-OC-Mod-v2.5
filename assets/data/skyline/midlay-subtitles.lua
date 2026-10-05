local MIDLAY_IN_STEP = 1176
local WHAT_STEP = 1188
local THE_STEP = 1191
local MIDLAY_OUT_STEP = 1196
local MIDLAY_IN_DURATION = 0.6
local MIDLAY_OUT_DURATION = 0.6
local TEXT_MOVE = 50
local timelineState = -1
local transitionOrders = nil
local textBaseY = 0

local function clampChannel(value)
	return math.max(0, math.min(255, math.floor((value or 255) + 0.5)))
end

local function gfColor()
	local color = getProperty('gf.healthColorArray')
	if color == nil then return 'FFFFFF' end
	return string.format('%02X%02X%02X', clampChannel(color[1]), clampChannel(color[2]), clampChannel(color[3]))
end

local function cancelMidlayTweens()
	cancelTween('skylineBlackMidlayIn')
	cancelTween('skylineBlackMidlayOut')
	cancelTween('skylineMidlayTextY')
	cancelTween('skylineMidlayTextHideY')
	cancelTween('skylineMidlayTextHideAlpha')
end

local function placeBlackMidlayBelowGameplay()
	if transitionOrders == nil then
		transitionOrders = {
			blackmidlay = getObjectOrder('blackmidlay'),
			text = getObjectOrder('skylineMidlayText'),
			notes = getObjectOrder('notes'),
			strums = getObjectOrder('strumLineNotes'),
			splashes = getObjectOrder('grpNoteSplashes')
		}
	end
	runHaxeCode([[
		var blackout = game.getLuaObject("blackmidlay");
		var subtitle = game.getLuaObject("skylineMidlayText");
		for (object in [blackout, game.strumLineNotes, game.notes, game.noteHeadLayer, game.grpAomHoldSplashes, game.grpNoteSplashes, subtitle])
		{
			if (object != null && game.members.indexOf(object) >= 0)
			{
				game.remove(object, true);
				game.add(object);
			}
		}
	]])
end

local function restoreTransitionOrders()
	if transitionOrders == nil then return end
	local objects = {
		{tag = 'blackmidlay', order = transitionOrders.blackmidlay},
		{tag = 'skylineMidlayText', order = transitionOrders.text},
		{tag = 'notes', order = transitionOrders.notes},
		{tag = 'strumLineNotes', order = transitionOrders.strums},
		{tag = 'grpNoteSplashes', order = transitionOrders.splashes}
	}
	table.sort(objects, function(a, b) return a.order < b.order end)
	for _, object in ipairs(objects) do
		setObjectOrder(object.tag, object.order)
	end
	transitionOrders = nil
end

local function setTextCue(text)
	cancelTween('skylineMidlayTextY')
	cancelTween('skylineMidlayTextHideY')
	cancelTween('skylineMidlayTextHideAlpha')
	setTextString('skylineMidlayText', text)
	setTextColor('skylineMidlayText', gfColor())
	screenCenter('skylineMidlayText', 'x')
	setProperty('skylineMidlayText.y', textBaseY + TEXT_MOVE)
	setProperty('skylineMidlayText.alpha', 1)
	doTweenY('skylineMidlayTextY', 'skylineMidlayText', textBaseY, 0.3, 'cubeOut')
end

local function stateForStep(step)
	if step < MIDLAY_IN_STEP then return 0 end
	if step < WHAT_STEP then return 1 end
	if step < THE_STEP then return 2 end
	if step < MIDLAY_OUT_STEP then return 3 end
	return 4
end

local function enterTimelineState(nextState)
	local previousState = timelineState
	timelineState = nextState
	if nextState == 0 then
		cancelMidlayTweens()
		setProperty('blackmidlay.alpha', 0)
		setProperty('skylineMidlayText.alpha', 0)
		setTextString('skylineMidlayText', '')
		setProperty('skylineMidlayText.y', textBaseY + TEXT_MOVE)
		restoreTransitionOrders()
	elseif nextState == 1 then
		cancelMidlayTweens()
		placeBlackMidlayBelowGameplay()
		setProperty('blackmidlay.alpha', 0)
		setProperty('skylineMidlayText.alpha', 0)
		setTextString('skylineMidlayText', '')
		doTweenAlpha('skylineBlackMidlayIn', 'blackmidlay', 1, MIDLAY_IN_DURATION, 'quadInOut')
	elseif nextState == 2 then
		cancelTween('skylineBlackMidlayOut')
		placeBlackMidlayBelowGameplay()
		if previousState == 0 or previousState == 4 then setProperty('blackmidlay.alpha', 1) end
		setTextCue('What')
	elseif nextState == 3 then
		cancelTween('skylineBlackMidlayOut')
		placeBlackMidlayBelowGameplay()
		if previousState == 0 or previousState == 4 then setProperty('blackmidlay.alpha', 1) end
		setTextCue('What the-?')
	elseif nextState == 4 then
		cancelTween('skylineBlackMidlayIn')
		cancelTween('skylineMidlayTextY')
		if previousState >= 1 and previousState <= 3 then
			doTweenAlpha('skylineBlackMidlayOut', 'blackmidlay', 0, MIDLAY_OUT_DURATION, 'quadInOut')
			doTweenAlpha('skylineMidlayTextHideAlpha', 'skylineMidlayText', 0, MIDLAY_OUT_DURATION, 'linear')
			doTweenY('skylineMidlayTextHideY', 'skylineMidlayText', textBaseY + TEXT_MOVE, MIDLAY_OUT_DURATION, 'cubeIn')
		else
			setProperty('blackmidlay.alpha', 0)
			setProperty('skylineMidlayText.alpha', 0)
			setTextString('skylineMidlayText', '')
			restoreTransitionOrders()
		end
	end
end

function onCreate()
	makeLuaSprite('blackmidlay', '', 0, 0)
	makeGraphic('blackmidlay', screenWidth, screenHeight, '000000')
	setObjectCamera('blackmidlay', 'hud')
	setProperty('blackmidlay.alpha', 0)
	addLuaSprite('blackmidlay', false)
	makeLuaText('skylineMidlayText', '', 1200, 0, 300)
	setTextAlignment('skylineMidlayText', 'center')
	setTextFont('skylineMidlayText', 'vcr.ttf')
	setTextSize('skylineMidlayText', 64)
	setTextColor('skylineMidlayText', gfColor())
	setProperty('skylineMidlayText.borderSize', 0)
	setObjectCamera('skylineMidlayText', 'hud')
	screenCenter('skylineMidlayText', 'xy')
	textBaseY = getProperty('skylineMidlayText.y')
	setProperty('skylineMidlayText.y', textBaseY + TEXT_MOVE)
	setProperty('skylineMidlayText.alpha', 0)
	addLuaText('skylineMidlayText')
end

function onCreatePost()
	enterTimelineState(stateForStep(curStep))
end

function onStepHit()
	local nextState = stateForStep(curStep)
	if nextState ~= timelineState then enterTimelineState(nextState) end
end

function onUpdatePost(elapsed)
	local nextState = stateForStep(curStep)
	if nextState ~= timelineState then enterTimelineState(nextState) end
end

function onTweenCompleted(tag)
	if tag == 'skylineBlackMidlayOut' then restoreTransitionOrders() end
	if tag == 'skylineMidlayTextHideY' then
		setTextString('skylineMidlayText', '')
		setProperty('skylineMidlayText.y', textBaseY + TEXT_MOVE)
	end
end

function onGameOverStart()
	cancelMidlayTweens()
	setProperty('blackmidlay.alpha', 0)
	setProperty('skylineMidlayText.alpha', 0)
	restoreTransitionOrders()
end

function onDestroy()
	restoreTransitionOrders()
end
