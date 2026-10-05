function onCreate()
	 
	makeLuaSprite('legacyWhiteBG', '', -680, 0)
	makeGraphic('legacyWhiteBG', 4, 4, 'FFFFFF')
	scaleObject('legacyWhiteBG', 1000, 625)
	setObjectCamera('legacyWhiteBG', 'game')
	setBlendMode('legacyWhiteBG', 'normal')
	setProperty('legacyWhiteBG.alpha', 1)
	setProperty('legacyWhiteBG.color', getColorFromHex('FFFFFF'))
	addLuaSprite('legacyWhiteBG', false)










	makeLuaSprite('black1', 'Freeplay-Chrs/gabriella/legacy-shiftr/gabby/black', -500, 0);
	scaleObject('black1' ,1.5,1.5)
	addLuaSprite('black1', false);

	makeLuaSprite('blackunderlay', 'Freeplay-Chrs/gabriella/legacy-shiftr/dablack', -480, 700);
	setObjectCamera('blackunderlay', 'camgame')
	addLuaSprite('blackunderlay', false);
	scaleObject('blackunderlay', 6, 6)
	screenCenter('blackunderlay', 'x')
	screenCenter('blackunderlay', 'y')

	makeLuaSprite('blackoverlay', 'Freeplay-Chrs/gabriella/legacy-shiftr/dablack', -480, 700);
	setObjectCamera('blackoverlay', 'camOther')
	addLuaSprite('blackoverlay', false);
	scaleObject('blackoverlay', 6, 6)
	screenCenter('blackoverlay', 'x')
	screenCenter('blackoverlay', 'y')
	setProperty('blackoverlay.alpha', 0);


	setProperty('blackunderlay.alpha', 1);

	makeLuaSprite('dadSpotlight', 'Freeplay-Chrs/gabriella/legacy-shiftr/spotlight', 350, 300)  
	setProperty('dadSpotlight.alpha', 0)
	scaleObject('dadSpotlight', 1.2, 1.2)
	setBlendMode('dadSpotlight', 'add')
	addLuaSprite('dadSpotlight', true)

	makeLuaSprite('bfSpotlight', 'Freeplay-Chrs/gabriella/legacy-shiftr/spotlight', 1400, 400)  
	setProperty('bfSpotlight.alpha', 0)
	scaleObject('bfSpotlight', 1.1, 1.1)
	setBlendMode('bfSpotlight', 'add')
	addLuaSprite('bfSpotlight', true)
end


function onStepHit()
  if curStep >= 256 and curStep <= 500 then
		setProperty('dad.alpha', 1);
		setProperty('boyfriend.alpha', 1);
		setProperty('blackunderlay.alpha', 0);
		setProperty('cameraSpeed', 6)
    defParticleOpacity = 1
  else
		setProperty('cameraSpeed', 0.7)
	end
	if curStep == 50 then
	doTweenAlpha('dadSpotlight','dadSpotlight',0.35,0.4,'quadIn')
	doTweenAlpha('dad','dad',1,0.2,'quadOut')
  end
	if curStep == 64 then
	doTweenAlpha('dadSpotlight','dadSpotlight',0,1.1,'quadIn')
	doTweenAlpha('dad','dad',0,0.8,'quadOut')
	end

	if curStep == 118 then
	doTweenAlpha('bfSpotlight','bfSpotlight',0.35,0.4,'quadIn')
	doTweenAlpha('boyfriend','boyfriend',1,0.2,'quadOut')
	end
	if curStep == 126 then
	doTweenAlpha('bfSpotlight','bfSpotlight',0,0.7,'quadIn')
	doTweenAlpha('boyfriend','boyfriend',0,0.5,'quadOut')
	end
	if curStep == 179 then
	doTweenAlpha('dadSpotlight','dadSpotlight',0.35,0.4,'quadIn')
	doTweenAlpha('dad','dad',1,0.2,'quadOut')

	end
	if curStep == 192 then
	doTweenAlpha('dadSpotlight','dadSpotlight',0,1.1,'quadIn')
	doTweenAlpha('dad','dad',0,0.8,'quadOut')
	end
	if curStep == 1295 then
		defParticleOpacity = 0
	end
	if curStep >= 1792 then
	doTweenAlpha('legacyWhiteBG','legacyWhiteBG',1,2.7,'quadIn')
	setProperty('cameraSpeed', 6)
	defParticleOpacity = 0
	end
	if curStep == 2048 then
		setProperty('blackoverlay.alpha', 1);
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
 

 

  

         
particlePath = "Freeplay-Chrs/gabriella/legacy-shiftr/gabby/particle"  
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
 

 
enabled = true  
modeName = 'Embers'  


 
 


         
            

            
BetaPathing = false  
VelocityXMod = 0  
VelocityYMod = 0  

            
camera = 'camGame'  
particleWidth = 3500  
particleHeight = 350  
particleX = -1200  
particleY = 500  




 
loop = 0
mode = 1
particles = 0
sprites = 0
nameResolved = false
processedTicks = 0
spawnClock = 0
particleFrames = 0
modes = {'Blizzard', 'Fireflies', 'Embers', 'Snow', 'Wind Left', 'Wind Right'}  
local activeParticleTags = {}

function onCreatePost()
 		setProperty('dad.alpha', 0);
		setProperty('boyfriend.alpha', 0)
	for index, availableMode in ipairs(modes) do
		if availableMode == modeName then
			mode = index
			nameResolved = true
			break
		end
	end
	reCalcTicks()
    runTimer('del', 2)
end



