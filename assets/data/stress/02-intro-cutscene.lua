local phase = 'opening'
local introStarted = false
local introComplete = false
local voiceFinished = false
local voiceFrame = 0
local tankSprite = nil
local hudVisible = true
local gameplayBoyfriend = nil
local dadIdleRate = 8
local grayActive = false
local steveEntryTime = nil
local snapSoundPlayed = false
local killSoundPlayed = false
local lastRavenWalkFrame = -1
local introStoryBeat = 'stress-intro'
local skipIntro = false
local storyPresentation = false
local skipFinishPending = false
local introPath = 'fahmix/week7/intro/'
local temporarySprites = {'stressBesties', 'stressSnap', 'stressKiddin', 'stressRay', 'stressPee', 'stressCockyRay', 'stressCockyPee', 'stressRaven', 'stressGray'}

local function setPhase(value)
	phase = value
	setVar('stressIntroPhase', value)
end

local function makeActor(tag, image, animation, prefix, loop)
	makeAnimatedLuaSprite(tag, image, 0, 0)
	addAnimationByPrefix(tag, animation, prefix, 8, loop)
	playAnim(tag, animation, true)
	addLuaSprite(tag, false)
	setProperty(tag .. '.visible', false)
	setProperty(tag .. '.active', false)
	setProperty(tag .. '.origin.x', 0)
	setProperty(tag .. '.origin.y', 0)
	setProperty(tag .. '.offset.x', 0)
	setProperty(tag .. '.offset.y', 0)
end

local function showActor(tag, animation)
	setProperty(tag .. '.visible', true)
	setProperty(tag .. '.active', true)
	playAnim(tag, animation, true)
end

local function tankIdle()
	if tankSprite ~= nil then
		setProperty(tankSprite .. '.visible', false)
		setProperty(tankSprite .. '.active', false)
		tankSprite = nil
	end
	setProperty('dad.visible', true)
	playAnim('dad', 'idle', true)
	setProperty('dad.animation.curAnim.frameRate', 8)
end

local function playTank(tag)
	tankIdle()
	voiceFrame = 0
	tankSprite = tag
	setVar('stressTankActor', tag)
	runHaxeCode([[stressPlaceTank();]])
	setProperty('dad.visible', false)
	showActor(tag, 'play')
end

local function playPair(animation)
	setProperty('stressRay.visible', false)
	setProperty('stressPee.visible', false)
	showActor('stressCockyRay', animation)
	showActor('stressCockyPee', animation)
end

local function syncVoiceAnimation(sprite, sound, lastFrame)
	if voiceFinished then
		setProperty(sprite .. '.animation.curAnim.curFrame', lastFrame)
		setProperty(sprite .. '.animation.curAnim.finished', true)
	else
		voiceFrame = math.max(voiceFrame, math.min(lastFrame, math.floor(getSoundTime(sound) * 8 / 1000)))
		setProperty(sprite .. '.animation.curAnim.curFrame', voiceFrame)
	end
end

local function clearGray()
	if not grayActive then return end
	grayActive = false
	runHaxeCode([[
		var saved = getVar('stressIntroCameraFilters');
		if(saved != null) for(entry in saved) {
			if(entry.camera != null && entry.camera.flashSprite != null) entry.camera.setFilters(entry.filters);
		}
		removeVar('stressIntroCameraFilters');
		removeVar('stressIntroGrayFilters');
	]])
end

local function beginKill()
	tankIdle()
	setPhase('kill')
	killSoundPlayed = false
	playPair('kill')
	grayActive = true
	runHaxeCode([[
		var saved = [];
		var gray = [];
		for(camera in FlxG.cameras.list) {
			var filters = camera.flashSprite.filters == null ? [] : camera.flashSprite.filters.copy();
			saved.push({camera: camera, filters: filters});
			var filter = new ColorMatrixFilter();
			gray.push(filter);
			var combined = filters.copy();
			combined.push(filter);
			camera.setFilters(combined);
		}
		setVar('stressIntroCameraFilters', saved);
		setVar('stressIntroGrayFilters', gray);
	]])
	doTweenAlpha('stressDesaturate', 'stressGray', 1, 0.25, 'sineOut')
