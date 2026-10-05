local currentTint = ''
local particleSlotsCreated = 0
local activeParticleCount = 0
local spawnClock = 0
local freeParticles = {}
local activeParticles = {}
local particleFadeOwners = {}
local particlePoolSize = 25

local function clampChannel(value)
	return math.max(0, math.min(255, math.floor(value + 0.5)))
end

local function arrayToHex(color)
	if color == nil then return 'FFFFFF' end
	return string.format('%02X%02X%02X', clampChannel(color[1] or 255), clampChannel(color[2] or 255), clampChannel(color[3] or 255))
end

local function hexToArray(hex)
	hex = string.gsub(hex or 'FFFFFF', '#', '')
	return {
		tonumber(string.sub(hex, 1, 2), 16) or 255,
		tonumber(string.sub(hex, 3, 4), 16) or 255,
		tonumber(string.sub(hex, 5, 6), 16) or 255
	}
end

local function mixedHex(first, second)
	return arrayToHex({
		(first[1] + second[1]) * 0.5,
		(first[2] + second[2]) * 0.5,
		(first[3] + second[3]) * 0.5
	})
end

local function ownerTint()
	local dadColor = hexToArray(getOpponentIconColor())
	local gfColor = getProperty('gf.healthColorArray')
	if gfColor == nil then gfColor = dadColor end
	local owner = runHaxeCode([[
		var owner = game.hudSectionOwner();
		return owner == "bf" ? game.hudOpponentBarOwner() : owner;
	]])
	if owner == 'gf' then return arrayToHex(gfColor) end
	if owner == 'gf-dad' or owner == 'all' then return mixedHex(dadColor, gfColor) end
	return arrayToHex(dadColor)
end

local function applyOwnerTint(instant)
	local tint = ownerTint()
	if tint == currentTint then return end
	currentTint = tint
	if instant then
		setLuaSpriteHexColor('nolaBlack', tint)
	else
		doTweenColor('nolaOwnerTint', 'nolaBlack', tint, 0.25, 'quadOut')
	end
end

local function prewarmParticlePoolChunk(count)
	local lastIndex = math.min(particlePoolSize, particleSlotsCreated + count)
	for index = particleSlotsCreated + 1, lastIndex do
		local tag = 'nolaParticle' .. index
		makeLuaSprite(tag, 'Freeplay-Chrs/gabriella/gabby/particle', -1200, 500)
		setObjectCamera(tag, 'camGame')
		addLuaSprite(tag, false)
		setObjectOrder(tag, 2)
		setProperty(tag .. '.visible', false)
		setProperty(tag .. '.alpha', 0)
		freeParticles[#freeParticles + 1] = tag
	end
	particleSlotsCreated = lastIndex
end

local function acquireParticle()
	local count = #freeParticles
	if count == 0 then return nil end
	local tag = freeParticles[count]
	freeParticles[count] = nil
	return tag
end

local function releaseParticle(tag)
	if activeParticles[tag] == nil then return end
	activeParticles[tag] = nil
	activeParticleCount = math.max(0, activeParticleCount - 1)
	setProperty(tag .. '.visible', false)
	setProperty(tag .. '.alpha', 0)
	setProperty(tag .. '.velocity.x', 0)
	setProperty(tag .. '.velocity.y', 0)
	freeParticles[#freeParticles + 1] = tag
end

local function spawnParticle()
	local tag = acquireParticle()
	if tag == nil then return end
	setProperty(tag .. '.x', getRandomInt(-1200, 2300))
	setProperty(tag .. '.y', 950)
	setProperty(tag .. '.visible', true)
	scaleObject(tag, 1, 1)
	setProperty(tag .. '.alpha', 1)
	setProperty(tag .. '.angle', 0)
	setProperty(tag .. '.velocity.x', getRandomInt(-100, 100))
	setProperty(tag .. '.velocity.y', -400)
	activeParticles[tag] = true
	activeParticleCount = activeParticleCount + 1
	local fadeTag = 'nolaParticleFade' .. tag
	particleFadeOwners[fadeTag] = tag
	doTweenAlpha(fadeTag, tag, 0, 2, 'linear')
end

function onCreate()
	makeLuaSprite('nolaVoid', 'dawhite', -680, 0)
	addLuaSprite('nolaVoid', false)
	initLuaShader('void')
	setSpriteShader('nolaVoid', 'void')
	setShaderFloat('nolaVoid', 'u_mix', 0.03)
	setShaderFloatArray('nolaVoid', 'u_scale', {1, 1})
	setShaderFloatArray('nolaVoid', 'u_offset', {0, 0})

	makeLuaSprite('nolaBlack', 'Freeplay-Chrs/nola/black', -500, 0)
	scaleObject('nolaBlack', 1.5, 1.5)
	addLuaSprite('nolaBlack', false)


	makeLuaSprite('floor', 'Freeplay-Chrs/raven/floor2', -680, 1200)

	addLuaSprite('floor', false)
	setProperty('floor.alpha', 0.8)
	scaleObject('floor', 6.35, 0.7);
end

function onCreatePost()
	applyOwnerTint(true)
	if not lowQuality then runTimer('nolaParticlePrewarm', 0.15, 8) end
end

function onSectionHit()
	applyOwnerTint(false)
end

function onTimerCompleted(tag)
	if tag == 'nolaParticlePrewarm' and not lowQuality then
		prewarmParticlePoolChunk(12)
	end
end

function onUpdate(elapsed)
	setShaderFloat('nolaVoid', 'u_time', getSongPosition() / 1250)
	if lowQuality then return end
	spawnClock = spawnClock + math.max(0, elapsed) * 60
	if activeParticleCount < 25 and spawnClock >= 5 then
		spawnClock = spawnClock % 5
		spawnParticle()
	end
end

function onTweenCompleted(tag)
	local particleTag = particleFadeOwners[tag]
	if particleTag == nil then return end
	particleFadeOwners[tag] = nil
	releaseParticle(particleTag)
end

function onGameOverStart()
	for tag in pairs(activeParticles) do
		setProperty(tag .. '.visible', false)
		setProperty(tag .. '.alpha', 0)
	end
end
