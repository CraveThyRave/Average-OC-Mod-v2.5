local SHADER_NAME = 'ntsc'
local SHADER_HOLDER = 'skylineNtscShaderHolder'
local START_STEP = 1711
local START_DURATION_MS = 400
local RETURN_STEP = 1834
local RETURN_DURATION_MS = 500
local DIM_ALPHA = 0.4
local DIM_ZOOM = 0.58

local shaderReady = false
local filterActive = false
local prewarmPending = false
local prewarmApplied = false
local normalZoom = 0.7
local entryZoom = 0.7

local function clamp(value)
	return math.max(0, math.min(1, value))
end

local function smoothstep(value)
	value = clamp(value)
	return value * value * (3 - 2 * value)
end

local function setFilterActive(active)
	if filterActive == active then return end
	runHaxeCode([[
		var holder = game.getLuaObject("]] .. SHADER_HOLDER .. [[");
		var scrolling = game.getLuaObject("nolaShaderHolder");
		var filters = [];
		if (scrolling != null && scrolling.shader != null && scrolling.alpha > 0.001)
			filters.push(new ShaderFilter(scrolling.shader));
		if (]] .. tostring(active) .. [[ && holder != null && holder.shader != null)
			filters.push(new ShaderFilter(holder.shader));
		game.camGame.setFilters(filters);
	]])
	filterActive = active
end

local function timelineValues()
	local step = curDecStep or curStep
	local stepLength = math.max(0.0001, stepCrochet or 100)
	if step < START_STEP then return 0, 1, nil end
	if step < START_STEP + START_DURATION_MS / stepLength then
		local progress = smoothstep((step - START_STEP) * stepLength / START_DURATION_MS)
		return progress, 1 + (DIM_ALPHA - 1) * progress, entryZoom + (DIM_ZOOM - entryZoom) * progress
	end
	if step < RETURN_STEP then return 1, DIM_ALPHA, DIM_ZOOM end
	if step < RETURN_STEP + RETURN_DURATION_MS / stepLength then
		local progress = smoothstep((step - RETURN_STEP) * stepLength / RETURN_DURATION_MS)
		return 1 - progress, DIM_ALPHA + (1 - DIM_ALPHA) * progress, DIM_ZOOM + (normalZoom - DIM_ZOOM) * progress
	end
	return 0, 1, normalZoom
end

local function applyTimeline()
	local step = curDecStep or curStep
	if step < START_STEP then
		normalZoom = getProperty('defaultCamZoom')
		entryZoom = getProperty('camGame.zoom')
	end
	local strength, backgroundAlpha, zoom = timelineValues()
	setVar('skylineNtscBackgroundFade', backgroundAlpha)
	setVar('skylineNtscBackgroundStrength', strength)
	setProperty(SHADER_HOLDER .. '.alpha', strength)
	if shaderReady then
		setFilterActive(strength > 0.001)
		setShaderFloat(SHADER_HOLDER, 'effectStrength', strength)
		setShaderFloat(SHADER_HOLDER, 'uInterlace', 1)
		setShaderInt(SHADER_HOLDER, 'uFrame', math.floor(math.max(0, getSongPosition()) / 16.6667) % 2)
	end
	if zoom ~= nil then
		setProperty('defaultCamZoom', zoom)
		setProperty('camGame.zoom', zoom)
	end
end

function onCreate()
	setVar('skylineNtscBackgroundFade', 1)
	setVar('skylineNtscBackgroundStrength', 0)
end

function onCreatePost()
	normalZoom = getProperty('defaultCamZoom')
	entryZoom = getProperty('camGame.zoom')
	makeLuaSprite(SHADER_HOLDER, '', 0, 0)
	makeGraphic(SHADER_HOLDER, 1, 1, 'FFFFFF')
	setProperty(SHADER_HOLDER .. '.visible', false)
	addLuaSprite(SHADER_HOLDER, false)
	addHaxeLibrary('ShaderFilter', 'openfl.filters')
	shaderReady = initLuaShader(SHADER_NAME)
	if shaderReady then
		setSpriteShader(SHADER_HOLDER, SHADER_NAME)
		setShaderFloat(SHADER_HOLDER, 'effectStrength', 0)
		setShaderFloat(SHADER_HOLDER, 'uInterlace', 1)
		prewarmPending = true
	end
	runHaxeCode([[
		skylineNtscResizeFix = function(?_)
		{
			var sprite = game.camGame.flashSprite;
			if (sprite == null || sprite.filters == null || sprite.filters.length == 0) return;
			sprite.__cacheBitmap = null;
			sprite.__cacheBitmapData = null;
		};
		FlxG.signals.gameResized.add(skylineNtscResizeFix);
		skylineNtscResizeFix();
	]])
end

function onUpdate(elapsed)
	if prewarmApplied then
		prewarmApplied = false
		prewarmPending = false
	end
	applyTimeline()
end

function onUpdatePost(elapsed)
	applyTimeline()
	if prewarmPending and not prewarmApplied then
		runHaxeCode([[
			var filters = [];
			var scrolling = game.getLuaObject("nolaShaderHolder");
			var ntsc = game.getLuaObject("]] .. SHADER_HOLDER .. [[");
			if (scrolling != null && scrolling.shader != null)
				filters.push(new ShaderFilter(scrolling.shader));
			if (ntsc != null && ntsc.shader != null)
				filters.push(new ShaderFilter(ntsc.shader));
		game.camGame.setFilters(filters);
	]])
		setShaderFloat(SHADER_HOLDER, 'effectStrength', 0.001)
		filterActive = true
		prewarmApplied = true
	end
end

function onDestroy()
	setVar('skylineNtscBackgroundFade', 1)
	setVar('skylineNtscBackgroundStrength', 0)
	setProperty('defaultCamZoom', normalZoom)
	runHaxeCode([[
		if (skylineNtscResizeFix != null)
			FlxG.signals.gameResized.remove(skylineNtscResizeFix);
		skylineNtscResizeFix = null;
		if (game.camGame != null)
			game.camGame.setFilters([]);
	]])
	filterActive = false
end