end

local function beginWalk()
	setPhase('walk')
	lastRavenWalkFrame = -1
	setProperty('stressCockyRay.visible', false)
	setProperty('stressCockyRay.active', false)
	showActor('stressCockyPee', 'step')
	runHaxeCode([[stressPreparePhoenixStep();]])
	doTweenX('stressPhoenixStepX', 'stressCockyPee', getVar('stressPhoenixStepX'), 0.25, 'linear')
	doTweenY('stressPhoenixStepY', 'stressCockyPee', getVar('stressPhoenixStepY'), 0.25, 'linear')
	showActor('stressRaven', 'walk')
	runHaxeCode([[stressPreparePickup();]])
	local travelTime = getVar('stressRavenTravelTime')
	doTweenX('stressRavenTravelX', 'stressRaven', getVar('stressRavenWalkEndX'), travelTime, 'linear')
	doTweenY('stressRavenTravelY', 'stressRaven', getVar('stressRavenWalkEndY'), travelTime, 'linear')
	doTweenX('stressRavenScaleX', 'stressRaven.scale', getVar('stressRavenWalkEndScaleX'), travelTime, 'linear')
	doTweenY('stressRavenScaleY', 'stressRaven.scale', getVar('stressRavenWalkEndScaleY'), travelTime, 'linear')
end

local function beginHoist()
	setPhase('hoist')
	setProperty('boyfriend.visible', false)
	showActor('stressRaven', 'hoist')
	setProperty('stressRaven.x', getVar('stressHoistStartX'))
	setProperty('stressRaven.y', getVar('stressHoistStartY'))
	setProperty('stressRaven.scale.x', getVar('stressRavenWalkEndScaleX'))
	setProperty('stressRaven.scale.y', getVar('stressRavenWalkEndScaleY'))
	doTweenX('stressRavenHoistX', 'stressRaven', getVar('stressHoistEndX'), 0.4, 'sineInOut')
	doTweenY('stressRavenHoistY', 'stressRaven', getVar('stressHoistEndY'), 0.4, 'sineInOut')
end

local function beginFibbin()
	setPhase('fibbin')
	setProperty('stressRaven.visible', false)
	setProperty('stressRaven.active', false)
	triggerEvent('Change Character', 'bf', gameplayBoyfriend)
	setProperty('boyfriend.visible', true)
	playAnim('boyfriend', 'idle', true, false, 2)
	voiceFinished = false
	playTank('stressKiddin')
	playSound('intro/stress-fibbin', 0.85, 'stressFibbinVoice')
end

local function beginSteveEntrance()
	steveEntryTime = nil
	showActor('stressSteveWalk', 'walk')
	runHaxeCode([[stressStartSteve();]])
	setObjectOrder('stressSteveWalk', getObjectOrder('steve'))
	doTweenX('stressSteveArrival', 'stressSteveWalk', getVar('stressSteveEndX'), getVar('stressSteveTravelTime'), 'linear')
end

