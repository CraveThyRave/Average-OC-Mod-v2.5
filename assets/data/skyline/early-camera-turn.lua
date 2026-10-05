local WHITE_TAG = 'skylineEarlyTurnWhite'
local TURN_START_STEP = 248
local HUD_FADE_START_STEP = 252
local TURN_END_STEP = 255
local CAMERA_RESET_STEP = 265
local RESTORE_STEP = 269
local RESTORE_DURATION_MS = 200
local FINAL_ANGLE = 100
local GAME_ZOOM_MULTIPLIER = 1.25
local GAME_ZOOM_RESET = 0.7
local GAME_ZOOM_RESET_DURATION = 1
local TURN_OVERSCAN = 3
local lastGameTurn = 0
local lastHudTurn = 0
local lastHudAlphaDelta = 0
local lastGameZoomDelta = 0
local gameZoomReset = false
local gameZoomResetStart = 0
local gameZoomResetElapsed = 0
local gameZoomTransitioning = false
local lastVisibleGameZoom = nil
local timelineEnabled = true
local baseCameraOverscan = nil
local appliedCameraOverscan = nil

local function clamp(value)
	return math.max(0, math.min(1, value))
end

local function smoothstep(value)
	value = clamp(value)
	return value * value * (3 - 2 * value)
end

local function removeCameraOverlay()
	setProperty('camGame.angle', getProperty('camGame.angle') - lastGameTurn)
	setProperty('camHUD.angle', getProperty('camHUD.angle') - lastHudTurn)
	setProperty('camHUD.alpha', getProperty('camHUD.alpha') - lastHudAlphaDelta)
	lastGameTurn = 0
	lastHudTurn = 0
	lastHudAlphaDelta = 0
end

local function removeGameZoomOverlay()
	if lastGameZoomDelta == 0 then return end
	setProperty('camGame.zoom', getProperty('camGame.zoom') - lastGameZoomDelta)
	lastGameZoomDelta = 0
end

local function applyTimeline(elapsed)
	removeCameraOverlay()
	if not timelineEnabled then
		setProperty(WHITE_TAG .. '.alpha', 0)
		return
	end
	local step = curDecStep or curStep
	local turnProgress = smoothstep((step - TURN_START_STEP) / (TURN_END_STEP - TURN_START_STEP))
	local hudFadeProgress = smoothstep((step - HUD_FADE_START_STEP) / (TURN_END_STEP - HUD_FADE_START_STEP))
	local restoreStepLength = math.max(0.0001, stepCrochet or 100)
	local restoreProgress = smoothstep((step - RESTORE_STEP) * restoreStepLength / RESTORE_DURATION_MS)
	lastGameTurn = step >= CAMERA_RESET_STEP and 0 or FINAL_ANGLE * turnProgress
	lastHudTurn = step >= CAMERA_RESET_STEP and 0 or FINAL_ANGLE * turnProgress
	local hudBaseAlpha = getProperty('camHUD.alpha')
	lastHudAlphaDelta = -hudBaseAlpha * hudFadeProgress * (1 - restoreProgress)
	setProperty('camGame.angle', getProperty('camGame.angle') + lastGameTurn)
	setProperty('camHUD.angle', getProperty('camHUD.angle') + lastHudTurn)
	setProperty('camHUD.alpha', hudBaseAlpha + lastHudAlphaDelta)
	setProperty(WHITE_TAG .. '.alpha', turnProgress * (1 - restoreProgress))
	if step < RESTORE_STEP then
		gameZoomReset = false
		gameZoomResetElapsed = 0
		gameZoomTransitioning = false
		local gameBaseZoom = getProperty('camGame.zoom')
		lastGameZoomDelta = gameBaseZoom * (GAME_ZOOM_MULTIPLIER - 1) * turnProgress
		setProperty('camGame.zoom', gameBaseZoom + lastGameZoomDelta)
	elseif not gameZoomReset then
		gameZoomReset = true
		gameZoomResetStart = lastVisibleGameZoom or getProperty('camGame.zoom')
		gameZoomResetElapsed = 0
		gameZoomTransitioning = true
	end
	if gameZoomTransitioning then
		gameZoomResetElapsed = gameZoomResetElapsed + math.max(0, elapsed or 0)
		local gameZoomResetProgress = smoothstep(gameZoomResetElapsed / GAME_ZOOM_RESET_DURATION)
		setProperty('camGame.zoom', gameZoomResetStart + (GAME_ZOOM_RESET - gameZoomResetStart) * gameZoomResetProgress)
		if gameZoomResetProgress >= 1 then gameZoomTransitioning = false end
	end
	if baseCameraOverscan ~= nil then
		local targetCameraOverscan = math.max(baseCameraOverscan, TURN_OVERSCAN)
		if appliedCameraOverscan ~= targetCameraOverscan then
			setProperty('cameraRenderOverscanScale', targetCameraOverscan)
			appliedCameraOverscan = targetCameraOverscan
		end
	end
end

function onCreate()
	makeLuaSprite(WHITE_TAG, '', -screenWidth, -screenHeight)
	makeGraphic(WHITE_TAG, 2, 2, 'FFFFFF')
	scaleObject(WHITE_TAG, screenWidth * 1.5, screenHeight * 1.5)
	updateHitbox(WHITE_TAG)
	setScrollFactor(WHITE_TAG, 0, 0)
	setObjectCamera(WHITE_TAG, 'game')
	setProperty(WHITE_TAG .. '.alpha', 0)
	addLuaSprite(WHITE_TAG, true)
end

function onCreatePost()
	baseCameraOverscan = getProperty('cameraRenderOverscanScale')
	appliedCameraOverscan = baseCameraOverscan
	applyTimeline(0)
end

function onUpdate()
	lastVisibleGameZoom = getProperty('camGame.zoom')
	removeGameZoomOverlay()
end

function onUpdatePost(elapsed)
	applyTimeline(elapsed)
end

function onGameOverStart()
	timelineEnabled = false
	gameZoomTransitioning = false
	removeGameZoomOverlay()
	removeCameraOverlay()
	setProperty(WHITE_TAG .. '.alpha', 0)
	if baseCameraOverscan ~= nil and appliedCameraOverscan ~= baseCameraOverscan then
		setProperty('cameraRenderOverscanScale', baseCameraOverscan)
		appliedCameraOverscan = baseCameraOverscan
	end
end

function onDestroy()
	lastGameZoomDelta = 0
	lastGameTurn = 0
	lastHudTurn = 0
	lastHudAlphaDelta = 0
	gameZoomTransitioning = false
end
