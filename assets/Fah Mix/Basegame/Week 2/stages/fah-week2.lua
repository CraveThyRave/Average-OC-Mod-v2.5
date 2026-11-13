
local lockX = 1780
local lockY = 1020

local lightningNoteSafetyWindow = 1600
local lightningRetryDelay = 0.25
local windowChoice = 1

local function makeRoomLayer(tag, image, prefix)
	makeAnimatedLuaSprite(tag, image, 800, 400)
	addAnimationByPrefix(tag, 'idle', prefix, 6, true)
	scaleObject(tag, 1899 * 1.1 / 2940, 1899 * 1.1 / 2940)
	addLuaSprite(tag, false)
end


function onCreate()

	makeAnimatedLuaSprite('paper', 'fahmix/week2/paper', 50, 50)
	addAnimationByPrefix('paper', 'idle', 'BG idle', 3, true)
	addLuaSprite('paper', false)
	scaleObject('paper', 1.5, 1.5);

	makeAnimatedLuaSprite('paper2', 'Freeplay-Chrs/fah/BG', 50, 50)
	addAnimationByPrefix('paper2', 'idle', 'BG idle', 3, true)
	addLuaSprite('paper2', false)
	scaleObject('paper2', 1.5, 1.5);
	setProperty('paper2.alpha', 0)

	windowChoice = getRandomInt(1, 3)
	local windowNames = {'cult', 'eye', 'aspen1'}
	makeRoomLayer('week2Window', 'fahmix/week2/window-randoms', 'window ' .. windowNames[windowChoice])
	addAnimationByPrefix('week2Window', 'lightning', 'window aspen2', 6, true)
	for painting = 1, 6 do
		local variant = getRandomInt(1, 2)
		local prefix = 'paintings painting' .. painting .. '-' .. variant
		makeRoomLayer('week2Painting' .. painting, 'fahmix/week2/painting-randoms', prefix)
	end
	makeRoomLayer('background', 'fahmix/week2/main-bg', 'bg idle')




	
	
	

	makeAnimatedLuaSprite('raven-spooky', 'fahmix/week2/raven-spooky', 1460, 620)

	addAnimationByPrefix('raven-spooky', 'idle', 'idle', 6, true)
	addAnimationByPrefix('raven-spooky', 'dance', 'dance', 6, true)

	addLuaSprite('raven-spooky', false)

	
	
	

	makeAnimatedLuaSprite('raven-spooky-lightning', 'fahmix/week2/raven-spooky-lightning', 1460, 620)

	addAnimationByPrefix('raven-spooky-lightning', 'idle', 'idle', 6, true)
	addAnimationByPrefix('raven-spooky-lightning', 'dance', 'dance', 6, true)

	addLuaSprite('raven-spooky-lightning', false)

	setProperty('raven-spooky-lightning.alpha', 0)

	
	
	

	makeAnimatedLuaSprite('phoenix-spooky', 'fahmix/week2/phoenix-spooky', 1660, 680)

	addAnimationByPrefix('phoenix-spooky', 'idle', 'idle', 6, true)
	addAnimationByPrefix('phoenix-spooky', 'dance', 'dance', 6, true)

	addLuaSprite('phoenix-spooky', false)

	
	
	

	makeAnimatedLuaSprite('phoenix-spooky-lightning', 'fahmix/week2/phoenix-spooky-lightning', 1660, 680)

	addAnimationByPrefix('phoenix-spooky-lightning', 'idle', 'idle', 6, true)
	addAnimationByPrefix('phoenix-spooky-lightning', 'dance', 'dance', 6, true)

	addLuaSprite('phoenix-spooky-lightning', false)

	setProperty('phoenix-spooky-lightning.alpha', 0)





	scheduleLightning()
end


function onCreatePost()
    for _, tag in ipairs({'boyfriend', 'dad', 'lightning-fah', 'lightning-spookykids', 'raven-spooky', 'raven-spooky-lightning', 'phoenix-spooky', 'phoenix-spooky-lightning'}) do
        scaleObject(tag, getProperty(tag .. '.scale.x') * 0.85, getProperty(tag .. '.scale.y') * 0.85, false)
    end
    setProperty('isCameraOnForcedPos', true)
    setProperty('camFollow.x', lockX)
    setProperty('camFollow.y', lockY)
    setProperty('camFollowPos.x', lockX)
    setProperty('camFollowPos.y', lockY)
    if string.lower(songName) == 'south' then
        for _, tag in ipairs({'raven-spooky', 'raven-spooky-lightning', 'phoenix-spooky', 'phoenix-spooky-lightning'}) do
            objectPlayAnimation(tag, 'dance', true)
        end
        runHaxeCode([[
            game.boyfriend.idleSuffix = '2';
            game.boyfriend.recalculateDanceIdle();
            game.boyfriend.dance();
            game.dad.idleSuffix = '-dance';
            game.dad.recalculateDanceIdle();
            game.dad.dance();
        ]])
    end
