local SHADER_NAME = 'uh'
local SHADER_HOLDER = 'nolaShaderHolder'
local IMAGE_PATH = 'Freeplay-Chrs/nola/skyline'
local SPRITE_1 = 'nolaSkyline1'
local SPRITE_2 = 'nolaSkyline2'
local OPPONENT_SPEED = -45
local BF_SPEED = 45
local SCROLL_EASE_SPEED = 3
local ACTIVATION_FADE_DURATION = 1
local FILTER_START_STEP = 265
local SKYLINE_X = -1152
local SKYLINE_Y = -350
local SKYLINE_ALPHA = 0.25
local START_ACTIVE = false
local ACTIVATION_CHANGES = {
	{step = 264, active = true},
	{step = 527, active = false}
}

local imageWidth = 0
local currentSpeed = 0
local targetSpeed = OPPONENT_SPEED
local scrollOffset = 0
local activationAmount = 0
local activationTarget = 0
local activationStart = 0
local activationElapsed = 0
local activationTransitioning = false
local hasActivated = false
local lastActivationAmount = -1
local backgroundFadeAmount = 1
local lastBackgroundFadeAmount = -1
local shaderReady = false
local filterActive = false
local scheduledActivation = nil
local lastScheduledStep = nil
local shaderPrewarmPending = false

local function smoothApproach(current, target, speed, elapsed)
	local amount = 1 - math.exp(-speed * elapsed)
	current = current + (target - current) * amount
	if math.abs(target - current) < 0.0001 then current = target end
	return current
end

local function smoothstep(value)
	value = math.max(0, math.min(1, value))
	return value * value * (3 - 2 * value)
end

local function refreshDirection()
	targetSpeed = mustHitSection and BF_SPEED or OPPONENT_SPEED
end

local function createSkylineSprite(tag, x)
	makeLuaSprite(tag, IMAGE_PATH, x, SKYLINE_Y)
	scaleObject(tag, 2, 2)
	updateHitbox(tag)
	setScrollFactor(tag, 0, 0)
	setProperty(tag .. '.antialiasing', false)
	setProperty(tag .. '.alpha', 0)
	addLuaSprite(tag, false)
end

function reloadShader()
	if lowQuality then return end
	runHaxeCode([[
		var shaderName = "]] .. SHADER_NAME .. [[";
		var holder = game.getLuaObject("]] .. SHADER_HOLDER .. [[");
		game.camGame.setFilters([]);
		if (game.runtimeShaders.exists(shaderName))
			game.runtimeShaders.remove(shaderName);
		game.initLuaShader(shaderName);
		holder.shader = game.createRuntimeShader(shaderName);
	]])
	shaderReady = true
	filterActive = false
	lastActivationAmount = -1
end

local function setFilterActive(active)
	if lowQuality then return end
	if filterActive == active then return end
	runHaxeCode([[
		var holder = game.getLuaObject("]] .. SHADER_HOLDER .. [[");
		var ntsc = game.getLuaObject("skylineNtscShaderHolder");
		var filters = [];
		if (]] .. tostring(active) .. [[ && holder != null && holder.shader != null)
			filters.push(new ShaderFilter(holder.shader));
		if (ntsc != null && ntsc.shader != null)
			filters.push(new ShaderFilter(ntsc.shader));
		game.camGame.setFilters(filters);
	]])
	filterActive = active
end

local function applyActivationVisuals()
	local combinedAmount = activationAmount * backgroundFadeAmount
	local alpha = SKYLINE_ALPHA * combinedAmount
	setProperty(SPRITE_1 .. '.alpha', alpha)
	setProperty(SPRITE_2 .. '.alpha', alpha)
	setProperty(SHADER_HOLDER .. '.alpha', combinedAmount)
	if shaderReady then
		setShaderFloat(SHADER_HOLDER, 'effectStrength', combinedAmount)
	end
	lastActivationAmount = activationAmount
	lastBackgroundFadeAmount = backgroundFadeAmount
end

function setSkylineScrollingActive(active)
	local target = active and 1 or 0
	if target == activationTarget and not activationTransitioning then return end
	activationTarget = target
	if active and not hasActivated then
		hasActivated = true
		activationAmount = 1
		activationStart = 1
		activationElapsed = 0
		activationTransitioning = false
	else
		activationStart = activationAmount
		activationElapsed = 0
		activationTransitioning = activationStart ~= activationTarget
	end
	applyActivationVisuals()
end

local function refreshScheduledActivation()
	local active = START_ACTIVE
	local latestStep = -math.huge
	for _, change in ipairs(ACTIVATION_CHANGES) do
		if change.step <= curStep and change.step >= latestStep then
			latestStep = change.step
			active = change.active
		end
	end
	if active ~= scheduledActivation then
		scheduledActivation = active
		setSkylineScrollingActive(active)
	end
	lastScheduledStep = curStep