function onCreate()
	storyPresentation = getPropertyFromClass('PlayState', 'isStoryMode') or getPropertyFromClass('PlayState', 'fahMixFullWeekActive')
	skipIntro = getProperty('songRestart') or (not shouldRepeatStoryBeats() and hasSeenStoryBeat(introStoryBeat))
	setVar('stressCrowdState', skipIntro and 'hidden' or 'intro')
	addCharacterToList('fahtank-playable', 'bf')
	precacheSound('intro/stress-besties')
	precacheSound('intro/stress-fibbin')
	precacheSound('intro/stress-snap')
	precacheSound('intro/stress-explosion')
	precacheSound('intro/raven-walk-squeak')
	makeActor('stressBesties', introPath .. 'besties', 'play', 'besties idle', false)
	makeActor('stressSnap', introPath .. 'snap', 'play', 'snap idle', false)
	makeActor('stressKiddin', introPath .. 'kiddin', 'play', 'kiddin idle', false)
	makeActor('stressRay', 'fahmix/week7/ray', 'idle', 'idle', true)
	makeActor('stressPee', 'fahmix/week7/pee', 'idle', 'idle', true)
	makeActor('stressCockyRay', introPath .. 'r-anim', 'cock', 'r-anim cock', false)
	addAnimationByPrefix('stressCockyRay', 'idle', 'r-anim idle', 8, true)
	addAnimationByPrefix('stressCockyRay', 'kill', 'r-anim explode', 8, false)
	makeActor('stressCockyPee', introPath .. 'p-anim', 'cock', 'p-anim cock', false)
	addAnimationByPrefix('stressCockyPee', 'idle', 'p-anim idle', 8, true)
	addAnimationByPrefix('stressCockyPee', 'kill', 'p-anim explode', 8, false)
	addAnimationByPrefix('stressCockyPee', 'step', 'p-anim step', 8, false)
	makeActor('stressRaven', introPath .. 'raven-walk', 'walk', 'raven walk walk', true)
	addAnimationByPrefix('stressRaven', 'hoist', 'raven walk hoist', 8, false)
	makeActor('stressSteveWalk', introPath .. 'steve-walk', 'walk', 'steve-walk idle', true)
	makeLuaSprite('stressGray', nil, 0, 0)
	setProperty('stressGray.alpha', 0)
	if storyPresentation then
		makeLuaSprite('stressStoryBlack', nil, -4, -4)
		makeGraphic('stressStoryBlack', screenWidth + 8, screenHeight + 8, '000000')
		setObjectCamera('stressStoryBlack', 'other')
		setProperty('stressStoryBlack.alpha', 1)
		addLuaSprite('stressStoryBlack', true)
	end
	setProperty('pee.visible', false)
	setProperty('steve.visible', false)
	addHaxeLibrary('FlxRect', 'flixel.math')
	addHaxeLibrary('ColorMatrixFilter', 'openfl.filters')
	addHaxeLibrary('Math')
end

