local defaultAngle = 0
local rotated = false
local flyPoolSize = 12
local flyStates = {}
local flyCameraX = nil
local flyCameraY = nil

local function getFlyBounds()
	local left = getProperty('camGame.scroll.x') or 0
	local top = getProperty('camGame.scroll.y') or 0
	return left - 200, left + screenWidth + 200, top - 150, top + screenHeight - 200
end

local function getFlySectorBounds(sector)
	local minX, maxX, minY, maxY = getFlyBounds()
	local index = sector - 1
	local column = index % 4
	local row = math.floor(index / 4)
	local cellWidth = (maxX - minX) / 4
	local cellHeight = (maxY - minY) / 3
	return minX + column * cellWidth, minX + (column + 1) * cellWidth, minY + row * cellHeight, minY + (row + 1) * cellHeight
end

local function getFlySectorTarget(sector)
	local minX, maxX, minY, maxY = getFlySectorBounds(sector)
	local index = sector - 1
	local column = index % 4
	local row = math.floor(index / 4)
	local width = maxX - minX
	local height = maxY - minY
	local targetX
	local targetY
	if column == 0 then
		targetX = getRandomFloat(minX + width * 0.02, minX + width * 0.24)
	elseif column == 3 then
		targetX = getRandomFloat(maxX - width * 0.24, maxX - width * 0.02)
	else
		targetX = getRandomFloat(minX + width * 0.08, maxX - width * 0.08)
	end
	if row == 0 then
		targetY = getRandomFloat(minY + height * 0.03, minY + height * 0.35)
	elseif row == 2 then
		targetY = getRandomFloat(maxY - height * 0.35, maxY - height * 0.03)
	else
		targetY = getRandomFloat(minY + height * 0.08, maxY - height * 0.08)
	end
	return targetX, targetY
end

local function getDistributedFlySectors(count)
	local sectors = {1, 4, 9, 12}
	local remaining = {2, 3, 5, 6, 7, 8, 10, 11}
	for i = #remaining, 2, -1 do
		local swap = getRandomInt(1, i)
		remaining[i], remaining[swap] = remaining[swap], remaining[i]
	end
	for i = 1, count - #sectors do table.insert(sectors, remaining[i]) end
	return sectors
end

local function chooseFlyMotion(state)
	local direction = getRandomFloat(0, math.pi * 2)
	local rapid = getRandomInt(1, 100) <= 28
	state.speed = rapid and getRandomFloat(100, 185) or getRandomFloat(30, 90)
	state.targetVX = math.cos(direction) * state.speed
	state.targetVY = math.sin(direction) * state.speed
	state.changeTimer = rapid and getRandomFloat(0.06, 0.16) or getRandomFloat(0.16, 0.58)
end

local function burstFly(state, targetX, targetY)
	local x = getProperty(state.tag .. '.x')
	local y = getProperty(state.tag .. '.y')
	local duration = getRandomFloat(0.19, 0.29)
	state.vx = (targetX - x) / duration
	state.vy = (targetY - y) / duration
	state.targetVX = state.vx
	state.targetVY = state.vy
	state.burstTargetX = targetX
	state.burstTargetY = targetY
	state.burstTimer = duration
	state.changeTimer = state.burstTimer
end

local function createFlySwarm()
	local backgroundOrder = getObjectOrder('sun-2') + 1
	for i = 1, flyPoolSize do
		local tag = 'fahFly' .. i
		makeAnimatedLuaSprite(tag, 'Freeplay-Chrs/fah/fly', 0, 0)
		addAnimationByPrefix(tag, 'appear', 'fly appear', 12, false)
		addAnimationByPrefix(tag, 'idle', 'fly idle', getRandomInt(7, 11), true)
		addAnimationByPrefix(tag, 'disappear', 'fly disappear', 12, false)
		addLuaSprite(tag, false)
		setObjectOrder(tag, backgroundOrder)
		setProperty(tag .. '.visible', false)
		setProperty(tag .. '.active', false)
		flyStates[i] = {tag = tag, index = i, phase = 'hidden', vx = 0, vy = 0}
	end
end