end

function onCreate()
	createSkylineSprite(SPRITE_1, SKYLINE_X)
	imageWidth = getProperty(SPRITE_1 .. '.width')
	scrollOffset = -imageWidth
	setProperty(SPRITE_1 .. '.x', SKYLINE_X + scrollOffset)
	createSkylineSprite(SPRITE_2, SKYLINE_X)
end

function onCreatePost()
	local floorTag = luaSpriteExists('floor') and 'floor' or 'nolaBlack'
	if luaSpriteExists(floorTag) then
		setObjectOrder(SPRITE_1, getObjectOrder(floorTag))
		setObjectOrder(SPRITE_2, getObjectOrder(floorTag))
	end
	makeLuaSprite(SHADER_HOLDER, '', 0, 0)
	makeGraphic(SHADER_HOLDER, 1, 1, 'FFFFFF')
	setProperty(SHADER_HOLDER .. '.visible', false)
	if not lowQuality then
		addHaxeLibrary('ShaderFilter', 'openfl.filters')
		reloadShader()
		setShaderFloat(SHADER_HOLDER, 'effectStrength', 0)
		setFilterActive(true)
		shaderPrewarmPending = true
		runHaxeCode([[
			nolaShaderResizeFix = function(?_)
			{
				var reset = function(sprite)
				{
					if (sprite == null || sprite.filters == null || sprite.filters.length == 0) return;
					sprite.__cacheBitmap = null;
					sprite.__cacheBitmapData = null;
				};
				reset(game.camGame.flashSprite);
				reset(game.camHUD.flashSprite);
				reset(game.camOther.flashSprite);
			};
			FlxG.signals.gameResized.add(nolaShaderResizeFix);
			nolaShaderResizeFix();
		]])
	end
	local openingOwner = runHaxeCode([[return game.hudSectionOwner();]])
	targetSpeed = openingOwner == 'bf' and BF_SPEED or OPPONENT_SPEED
	currentSpeed = targetSpeed
	refreshScheduledActivation()
end

function onSectionHit()
	refreshDirection()
end

function onStepHit()
	refreshScheduledActivation()
end

function onUpdate(elapsed)
	if shaderPrewarmPending then
		shaderPrewarmPending = false
		setFilterActive(false)
	end
	if imageWidth <= 0 then return end
	if curStep ~= lastScheduledStep then refreshScheduledActivation() end
	local requestedBackgroundFade = getVar('skylineBackgroundFade')
	if type(requestedBackgroundFade) == 'number' then
		backgroundFadeAmount = math.max(0, math.min(1, requestedBackgroundFade))
	else
		backgroundFadeAmount = 1
	end
	if activationTransitioning then
		activationElapsed = activationElapsed + math.max(0, elapsed)
		local progress = math.min(1, activationElapsed / ACTIVATION_FADE_DURATION)
		activationAmount = activationStart + (activationTarget - activationStart) * smoothstep(progress)
		if progress >= 1 then
			activationAmount = activationTarget
			activationTransitioning = false
		end
	end
	if activationAmount ~= lastActivationAmount or backgroundFadeAmount ~= lastBackgroundFadeAmount then
		applyActivationVisuals()
	end
	if shaderReady then
		setFilterActive(activationAmount * backgroundFadeAmount > 0.001
			and (curDecStep or curStep) >= FILTER_START_STEP)
	end
	currentSpeed = smoothApproach(currentSpeed, targetSpeed, SCROLL_EASE_SPEED, elapsed)
	scrollOffset = scrollOffset + currentSpeed * elapsed
	while scrollOffset <= -imageWidth do scrollOffset = scrollOffset + imageWidth end
	while scrollOffset > 0 do scrollOffset = scrollOffset - imageWidth end
	local firstX = SKYLINE_X + scrollOffset
	setProperty(SPRITE_1 .. '.x', firstX)
	setProperty(SPRITE_2 .. '.x', firstX + imageWidth)
	local reloadPressed = keyboardJustPressed and keyboardJustPressed('PLUS')
	local minusHeld = keyboardPressed and keyboardPressed('MINUS')
	if reloadPressed == true and minusHeld == true then reloadShader() end
end

function onDestroy()
	if lowQuality then return end
	runHaxeCode([[
		if (nolaShaderResizeFix != null)
			FlxG.signals.gameResized.remove(nolaShaderResizeFix);
		nolaShaderResizeFix = null;
		if (game.camGame != null)
			game.camGame.setFilters([]);
	]])
	filterActive = false
end
