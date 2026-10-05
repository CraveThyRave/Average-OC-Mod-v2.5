math.randomseed(os.time())
math.random()
math.random()
math.random()

local lockX = 1800
local lockY = 1100
local tankPasses = 0
local passTime = 10
local runnerID = 0
local fireworkID = 0
local fireworkPositions = {1150, 1755, 2360}
local runnerMinSpeed = 0.42
local runnerMaxSpeed = 0.65
local explodeTime = 0.17
local explodeFadeTime = 0.12
local leftSpawnX = 350
local leftEndX = 1100
local rightSpawnX = 2860
local rightEndX = 2060
local runnerY = 1040
local explodeVariation = 130
local phoenixBlowTimes = {}
local nextPhoenixBlow = 1
local nextSyncedRunner = 1
local syncedRunners = {}
local syncedRunnerTravelTime = 550
local drummerAlternating = false
local drummerNextLeft = true
local drummerAlternatingInterval = 0.2
local cymbalAlternating = false
local cymbalNextLeft = true
local cymbalAlternatingInterval = 0.2
local extraCymbalSteps = {1022, 1087, 1410, 1440, 1600, 1920, 2048}
local kevinCenterY = 0
local bonusRestY = 0
local bonusFlickering = false
local bonusFlickerVisible = false

local function loadPhoenixBlowTimes()
	local raw = getTextFromFile('data/stress/phoenix-blow.json')
	if raw == nil or raw == '' then
		return
	end

	for timestamp in string.gmatch(raw, '%[%s*([%d%.]+),%s*%[') do
		table.insert(phoenixBlowTimes, tonumber(timestamp))
	end
	table.sort(phoenixBlowTimes)
end

local function spawnSyncedRunner(eventTime, eventIndex)
	runnerID = runnerID + 1
	local tag = 'runner' .. runnerID
	local fromRight = eventIndex % 2 == 0
	local startX = fromRight and rightSpawnX or leftSpawnX
	local endX = fromRight and rightEndX or leftEndX

	local runVariant = getProperty('stressTankmanFallers.runnerVariants[' .. (eventIndex - 1) .. ']')
	if runVariant == nil then runVariant = getRandomInt(1, 3) end
	local runY = runnerY + (runVariant == 1 and 44 or runVariant == 2 and -32 or 36)
	makeAnimatedLuaSprite(tag, 'fahmix/week7/kill', startX, runY)
	addAnimationByPrefix(tag, 'run', 'kill walk' .. runVariant, 10, true)
	addAnimationByPrefix(tag, 'explode', 'kill explode', 30, false)
	addLuaSprite(tag, false)
	setObjectOrder(tag, getObjectOrder('floor') + 1)
	scaleObject(tag, fromRight and 0.92 or -0.92, 0.92)
	objectPlayAnimation(tag, 'run', true)

	table.insert(syncedRunners, {
		tag = tag,
		startX = startX,
		endX = endX,
		startTime = eventTime - syncedRunnerTravelTime,
		eventTime = eventTime,
		fromRight = fromRight,
		exploded = false
	})
end

local function explodeSyncedRunner(runner)
	runner.exploded = true
	setProperty(runner.tag .. '.x', runner.endX + (runner.fromRight and -110 or 110))
	setProperty(runner.tag .. '.y', getProperty(runner.tag .. '.y') - 110)
	objectPlayAnimation(runner.tag, 'explode', true)
	runTimer(runner.tag .. '_fade', explodeTime)
end

local function playPhoenixSnap(fromRight)
	local side = fromRight and 'right' or 'left'
	local variant = getRandomInt(1, 2)
	playAnim('pee', side .. variant, true)
	cancelTimer('peeIdle')
	runTimer('peeIdle', 0.30)
end