local function startFlySwarm()
	if lowQuality then return end
	local count = getRandomInt(8, flyPoolSize)
	local sectors = getDistributedFlySectors(count)
	for i = count, 2, -1 do
		local swap = getRandomInt(1, i)
		sectors[i], sectors[swap] = sectors[swap], sectors[i]
	end
	for i = 1, flyPoolSize do
		local state = flyStates[i]
		if i <= count then
			local tag = state.tag
			local size = getRandomFloat(0.72, 1.08)
			state.sector = sectors[i]
			local spawnX, spawnY = getFlySectorTarget(state.sector)
			state.phase = 'appear'
			state.vx = 0
			state.vy = 0
			state.burstTimer = 0
			setProperty(tag .. '.x', spawnX)
			setProperty(tag .. '.y', spawnY)
			chooseFlyMotion(state)
			setProperty(tag .. '.scale.x', size)
			setProperty(tag .. '.scale.y', size)
			setProperty(tag .. '.angle', 0)
			setProperty(tag .. '.visible', true)
			setProperty(tag .. '.active', true)
			playAnim(tag, 'appear', true)
		else
			state.phase = 'hidden'
			setProperty(state.tag .. '.visible', false)
			setProperty(state.tag .. '.active', false)
		end
	end
end

local function stopFlySwarm()
	if lowQuality then return end
	for i = 1, flyPoolSize do
		local state = flyStates[i]
		if state.phase ~= 'hidden' and state.phase ~= 'disappear' then
			state.phase = 'disappear'
			playAnim(state.tag, 'disappear', true)
		end
	end
end

local function updateFlyCameraAnchor()
	local cameraX = getProperty('camGame.scroll.x') or 0
	local cameraY = getProperty('camGame.scroll.y') or 0
	if flyCameraX ~= nil then
		local dx = cameraX - flyCameraX
		local dy = cameraY - flyCameraY
		if dx ~= 0 or dy ~= 0 then
			for i = 1, flyPoolSize do
				local state = flyStates[i]
				if state.phase ~= 'hidden' then
					setProperty(state.tag .. '.x', getProperty(state.tag .. '.x') + dx)
					setProperty(state.tag .. '.y', getProperty(state.tag .. '.y') + dy)
					if state.burstTargetX ~= nil then state.burstTargetX = state.burstTargetX + dx end
					if state.burstTargetY ~= nil then state.burstTargetY = state.burstTargetY + dy end
					if state.pendingBurstX ~= nil then state.pendingBurstX = state.pendingBurstX + dx end
					if state.pendingBurstY ~= nil then state.pendingBurstY = state.pendingBurstY + dy end
				end
			end
		end
	end
	flyCameraX = cameraX
	flyCameraY = cameraY
end

local function updateFly(state, elapsed)
	if state.phase == 'hidden' then return end
	local tag = state.tag
	if state.phase == 'appear' and getProperty(tag .. '.animation.curAnim.finished') then
		state.phase = 'idle'
		playAnim(tag, 'idle', true)
	elseif state.phase == 'disappear' and getProperty(tag .. '.animation.curAnim.finished') then
		state.phase = 'hidden'
		setProperty(tag .. '.visible', false)
		setProperty(tag .. '.active', false)
		return
	end

	local wasBursting = state.burstTimer ~= nil and state.burstTimer > 0
	state.changeTimer = state.changeTimer - elapsed
	state.burstTimer = math.max(0, (state.burstTimer or 0) - elapsed)
	if state.changeTimer <= 0 and state.burstTimer <= 0 then chooseFlyMotion(state) end
	local steering = math.min(1, elapsed * (state.burstTimer > 0 and 2.2 or 8.5))
	state.vx = state.vx + (state.targetVX - state.vx) * steering
	state.vy = state.vy + (state.targetVY - state.vy) * steering

	local x = getProperty(tag .. '.x') + state.vx * elapsed
	local y = getProperty(tag .. '.y') + state.vy * elapsed
	if wasBursting and state.burstTimer <= 0 then
		x = state.burstTargetX
		y = state.burstTargetY
	end
	local minX, maxX, minY, maxY = getFlyBounds()
	if x < minX then
		x = minX
		state.vx = math.abs(state.vx)
		state.targetVX = math.abs(state.targetVX)
	elseif x > maxX then
		x = maxX
		state.vx = -math.abs(state.vx)
		state.targetVX = -math.abs(state.targetVX)
	end
	if y < minY then
		y = minY
		state.vy = math.abs(state.vy)
		state.targetVY = math.abs(state.targetVY)
	elseif y > maxY then
		y = maxY
		state.vy = -math.abs(state.vy)
		state.targetVY = -math.abs(state.targetVY)
	end

	setProperty(tag .. '.x', x)
	setProperty(tag .. '.y', y)
	local tilt = math.max(-15, math.min(15, state.vx * 0.075))
	local angle = getProperty(tag .. '.angle')
	setProperty(tag .. '.angle', angle + (tilt - angle) * math.min(1, elapsed * 5))
