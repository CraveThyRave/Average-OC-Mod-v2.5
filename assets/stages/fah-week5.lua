
local lockX = 1700
local lockY = 1000


local cocoaThrowStep = 115 

local throwLollyDelay = 0.1   
local throwEndDelay = 0.3     

local cocoaSong = false
local eggnogSong = false
local lollyFlying = false

local walkerNames = {'jasper', 'sora', 'jinx', 'tennie-vivi', 'jane', 'hana', 'finch', 'airu', 'niko-jael', 'ret-kit'}
local walkers = {}
local walkerSchedule = {}
local nextWalker = 1
local walkerScale = 1.1 * 0.75 * 1259 / 1388
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
					walker.startX = event.fromRight and 3500 or -1600
					walker.endX = event.fromRight and -1600 or 3500
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
	walkerSchedule = getRecordedSceneValue('week5.walkers')
	if walkerSchedule == nil then
		walkerSchedule = {}
		local minimum = 7
		local maximum = 12
		local time = getRandomFloat(minimum, maximum) * 1000
		local length = getProperty('songLength')
		while time < length do
			table.insert(walkerSchedule, {time = time, name = walkerNames[getRandomInt(1, #walkerNames)], fromRight = getRandomBool(50)})
			time = time + walkerTravelTime + getRandomFloat(minimum, maximum) * 1000
		end
	end
	nextWalker = 1
	recordSceneValue('week5.walkers', walkerSchedule)
end

function onCreate()

	local currentSong = string.lower(songName or '')
	cocoaSong = currentSong == 'cocoa'
	eggnogSong = currentSong == 'eggnog'


	makeAnimatedLuaSprite('paper', 'Freeplay-Chrs/fah/BG', 50, 50)
	addAnimationByPrefix('paper', 'idle', 'BG idle', 3, true)
	addLuaSprite('paper', false)
	scaleObject('paper', 1.5, 1.5);

	makeAnimatedLuaSprite('bg-merry', 'fahmix/week5/bg-merry', 80, -200)
	addAnimationByPrefix('bg-merry', 'idle', 'idle', 6, true)
	addLuaSprite('bg-merry', false)
	scaleObject('bg-merry', 1.65, 1.65);

	makeAnimatedLuaSprite('back', 'fahmix/week5/back-merry', 80, 135)
	addAnimationByPrefix('back', 'idle', 'idle', 6, true)
	addLuaSprite('back', false)
	scaleObject('back', 1.1, 1.1);


	makeAnimatedLuaSprite('aubrey', 'fahmix/week5/aubrey', 300, 800)
	addAnimationByPrefix('aubrey', 'idle', 'idle', 6, true)
	addLuaSprite('aubrey', false)
	scaleObject('aubrey', 1, 1);


	makeAnimatedLuaSprite('dusk', 'fahmix/week5/dusk', 400, 810)
	addAnimationByPrefix('dusk', 'idle', 'idle', 6, true)
	addLuaSprite('dusk', false)
	scaleObject('dusk', 1, 1);

	makeAnimatedLuaSprite('dahlia', 'fahmix/week5/dahlia', 1200, 840)
	addAnimationByPrefix('dahlia', 'idle', 'idle', 6, true)
	addLuaSprite('dahlia', false)
	scaleObject('dahlia', 0.9, 0.9);


	makeAnimatedLuaSprite('poppy', 'fahmix/week5/poppy', 1980, 1000)
	addAnimationByPrefix('poppy', 'idle', 'idle', 6, true)
	addLuaSprite('poppy', false)
	scaleObject('poppy', 0.9, 0.9);


	makeAnimatedLuaSprite('salena', 'fahmix/week5/salena', 2850, 930)
	addAnimationByPrefix('salena', 'idle', 'idle', 6, true)
	addLuaSprite('salena', false)
	scaleObject('salena', 0.9, 0.9);



	makeAnimatedLuaSprite('merry-pee', 'fahmix/week5/merry-pee', 1580, 930)
	addAnimationByPrefix('merry-pee', 'idle', 'idle', 6, true)
	addLuaSprite('merry-pee', false)
	scaleObject('merry-pee', 1.1, 1.1);

	makeAnimatedLuaSprite('merry-ray', 'fahmix/week5/merry-ray', 1370, 930)
	addAnimationByPrefix('merry-ray', 'idle', 'idle', 6, true)
	addLuaSprite('merry-ray', false)
	scaleObject('merry-ray', 1.1, 1.1);





	makeAnimatedLuaSprite('santa', 'fahmix/week5/santa', 100, 1100)
	addAnimationByPrefix('santa', 'idle', 'eating', 6, true)
	addAnimationByPrefix('santa', 'eaten', 'eaten', 6, true)
	addLuaSprite('santa', false)
	scaleObject('santa', 1.06, 1.06)


	if cocoaSong then
	    objectPlayAnimation('santa', 'idle', true)
	else
	    objectPlayAnimation('santa', 'eaten', true)
	end


	makeLuaSprite('lolly', 'fahmix/week5/lolly', 590, 1150)
	addLuaSprite('lolly', false)
	scaleObject('lolly', 1.15, 1.15)
	setProperty('lolly.visible', false)
	setProperty('lolly.alpha', 0)
    local tag = 'week5Walker'
    makeAnimatedLuaSprite(tag, 'fahmix/week5/week5-walkers', -1600, 0)
    for _, name in ipairs(walkerNames) do
        addAnimationByPrefix(tag, name, 'week5-walkers ' .. name, 6, true)
    end
    scaleObject(tag, walkerScale, walkerScale)
    setObjectCamera(tag, 'game')
    anchorSpriteToScreenBottom(tag)
    addLuaSprite(tag, true)
    setProperty(tag .. '.visible', false)
    setProperty(tag .. '.active', false)
    table.insert(walkers, {tag = tag, active = false})
end


function onCreatePost()
    setProperty('isCameraOnForcedPos', true)
    setProperty('camFollow.x', lockX)
    setProperty('camFollow.y', lockY)
    setProperty('camFollowPos.x', lockX)
    setProperty('camFollowPos.y', lockY)

	
	
	if eggnogSong and getProperty('dad.curCharacter') ~= 'merrydad-fah-nopop' then
		triggerEvent('Change Character', 'dad', 'merrydad-fah-nopop')
	end

end

function onStepHit()

	if cocoaSong and curStep == cocoaThrowStep then
		characterPlayAnim('dad', 'throw', true)
		setProperty('dad.specialAnim', true)

		runTimer('throwLolly', throwLollyDelay)
		runTimer('throwFinished', throwEndDelay)
	end
end


function onTimerCompleted(tag)
	if tag == 'throwLolly' then

		triggerEvent('Change Character', 'dad', 'merrydad-fah-nopop')

		setProperty('lolly.visible', true)
		setProperty('lolly.alpha', 1)

		setProperty('lolly.x', 590)
		setProperty('lolly.y', 1150)
		setProperty('lolly.angle', -20)

		lollyFlying = true

		doTweenX('lollyX', 'lolly', 320, 0.2, 'quadOut')
		doTweenY('lollyY', 'lolly', 1250, 0.2, 'quadIn')
		doTweenAngle('lollyAngle', 'lolly', 15, 0.2, 'quadOut')
	elseif tag == 'throwFinished' then
		triggerEvent('Change Character', 'dad', 'merrydad-fah-nopop')

	end
end



function onUpdate(elapsed)
	if lollyFlying then
		local progress = (590 - getProperty('lolly.x')) / (590 - 320)
		local arc = math.sin(progress * math.pi) * 70
		setProperty('lolly.y', getProperty('lolly.y') - arc * elapsed * 8)
	end
end


function onTweenCompleted(tag)
	if tag == 'lollyX' then
		lollyFlying = false

		doTweenX('lollyScaleX', 'lolly.scale', 0, 0.15, 'quadIn')
		doTweenY('lollyScaleY', 'lolly.scale', 0, 0.15, 'quadIn')

	elseif tag == 'lollyScaleY' then
		   setProperty('lolly.visible', false)
		   setProperty('lolly.alpha', 0)

		   scaleObject('lolly', 1.15, 1.15)

		   if cocoaSong then
		       objectPlayAnimation('santa', 'eaten', true)
	    end
	end
end

function onUpdatePost(elapsed)
    updateWalkers()
end
