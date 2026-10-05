local activeParticleTags = {}
local transitionOrders = nil
local introBlackoutReleased = false
local introTransitionFinished = false
local blackMidlayStarted = false
local blackMidlayFinished = false
local postMidlayCueFinished = false
local endingHudFadeStarted = false
local endingOverlayStarted = false
local endingFlashFinished = false

local function placeBlackMidlayBelowGameplay()
	transitionOrders = {
		blackmidlay = getObjectOrder('blackmidlay'),
		notes = getObjectOrder('notes'),
		strums = getObjectOrder('strumLineNotes'),
		splashes = getObjectOrder('grpNoteSplashes')
	}



	runHaxeCode([[
		var blackout = game.getLuaObject("blackmidlay");
		if (blackout != null)
		{
			game.remove(blackout, true);
			game.add(blackout);
		}

		for (group in [game.notes, game.strumLineNotes, game.grpNoteSplashes])
		{
			if (group != null)
			{
				game.remove(group, true);
				game.add(group);
			}
		}
	]])
end

local function restoreTransitionOrders()
	if transitionOrders == nil then return end

	local objects = {
		{tag = 'blackmidlay', order = transitionOrders.blackmidlay},
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

function onCreate()

	makeLuaSprite('bg', 'dawhite', -680, 0)

	addLuaSprite('bg', false)
	initLuaShader('void')
	setSpriteShader('bg', 'void')
	setShaderFloat('bg', 'u_mix', 0.03)
	setShaderFloatArray('bg', 'u_scale', {1, 1})
	setShaderFloatArray('bg', 'u_offset', {0, 0})

	makeLuaSprite('black1', 'Freeplay-Chrs/gabriella/gabby/black', -500, 0);
	scaleObject('black1' ,1.5,1.5)
	addLuaSprite('black1', false);

	makeLuaSprite('blackunderlay', 'dablack', -480, 700);
	setObjectCamera('blackunderlay', 'camgame')
	addLuaSprite('blackunderlay', true);
	scaleObject('blackunderlay', 6, 6)
	screenCenter('blackunderlay', 'x')
	screenCenter('blackunderlay', 'y')


	makeLuaSprite('blackmidlay', 'dablack', -480, 700);
	setObjectCamera('blackmidlay', 'camHUD')
	addLuaSprite('blackmidlay', false);
	scaleObject('blackmidlay', 6, 6)
	screenCenter('blackmidlay', 'x')
	screenCenter('blackmidlay', 'y')
	setProperty('blackmidlay.alpha', 0);


	makeLuaSprite('blackoverlay', 'dablack', -480, 700);
	setObjectCamera('blackoverlay', 'camOther')
	addLuaSprite('blackoverlay', false);
	scaleObject('blackoverlay', 6, 6)
	screenCenter('blackoverlay', 'x')
	screenCenter('blackoverlay', 'y')
	setProperty('blackoverlay.alpha', 1);


	setProperty('blackunderlay.alpha', 0.85);

	makeLuaSprite('dadSpotlight', 'Freeplay-Chrs/gabriella/gabby/spotlight', 560, 350)
	setProperty('dadSpotlight.alpha', 0.7)
	scaleObject('dadSpotlight', 1.2, 1.2)
	setBlendMode('dadSpotlight', 'add')
	addLuaSprite('dadSpotlight', true)

	makeLuaSprite('bfSpotlight', 'Freeplay-Chrs/gabriella/gabby/spotlight', 1650, 350)
	setProperty('bfSpotlight.alpha', 0.7)
	scaleObject('bfSpotlight', 1, 1.2)
	setBlendMode('bfSpotlight', 'add')
	addLuaSprite('bfSpotlight', true)


	setProperty('camHUD.alpha', 0)

	makeLuaSprite('dawhitefront', 'dawhite', 0, 0)
	setObjectCamera('dawhitefront', 'other')
	setProperty('dawhitefront.alpha', 0)
	addLuaSprite('dawhitefront', true)



	makeLuaSprite('blackoverlaybutgame', 'dablack', -480, 700);
	setObjectCamera('blackoverlaybutgame', 'camGame')
	addLuaSprite('blackoverlaybutgame', true);
	scaleObject('blackoverlaybutgame', 6, 6)
	screenCenter('blackoverlaybutgame', 'x')
	screenCenter('blackoverlaybutgame', 'y')
	setProperty('blackoverlaybutgame.alpha', 0);

end


local backgroundOpacityCues = {
	{step = 1, opacity = 1},
	{step = 1055, opacity = 0.6},
	{step = 1311, opacity = 0.75},
	{step = 1567, opacity = 1}
}
local nextBackgroundOpacityCue = 1

function onStepHit()
	while nextBackgroundOpacityCue <= #backgroundOpacityCues
		and curStep >= backgroundOpacityCues[nextBackgroundOpacityCue].step do
		local cue = backgroundOpacityCues[nextBackgroundOpacityCue]
		defParticleOpacity = cue.opacity
		enabled = not lowQuality and defParticleOpacity > 0
		if cue.step == 1 then
			setProperty('bg.alpha', cue.opacity)
			setProperty('black1.alpha', cue.opacity)
		else
			doTweenAlpha('shiftrBackgroundOpacity', 'bg', cue.opacity, 0.3, 'quadInOut')
			doTweenAlpha('shiftrGroundOpacity', 'black1', cue.opacity, 0.3, 'quadInOut')
			if luaSpriteExists('floor') then
				doTweenAlpha('shiftrFloorOpacity', 'floor', cue.opacity, 0.3, 'quadInOut')
			end
		end
		nextBackgroundOpacityCue = nextBackgroundOpacityCue + 1
	end

	if curStep >= 32 and not introBlackoutReleased then
		introBlackoutReleased = true
		setProperty('blackoverlay.alpha', 0);
	end

	if curStep >= 287 and not introTransitionFinished then
		introTransitionFinished = true
		doTweenAlpha('bfSpotlight', 'bfSpotlight', 0, 0.7, 'quadInOut')
		doTweenAlpha('blackoverlay', 'blackoverlay', 0, 0.7, 'quadInOut')
		doTweenAlpha('dadSpotlight', 'dadSpotlight', 0, 0.7, 'quadInOut')
		doTweenAlpha('hudFade', 'camHUD', 1, 0.7, 'quadOut')
		setProperty('blackunderlay.alpha', 0);
	end

	if curStep >= 2048 and not blackMidlayStarted then
		blackMidlayStarted = true
		placeBlackMidlayBelowGameplay()
		doTweenAlpha('shiftrBlackMidlayIn', 'blackmidlay', 1, 1.3, 'quadInOut')
	end


		if curStep >= 2067 and not blackMidlayFinished then
			blackMidlayFinished = true
			doTweenAlpha('shiftrBlackMidlayOut', 'blackmidlay', 0, 0.3, 'quadInOut')
		end


	if curStep >= 2072 and not postMidlayCueFinished then
		postMidlayCueFinished = true
		doTweenAlpha('blackoverlaybutgame', 'blackoverlaybutgame', 0, 0.5, 'quadInOut')
	end


	if curStep >= 2592 and not endingHudFadeStarted then
		endingHudFadeStarted = true
		doTweenAlpha('hudFade', 'camHUD', 0, 2.3, 'quadOut')
		doTweenAlpha('blackunderlay', 'blackunderlay', 0, 1.5, 'quadInOut')
	end

	if curStep >= 2608 and not endingOverlayStarted then
		endingOverlayStarted = true
		doTweenAlpha('dawhitefront', 'dawhitefront', 1, 1.4, 'quadInOut')
		doTweenAlpha('blackoverlay', 'blackoverlay', 1, 1.4, 'quadInOut')
	end

	if curStep >= 2623 and not endingFlashFinished then
		endingFlashFinished = true
		doTweenAlpha('dawhitefrontaway', 'dawhitefront', 0, 0.3, 'quadInOut')
	end

end

function onUpdatePost()


	if curStep < 287 then
		setProperty('camHUD.alpha', 0)
		setProperty('blackoverlay.alpha', curStep < 32 and 1 or 0)
		setProperty('dadSpotlight.alpha', 0.7)
		setProperty('bfSpotlight.alpha', 0.7)
	end
end






function colorFromString(color)
    val = 0xFFFFFFFF
    if color:lower() == 'white' then val = 0xFFFFFF end
    if color:lower() == 'gray' then val = 0x808080 end
    if color:lower() == 'black' then val = 0x000000 end

    if color:lower() == 'green' then val = 0x008000 end
    if color:lower() == 'lime' then val = 0x00FF00 end
    if color:lower() == 'yellow' then val = 0xFFFF00 end
    if color:lower() == 'orange' then val = 0xFFA500 end
    if color:lower() == 'red' then val = 0xFF0000 end
    if color:lower() == 'purple' then val = 0x800080 end
    if color:lower() == 'blue' then val = 0x0000FF end
    if color:lower() == 'brown' then val = 0x8B4513 end
    if color:lower() == 'pink' then val = 0xFFC0CB end
    if color:lower() == 'magenta' then val = 0xFF00FF end
    if color:lower() == 'cyan' then val = 0x00FFFF end

    return val
end







particlePath = "Freeplay-Chrs/gabriella/gabby/particle"
defParticleScaleX = 1
defParticleScaleY = 1
defParticleOpacity = 0

defParticleAngle = 0
waitingTicks = 5
randomScale = false


scaleDependantAlpha = false


maxParticles = 25
colorParticle = false
defParticleColor = colorFromString('white')



enabled = defParticleOpacity > 0
modeName = 'Embers'










BetaPathing = false
VelocityXMod = 0
VelocityYMod = 0


camera = 'camGame'
particleWidth = 3500
particleHeight = 350
particleX = -1200
particleY = 500





local mode = 1
local particleSlotsCreated = 0
local sprites = 0
local nameResolved = false
local processedTicks = waitingTicks
local spawnClock = 0
local particleFrames = 0
local modes = {'Blizzard', 'Fireflies', 'Embers', 'Snow', 'Wind Left', 'Wind Right'}
local freeParticleTags = {}
local particleFadeOwners = {}
local particlePoolSize = 25

function onCreatePost()
    for index, availableMode in ipairs(modes) do
        if availableMode == modeName then
            mode = index
            nameResolved = true
            break
        end
    end
    reCalcTicks()
    if not lowQuality then runTimer('gabbyParticlePrewarm', 0.15, 8) end
end



function reCalcTicks()
    processedTicks = mode == 4 and math.max(1, waitingTicks * 2)
        or math.max(1, waitingTicks)
end

local function prewarmParticlePoolChunk(count)
    local lastIndex = math.min(particlePoolSize, particleSlotsCreated + count)
    for index = particleSlotsCreated + 1, lastIndex do
        local tag = 'gabbyParticle' .. index
        makeLuaSprite(tag, particlePath, particleX, particleY)
        setObjectCamera(tag, camera)
        addLuaSprite(tag, false)
        setObjectOrder(tag, 2)
        setProperty(tag .. '.visible', false)
        setProperty(tag .. '.alpha', 0)
        freeParticleTags[#freeParticleTags + 1] = tag
    end
    particleSlotsCreated = lastIndex
end

local function acquireParticle()
    local count = #freeParticleTags
    if count == 0 then return nil end
    local tag = freeParticleTags[count]
    freeParticleTags[count] = nil
    return tag
end

local function releaseParticle(tag)
    if tag == nil then return end
    for index = #activeParticleTags, 1, -1 do
        if activeParticleTags[index] == tag then
            table.remove(activeParticleTags, index)
            sprites = math.max(0, sprites - 1)
            setProperty(tag .. '.visible', false)
            setProperty(tag .. '.alpha', 0)
            setProperty(tag .. '.velocity.x', 0)
            setProperty(tag .. '.velocity.y', 0)
            freeParticleTags[#freeParticleTags + 1] = tag
            return
        end
    end
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'gabbyParticlePrewarm' and not lowQuality then
        prewarmParticlePoolChunk(12)
    end
end

function onUpdate(elapsed)
    if lowQuality then
        enabled = false
        return
    end
	setShaderFloat('bg', 'u_time', (getSongPosition() / 1000) * 0.8)
	local elapsedFrames = math.max(0, elapsed) * 60
	spawnClock = spawnClock + elapsedFrames
	particleFrames = particleFrames + elapsedFrames
    if enabled and nameResolved and sprites < maxParticles
		and spawnClock >= processedTicks then
		spawnClock = spawnClock % processedTicks
        spawnParticle()
    end
    if BetaPathing and nameResolved and enabled then
        particleTick(particleFrames, elapsed)
    end
end

function particleTick(frames, elapsed)



    for _, i in ipairs(activeParticleTags) do
        if luaSpriteExists(i) then
            local particleHealth = mode ~= 1 and getProperty(i..'.health') or 0
            if mode == 1 then
                setProperty(i..'.x', calcVelocity(getProperty(i..'.x'), 2500 + VelocityXMod, elapsed))
                setProperty(i..'.y', calcVelocity(getProperty(i..'.y'), 2000 + VelocityYMod, elapsed))
            end
            if mode == 2 then
                setProperty(i..'.x', calcVelocity(getProperty(i..'.x'), particleHealth + VelocityXMod, elapsed))
                setProperty(i..'.y', calcVelocity(getProperty(i..'.y'), particleHealth + VelocityYMod, elapsed))
            end
            if mode == 3 or mode == 4 then
                if mode == 3 then
                    setProperty(i..'.y', calcVelocity(getProperty(i..'.y'), -400 + VelocityYMod, elapsed))
                else
                    setProperty(i..'.y', calcVelocity(getProperty(i..'.y'), 800 + VelocityYMod, elapsed))
                end
                if particleHealth > screenWidth/2 then
                    setProperty(i..'.x', math.sin(frames*(particleHealth/16000))*80 + particleHealth)
                else
                    if particleHealth < 300 then
                        if particleHealth < 100 then
                            if particleHealth < 30 then
                                if particleHealth < 10 then
                                    setProperty(i..'.visible', false)
                                else
                                    setProperty(i..'.x', math.sin(frames/(particleHealth/1.05))*80 + particleHealth)
                                end
                            else
                                setProperty(i..'.x', math.sin(frames/(particleHealth/1.3))*80 + particleHealth)
                            end
                        else
                            setProperty(i..'.x', math.sin(frames/(particleHealth/10))*80 + particleHealth)
                        end
                    else
                        setProperty(i..'.x', math.sin(frames/(particleHealth/40))*80 + particleHealth)
                    end
                end
            end
            if mode == 5 then
                setProperty(i..'.x', calcVelocity(getProperty(i..'.x'), particleHealth + VelocityXMod, elapsed))
                setProperty(i..'.y', calcVelocity(getProperty(i..'.y'), 0 + VelocityYMod, elapsed))
            end
            if mode == 6 then
                setProperty(i..'.x', calcVelocity(getProperty(i..'.x'), particleHealth + VelocityXMod, elapsed))
                setProperty(i..'.y', calcVelocity(getProperty(i..'.y'), 0 + VelocityYMod, elapsed))
            end
        end
    end
end

function calcVelocity(curPos, velocity, elapsed)
    compVel = velocity
    delta = compVel * elapsed
    nextPos = curPos + delta
    return nextPos
end

function spawnParticle()
    local particleTag = acquireParticle()
    if particleTag == nil then return end
    local x, y, velocityX, velocityY, pathVelocity
    if mode == 1 then
        x = particleX - 200
        y = getRandomInt(particleY - 1500, particleY + particleHeight + 300)
        velocityX, velocityY, pathVelocity = 2500, 2000, x
    elseif mode == 2 then
        x = getRandomInt(particleX, particleX + particleWidth)
        y = getRandomInt(particleY, particleY + particleHeight)
        pathVelocity = getRandomInt(-20, 20)
        velocityX, velocityY = getRandomInt(-20, 20), getRandomInt(-20, 20)
    elseif mode == 3 then
        x = getRandomInt(particleX, particleX + particleWidth)
        y = particleY + particleHeight + 100
        velocityX, velocityY, pathVelocity = getRandomInt(-100, 100), -400, x
    elseif mode == 4 then
        x = getRandomInt(particleX, particleX + particleWidth)
        y = particleY - 100
        velocityX, velocityY, pathVelocity = getRandomInt(-100, 100), 800, x
    elseif mode == 5 then
        x = particleX + particleWidth + 100
        y = getRandomInt(particleY, particleY + particleHeight)
        pathVelocity = getRandomInt(-1300, -700)
        velocityX, velocityY = pathVelocity, 0
    else
        x = particleX - 100
        y = getRandomInt(particleY, particleY + particleHeight)
        pathVelocity = getRandomInt(700, 1300)
        velocityX, velocityY = pathVelocity, 0
    end

	setProperty(particleTag .. '.x', x)
	setProperty(particleTag .. '.y', y)
	setProperty(particleTag .. '.health', pathVelocity)
	setProperty(particleTag .. '.visible', true)
	table.insert(activeParticleTags, particleTag)
	sprites = sprites + 1
	local scale = randomScale and getRandomFloat(defParticleScaleY / 2, defParticleScaleY)
		or defParticleScaleY
	scaleObject(particleTag, scale, scale)
	setProperty(particleTag .. '.alpha', scaleDependantAlpha and scale or defParticleOpacity)
	setProperty(particleTag .. '.angle', defParticleAngle)
	setProperty(particleTag .. '.velocity.x', BetaPathing and 0 or velocityX)
	setProperty(particleTag .. '.velocity.y', BetaPathing and 0 or velocityY)
	if colorParticle then setProperty(particleTag .. '.color', defParticleColor) end
	local duration = mode == 1 and 1.8
		or mode == 2 and 1
		or (mode == 3 or mode == 4) and 2
		or 4
	local fadeTag = 'gabbyParticleFade' .. particleTag
	particleFadeOwners[fadeTag] = particleTag
	doTweenAlpha(fadeTag, particleTag, 0, duration, 'linear')
end

function onTweenCompleted(tag)
	local particleTag = particleFadeOwners[tag]
	if particleTag ~= nil then
		particleFadeOwners[tag] = nil
		releaseParticle(particleTag)
	end
	if tag == 'shiftrBlackMidlayOut' then
		restoreTransitionOrders()
	end
end


function onGameOverStart()
    enabled = false

    for i = #activeParticleTags, 1, -1 do
        local particleTag = activeParticleTags[i]
        if luaSpriteExists(particleTag) then
			setProperty(particleTag .. '.visible', false)
			setProperty(particleTag .. '.alpha', 0)
        end
    end
    activeParticleTags = {}
    sprites = 0
end