end

function onCreate()
	
	makeAnimatedLuaSprite('paper', 'Freeplay-Chrs/fah/BG', 50, 50)
	addAnimationByPrefix('paper', 'idle', 'BG idle', 3, true)
	addLuaSprite('paper', false)
	scaleObject('paper', 1.5, 1.5);


	makeAnimatedLuaSprite('big-orange5', 'Freeplay-Chrs/fah/big-orange', 730, 50)
	addAnimationByPrefix('big-orange5', 'idle', 'big-orange idle', 6, true)
	addAnimationByPrefix('big-orange5', 'trans', 'big-orange trans', 10, true)
	addLuaSprite('big-orange5', false)
	scaleObject('big-orange5', 0.5, 1);
	setProperty('big-orange5.alpha', 0)

	makeAnimatedLuaSprite('big-orange6', 'Freeplay-Chrs/fah/big-orange', 1930, 50)
	addAnimationByPrefix('big-orange6', 'idle', 'big-orange idle', 6, true)
	addAnimationByPrefix('big-orange6', 'trans', 'big-orange trans', 10, true)
	addLuaSprite('big-orange6', false)
	scaleObject('big-orange6', 0.5, 1);
	setProperty('big-orange6.alpha', 0)


	makeAnimatedLuaSprite('big-orange1', 'Freeplay-Chrs/fah/big-orange', 690, 175)
	addAnimationByPrefix('big-orange1', 'idle', 'big-orange idle', 6, true)
	addAnimationByPrefix('big-orange1', 'trans', 'big-orange trans', 10, true)
	addLuaSprite('big-orange1', false)
	scaleObject('big-orange1', 1.6, 1);
	setProperty('big-orange1.alpha', 0)


	makeAnimatedLuaSprite('big-orange2', 'Freeplay-Chrs/fah/big-orange', 800, 320)
	addAnimationByPrefix('big-orange2', 'idle', 'big-orange idle', 6, true)
	addAnimationByPrefix('big-orange2', 'trans', 'big-orange trans', 10, true)
	addLuaSprite('big-orange2', false)
	scaleObject('big-orange2', 1.4, 1);
	setProperty('big-orange2.alpha', 0)


	makeAnimatedLuaSprite('big-orange3', 'Freeplay-Chrs/fah/big-orange', 910, 490)
	addAnimationByPrefix('big-orange3', 'idle', 'big-orange idle', 6, true)
	addAnimationByPrefix('big-orange3', 'trans', 'big-orange trans', 10, true)
	addLuaSprite('big-orange3', false)
	scaleObject('big-orange3', 1.2, 1);
	setProperty('big-orange3.alpha', 0)


	makeAnimatedLuaSprite('big-orange4', 'Freeplay-Chrs/fah/big-orange', 730, 660)
	addAnimationByPrefix('big-orange4', 'idle', 'big-orange idle', 6, true)
	addAnimationByPrefix('big-orange4', 'trans', 'big-orange trans', 10, true)
	addLuaSprite('big-orange4', false)
	scaleObject('big-orange4', 1.5, 1);
	setProperty('big-orange4.alpha', 0)




	makeAnimatedLuaSprite('clouds', 'Freeplay-Chrs/fah/clouds', 690, 50)
	addAnimationByPrefix('clouds', 'idle', 'clouds idle', 6, true)
	addLuaSprite('clouds', false)
	scaleObject('clouds', 1.3, 1);


	makeAnimatedLuaSprite('dots-bottom', 'Freeplay-Chrs/fah/dots-bottom', -1300, 100)
	addAnimationByPrefix('dots-bottom', 'idle', 'dots-bottom idle', 6, true)
	addLuaSprite('dots-bottom', false)
	scaleObject('dots-bottom', 1.36, 1.36);

	makeAnimatedLuaSprite('dots-mid', 'Freeplay-Chrs/fah/dots-mid', 2400, 100)
	addAnimationByPrefix('dots-mid', 'idle', 'dots-mid idle', 6, true)
	addLuaSprite('dots-mid', false)
	scaleObject('dots-mid', 1.36, 1.36);

	makeAnimatedLuaSprite('dots-top', 'Freeplay-Chrs/fah/dots-top', -1100, 100)
	addAnimationByPrefix('dots-top', 'idle', 'dots-top idle', 6, true)
	addLuaSprite('dots-top', false)
	scaleObject('dots-top', 1.36, 1.36);


	makeAnimatedLuaSprite('trix', 'Freeplay-Chrs/fah/trix', 1370, 200)
	addAnimationByPrefix('trix', 'idle', 'trix idle', 6, true)
	addLuaSprite('trix', false)
	scaleObject('trix', 1.3, 1.3);
	runTimer('rotatetrix', 0.5, 0)
	setProperty('trix.visible', false)
	defaultAngle = getProperty('trix.angle')
	doTweenX('trix', 'trix.scale', 0, 0.4, 'quintIn')
	doTweenY('trix2', 'trix.scale', 0, 0.4, 'quintIn')



	makeAnimatedLuaSprite('sun', 'Freeplay-Chrs/fah/sun', 690, 50)
	addAnimationByPrefix('sun', 'idle', 'sun idle', 6, true)
	addLuaSprite('sun', false)
	scaleObject('sun', 1, 1);



	makeAnimatedLuaSprite('sun-2', 'Freeplay-Chrs/fah/sun-2', 690, 50)
	addAnimationByPrefix('sun-2', 'idle', 'sun-2 idle', 6, true)
	addAnimationByPrefix('sun-2', 'trans', 'sun-2 trans', 12, true)
	addOffset('sun-2', 'idle', -800, 0)
	addLuaSprite('sun-2', false)
	scaleObject('sun-2', 1, 1);
	setProperty('sun-2.alpha', 0)



	makeAnimatedLuaSprite('tree1', 'Freeplay-Chrs/fah/tree', 600, 0)
	addAnimationByPrefix('tree1', 'idle', 'tree idle', 4, true)
	addAnimationByPrefix('tree1', 'grow', 'tree grow', 8, false)
	addAnimationByPrefix('tree1', 'shrink', 'tree shrink', 8, false)
	scaleObject('tree1', 1.2, 1.2);

	makeAnimatedLuaSprite('tree2', 'Freeplay-Chrs/fah/tree', 870, -70)
	addAnimationByPrefix('tree2', 'idle', 'tree idle', 4, true)
	addAnimationByPrefix('tree2', 'grow', 'tree grow', 8, false)
	addAnimationByPrefix('tree2', 'shrink', 'tree shrink', 8, false)
	scaleObject('tree2', 1.2, 1.2);



	makeAnimatedLuaSprite('tree3', 'Freeplay-Chrs/fah/tree', 1140, -130)
	addAnimationByPrefix('tree3', 'idle', 'tree idle', 4, true)
	addAnimationByPrefix('tree3', 'grow', 'tree grow', 8, false)
	addAnimationByPrefix('tree3', 'shrink', 'tree shrink', 8, false)
	scaleObject('tree3', 1.2, 1.2);


	makeAnimatedLuaSprite('tree4', 'Freeplay-Chrs/fah/tree', 1340, -130)
	addAnimationByPrefix('tree4', 'idle', 'tree idle', 4, true)
	addAnimationByPrefix('tree4', 'grow', 'tree grow', 8, false)
	addAnimationByPrefix('tree4', 'shrink', 'tree shrink', 8, false)
	setProperty('tree4.flipX', true)
	scaleObject('tree4', 1.2, 1.2);


	makeAnimatedLuaSprite('tree5', 'Freeplay-Chrs/fah/tree', 1610, -70)
	addAnimationByPrefix('tree5', 'idle', 'tree idle', 4, true)
	addAnimationByPrefix('tree5', 'grow', 'tree grow', 8, false)
	addAnimationByPrefix('tree5', 'shrink', 'tree shrink', 8, false)
	setProperty('tree5.flipX', true)
	scaleObject('tree5', 1.2, 1.2);


	makeAnimatedLuaSprite('tree6', 'Freeplay-Chrs/fah/tree', 1880, -70)
	addAnimationByPrefix('tree6', 'idle', 'tree idle', 4, true)
	addAnimationByPrefix('tree6', 'grow', 'tree grow', 8, false)
	addAnimationByPrefix('tree6', 'shrink', 'tree shrink', 8, false)
	setProperty('tree6.flipX', true)
	scaleObject('tree6', 1.2, 1.2);







	makeAnimatedLuaSprite('tall-flower1', 'Freeplay-Chrs/fah/flower-tall', 400, 200)
	addAnimationByPrefix('tall-flower1', 'idle', 'flower-tall blow', 14, true)
	addAnimationByPrefix('tall-flower1', 'grow', 'flower-tall grow', 14, false)
	addAnimationByPrefix('tall-flower1', 'shrink', 'flower-tall shrink', 14, false)
	scaleObject('tall-flower1', 1.5, 1.5);
	addLuaSprite('tall-flower1', false)
	setProperty('tall-flower1.visible', false)


	makeAnimatedLuaSprite('tall-flower2', 'Freeplay-Chrs/fah/flower-tall', 840, 140)
	addAnimationByPrefix('tall-flower2', 'idle', 'flower-tall blow', 14, true)
	addAnimationByPrefix('tall-flower2', 'grow', 'flower-tall grow', 14, false)
	addAnimationByPrefix('tall-flower2', 'shrink', 'flower-tall shrink', 14, false)
	scaleObject('tall-flower2', 1.5, 1.5);
	addLuaSprite('tall-flower2', false)
	setProperty('tall-flower2.visible', false)



	makeAnimatedLuaSprite('tall-flower3', 'Freeplay-Chrs/fah/flower-tall', 1400, 140)
	addAnimationByPrefix('tall-flower3', 'idle', 'flower-tall blow', 14, true)
	addAnimationByPrefix('tall-flower3', 'grow', 'flower-tall grow', 14, false)
	addAnimationByPrefix('tall-flower3', 'shrink', 'flower-tall shrink', 14,false)
	scaleObject('tall-flower3', 1.5, 1.5);
	addLuaSprite('tall-flower3', false)
	setProperty('tall-flower3.visible', false)


	makeAnimatedLuaSprite('tall-flower4', 'Freeplay-Chrs/fah/flower-tall', 1800, 200)
	addAnimationByPrefix('tall-flower4', 'idle', 'flower-tall blow', 14, true)
	addAnimationByPrefix('tall-flower4', 'grow', 'flower-tall grow', 14, false)
	addAnimationByPrefix('tall-flower4', 'shrink', 'flower-tall shrink', 14, false)
	scaleObject('tall-flower4', 1.5, 1.5);
	addLuaSprite('tall-flower4', false)
	setProperty('tall-flower4.visible', false)




	makeAnimatedLuaSprite('short-flower1', 'Freeplay-Chrs/fah/flower-short', 640, 300)
	addAnimationByPrefix('short-flower1', 'idle', 'flower-short idle', 12, true)
	addAnimationByPrefix('short-flower1', 'grow', 'flower-short grow', 12, false)
	addAnimationByPrefix('short-flower1', 'shrink', 'flower-short shrink', 12, false)
	scaleObject('short-flower1', 1.5, 1.5);
	addLuaSprite('short-flower1', false)
	setProperty('short-flower1.visible', false)


	makeAnimatedLuaSprite('short-flower2', 'Freeplay-Chrs/fah/flower-short', 1140, 285)
	addAnimationByPrefix('short-flower2', 'idle', 'flower-short idle', 12, true)
	addAnimationByPrefix('short-flower2', 'grow', 'flower-short grow', 12, false)
	addAnimationByPrefix('short-flower2', 'shrink', 'flower-short shrink', 12, false)
	scaleObject('short-flower2', 1.5, 1.5);
	addLuaSprite('short-flower2', false)
	setProperty('short-flower2.visible', false)



	makeAnimatedLuaSprite('short-flower3', 'Freeplay-Chrs/fah/flower-short', 1600, 320)
	addAnimationByPrefix('short-flower3', 'idle', 'flower-short idle', 12, true)
	addAnimationByPrefix('short-flower3', 'grow', 'flower-short grow', 12, false)
	addAnimationByPrefix('short-flower3', 'shrink', 'flower-short shrink', 12,false)
	scaleObject('short-flower3', 1.5, 1.5);
	addLuaSprite('short-flower3', false)
	setProperty('short-flower3.visible', false)








	makeAnimatedLuaSprite('the', 'Freeplay-Chrs/fah/the', 850, 150)
	addAnimationByPrefix('the', 'idle', 'the idle', 6, true)
	addLuaSprite('the', false)
	scaleObject('the', 1, 1);
	setProperty('the.alpha', 0)



	makeAnimatedLuaSprite('fah', 'Freeplay-Chrs/fah/fah', 850, 150)
	addAnimationByPrefix('fah', 'idle', 'fah idle', 6, true)
	addLuaSprite('fah', false)
	scaleObject('fah', 1, 1);
	setProperty('fah.alpha', 0)


	makeAnimatedLuaSprite('what', 'Freeplay-Chrs/fah/what', 850, 150)
	addAnimationByPrefix('what', 'idle', 'what idle', 6, true)
	addLuaSprite('what', false)
	scaleObject('what', 1, 1);
	setProperty('what.alpha', 0)



	if not lowQuality then createFlySwarm() end


	makeAnimatedLuaSprite('floor', 'Freeplay-Chrs/fah/floor', 500, 710)
	addAnimationByPrefix('floor', 'idle', 'floor idle', 6, true)
	addLuaSprite('floor', false)
	scaleObject('floor', 1.5, 1.1);



	makeAnimatedLuaSprite('flower-floor', 'Freeplay-Chrs/fah/flower-floor', 500, 710)
	addAnimationByPrefix('flower-floor', 'idle', 'flower-floor idle', 6, true)
	addAnimationByPrefix('flower-floor', 'grow', 'flower-floor grow', 10, false)
	addLuaSprite('flower-floor', false)
	scaleObject('flower-floor', 1.5, 1.1);
	playAnim('flower-floor', 'idle', true)
	setProperty('flower-floor.visible', false)


	makeAnimatedLuaSprite('flower-foreground', 'Freeplay-Chrs/fah/flower-foreground', 700, 0)
	addAnimationByPrefix('flower-foreground', 'idle', 'flower-foreground idle', 6, true)
	addAnimationByPrefix('flower-foreground', 'grow', 'flower-foreground grow', 10, false)
	addLuaSprite('flower-foreground', true)
	scaleObject('flower-foreground', 1.25, 1.2);
	playAnim('flower-foreground', 'idle', true)
	setProperty('flower-foreground.visible', false)


	makeAnimatedLuaSprite('ray', 'Freeplay-Chrs/fah/ray', 780, 50)
	addAnimationByPrefix('ray', 'idle', 'ray idle', 6, true)
	addLuaSprite('ray', false)
	scaleObject('ray', 1.1, 1.1);

	makeAnimatedLuaSprite('pee', 'Freeplay-Chrs/fah/pee', 780, 50)
	addAnimationByPrefix('pee', 'idle', 'pee idle', 6, true)
	addLuaSprite('pee', false)
	scaleObject('pee', 1.1, 1.1);


	makeAnimatedLuaSprite('pheeven-dance', 'Freeplay-Chrs/fah/pheeven-dance', 1300, 380)
	addAnimationByPrefix('pheeven-dance', 'idle', 'pheeven-dance idle', 6, true)
	addLuaSprite('pheeven-dance', false)
	scaleObject('pheeven-dance', 1.1, 1.1);
	setProperty('pheeven-dance.visible', false)


	makeAnimatedLuaSprite('pheeven-trans', 'Freeplay-Chrs/fah/trans', 1300, 380)
	addAnimationByPrefix('pheeven-trans', 'idle', 'trans trans', 8, true)
	addLuaSprite('pheeven-trans', false)
	scaleObject('pheeven-trans', 1.1, 1.1);
	setProperty('pheeven-trans.visible', false)


	makeAnimatedLuaSprite('diving', 'Freeplay-Chrs/fah/diving', 1025, 598)
	addAnimationByPrefix('diving', 'diving', 'diving trans', 18, true)
	addAnimationByPrefix('diving', 'idle', 'diving idle', 10, true)
	addOffset('diving', 'idle', -135, -230)
	addLuaSprite('diving', false)
	scaleObject('diving', 1.1, 1.1);
	setProperty('diving.visible', false)



	makeAnimatedLuaSprite('falling', 'Freeplay-Chrs/fah/falling', 1035, -300)
	addAnimationByPrefix('falling', 'idle', 'falling idle', 10, true)
	addOffset('falling', 'idle', -135, -230)
	addLuaSprite('falling', false)
	scaleObject('falling', 1.1, 1.1);
	setProperty('falling.visible', true)