local function updatePhoenixBlows()
	local songPosition = getSongPosition()

	while nextSyncedRunner <= #phoenixBlowTimes and phoenixBlowTimes[nextSyncedRunner] - syncedRunnerTravelTime <= songPosition do
		spawnSyncedRunner(phoenixBlowTimes[nextSyncedRunner], nextSyncedRunner)
		nextSyncedRunner = nextSyncedRunner + 1
	end

	for _, runner in ipairs(syncedRunners) do
		if not runner.exploded then
			local progress = (songPosition - runner.startTime) / syncedRunnerTravelTime
			if progress >= 1 then
				explodeSyncedRunner(runner)
			elseif progress >= 0 then
				setProperty(runner.tag .. '.x', runner.startX + (runner.endX - runner.startX) * progress)
			end
		end
	end

	while nextPhoenixBlow <= #phoenixBlowTimes and phoenixBlowTimes[nextPhoenixBlow] <= songPosition do
		playPhoenixSnap(nextPhoenixBlow % 2 == 0)
		nextPhoenixBlow = nextPhoenixBlow + 1
	end
end

function onCreate()
	loadPhoenixBlowTimes()
	makeAnimatedLuaSprite('paper', 'fahmix/week7/BG', 50, 50)
	addAnimationByPrefix('paper', 'idle', 'BG idle', 3, true)
	addLuaSprite('paper', false)
	scaleObject('paper', 1.5, 1.5)

	makeLuaSprite('logo', 'fahmix/week7/stress-logo', 320, -800)
	setProperty('logo.flipX', getPropertyFromClass('MirrorMode', 'active'))
	scaleObject('logo', 0.47, 0.47)
	setObjectCamera('logo', 'other')
	addLuaSprite('logo', false)

	makeAnimatedLuaSprite('bg-tank', 'fahmix/week7/bg-tank', 300, 400)
	addAnimationByPrefix('bg-tank', 'idle', 'idle', 6, true)
	addLuaSprite('bg-tank', false)
	scaleObject('bg-tank', 1, 1)

	makeAnimatedLuaSprite('tank', 'fahmix/week7/tank', 300, 1200)
	addAnimationByPrefix('tank', 'idle', 'idle', 3, true)
	addLuaSprite('tank', false)
	scaleObject('tank', 1, 1)

	makeAnimatedLuaSprite('paper2', 'fahmix/week7/BG', 50, 1450)
	addAnimationByPrefix('paper2', 'idle', 'BG idle', 3, true)
	addLuaSprite('paper2', false)
	scaleObject('paper2', 1.5, 1.5)

	precacheImage('fahmix/week7/firework')

	makeAnimatedLuaSprite('floor', 'fahmix/week7/floor', 600, 1230)
	addAnimationByPrefix('floor', 'idle', 'idle', 6, true)
	addLuaSprite('floor', false)
	scaleObject('floor', 0.94, 0.94)

	makeAnimatedLuaSprite('bell', 'fahmix/week7/bell', 0, 720)
	addAnimationByPrefix('bell', 'entrance', 'bell idle-entry', 10, false)
	addAnimationByPrefix('bell', 'slam', 'bell bang', 9, true)
	addLuaSprite('bell', false)
	setObjectCamera('bell', 'other')
	scaleObject('bell', 0.8, 0.8)
	screenCenter('bell', 'x')
	objectPlayAnimation('bell', 'entrance', true)

	makeAnimatedLuaSprite('kevin', 'fahmix/week7/kevin', 0, 0)
	addAnimationByPrefix('kevin', 'idle', 'kevin idle', 8, true)
	addLuaSprite('kevin', false)
	setObjectCamera('kevin', 'other')
	scaleObject('kevin', 0.8, 0.8)
	screenCenter('kevin', 'xy')
	setProperty('kevin.x', getProperty('kevin.x') - 80)
	kevinCenterY = getProperty('kevin.y')
	setProperty('kevin.y', 720)
	objectPlayAnimation('kevin', 'idle', true)

	makeAnimatedLuaSprite('bonus', 'fahmix/week7/bonus', 0, 0)
	addAnimationByPrefix('bonus', 'idle', 'bonus idle', 8, true)
	addLuaSprite('bonus', false)
	setObjectCamera('bonus', 'other')
	scaleObject('bonus', 1.1, 1.1)
	screenCenter('bonus', 'x')
	setProperty('bonus.y', screenHeight - getProperty('bonus.height') + 30)
	bonusRestY = getProperty('bonus.y')
	setProperty('bonus.alpha', 0)
	objectPlayAnimation('bonus', 'idle', true)

	makeAnimatedLuaSprite('duck', 'fahmix/week7/duck', -9999, 820)
	addAnimationByPrefix('duck', 'idle', 'duck idle', 12, true)
	addLuaSprite('duck', true)
	setObjectCamera('duck', 'other')
	scaleObject('duck', 0.5, 0.5)
	setProperty('duck.visible', false)

	makeAnimatedLuaSprite('drummerLeft', 'fahmix/week7/drummer', -120, 430)
	addAnimationByPrefix('drummerLeft', 'idle', 'drummer idle', 8, true)
	addAnimationByPrefix('drummerLeft', 'slam', 'drummer slam', 9, false)
	addLuaSprite('drummerLeft', false)
	setObjectCamera('drummerLeft', 'hud')
	scaleObject('drummerLeft', 0.55, 0.55)
	setProperty('drummerLeft.alpha', 0.68)
	objectPlayAnimation('drummerLeft', 'idle', true)

	makeAnimatedLuaSprite('drummerRight', 'fahmix/week7/drummer', 895, 430)
	addAnimationByPrefix('drummerRight', 'idle', 'drummer idle', 8, true)
	addAnimationByPrefix('drummerRight', 'slam', 'drummer slam', 9, false)
	addLuaSprite('drummerRight', false)
	setObjectCamera('drummerRight', 'hud')
	scaleObject('drummerRight', 0.55, 0.55)
	setProperty('drummerRight.flipX', true)
	setProperty('drummerRight.alpha', 0.68)
	objectPlayAnimation('drummerRight', 'idle', true)

	makeAnimatedLuaSprite('cymbalLeft', 'fahmix/week7/cymbal', -80, 720)
	addAnimationByPrefix('cymbalLeft', 'idle', 'cymbal idle', 8, true)
	addAnimationByPrefix('cymbalLeft', 'clap', 'cymbal clap', 9, false)
	addLuaSprite('cymbalLeft', false)
	setObjectCamera('cymbalLeft', 'hud')
	scaleObject('cymbalLeft', 0.55, 0.55)
	setProperty('cymbalLeft.alpha', 0.68)
	objectPlayAnimation('cymbalLeft', 'idle', true)

	makeAnimatedLuaSprite('cymbalRight', 'fahmix/week7/cymbal', 993, 720)
	addAnimationByPrefix('cymbalRight', 'idle', 'cymbal idle', 8, true)
	addAnimationByPrefix('cymbalRight', 'clap', 'cymbal clap', 9, false)
	addLuaSprite('cymbalRight', false)
	setObjectCamera('cymbalRight', 'hud')
	scaleObject('cymbalRight', 0.55, 0.55)
	setProperty('cymbalRight.flipX', true)
	setProperty('cymbalRight.alpha', 0.68)
	objectPlayAnimation('cymbalRight', 'idle', true)

	makeAnimatedLuaSprite('pee', 'fahmix/week7/phoenix-stress', 1540, 925)
	addAnimationByPrefix('pee', 'idle', 'idle', 6, true)
	addAnimationByPrefix('pee', 'left1', 'kill snap-left1', 14, false)
	addAnimationByPrefix('pee', 'left2', 'kill snap-left2', 14, false)
	addAnimationByPrefix('pee', 'right1', 'kill snap-right1', 14, false)
	addAnimationByPrefix('pee', 'right2', 'kill snap-right2', 14, false)
	addOffset('pee', 'idle', 0, 0)
	addOffset('pee', 'left1', 7, 11)
	addOffset('pee', 'left2', -3, 1)
	addOffset('pee', 'right1', -10, 11)
	addOffset('pee', 'right2', -23, -9)
	addLuaSprite('pee', false)
	scaleObject('pee', 1.15, 1.15)
	playAnim('pee', 'idle', true)

	makeAnimatedLuaSprite('steve', 'fahmix/week7/steve-stress', 740, 945)
	addAnimationByPrefix('steve', 'idle', 'idle', 6, true)
	addLuaSprite('steve', false)
	scaleObject('steve', 0.92, 0.92)
