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
	if transitionOrders then return end
	transitionOrders = true
	runHaxeCode([[
		var layers = [game.getLuaObject("blackmidlay"), game.timeBarBG, game.timeBar, game.timeTxt,
			game.timeColonTxt, game.timeSecondsTxt, game.getLuaObject("timebarbg"), game.getLuaObject("timebar"),
			game.getLuaObject("fakeTimeTxt"), game.strumLineNotes, game.notes, game.noteHeadLayer,
			game.grpAomHoldSplashes, game.grpNoteSplashes, game.getLuaObject("skylineMidlayText")];
		var saved = [];
		for (layer in layers) {
			var index = game.members.indexOf(layer);
			if (layer != null && index >= 0) saved.push({layer:layer, index:index});
		}
		game.variables.set("skylineMidlayOrders", saved);
		for (entry in saved) {
			game.remove(entry.layer, true);
			game.insert(game.members.length, entry.layer);
		}
	]])
end

local function restoreTransitionOrders()
	if not transitionOrders then return end
	runHaxeCode([[
		var saved = game.variables.get("skylineMidlayOrders");
		if (saved != null) {
			saved.sort(function(a, b) { return a.index - b.index; });
			for (entry in saved) game.remove(entry.layer, true);
			for (entry in saved) game.insert(entry.index, entry.layer);
			game.variables.remove("skylineMidlayOrders");
		}
	]])
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