end

function onUpdate(elapsed)
    if lowQuality then return end
	updateFlyCameraAnchor()
	for i = 1, flyPoolSize do updateFly(flyStates[i], elapsed) end
end


local titleWordSteps = {
	[1] = 'what', [3] = 'the', [7] = 'fah',
	[31] = 'what', [33] = 'the', [37] = 'fah',
	[63] = 'what', [65] = 'the', [69] = 'fah',
	[95] = 'what', [97] = 'the', [101] = 'fah'
}
local titleExitSteps = {[12] = true, [42] = true, [74] = true, [106] = true}
local fairyStartSteps = {[386] = true, [896] = true}
local fairyStopSteps = {[636] = true, [1144] = true}
local flowerTags = {
	'short-flower1', 'short-flower2', 'short-flower3',
	'tall-flower1', 'tall-flower2', 'tall-flower3', 'tall-flower4'
}

local function transitionPheeven()
	setProperty('pheeven-dance.visible', false)
	setProperty('pheeven-trans.visible', true)
	setProperty('pheeven-trans.animation.curAnim.curFrame', 0)
	runTimer('pheeven-trans', 0.46)
	setObjectOrder('pee', getObjectOrder('pheeven-dance') + 2)
end

local function setFairiesVisible(active)
	if lowQuality then return end
	if active then
		startFlySwarm()
	else
		stopFlySwarm()
	end