function onCreatePost()
	gameplayBoyfriend = getProperty('boyfriend.curCharacter')
	addCharacterToList(gameplayBoyfriend, 'bf')
	setVar('stressGameplayBoyfriend', gameplayBoyfriend)
	dadIdleRate = getProperty('dad.animation.curAnim.frameRate')
	hudVisible = getProperty('camHUD.visible')
	setProperty('camHUD.visible', false)
	triggerEvent('Change Character', 'bf', 'fahtank-playable')
	setProperty('dad.skipDance', true)
	setProperty('dad.animation.curAnim.frameRate', 8)
	showActor('stressRay', 'idle')
	showActor('stressPee', 'idle')
	runHaxeCode([[
		function stressPlace(sprite, x, y, sx, sy) {
			sprite.scale.set(sx, sy);
			sprite.origin.set(0, 0);
			sprite.offset.set(0, 0);
			sprite.setPosition(x, y);
		}
		function stressLeft(sprite) {
			return sprite.x - sprite.offset.x + sprite.origin.x * (1 - sprite.scale.x);
		}
		function stressTop(sprite) {
			return sprite.y - sprite.offset.y + sprite.origin.y * (1 - sprite.scale.y);
		}
		function stressVisibleBottom(sprite) {
			return stressTop(sprite) + (sprite.frame.offset.y + sprite.frame.frame.height) * sprite.scale.y;
		}
		function stressAlignLowest(actor, target, targetX, targetY, actorX, actorY, sx, sy) {
			stressPlace(actor,
				stressLeft(target) + targetX * target.scale.x - actorX * sx,
				stressTop(target) + targetY * target.scale.y - actorY * sy, sx, sy);
		}
		function stressPlaceTank() {
			var tag = getVar('stressTankActor');
			var actor = game.getLuaObject(tag);
			var sx = game.dad.scale.x;
			var sy = game.dad.scale.y;
			var anchorX = tag == 'stressBesties' ? 194 : (tag == 'stressSnap' ? 247 : 155);
			var laterOffsetX = tag == 'stressBesties' ? 0 : (tag == 'stressKiddin' ? -8 : -15) * sx;
			var laterOffsetY = tag == 'stressBesties' ? 0 : (tag == 'stressKiddin' ? -8 : -15) * sy;
			stressPlace(actor, stressLeft(game.dad) + (264 - anchorX) * sx + laterOffsetX,
				stressVisibleBottom(game.dad) - (actor.frame.offset.y + actor.frame.frame.height) * sy + laterOffsetY, sx, sy);
			actor.antialiasing = game.dad.antialiasing;
		}
		stressPlace(game.getLuaObject('stressRay'), 1250, 875, 1.1, 1.1);
		stressPlace(game.getLuaObject('stressPee'), 1720, 875, 1.15, 1.15);
		var ray = game.getLuaObject('stressCockyRay');
		var pee = game.getLuaObject('stressCockyPee');
		stressAlignLowest(ray, game.getLuaObject('stressRay'), 150, 572, 130, 488, 1.1, 1.1);
		stressAlignLowest(pee, game.getLuaObject('stressPee'), 464, 555, 476, 492, 1.15, 1.15);
		function stressPreparePickup() {
			var player = game.boyfriend;
			var raven = game.getLuaObject('stressRaven');
			var sx = player.scale.x;
			var sy = player.scale.y;
			var pickupX = stressLeft(player) + (218 - 414) * sx;
			var pickupY = stressTop(player) + (382 - 841) * sy;
			setVar('stressHoistStartX', pickupX);
			setVar('stressHoistStartY', pickupY);
			setVar('stressHoistEndX', pickupX + 100 * sx);
			setVar('stressHoistEndY', pickupY + 33 * sy);
			var walkX = pickupX + 65 * sx;
			var walkY = pickupY + 285 * sy;
			var startX = 1250 + 310 * 1.1 + 30;
			var startY = Math.min(875 + 94 * 1.1 + 20, walkY - 35);
			stressPlace(raven, startX, startY, sx * 0.82, sy * 0.82);
			setVar('stressRavenWalkEndX', walkX);
			setVar('stressRavenWalkEndY', walkY);
			setVar('stressRavenWalkEndScaleX', sx);
			setVar('stressRavenWalkEndScaleY', sy);
			setVar('stressRavenTravelTime', Math.max(0.75, Math.sqrt((walkX - startX) * (walkX - startX)
				+ (walkY - startY) * (walkY - startY)) / 320));
		}
		function stressPreparePhoenixStep() {
			var source = game.getLuaObject('stressCockyPee');
			var target = game.getLuaObject('pee');
			setVar('stressPhoenixStepX', stressLeft(target) + 276 * target.scale.x - 40 * source.scale.x);
			setVar('stressPhoenixStepY', stressTop(target) + 522 * target.scale.y - 474 * source.scale.y);
		}
		function stressStartSteve() {
			var idle = game.getLuaObject('steve');
			var walk = game.getLuaObject('stressSteveWalk');
			var sx = idle.scale.x;
			var sy = idle.scale.y;
			var endX = stressLeft(idle) + (249 - 159) * sx;
			var endY = stressTop(idle) + (674 - 587) * sy;
			var left = game.camGame.scroll.x + game.camGame.width * 0.5 * (1 - 1 / game.camGame.zoom);
			stressPlace(walk, Math.min(left - 402 * sx - 80, endX - 450), endY, sx, sy);
			walk.antialiasing = idle.antialiasing;
			setVar('stressSteveEndX', endX);
			setVar('stressSteveTravelTime', Math.max(1.25, (endX - walk.x) / 360));
		}
	]])
	setObjectOrder('stressRaven', getObjectOrder('boyfriendGroup') + 1)
	for _, tag in ipairs({'stressBesties', 'stressSnap', 'stressKiddin'}) do
		setObjectOrder(tag, getObjectOrder('dadGroup') + 1)
	end
	if storyPresentation then setObjectOrder('stressStoryBlack', 9999) end
