
local lockX = 1600
local lockY = 950


local minTrainDelay = 8
local maxTrainDelay = 18
local trainSoundEnabled = true

local walkerNames = {'alien', 'ena', 'castle', 'charles', 'salad', 'hank', 'edd', 'meat'}
local walkers = {}
local walkerSchedule = {}
local nextWalker = 1
local walkerScale = 1.1 * 0.75 * 1259 / 1290
local walkerTravelTime = 15000
local walkerBounce = {0, 2, 14, 15, 12, 0}

local function walkerDepth(age)
	return walkerBounce[math.floor(math.max(0, age) * 12 / 1000) % #walkerBounce + 1] * 18 / 15
end

local function hideWalker(walker)
	walker.active = false
	setProperty(walker.tag .. '.visible', false)
	setProperty(walker.tag .. '.active', false)
	setProperty(walker.tag .. '.bottomAnchor.y', 0)
end

local function updateWalkers()
	local position = getSongPosition()
	for _, walker in ipairs(walkers) do
		if walker.active then
			local progress = (position - walker.time) / walkerTravelTime
			if progress >= 1 then
				hideWalker(walker)
			else
				setProperty(walker.tag .. '.x', walker.startX + (walker.endX - walker.startX) * progress)
				setProperty(walker.tag .. '.bottomAnchor.y', walkerDepth(position - walker.time))
			end
		end
	end
	while nextWalker <= #walkerSchedule and walkerSchedule[nextWalker].time <= position do
		local event = walkerSchedule[nextWalker]
		nextWalker = nextWalker + 1
		if position - event.time < walkerTravelTime then
			for _, walker in ipairs(walkers) do
				if not walker.active then
					walker.active = true
					walker.time = event.time
					walker.startX = event.fromRight and 3500 or -600
					walker.endX = event.fromRight and -600 or 3500
					setProperty(walker.tag .. '.flipX', event.fromRight)
					setProperty(walker.tag .. '.x', walker.startX + (walker.endX - walker.startX) * (position - event.time) / walkerTravelTime)
					setProperty(walker.tag .. '.bottomAnchor.y', walkerDepth(position - event.time))
					setProperty(walker.tag .. '.visible', true)
					setProperty(walker.tag .. '.active', true)
					playAnim(walker.tag, event.name, true)
					break
				end
			end
		end
	end
end

function onSongStart()
	for _, walker in ipairs(walkers) do hideWalker(walker) end
	walkerSchedule = getRecordedSceneValue('week3.walkers')
	if walkerSchedule == nil then
		walkerSchedule = {}
		local minimum = 20
		local maximum = 35
		local time = getRandomFloat(minimum, maximum) * 1000
		local length = getProperty('songLength')
		while time < length do
			table.insert(walkerSchedule, {time = time, name = walkerNames[getRandomInt(1, #walkerNames)], fromRight = getRandomBool(50)})
			time = time + walkerTravelTime + getRandomFloat(minimum, maximum) * 1000
		end
	end
	nextWalker = 1
	recordSceneValue('week3.walkers', walkerSchedule)
end

local blammedColorsActive = false
local blammedLightIndex = 1
local blammedTransitionActive = false
local pendingBlammedState = false
local blammedPaperColors = {'44FF55', '44FFFC', 'AB44FF', 'FF8099', 'FFDF80'}
local blammedBuildingSprites = {
	'buildings-green',
	'buildings-cyan',
	'buildings-purple',
	'buildings-red',
	'buildings-yellow'
}
local paperTransformProperties = {'x', 'y', 'scale.x', 'scale.y', 'origin.x', 'origin.y', 'offset.x', 'offset.y', 'scrollFactor.x', 'scrollFactor.y', 'angle', 'flipX', 'flipY'}

local function placePaperOverlay()
	for _, property in ipairs(paperTransformProperties) do
		setProperty('blammed-paper-overlay.' .. property, getProperty('paper.' .. property))
	end
	local top = getProperty('members.length') - 1
	if getObjectOrder('blammed-paper-overlay') ~= top then
		setObjectOrder('blammed-paper-overlay', top)
	end
end

local function updateBlammedPaperColor()
	local color = getColorFromHex(blammedColorsActive and blammedPaperColors[blammedLightIndex] or 'FFFFFF')
	setProperty('paper.color', color)
	setProperty('blammed-paper-overlay.color', color)
end

local function applyBlammedState(enabled)
	blammedColorsActive = enabled
	setProperty('blammedPaperInverted', enabled)
	setProperty('lines.visible', not enabled)
	setProperty('moon.visible', not enabled)
	setProperty('blammed-paper-overlay.visible', enabled)

	if enabled then
		blammedLightIndex = 1
		for _, sprite in ipairs(blammedBuildingSprites) do
			setProperty(sprite .. '.visible', false)
		end
		setProperty(blammedBuildingSprites[blammedLightIndex] .. '.visible', true)
		playAnim(blammedBuildingSprites[blammedLightIndex], 'idle', true)
		setProperty(blammedBuildingSprites[blammedLightIndex] .. '.animation.curAnim.paused', false)
	end
	updateBlammedPaperColor()
end


function onCreate()
	precacheSound('week3-train-pass')
	makeAnimatedLuaSprite('paper', 'Freeplay-Chrs/fah/BG', 50, 50)
	addAnimationByPrefix('paper', 'idle', 'BG idle', 3, true)
	addLuaSprite('paper', false)
	scaleObject('paper', 1.5, 1.5);






	makeAnimatedLuaSprite('moon', 'fahmix/week 3/moon', 430, 280)
	addAnimationByPrefix('moon', 'idle', 'idle', 6, true)
	addLuaSprite('moon', false)
	scaleObject('moon', 1, 1);



	makeAnimatedLuaSprite('lines', 'fahmix/week 3/lines', -95, -453)
	addAnimationByPrefix('lines', 'idle', 'idle', 6, true)
	addLuaSprite('lines', false)
	scaleObject('lines', 1, 1);



	for _, color in ipairs({'green', 'cyan', 'purple', 'red', 'yellow'}) do
		local tag = 'buildings-' .. color
		makeAnimatedLuaSprite(tag, 'fahmix/week 3/buildings/' .. tag, 460, 240)
		addAnimationByPrefix(tag, 'idle', 'idle', 4, true)
		addLuaSprite(tag, false)
		scaleObject(tag, 1.5, 1.5)
		playAnim(tag, 'idle', true)
		setProperty(tag .. '.visible', false)
	end
	setProperty('buildings-green.visible', true)


	makeAnimatedLuaSprite('poles', 'fahmix/week 3/poles', 460, 198)
	addAnimationByPrefix('poles', 'idle', 'idle', 6, true)
	addLuaSprite('poles', false)
	scaleObject('poles', 1, 1);



	makeAnimatedLuaSprite('train', 'fahmix/week 3/train', -3000, 260)
	addAnimationByPrefix('train', 'idle', 'train idle', 6, true)
	addLuaSprite('train', false)
	scaleObject('train', 1, 1);
	setProperty('train.flipX', true)

	setProperty('train.x', -3000)
	runTimer('trainMove', getRandomFloat(minTrainDelay, maxTrainDelay))



	makeAnimatedLuaSprite('front poles', 'fahmix/week 3/front poles', 460, 198)
	addAnimationByPrefix('front poles', 'idle', 'idle', 6, true)
	addLuaSprite('front poles', false)
	scaleObject('front poles', 1, 1);


	makeAnimatedLuaSprite('floor', 'fahmix/week 3/floor', 460, 200)
	addAnimationByPrefix('floor', 'idle', 'idle', 6, true)
	addLuaSprite('floor', false)
	scaleObject('floor', 1, 1);

	for index = 1, 4 do
		local tag = 'newgroundsWalker' .. index
		makeAnimatedLuaSprite(tag, 'fahmix/week 3/newgrounds-walkers', -600, 0)
		for _, name in ipairs(walkerNames) do
			addAnimationByPrefix(tag, name, 'newgrounds-walkers ' .. name, 6, true)
		end
		scaleObject(tag, walkerScale, walkerScale)
		setObjectCamera(tag, 'game')
		anchorSpriteToScreenBottom(tag)
		addLuaSprite(tag, true)
		setProperty(tag .. '.visible', false)
		setProperty(tag .. '.active', false)
		table.insert(walkers, {tag = tag, active = false})
	end

	makeAnimatedLuaSprite('blammed-paper-overlay', 'Freeplay-Chrs/fah/BG', 50, 50)
	addAnimationByPrefix('blammed-paper-overlay', 'idle', 'BG idle', 3, true)
	addLuaSprite('blammed-paper-overlay', true)
	setObjectCamera('blammed-paper-overlay', 'game')
	setBlendMode('blammed-paper-overlay', 'multiply')
	setProperty('blammed-paper-overlay.alpha', 0.74)
	setProperty('blammed-paper-overlay.visible', false)
	setProperty('blammed-paper-overlay.animation.curAnim.paused', true)


	makeLuaSprite('dablacktrans', 'dablack', -2000, 0)
	setObjectCamera('dablacktrans', 'hud')
	setProperty('dablacktrans.alpha', 1)
	addLuaSprite('dablacktrans', true)
end


function onEvent(name, value1, value2)
	local eventName = string.lower(name):gsub('_', ' ')

	if (eventName == 'blammed colors' or eventName == 'blammed lights') and not blammedTransitionActive then
		blammedTransitionActive = true
		pendingBlammedState = not blammedColorsActive
		setProperty('dablacktrans.x', -2000)
		doTweenX('blammedTransitionPass', 'dablacktrans', 2000, 0.8, 'linear')
		runTimer('applyBlammedTransition', 0.4)
	end
end


function onBeatHit()
	
	for _, sprite in ipairs(blammedBuildingSprites) do
		setProperty(sprite .. '.visible', false)
	end
	blammedLightIndex = (blammedLightIndex % #blammedBuildingSprites) + 1
	setProperty(blammedBuildingSprites[blammedLightIndex] .. '.visible', true)
	playAnim(blammedBuildingSprites[blammedLightIndex], 'idle', true)
	setProperty(blammedBuildingSprites[blammedLightIndex] .. '.animation.curAnim.paused', false)
	if blammedColorsActive then updateBlammedPaperColor() end

end


function onCreatePost()
	runHaxeCode([[
		game.getLuaObject('blammed-paper-overlay').appearanceSource = game.getLuaObject('paper');
	]])
    setProperty('isCameraOnForcedPos', true)
    setProperty('camFollow.x', lockX)
    setProperty('camFollow.y', lockY)
    setProperty('camFollowPos.x', lockX)
    setProperty('camFollowPos.y', lockY)
	placePaperOverlay()
end

function onUpdatePost(elapsed)
	updateWalkers()
	if blammedColorsActive then
		setProperty('blammed-paper-overlay.animation.curAnim.curFrame', getProperty('paper.animation.curAnim.curFrame'))
		placePaperOverlay()
	end
end


function onTimerCompleted(tag)
	if tag == 'applyBlammedTransition' then
		
		applyBlammedState(pendingBlammedState)
    elseif tag == 'trainMove' then
        if trainSoundEnabled then
            playSound('week3-train-pass', 0, 'week3TrainPass', true)
            soundFadeIn('week3TrainPass', 0.18, 0, 1)
        end
        runTimer('trainStartPass', 0.12)
    elseif tag == 'trainStartPass' then
        setProperty('train.x', -3000)
        doTweenX('trainTween', 'train', 3000, 1.5, 'linear')
    elseif tag == 'trainStopSound' then
        stopSound('week3TrainPass')
    end
end

function onTweenCompleted(tag)
	if tag == 'blammedTransitionPass' then
		
		setProperty('dablacktrans.x', -2000)
		blammedTransitionActive = false
    elseif tag == 'trainTween' then
        soundFadeOut('week3TrainPass', 0.18, 0)
        runTimer('trainStopSound', 0.18)
        setProperty('train.x', -3000)
        runTimer('trainMove', getRandomFloat(minTrainDelay, maxTrainDelay))
    end
end

function onPause()
    pauseSound('week3TrainPass')
    runHaxeCode([[
        var sound = game.modchartSounds.get('week3TrainPass');
        if (sound != null && sound.fadeTween != null) sound.fadeTween.active = false;
    ]])
end

function onResume()
    resumeSound('week3TrainPass')
    runHaxeCode([[
        var sound = game.modchartSounds.get('week3TrainPass');
        if (sound != null && sound.fadeTween != null) sound.fadeTween.active = true;
    ]])
end

function onGameOverStart()
    trainSoundEnabled = false
    stopSound('week3TrainPass')
end