end

function scheduleLightning()
    if getPropertyFromClass('MirrorMode', 'active') then return end
		if inGameOver or getProperty('isDead') then return end
		local intervalScale = string.lower(songName) == 'south' and 0.5 or 1
		runTimer('randomLightning', getRandomFloat(8 * intervalScale, 17 * intervalScale))
end

function playerNoteNearStrumline()
	local songPosition = getSongPosition()

	
	for i = 0, getProperty('notes.length') - 1 do
		local mustPress = getPropertyFromGroup('notes', i, 'mustPress')
		local ignoreNote = getPropertyFromGroup('notes', i, 'ignoreNote')
		local strumTime = getPropertyFromGroup('notes', i, 'strumTime')

		if mustPress and not ignoreNote and
			math.abs(strumTime - songPosition) <= lightningNoteSafetyWindow then
			return true
		end
	end

	
	for i = 0, getProperty('unspawnNotes.length') - 1 do
		local mustPress = getPropertyFromGroup('unspawnNotes', i, 'mustPress')
		local ignoreNote = getPropertyFromGroup('unspawnNotes', i, 'ignoreNote')
		local strumTime = getPropertyFromGroup('unspawnNotes', i, 'strumTime')

		if mustPress and not ignoreNote and
			math.abs(strumTime - songPosition) <= lightningNoteSafetyWindow then
			return true
		end
	end

	return false
end

function onTimerCompleted(tag)
    if inGameOver or getProperty('isDead') then return end
    if tag == 'randomLightning' then

        
        if not mustHitSection and not playerNoteNearStrumline() then
            cancelTween('paper2In')
            cancelTween('paper2Out')
			if windowChoice == 3 then objectPlayAnimation('week2Window', 'lightning', true) end


						playSound('lightning', 1)
						doTweenAlpha('paper2In', 'paper2', 1, 0.2, 'quadOut')
						cancelTween('lightningFahOut')
						doTweenAlpha('lightningFahIn', 'lightning-fah', 1, 0.2, 'quadOut')
						doTweenAlpha('lightningDadIn', 'lightning-spookykids', 1, 0.2, 'quadOut')

						doTweenAlpha('lightningPIn', 'phoenix-spooky-lightning', 1, 0.2, 'quadOut')
						doTweenAlpha('lightningRIn', 'raven-spooky-lightning', 1, 0.2, 'quadOut')
						triggerEvent('LightningMechanic', '', '')


            runTimer('paper2Hide', 0.15)
			scheduleLightning()
		elseif not mustHitSection then
			
			runTimer('randomLightning', lightningRetryDelay)
		else
			scheduleLightning()
        end
    end

    if tag == 'paper2Hide' then
				doTweenAlpha('paper2Out', 'paper2', 0, 0.45, 'quadIn')
				cancelTween('lightningFahIn')
				doTweenAlpha('lightningFahOut', 'lightning-fah', 0, 0.45, 'quadIn')
				doTweenAlpha('lightningDadOut', 'lightning-spookykids', 0, 0.45, 'quadIn')

				doTweenAlpha('lightningPout', 'phoenix-spooky-lightning', 0, 0.45, 'quadOut')
				doTweenAlpha('lightningRout', 'raven-spooky-lightning', 0, 0.45, 'quadOut')
    end
end

function onTweenCompleted(tag)
	if tag == 'paper2Out' and windowChoice == 3 then
		objectPlayAnimation('week2Window', 'idle', true)
	end
end

function onGameOver()
	cancelTimer('randomLightning')
	cancelTimer('paper2Hide')
end

function onGameOverStart()
	onGameOver()
end

function onStepHit()
    if songName == 'Spookeez' and curStep == 800 then
        objectPlayAnimation('raven-spooky-lightning', 'dance', true)
				objectPlayAnimation('raven-spooky', 'dance', true)


				objectPlayAnimation('phoenix-spooky-lightning', 'dance', true)
				objectPlayAnimation('phoenix-spooky', 'dance', true)
    end
end
