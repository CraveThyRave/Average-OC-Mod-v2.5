local TAG = 'skylineFinalBlackout'
local START_STEP = 2352
local DURATION_MS = 400

local function clamp(value)
	return math.max(0, math.min(1, value))
end

local function smoothstep(value)
	value = clamp(value)
	return value * value * (3 - 2 * value)
end

local function applyTimeline()
	local step = curDecStep or curStep
	local stepLength = math.max(0.0001, stepCrochet or 100)
	local progress = smoothstep((step - START_STEP) * stepLength / DURATION_MS)
	setProperty(TAG .. '.alpha', progress)
end

function onCreate()
	makeLuaSprite(TAG, '', -screenWidth, -screenHeight)
	makeGraphic(TAG, 2, 2, '000000')
	scaleObject(TAG, screenWidth * 1.5, screenHeight * 1.5)
	updateHitbox(TAG)
	setScrollFactor(TAG, 0, 0)
	setObjectCamera(TAG, 'other')
	setProperty(TAG .. '.alpha', 0)
	addLuaSprite(TAG, true)
end

function onCreatePost()
	applyTimeline()
end

function onUpdatePost()
	applyTimeline()
end

