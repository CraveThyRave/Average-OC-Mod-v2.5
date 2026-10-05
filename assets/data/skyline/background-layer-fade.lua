local FADE_OUT_START_STEP = 1167
local FADE_OUT_END_STEP = 1180
local RESTORE_STEP = 1196
local RESTORE_DURATION_MS = 800

local function clamp(value)
	return math.max(0, math.min(1, value))
end

local function smoothstep(value)
	value = clamp(value)
	return value * value * (3 - 2 * value)
end

local function timelineAlpha()
	local step = curDecStep or curStep
	if step < FADE_OUT_START_STEP then return 1 end
	if step < FADE_OUT_END_STEP then
		return 1 - smoothstep((step - FADE_OUT_START_STEP) / (FADE_OUT_END_STEP - FADE_OUT_START_STEP))
	end
	if step < RESTORE_STEP then return 0 end
	local stepLength = math.max(0.0001, stepCrochet or 100)
	return smoothstep((step - RESTORE_STEP) * stepLength / RESTORE_DURATION_MS)
end

local function applyTimeline()
	local timeline = timelineAlpha()
	local alpha = timeline
	local ntscFade = getVar('skylineNtscBackgroundFade')
	if type(ntscFade) == 'number' then alpha = alpha * clamp(ntscFade) end
	local floorAlpha = timeline * 0.8
	local ntscStrength = getVar('skylineNtscBackgroundStrength')
	if type(ntscStrength) == 'number' then
		floorAlpha = timeline * (0.8 + (0.4 - 0.8) * clamp(ntscStrength))
	end
	setVar('skylineBackgroundFade', alpha)
	if luaSpriteExists('nolaVoid') then setProperty('nolaVoid.alpha', alpha) end
	if luaSpriteExists('nolaBlack') then setProperty('nolaBlack.alpha', alpha) end
	if luaSpriteExists('floor') then setProperty('floor.alpha', floorAlpha) end
end

function onCreate()
	setVar('skylineBackgroundFade', 1)
end

function onCreatePost()
	applyTimeline()
end

function onUpdate()
	applyTimeline()
end

function onUpdatePost()
	applyTimeline()
end

function onGameOverStart()
	setVar('skylineBackgroundFade', 1)
end

function onDestroy()
	setVar('skylineBackgroundFade', 1)
end
