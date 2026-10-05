
local lockX = 1720
local lockY = 1100

local lightningNoteSafetyWindow = 1600
local lightningRetryDelay = 0.25


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

	makeAnimatedLuaSprite('background', 'fahmix/week2/background', 800, 400)
	addAnimationByPrefix('background', 'idle', 'background idle', 6, true)
	addLuaSprite('background', false)
	scaleObject('background', 1.1, 1.1);




	
	
	

	makeAnimatedLuaSprite('raven-spooky', 'fahmix/week2/raven-spooky', 1400, 700)

	addAnimationByPrefix('raven-spooky', 'idle', 'idle', 6, true)
	addAnimationByPrefix('raven-spooky', 'dance', 'dance', 6, true)

	addLuaSprite('raven-spooky', false)

	
	
	

	makeAnimatedLuaSprite('raven-spooky-lightning', 'fahmix/week2/raven-spooky-lightning', 1400, 700)

	addAnimationByPrefix('raven-spooky-lightning', 'idle', 'idle', 6, true)
	addAnimationByPrefix('raven-spooky-lightning', 'dance', 'dance', 6, true)

	addLuaSprite('raven-spooky-lightning', false)

	setProperty('raven-spooky-lightning.alpha', 0)

	
	
	

	makeAnimatedLuaSprite('phoenix-spooky', 'fahmix/week2/phoenix-spooky', 1600, 760)

	addAnimationByPrefix('phoenix-spooky', 'idle', 'idle', 6, true)
	addAnimationByPrefix('phoenix-spooky', 'dance', 'dance', 6, true)

	addLuaSprite('phoenix-spooky', false)

	
	
	

	makeAnimatedLuaSprite('phoenix-spooky-lightning', 'fahmix/week2/phoenix-spooky-lightning', 1600, 760)

	addAnimationByPrefix('phoenix-spooky-lightning', 'idle', 'idle', 6, true)
	addAnimationByPrefix('phoenix-spooky-lightning', 'dance', 'dance', 6, true)

	addLuaSprite('phoenix-spooky-lightning', false)

	setProperty('phoenix-spooky-lightning.alpha', 0)





	scheduleLightning()
end


function onCreatePost()
    setProperty('isCameraOnForcedPos', true)
    setProperty('camFollow.x', lockX)
    setProperty('camFollow.y', lockY)
    setProperty('camFollowPos.x', lockX)
    setProperty('camFollowPos.y', lockY)
end

function scheduleLightning()
    if getPropertyFromClass('MirrorMode', 'active') then return end
		if inGameOver or getProperty('isDead') then return end
		runTimer('randomLightning', getRandomFloat(8, 17))
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
