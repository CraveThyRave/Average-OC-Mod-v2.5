local introStarted = false
local introAnimationPlaying = false
local introHoldComplete = false
local introComplete = false
local introDad = 'tankman-fah-bleh'
local normalDad = 'tankman-fah'
local introVoiceTag = 'blehIntroVoice'
local introMusicVolume = 0.45
local introMusicFadeOutDuration = 0.6
local introStoryBeat = 'bleh-intro'
local skipIntro = false
local storyPresentation = false
local storyFadeActive = false

local function finishWithStoryFade()
	if storyPresentation then
		storyFadeActive = true
		setProperty('inCutscene', true)
		setProperty('blehStoryBlack.visible', true)
		setProperty('blehStoryBlack.alpha', 1)
		doTweenAlpha('blehStoryFade', 'blehStoryBlack', 0, 0.2, 'linear')
		runTimer('blehStoryFadeFinish', 0.2)
	else
		introComplete = true
		setProperty('inCutscene', false)
		startCountdown()
	end
end

function onCreate()
	storyPresentation = getPropertyFromClass('PlayState', 'isStoryMode') or getPropertyFromClass('PlayState', 'fahMixFullWeekActive')
	skipIntro = getProperty('songRestart') or (not shouldRepeatStoryBeats() and hasSeenStoryBeat(introStoryBeat))
	addCharacterToList(introDad, 'dad')
	addCharacterToList(normalDad, 'dad')
	precacheMusic('week7cutscene1')
	precacheSound('intro/tankman1')
	if storyPresentation then
		makeLuaSprite('blehStoryBlack', nil, -4, -4)
		makeGraphic('blehStoryBlack', screenWidth + 8, screenHeight + 8, '000000')
		setObjectCamera('blehStoryBlack', 'other')
		setProperty('blehStoryBlack.alpha', 0)
		setProperty('blehStoryBlack.visible', false)
		addLuaSprite('blehStoryBlack', true)
	end
end

function onCreatePost()
	if storyPresentation then setObjectOrder('blehStoryBlack', 9999) end
end

function onStartCountdown()
	if introComplete then
		return Function_Continue
	end
	if skipIntro then
		if storyPresentation then
			if not storyFadeActive then finishWithStoryFade() end
			return Function_Stop
		end
		introComplete = true
		return Function_Continue
	end

	if not introStarted then
		introStarted = true
		markStoryBeatSeen(introStoryBeat)
		setProperty('inCutscene', true)
		runTimer('blehIntroStart', 0.3)
	end

	return Function_Stop
end

function onUpdate(elapsed)
	if introAnimationPlaying then
		local animationName = getProperty('dad.animation.curAnim.name')
		local animationFrame = getProperty('dad.animation.curAnim.curFrame')

		if not introHoldComplete and animationName == 'idle' and animationFrame >= 14 then
			introAnimationPlaying = false
			pauseSound(introVoiceTag)
			playAnim('dad', 'idle-hold', true)
			setProperty('dad.skipDance', true)
			playAnim('boyfriend', 'shrug', true)
			setProperty('boyfriend.specialAnim', true)
			runTimer('blehIntroHold', 1.5)
		elseif introHoldComplete and getProperty('dad.animation.curAnim.finished') then
			introAnimationPlaying = false
			triggerEvent('Change Character', 'dad', normalDad)
			setProperty('dad.skipDance', false)
			soundFadeOut('', introMusicFadeOutDuration, 0)
			runTimer('blehIntroFinish', introMusicFadeOutDuration)
		end
	end
end

function onTimerCompleted(tag)
	if tag == 'blehIntroStart' then
		triggerEvent('Change Character', 'dad', introDad)
		playAnim('dad', 'idle', true)
		setProperty('dad.skipDance', true)
		playMusic('week7cutscene1', 0, false)
		soundFadeIn('', 0.2, 0, introMusicVolume)
		playSound('intro/tankman1', 0.65, introVoiceTag)
		introAnimationPlaying = true
	elseif tag == 'blehIntroHold' then
		introHoldComplete = true
		playAnim('boyfriend', 'idle', true)
		setProperty('boyfriend.specialAnim', false)
		playAnim('dad', 'idle', true, false, 16)
		setProperty('dad.skipDance', true)
		resumeSound(introVoiceTag)
		introAnimationPlaying = true
	elseif tag == 'blehIntroFinish' then
		finishWithStoryFade()
	elseif tag == 'blehStoryFadeFinish' then
		storyFadeActive = false
		introComplete = true
		setProperty('blehStoryBlack.visible', false)
		setProperty('inCutscene', false)
		startCountdown()
	end
end