end

function onCreatePost()
	setProperty('isCameraOnForcedPos', true)
	setProperty('camFollow.x', lockX)
	setProperty('camFollow.y', lockY)
	setProperty('camFollowPos.x', lockX)
	setProperty('camFollowPos.y', lockY)
end

function onSongStart()
	local schedule = getRecordedSceneValue('week7.schedule')
	if schedule == nil then
		local songLength = getProperty('songLength') / 1000
		local maxTime = math.max(songLength - passTime - 1, 1)
		local time1 = math.random() * maxTime
		local time2 = math.random() * maxTime
		while math.abs(time2 - time1) < passTime + 2 do
			time2 = math.random() * maxTime
		end
		schedule = {tank1 = time1, tank2 = time2}
	end
	recordSceneValue('week7.schedule', schedule)
	runTimer('tankPass1', schedule.tank1 / playbackRate)
	runTimer('tankPass2', schedule.tank2 / playbackRate)
end

function onUpdate(elapsed)
	updatePhoenixBlows()
end

function launchFirework()
	fireworkID = fireworkID + 1
	local tag = 'firework' .. fireworkID
	local position = fireworkPositions[((fireworkID - 1) % #fireworkPositions) + 1]
	makeAnimatedLuaSprite(tag, 'fahmix/week7/firework', position, 1750)
	addAnimationByPrefix(tag, 'idle', 'firework idle', 12, true)
	addAnimationByPrefix(tag, 'explode', 'firework explode', 12, false)
	addLuaSprite(tag, false)
	scaleObject(tag, 0.55, 0.55)
	setObjectOrder(tag, getObjectOrder('paper2') - 1)
	setProperty(tag .. '.color', getColorFromHex('FFFFFF'))
	objectPlayAnimation(tag, 'idle', true)
	doTweenY(tag .. '_rise', tag, 750, 0.45, 'quadOut')
end

function enterDrummers(duration)
	cancelTween('drummerLeftExit')
	cancelTween('drummerRightExit')
	doTweenY('drummerLeftEnter', 'drummerLeft', 430, duration, 'quadOut')
	doTweenY('drummerRightEnter', 'drummerRight', 430, duration, 'quadOut')
end

function slamNextDrummer()
	if drummerNextLeft then
		objectPlayAnimation('drummerLeft', 'slam', true)
		runTimer('drummerLeftIdle', 0.34)
	else
		objectPlayAnimation('drummerRight', 'slam', true)
		runTimer('drummerRightIdle', 0.34)
	end
	drummerNextLeft = not drummerNextLeft
end

function startDrummerAlternating(interval)
	cancelTimer('drummerAlternating')
	drummerAlternating = true
	drummerAlternatingInterval = interval
	drummerNextLeft = true
	slamNextDrummer()
	runTimer('drummerAlternating', drummerAlternatingInterval)
end

function stopDrummerAlternating()
	drummerAlternating = false
	cancelTimer('drummerAlternating')
	doTweenY('drummerLeftExit', 'drummerLeft', 720, 0.5, 'quadIn')
	doTweenY('drummerRightExit', 'drummerRight', 720, 0.5, 'quadIn')
end

function enterCymbals()
	cancelTween('cymbalLeftExit')
	cancelTween('cymbalRightExit')
	doTweenY('cymbalLeftEnter', 'cymbalLeft', 390, 0.2, 'quadOut')
	doTweenY('cymbalRightEnter', 'cymbalRight', 390, 0.2, 'quadOut')
end

function clapCymbals()
	objectPlayAnimation('cymbalLeft', 'clap', true)
	objectPlayAnimation('cymbalRight', 'clap', true)
	runTimer('cymbalHide', 0.34)
end

function dropDuck()
	cancelTween('duckFall')
	cancelTween('duckDrift')
	cancelTween('duckSpin')
	setProperty('duck.visible', true)
	setProperty('duck.active', true)
	objectPlayAnimation('duck', 'idle', true)
	local width = getProperty('duck.width')
	local height = getProperty('duck.height')
	local startX = getRandomFloat(0, math.max(0, screenWidth - width))
	local startY = -height - getRandomFloat(12, 55)
	local driftDirection = getRandomInt(0, 1) == 0 and -1 or 1
	local drift = getRandomFloat(35, 110) * driftDirection
	local endX = math.max(-width * 0.35, math.min(screenWidth - width * 0.65, startX + drift))
	local duration = getRandomFloat(0.55, 0.7)
	local spinDirection = getRandomInt(0, 1) == 0 and -1 or 1
	local startAngle = getRandomFloat(-25, 25)
	local spinDegrees = getRandomFloat(306, 414) * spinDirection
	setProperty('duck.x', startX)
	setProperty('duck.y', startY)
	setProperty('duck.angle', startAngle)
	doTweenY('duckFall', 'duck', screenHeight + height + 35, duration, 'quadIn')
	doTweenX('duckDrift', 'duck', endX, duration, 'sineOut')
	doTweenAngle('duckSpin', 'duck', startAngle + spinDegrees, duration, 'linear')
end

function clapNextCymbal()
	if cymbalNextLeft then
		objectPlayAnimation('cymbalLeft', 'clap', true)
		runTimer('cymbalLeftIdle', 0.34)
	else
		objectPlayAnimation('cymbalRight', 'clap', true)
		runTimer('cymbalRightIdle', 0.34)
	end
	cymbalNextLeft = not cymbalNextLeft
end

function startCymbalAlternating(interval)
	cancelTimer('cymbalAlternating')
	cymbalAlternating = true
	cymbalAlternatingInterval = interval
	cymbalNextLeft = true
	clapNextCymbal()
	runTimer('cymbalAlternating', cymbalAlternatingInterval)
end

function stopCymbalAlternating()
	cymbalAlternating = false
	cancelTimer('cymbalAlternating')
	objectPlayAnimation('cymbalLeft', 'idle', true)
	objectPlayAnimation('cymbalRight', 'idle', true)
	doTweenY('cymbalLeftExit', 'cymbalLeft', 720, 0.2, 'quadIn')
	doTweenY('cymbalRightExit', 'cymbalRight', 720, 0.2, 'quadIn')
end

function onStepHit()
	if curStep == 127 then
		doTweenY('stressLogoIn', 'logo', (screenHeight - getProperty('logo.height')) * 0.5, 1, 'quartOut')
	elseif curStep == 162 then
		doTweenX('stressLogoScaleXOut', 'logo.scale', 0, 0.4, 'quintIn')
		doTweenY('stressLogoScaleYOut', 'logo.scale', 0, 0.4, 'quintIn')
	end

	if curStep == 2048 then
		doTweenAlpha('stressHudFadeOut', 'camHUD', 0, 2, 'linear')
		if luaSpriteExists('cursor') then doTweenAlpha('stressCursorFadeOut', 'cursor', 0, 2, 'linear') end
		if luaSpriteExists('cursorDot') then doTweenAlpha('stressCursorDotFadeOut', 'cursorDot', 0, 2, 'linear') end
		if luaSpriteExists('shotNumber') then doTweenAlpha('stressShotNumberFadeOut', 'shotNumber', 0, 2, 'linear') end
	end

	if (curStep >= 750 and curStep <= 764 and (curStep - 750) % 7 == 0)
		or (curStep >= 1646 and curStep <= 1667 and (curStep - 1646) % 7 == 0)
		or curStep == 831 or curStep == 879 then
		launchFirework()
	end

	if curStep == 111 or curStep == 383 then
		doTweenY('drummerLeftExit', 'drummerLeft', 720, 0.5, 'quadIn')
		doTweenY('drummerRightExit', 'drummerRight', 720, 0.5, 'quadIn')
	elseif curStep == 128 then
		doTweenY('drummerLeftEnter', 'drummerLeft', 430, 0.5, 'quadOut')
		doTweenY('drummerRightEnter', 'drummerRight', 430, 0.5, 'quadOut')
	end

	local drummerStart = nil
	if curStep >= 4 and curStep <= 108 and (curStep - 4) % 8 == 0 then
		drummerStart = 4
	elseif curStep >= 128 and curStep <= 376 and (curStep - 128) % 8 == 0 then
		drummerStart = 128
	end

	if drummerStart ~= nil then
		if math.floor((curStep - drummerStart) / 8) % 2 == 0 then
			objectPlayAnimation('drummerLeft', 'slam', true)
			runTimer('drummerLeftIdle', 0.34)
		else
			objectPlayAnimation('drummerRight', 'slam', true)
			runTimer('drummerRightIdle', 0.34)
		end
	end

	if curStep >= 638 and curStep <= 830 and (curStep - 638) % 64 == 0 then
		doTweenY('cymbalLeftEnter', 'cymbalLeft', 390, 0.2, 'quadOut')
		doTweenY('cymbalRightEnter', 'cymbalRight', 390, 0.2, 'quadOut')
	elseif curStep == 895 then
		cancelTimer('cymbalHide')
		cancelTween('cymbalLeftEnter')
		cancelTween('cymbalRightEnter')
		setProperty('cymbalLeft.y', 720)
		setProperty('cymbalRight.y', 720)
		objectPlayAnimation('cymbalLeft', 'idle', true)
		objectPlayAnimation('cymbalRight', 'idle', true)
	end

	if curStep >= 640 and curStep <= 832 and (curStep - 640) % 64 == 0 then
		objectPlayAnimation('cymbalLeft', 'clap', true)
		objectPlayAnimation('cymbalRight', 'clap', true)
		runTimer('cymbalHide', 0.34)
	end

	for _, cymbalStep in ipairs(extraCymbalSteps) do
		if curStep == cymbalStep - 2 then
			enterCymbals()
		elseif curStep == cymbalStep then
			clapCymbals()
		end
	end

	if curStep == 1135 then
		objectPlayAnimation('cymbalLeft', 'idle', true)
		objectPlayAnimation('cymbalRight', 'idle', true)
		enterCymbals()
	elseif curStep == 1138 then
		startCymbalAlternating(0.2)
	elseif curStep == 1153 then
		stopCymbalAlternating()
	elseif curStep == 1392 then
		enterDrummers(0.2)
		startDrummerAlternating(0.2)
	elseif curStep == 1410 then
		stopDrummerAlternating()
	elseif curStep == 1506 then
		enterDrummers(0.2)
		startDrummerAlternating(0.4)
	elseif curStep == 1523 then
		stopDrummerAlternating()
	elseif curStep == 1795 then
		enterDrummers(0.2)
		drummerAlternating = false
		cancelTimer('drummerAlternating')
	elseif curStep == 1915 then
		stopDrummerAlternating()
	end

	if curStep >= 1795 and curStep < 1915 and (curStep - 1795) % 8 == 0 then
		if math.floor((curStep - 1795) / 8) % 2 == 0 then
			objectPlayAnimation('drummerLeft', 'slam', true)
			runTimer('drummerLeftIdle', 0.34)
		else
			objectPlayAnimation('drummerRight', 'slam', true)
			runTimer('drummerRightIdle', 0.34)
		end
	end

	if curStep == 375 or curStep == 888 or curStep == 1782 then
		objectPlayAnimation('bell', 'entrance', true)
		doTweenY('bellEnter', 'bell', 60, 0.1, 'quadOut')
	elseif curStep == 383 or curStep == 896 or curStep == 1790 then
		doTweenY('bellExit', 'bell', 720, 0.2, 'quadIn')
	end

	if curStep == 1275 then
		setProperty('kevin.alpha', 1)
		doTweenY('kevinEnter', 'kevin', kevinCenterY, 0.1, 'quadOut')
	elseif curStep == 1280 then
		doTweenAlpha('kevinFade', 'kevin', 0, 0.2, 'linear')
	elseif curStep == 1297 then
		doTweenY('kevinExit', 'kevin', 720, 0.25, 'quadIn')
	end

	if curStep == 1367 then
		dropDuck()
	end

	if curStep == 1504 then
		cancelTween('bonusFall')
		cancelTween('bonusQuickFade')
		cancelTween('bonusLongFade')
		setProperty('bonus.y', bonusRestY)
		doTweenAlpha('bonusFadeIn', 'bonus', 1, 0.2, 'linear')
	elseif curStep == 1515 then
		cancelTween('bonusFadeIn')
		doTweenY('bonusFall', 'bonus', screenHeight + getProperty('bonus.height'), 0.25, 'quadIn')
	elseif curStep == 1520 then
		cancelTween('bonusFall')
		setProperty('bonus.y', bonusRestY)
		setProperty('bonus.alpha', 1)
	elseif curStep == 1521 then
		doTweenAlpha('bonusQuickFade', 'bonus', 0, 0.03, 'linear')
	elseif curStep == 1524 then
		cancelTween('bonusQuickFade')
		setProperty('bonus.alpha', 1)
		doTweenAlpha('bonusLongFade', 'bonus', 0, 0.3, 'linear')
	elseif curStep == 1527 then
		cancelTween('bonusLongFade')
		bonusFlickering = true
		bonusFlickerVisible = true
		setProperty('bonus.alpha', 0.9)
		runTimer('bonusFlicker', 0.07)
	elseif curStep == 1537 then
		bonusFlickering = false
		cancelTimer('bonusFlicker')
		setProperty('bonus.alpha', 0)
	end
end

function startTankPass()
	tankPasses = tankPasses + 1
	setProperty('tank.x', 300)
	doTweenX('tankMove' .. tankPasses, 'tank', 3100, passTime / playbackRate, 'linear')
end

function onTimerCompleted(tag)
	if tag == 'drummerLeftIdle' then
		objectPlayAnimation('drummerLeft', 'idle', true)
	elseif tag == 'drummerRightIdle' then
		objectPlayAnimation('drummerRight', 'idle', true)
	elseif tag == 'cymbalHide' then
		objectPlayAnimation('cymbalLeft', 'idle', true)
		objectPlayAnimation('cymbalRight', 'idle', true)
		doTweenY('cymbalLeftExit', 'cymbalLeft', 720, 0.2, 'quadIn')
		doTweenY('cymbalRightExit', 'cymbalRight', 720, 0.2, 'quadIn')
	elseif tag == 'drummerAlternating' and drummerAlternating then
		slamNextDrummer()
		runTimer('drummerAlternating', drummerAlternatingInterval)
	elseif tag == 'cymbalLeftIdle' then
		objectPlayAnimation('cymbalLeft', 'idle', true)
	elseif tag == 'cymbalRightIdle' then
		objectPlayAnimation('cymbalRight', 'idle', true)
	elseif tag == 'cymbalAlternating' and cymbalAlternating then
		clapNextCymbal()
		runTimer('cymbalAlternating', cymbalAlternatingInterval)
	elseif tag == 'bonusFlicker' and bonusFlickering then
		bonusFlickerVisible = not bonusFlickerVisible
		setProperty('bonus.alpha', bonusFlickerVisible and 0.9 or 0)
		runTimer('bonusFlicker', 0.07)
	elseif string.find(tag, '^firework%d+_off$') then
		local sprite = string.gsub(tag, '_off', '')
		removeLuaSprite(sprite, true)
	end

	if tag == 'tankPass1' or tag == 'tankPass2' then
		startTankPass()
	end

	if string.find(tag, '_fade') then
		local sprite = string.gsub(tag, '_fade', '')
		doTweenAlpha(sprite .. '_fadeout', sprite, 0, explodeFadeTime, 'linear')
	end

	if string.find(tag, '^spawnLeft_') then
		spawnRunner(false)
	end

	if string.find(tag, '^spawnRight_') then
		spawnRunner(true)
	end

	if tag == 'runnerWave' then
		spawnRunnerWave()
		runTimer('runnerWave', math.random(90, 180) / 100)
	end

	if tag == 'peeIdle' then
		playAnim('pee', 'idle', true)
	end
end

function spawnRunner(fromRight)
	runnerID = runnerID + 1
	local tag = 'runner' .. runnerID
	local startX
	local endX

	if fromRight then
		startX = rightSpawnX
		endX = rightEndX + math.random(-explodeVariation, explodeVariation)
	else
		startX = leftSpawnX
		endX = leftEndX + math.random(-explodeVariation, explodeVariation)
	end

	local runVariant = getRandomInt(1, 3)
	local runY = runnerY + (runVariant == 1 and 44 or runVariant == 2 and -32 or 36)
	makeAnimatedLuaSprite(tag, 'fahmix/week7/kill', startX, runY)
	addAnimationByPrefix(tag, 'run', 'kill walk' .. runVariant, 10, true)
	addAnimationByPrefix(tag, 'explode', 'kill explode', 30, false)
	addLuaSprite(tag, false)
	setObjectOrder(tag, getObjectOrder('floor') + 1)

	if fromRight then
		scaleObject(tag, 0.92, 0.92)
	else
		scaleObject(tag, -0.92, 0.92)
	end

	objectPlayAnimation(tag, 'run', true)
	local speed = math.random(runnerMinSpeed * 100, runnerMaxSpeed * 100) / 100
	doTweenX(tag .. '_move', tag, endX, speed, 'linear')
end

function onTweenCompleted(tag)
	if tag == 'duckFall' then
		cancelTween('duckDrift')
		cancelTween('duckSpin')
		setProperty('duck.visible', false)
		setProperty('duck.active', false)
	end

	if tag == 'bellEnter' then
		objectPlayAnimation('bell', 'slam', true)
	end

	if string.find(tag, '^firework%d+_rise$') then
		local sprite = string.gsub(tag, '_rise', '')
		setProperty(sprite .. '.x', getProperty(sprite .. '.x') - 279.4)
		setProperty(sprite .. '.y', getProperty(sprite .. '.y') - 215.325)
		objectPlayAnimation(sprite, 'explode', true)
		runTimer(sprite .. '_off', 0.34)
	end

	if string.find(tag, '_move') then
		local sprite = string.gsub(tag, '_move', '')
		cancelTween(tag)
		setProperty(sprite .. '.y', getProperty(sprite .. '.y') - 110)

		if getProperty(sprite .. '.scale.x') > 0 then
			setProperty(sprite .. '.x', getProperty(sprite .. '.x') - 110)
		else
			setProperty(sprite .. '.x', getProperty(sprite .. '.x') + 110)
		end

		objectPlayAnimation(sprite, 'explode', true)
		playPhoenixSnap(getProperty(sprite .. '.scale.x') > 0)
		runTimer(sprite .. '_fade', explodeTime)
	end

	if string.find(tag, '_fadeout') then
		local sprite = string.gsub(tag, '_fadeout', '')
		removeLuaSprite(sprite, true)
	end
end

function spawnRunnerWave()
	local roll = math.random()
	local count

	if roll < 0.25 then
		count = 1
	elseif roll < 0.60 then
		count = 2
	elseif roll < 0.90 then
		count = 3
	else
		count = 4
	end

	local spacing = math.random(22, 55) / 100
	if math.random() < 0.8 then
		for i = 0, count - 1 do
			runTimer('spawnLeft_' .. runnerID .. '_' .. i, i * spacing)
			runTimer('spawnRight_' .. runnerID .. '_' .. i, i * spacing)
		end
	else
		local fromRight = math.random() < 0.5
		for i = 0, count - 1 do
			if fromRight then
				runTimer('spawnRight_' .. runnerID .. '_' .. i, i * spacing)
			else
				runTimer('spawnLeft_' .. runnerID .. '_' .. i, i * spacing)
			end
		end
	end
end