end

function onBeatHit()
	if lowQuality then return end
	local active = {}
	for i = 1, flyPoolSize do
		local state = flyStates[i]
		if state.phase == 'appear' or state.phase == 'idle' then table.insert(active, state) end
	end
	for i = #active, 2, -1 do
		local swap = getRandomInt(1, i)
		active[i], active[swap] = active[swap], active[i]
	end
	local available = getDistributedFlySectors(#active)
	for i = #available, 2, -1 do
		local swap = getRandomInt(1, i)
		available[i], available[swap] = available[swap], available[i]
	end
	for i = 1, #active do
		local state = active[i]
		local sector = available[i]
		local targetX, targetY = getFlySectorTarget(sector)
		state.pendingBurstX = targetX
		state.pendingBurstY = targetY
		runTimer('fahFlyBurst' .. state.index, getRandomFloat(0.005, 0.075))
	end
end

function onStepHit()
	local titleWord = titleWordSteps[curStep]
	if titleWord ~= nil then
		doTweenAlpha(titleWord .. 'in', titleWord, 1, 0.3, 'Bounceout')
	elseif titleExitSteps[curStep] then
		for _, word in ipairs({'what', 'the', 'fah'}) do
			doTweenAlpha(word .. 'out', word, 0, 0.5, 'CubeOut')
		end
	end

	if fairyStartSteps[curStep] then
		setFairiesVisible(true)
	elseif fairyStopSteps[curStep] then
		setFairiesVisible(false)
	end

	if curStep == 891 then
		local treeOrder = getObjectOrder('floor') - 2
		for i = 1, 6 do
			local tree = 'tree' .. i
			setObjectOrder(tree, treeOrder)
			addLuaSprite(tree, false)
			objectPlayAnimation(tree, 'grow', true)
		end
		runTimer('toIdle', 0.625)
		setProperty('pheeven-dance.visible', true)
		setProperty('ray.visible', false)
		setProperty('pee.visible', false)
	elseif curStep == 1151 then
		removeTree()
		transitionPheeven()
	elseif curStep == 1156 then
		doTweenX('dots4', 'dots-top', 570, 0.7, 'Elasticout')
	elseif curStep == 1159 then
		doTweenX('dots2', 'dots-mid', 570, 0.7, 'Elasticout')
	elseif curStep == 1163 then
		doTweenX('dots3', 'dots-bottom', 570, 0.7, 'Elasticout')
	elseif curStep == 1166 then
		doTweenX('trix', 'trix.scale', 1, 0.5, 'quintIn')
		doTweenY('trix2', 'trix.scale', 1, 0.5, 'quintIn')
		setProperty('trix.visible', true)
	elseif curStep == 1284 then
		doTweenY('dots4', 'dots-bottom', 900, 0.25, 'quintIn')
	elseif curStep == 1286 then
		doTweenY('dots2', 'dots-mid', 900, 0.25, 'quintIn')
	elseif curStep == 1288 then
		doTweenY('dots3', 'dots-top', 900, 0.25, 'quintIn')
		doTweenY('trix', 'trix', 900, 0.4, 'quintIn')
	elseif curStep == 1403 then
		playAnim('flower-floor', 'grow', true)
		setProperty('flower-floor.y', 40)
		setProperty('flower-floor.visible', true)
		setProperty('floor.visible', false)
		runTimer('fahlower-grow', 0.5)

		playAnim('flower-foreground', 'grow', true)
		setProperty('flower-foreground.visible', true)
		runTimer('fahlower-grow-fore', 0.6)

		for _, flower in ipairs(flowerTags) do
			playAnim(flower, 'grow', true)
			setProperty(flower .. '.visible', true)
		end
		runTimer('small-grow', 0.33)
		runTimer('tall-grow', 0.43)
	elseif curStep == 1663 then
		removeSmalls()
		removeTalls()
	elseif curStep == 1664 then
		setProperty('dad.alpha', 0)
		setProperty('diving.visible', true)
		setProperty('diving.curAnim.curFrame', 0)
		runTimer('diving', 0.25)
		playAnim('diving', 'diving', true)
	elseif curStep == 1719 then
		objectPlayAnimation('sun-2', 'trans', true)
		setProperty('sun.alpha', 0)
		setProperty('sun-2.alpha', 1)
		runTimer('sun-2', 0.667)

		for i = 1, 6 do
			local orange = 'big-orange' .. i
			objectPlayAnimation(orange, 'trans', true)
			setProperty(orange .. '.alpha', 0.7)
		end
		runTimer('orange', 0.8)
		setProperty('pheeven-dance.visible', true)
		setProperty('ray.visible', false)
		setProperty('pee.visible', false)
	elseif curStep == 1726 then
		setProperty('falling.visible', true)
		setProperty('falling.curAnim.curFrame', 0)
		doTweenY('falling12', 'falling', 578, 0.15, 'quint')
		runTimer('falling', 0.15)
	elseif curStep == 2240 then
		transitionPheeven()
	end
end

function onTimerCompleted(tag)
		local flyIndex = tonumber(string.match(tag, '^fahFlyBurst(%d+)$'))
		if flyIndex ~= nil then
			local state = flyStates[flyIndex]
			if state ~= nil and (state.phase == 'appear' or state.phase == 'idle') and state.pendingBurstX ~= nil then
				burstFly(state, state.pendingBurstX, state.pendingBurstY)
				state.pendingBurstX = nil
				state.pendingBurstY = nil
			end
			return
		end
		if tag == 'unlockSwitch' then
    	switching = false
		end
		if tag == 'toIdle' then
				for i = 1, 6 do
					objectPlayAnimation('tree' .. i, 'idle', true)
				end
		elseif tag == 'removeSprite' then
				for i = 1, 6 do
					removeLuaSprite('tree' .. i, true)
				end
		end
		if tag == 'removeTree' then
			for i = 1, 6 do
				removeLuaSprite('tree' .. i, true)
			end
		end


		if tag == 'removeSmalls' then
			for i = 1, 3 do
				removeLuaSprite('short-flower' .. i, true)
			end
		end

		if tag == 'removeTalls' then
			for i = 1, 4 do
				removeLuaSprite('tall-flower' .. i, true)
			end
		end

		if tag == 'fahlower-grow' then
			playAnim('flower-floor', 'idle', true)
			setProperty('flower-floor.y', 710)
		end

		if tag == 'fahlower-grow-fore' then
			playAnim('flower-foreground', 'idle', true)
		end

		if tag == 'small-grow' then
			for i = 1, 3 do
				playAnim('short-flower' .. i, 'idle', true)
			end
		end

		if tag == 'tall-grow' then
			for i = 1, 4 do
				playAnim('tall-flower' .. i, 'idle', true)
			end
		end

		if tag == 'diving' then
			playAnim('diving', 'idle', true)
			doTweenY('diving20', 'diving', 920, 0.15, 'cubed')
		end

		if tag == 'sun-2' then
			playAnim('sun-2', 'idle', true)
		end

		if tag == 'orange' then
			for i = 1, 6 do
				playAnim('big-orange' .. i, 'idle', true)
			end
		end

		if tag == 'falling' then
			triggerEvent('Change Character', 'dad', 'fah-tiger')
			setProperty('falling.alpha', 0)
			setProperty('dad.alpha', 1)
		end

		if tag == 'rotatetrix' then
		        if not rotated then
		            setProperty('trix.angle', defaultAngle + 30) 
		        else
		            setProperty('trix.angle', defaultAngle) 
		        end
		        rotated = not rotated
		  end

			if tag == 'pheeven-trans' then
					setProperty('ray.visible', true)
					setProperty('pee.visible', true)
					setProperty('pheeven-trans.visible', false)
				end
end

function removeTree()
	for i = 1, 6 do
		playAnim('tree' .. i, 'shrink', true)
	end
    runTimer('removeTree', 0.625) 
end



function removeSmalls()
		playAnim('short-flower1', 'shrink', true)
		playAnim('short-flower2', 'shrink', true)
		playAnim('short-flower3', 'shrink', true)
    runTimer('removeSmalls', 0.33) 
end

function removeTalls()
    playAnim('tall-flower1', 'shrink', true)
		playAnim('tall-flower2', 'shrink', true)
		playAnim('tall-flower3', 'shrink', true)
		playAnim('tall-flower4', 'shrink', true)
    runTimer('removeTalls', 0.43) 
end