end

local function completeSkippedIntro()
	introComplete = true
	setPhase('complete')
	clearGray()
	setProperty('dad.visible', true)
	setProperty('dad.skipDance', false)
	setProperty('dad.animation.curAnim.frameRate', dadIdleRate)
	triggerEvent('Change Character', 'bf', gameplayBoyfriend)
	setProperty('boyfriend.visible', true)
	setProperty('camHUD.visible', hudVisible)
	for _, sprite in ipairs(temporarySprites) do removeLuaSprite(sprite, true) end
	setProperty('pee.visible', true)
	playAnim('pee', 'idle', true)
	setProperty('pee.animation.curAnim.frameRate', 8)
	setProperty('inCutscene', false)
end

function onStartCountdown()
	if introComplete then return Function_Continue end
	if skipIntro then
		if not skipFinishPending then
			skipFinishPending = true
			setProperty('inCutscene', true)
			if storyPresentation then
				doTweenAlpha('stressStorySkipFade', 'stressStoryBlack', 0, 0.2, 'linear')
				runTimer('stressStorySkipFadeFinish', 0.2)
			else
				runTimer('stressIntroSkipFinish', 0.001)
			end
		end
		return Function_Stop
	end
	setProperty('inCutscene', true)
	if not introStarted then
		introStarted = true
		markStoryBeatSeen(introStoryBeat)
		if storyPresentation then doTweenAlpha('stressStoryIntroFade', 'stressStoryBlack', 0, 0.2, 'linear') end
		runTimer('stressIntroBegin', 0.3)
	end
	return Function_Stop
end

function onUpdatePost(elapsed)
	if grayActive then
		runHaxeCode([[
			var amount = game.getLuaObject('stressGray').alpha;
			var keep = 1 - amount;
			var r = 0.2126 * amount;
			var g = 0.7152 * amount;
			var b = 0.0722 * amount;
			var matrix = [keep + r, g, b, 0, 0, r, keep + g, b, 0, 0,
				r, g, keep + b, 0, 0, 0, 0, 0, 1, 0];
			for(filter in getVar('stressIntroGrayFilters')) filter.matrix = matrix;
		]])
	end
	if introComplete then
		if steveEntryTime ~= nil and getSongPosition() >= steveEntryTime then beginSteveEntrance() end
		return
	end
	if phase == 'walk' then
		local ravenWalkFrame = getProperty('stressRaven.animation.curAnim.curFrame')
		if ravenWalkFrame ~= lastRavenWalkFrame then
			lastRavenWalkFrame = ravenWalkFrame
			if ravenWalkFrame == 1 or ravenWalkFrame == 3 then playSound('intro/raven-walk-squeak', 0.55) end
		end
	end
	if phase == 'besties' then syncVoiceAnimation('stressBesties', 'stressBestiesVoice', 18) end
	if phase == 'fibbin' then syncVoiceAnimation('stressKiddin', 'stressFibbinVoice', 8) end
	if phase == 'snap' and not snapSoundPlayed and getProperty('stressSnap.animation.curAnim.curFrame') >= 2 then
		snapSoundPlayed = true
		setVar('stressCrowdState', 'dismiss')
		playSound('intro/stress-snap', 0.65)
	end
	if phase == 'kill' and not killSoundPlayed and getProperty('stressCockyPee.animation.curAnim.curFrame') >= 1 then
		killSoundPlayed = true
		playSound('intro/stress-explosion', 0.55)
	end
	if phase == 'besties' and voiceFinished and getProperty('stressBesties.animation.curAnim.finished') then
		tankIdle()
		setPhase('cock')
		playPair('cock')
	elseif phase == 'cock' and getProperty('stressCockyPee.animation.curAnim.finished') then
		setPhase('idle')
		playPair('idle')
		runTimer('stressIntroSnap', 0.5)
	elseif phase == 'snap' and getProperty('stressSnap.animation.curAnim.finished') then
		setPhase('killDelay')
		runTimer('stressIntroKill', 0.1)
	elseif phase == 'kill' and getProperty('stressCockyPee.animation.curAnim.finished') then
		setPhase('restoreColor')
		doTweenAlpha('stressRestoreColor', 'stressGray', 0, 0.12, 'linear')
	elseif phase == 'walk' and getProperty('stressCockyPee.animation.curAnim.finished') and getProperty('stressCockyPee.visible') then
		setProperty('stressCockyPee.visible', false)
		setProperty('stressCockyPee.active', false)
		setProperty('pee.visible', true)
		playAnim('pee', 'idle', true)
		setProperty('pee.animation.curAnim.frameRate', 8)
	elseif phase == 'hoist' and getProperty('stressRaven.animation.curAnim.finished') then
		beginFibbin()
	elseif phase == 'fibbin' and voiceFinished and getProperty('stressKiddin.animation.curAnim.finished') then
		tankIdle()
		setPhase('finishDelay')
		runTimer('stressIntroFinish', 0.2)
	end