function reCalcTicks()  
    if mode == 1 then
        processedTicks = math.max(1, math.floor(waitingTicks / 2))
    elseif mode == 4 then
        processedTicks = math.max(1, waitingTicks * 2)
    else
        processedTicks = math.max(1, waitingTicks)
    end
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'del' then  
        for i = #activeParticleTags, 1, -1 do
            local particleTag = activeParticleTags[i]
            if not luaSpriteExists(particleTag) or getProperty(particleTag .. '.alpha') <= 0 then
                if luaSpriteExists(particleTag) then
                    removeLuaSprite(particleTag, true)
                end
                table.remove(activeParticleTags, i)
                sprites = math.max(0, sprites - 1)
            end
        end
        runTimer('del', 2)  
    end
end

function onUpdate(elapsed)
	local elapsedFrames = math.max(0, elapsed) * 60
	spawnClock = spawnClock + elapsedFrames
	particleFrames = particleFrames + elapsedFrames
    if not lowQuality and defParticleOpacity > 0 and sprites < maxParticles
		and spawnClock >= processedTicks then
		spawnClock = spawnClock % processedTicks
		if nameResolved and enabled then spawnParticle() end
    end
    if not lowQuality and BetaPathing and nameResolved and enabled then
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
    particles = particles + 1
    sprites = sprites + 1
    local particleTag = tostring(particles)
    if mode == 1 then
        makeLuaSprite(particles, particlePath, particleX-200, getRandomInt(particleY-1500, particleY+particleHeight + 300))  
        setProperty(particles .. '.health', getProperty(particles .. '.x'))  
        if not BetaPathing then
            setProperty(particles .. '.velocity.y', 2000)  
            setProperty(particles .. '.velocity.x', 2500)
        end
        setProperty(particles .. '.alpha', defParticleOpacity)  
        setProperty(particles .. '.angle', defParticleAngle)
        if colorParticle then
            setProperty(particles .. '.color', defParticleColor)
        end
    elseif mode == 2 then
        makeLuaSprite(particles, particlePath, getRandomInt(particleX+0, particleX+particleWidth), getRandomInt(particleY+0, particleY+particleHeight))
        setProperty(particles .. '.health', getRandomInt(-20, 20))
        if not BetaPathing then
            setProperty(particles .. '.velocity.y', getRandomInt(-20, 20))
            setProperty(particles .. '.velocity.x', getRandomInt(-20, 20))
        end
        setProperty(particles .. '.alpha', defParticleOpacity)
        setProperty(particles .. '.angle', defParticleAngle)
        if colorParticle then
            setProperty(particles .. '.color', defParticleColor)
        end
    elseif mode == 3 then
        makeLuaSprite(particles, particlePath, getRandomInt(particleX+0, particleX+particleWidth), particleY + particleHeight + 100)
        setProperty(particles .. '.health', getProperty(particles .. '.x'))
        if not BetaPathing then
            setProperty(particles .. '.velocity.y', -400)
            setProperty(particles .. '.velocity.x', getRandomInt(-100, 100))
        end
        setProperty(particles .. '.alpha', defParticleOpacity)
        setProperty(particles .. '.angle', defParticleAngle)
        if colorParticle then
            setProperty(particles .. '.color', defParticleColor)
        end
    elseif mode == 4 then
        makeLuaSprite(particles, particlePath, getRandomInt(particleX+0, particleX+particleWidth), particleY-100)
        setProperty(particles .. '.health', getProperty(particles .. '.x'))
        if not BetaPathing then
            setProperty(particles .. '.velocity.y', 800)
            setProperty(particles .. '.velocity.x', getRandomInt(-100, 100))
        end
        setProperty(particles .. '.alpha', defParticleOpacity)
        setProperty(particles .. '.angle', defParticleAngle)
        if colorParticle then
            setProperty(particles .. '.color', defParticleColor)
        end
    elseif mode == 5 then
        makeLuaSprite(particles, particlePath, particleX+particleWidth + 100, getRandomInt(particleY+0, particleY+particleHeight))
        setProperty(particles .. '.health', getRandomInt(-1300, -700))
        if not BetaPathing then
            setProperty(particles .. '.velocity.y', 0)
            setProperty(particles .. '.velocity.x', getRandomInt(-1300, -700))
        end
        setProperty(particles .. '.alpha', defParticleOpacity)
        setProperty(particles .. '.angle', defParticleAngle)
        if colorParticle then
            setProperty(particles .. '.color', defParticleColor)
        end
    elseif mode == 6 then
        makeLuaSprite(particles, particlePath, particleX-100, getRandomInt(particleY+0, particleY+particleHeight))
        setProperty(particles .. '.health', getRandomInt(700, 1300))
        if not BetaPathing then
            setProperty(particles .. '.velocity.y', 0)
            setProperty(particles .. '.velocity.x', getRandomInt(700, 1300))
        end
        setProperty(particles .. '.alpha', defParticleOpacity)
        setProperty(particles .. '.angle', defParticleAngle)
        if colorParticle then
            setProperty(particles .. '.color', defParticleColor)
        end
    end
    addLuaSprite(particles, false)
	table.insert(activeParticleTags, particleTag)
	setObjectOrder(particleTag, 2)
    if randomScale then
        rand = getRandomFloat(defParticleScaleY/2, defParticleScaleY)  
        scaleObject(particles, rand, rand)
    else
        scaleObject(particles, defParticleScaleY, defParticleScaleY)
    end

    if scaleDependantAlpha then
        setProperty(particles..'.alpha', rand)  
    end

    if mode == 1 then
        doTweenAlpha(particles, particles, 0, 1.8, 'linear')
    elseif mode == 2 then
        doTweenAlpha(particles, particles, 0, 1, 'linear')
    elseif mode == 3 or mode == 4 then
        doTweenAlpha(particles, particles, 0, 2, 'linear')
    elseif mode == 5 or mode == 6 then
        doTweenAlpha(particles, particles, 0, 4, 'linear')
    end
end