end

function onSoundFinished(tag)
	if tag == 'stressBestiesVoice' or tag == 'stressFibbinVoice' then voiceFinished = true end
end

function onTimerCompleted(tag)
	if tag == 'stressStorySkipFadeFinish' or tag == 'stressIntroSkipFinish' then
		skipFinishPending = false
		if storyPresentation then setProperty('stressStoryBlack.visible', false) end
		completeSkippedIntro()
		startCountdown()
	elseif tag == 'stressIntroBegin' then
		setPhase('besties')
		voiceFinished = false
		playTank('stressBesties')
		playSound('intro/stress-besties', 0.85, 'stressBestiesVoice')
	elseif tag == 'stressIntroSnap' then
		setPhase('snap')
		snapSoundPlayed = false
		playTank('stressSnap')
	elseif tag == 'stressIntroKill' then
		beginKill()
	elseif tag == 'stressIntroFinish' then
		introComplete = true
		setPhase('complete')
		clearGray()
		setProperty('dad.skipDance', false)
		setProperty('dad.animation.curAnim.frameRate', dadIdleRate)
		setProperty('camHUD.visible', hudVisible)
		setProperty('inCutscene', false)
		for _, sprite in ipairs(temporarySprites) do removeLuaSprite(sprite, true) end
		setProperty('skipCountdown', true)
		startCountdown()
	end
end

function onTweenCompleted(tag)
	if tag == 'stressStoryIntroFade' then
		setProperty('stressStoryBlack.visible', false)
	elseif tag == 'stressRestoreColor' then
		clearGray()
		beginWalk()
	elseif tag == 'stressRavenTravelX' then
		beginHoist()
	elseif tag == 'stressSteveArrival' then
		removeLuaSprite('stressSteveWalk', true)
		setProperty('steve.visible', true)
		playAnim('steve', 'idle', true)
		setProperty('steve.animation.curAnim.frameRate', 8)
		setVar('stressSteveArrived', true)
	end
end

function onSongStart()
	local delay = getRecordedSceneValue('week7.steveEntryDelay')
	if delay == nil then delay = getRandomFloat(5, 10) end
	recordSceneValue('week7.steveEntryDelay', delay)
	setVar('stressSteveEntryDelay', delay)
	steveEntryTime = delay * 1000
end

function onDestroy()
	stopSound('stressBestiesVoice')
	stopSound('stressFibbinVoice')
	clearGray()
	if storyPresentation then removeLuaSprite('stressStoryBlack', true) end
end
