local lockX = 1600
local lockY = 900

local camTime = 0
local swaySpeed = 2
local swayDistance = 40


local dadBaseX = 0
local bfBaseX = 0
local rayBaseX = 1200
local peeBaseX = 1500


local minions = {}
local MINION_COUNT = 6

local minionLeft = 980
local minionRight = 2400

local lampMoving = false
local lampCutsMinions = false
local lampSpeed = 2500
local lampEndX = 2600
local lampTriggerStep = 634
local backLowStartX = -450
local henchmenDieSave = 'highHenchmenDieProgress'
local henchmenDieAchievementTag = 'Die'
local henchmenPassesRequired = 5
local minionsCutThisPass = 0
local recordedHenchmenPass = false

local deadHalves = {}
local deadHalfPool = {}
local nextDeadHalf = 1


local frontHighMoving = false
local backHighMoving = false

local frontHighSpeed = 3000
local backHighSpeed = 2600

local frontHighChance = 0.003
local backHighChance = 0.0025

local function chanceForElapsed(chanceAt60Fps, elapsed)
	return 1 - math.pow(1 - chanceAt60Fps, math.max(0, elapsed) * 60)
end


local startDeadWalk = false 

function awardHenchmenAchievementTick()
	if recordedHenchmenPass then return end
	recordedHenchmenPass = true
	 
	 
	 
	local savedPasses = tonumber(getDataFromSave(
		henchmenDieSave, 'completedPasses', 0)) or 0
	local livePasses = tonumber(getPropertyFromClass(
		'ClientPrefs', 'henchmenMassacreCount')) or 0
	local count = math.min(henchmenPassesRequired,
		math.max(savedPasses, livePasses) + 1)
	 
	 
	setPropertyFromClass('ClientPrefs', 'henchmenMassacreCount', count)
	 
	 
	setDataFromSave(henchmenDieSave, 'completedPasses', count)
	flushSaveData(henchmenDieSave)
	 
	recordHenchmenMassacre(count)
end

 
 
 
function recordHenchmenWipe()
	if recordedHenchmenPass then return end
	local deadCount = 0
	for i = 1, #minions do
		if minions[i].dead then deadCount = deadCount + 1 end
	end
	if deadCount < #minions or #minions == 0 then return end

	awardHenchmenAchievementTick()
end


function onCreate()
	startDeadWalk = string.lower(songName or '') == 'mama'
	initSaveData(henchmenDieSave, 'psychenginemods')

	makeAnimatedLuaSprite('paper', 'Freeplay-Chrs/fah/BG', 50, 50)
	addAnimationByPrefix('paper', 'idle', 'BG idle', 3, true)
	addLuaSprite('paper', false)
	scaleObject('paper', 1, 1);



	makeAnimatedLuaSprite('lines', 'fahmix/week4/lines', 200, -120)
	addAnimationByPrefix('lines', 'idle', 'idle', 6, true)
	addLuaSprite('lines', false)
	scaleObject('lines', 1, 1);



	makeAnimatedLuaSprite('sun', 'fahmix/week4/sun', 1100, 300)
	addAnimationByPrefix('sun', 'idle', 'idle', 6, true)
	addLuaSprite('sun', false)
	scaleObject('sun', 1, 1);


	makeAnimatedLuaSprite('b-lamp-high', 'fahmix/week4/back-lamp-high', -300, 200)
	addAnimationByPrefix('b-lamp-high', 'idle', 'idle', 6, true)
	addLuaSprite('b-lamp-high', false)
	scaleObject('b-lamp-high', 1, 1.3);
	setProperty('b-lamp-high.alpha', 0)




	makeAnimatedLuaSprite('b-lamp-low', 'fahmix/week4/back-lamp-low', backLowStartX, 730)
	addAnimationByPrefix('b-lamp-low', 'idle', 'idle', 6, true)
	addLuaSprite('b-lamp-low', false)
	scaleObject('b-lamp-low', 1, 1);
	setProperty('b-lamp-low.alpha', 0)

	makeAnimatedLuaSprite('backcar', 'fahmix/week4/backcar', 600, 800)
	addAnimationByPrefix('backcar', 'idle', 'idle', 6, true)
	addLuaSprite('backcar', false)
	scaleObject('backcar', 1.1, 1.1);


	makeAnimatedLuaSprite('frontcar', 'fahmix/week4/frontcar', 600, 1000)
	addAnimationByPrefix('frontcar', 'idle', 'idle', 6, true)
	addLuaSprite('frontcar', false)
	scaleObject('frontcar', 1.1, 1.1);



	makeAnimatedLuaSprite('ray', 'Freeplay-Chrs/fah/ray', 800, 300)
	addAnimationByPrefix('ray', 'idle', 'ray idle', 6, true)
	addLuaSprite('ray', false)
	scaleObject('ray', 1.1, 1.1);

	makeAnimatedLuaSprite('pee', 'Freeplay-Chrs/fah/pee', 800, 300)
	addAnimationByPrefix('pee', 'idle', 'pee idle', 6, true)
	addLuaSprite('pee', false)
	scaleObject('pee', 1.1, 1.1);



	makeAnimatedLuaSprite('f-lamp-high', 'fahmix/week4/front-lamp-high', -450, 200)
	addAnimationByPrefix('f-lamp-high', 'idle', 'idle', 6, true)
	addLuaSprite('f-lamp-high', true)
	scaleObject('f-lamp-high', 1, 1.3);
	setProperty('f-lamp-high.alpha', 0)
	local spacing = (minionRight - minionLeft) / (MINION_COUNT - 1)

	for i = 1, MINION_COUNT do
	    local tag = 'minion' .. i

			 
			local startY = startDeadWalk and 835 or 650

			makeAnimatedLuaSprite(tag, 'fahmix/week4/minion', minionLeft + spacing * (i - 1), startY)
	    addAnimationByPrefix(tag, 'idle', 'idle', 6, true)
	    addAnimationByPrefix(tag, 'walk', 'walk', 8, true)
			addAnimationByPrefix(tag, 'dead-walk', 'dead-walk', 14, true)
			if startDeadWalk then
			    objectPlayAnimation(tag, 'dead-walk', true)
			else
			    objectPlayAnimation(tag, 'idle', true)
			end

			addLuaSprite(tag, false)
	    scaleObject(tag, 0.9, 0.9)

	    minions[i] = {
	        tag = tag,
	        baseX = minionLeft + spacing * (i - 1),
	        walkOffset = 0,

					dead = startDeadWalk,

	        state = startDeadWalk and 'walk' or 'idle',
	        direction = math.random(0,1) == 0 and -1 or 1,

					baseY = startY,

	        timer = math.random(3,10),
	        speed = startDeadWalk and math.random(320,420) or math.random(60,120)
	    }
	end

	-- The lamp can cut several minions only a few frames apart. Pre-create the
	-- six possible halves so collision frames only reactivate existing objects.
	for i = 1, MINION_COUNT do
		local halfTag = 'deadHalf' .. i
		makeLuaSprite(halfTag, 'fahmix/week4/miniopndeadtophalf', -2000, -2000)
		addLuaSprite(halfTag, false)
		scaleObject(halfTag, 0.85, 0.85)
		setProperty(halfTag .. '.visible', false)
		deadHalfPool[i] = {
			tag = halfTag,
			x = -2000,
			y = -2000,
			velX = 0,
			velY = 0,
			gravity = 2000,
			rotSpeed = 0
		}
	end

end


function onCreatePost()
    setProperty('isCameraOnForcedPos', true)
    setProperty('camFollow.x', lockX)
    setProperty('camFollow.y', lockY)
    setProperty('camFollowPos.x', lockX)
    setProperty('camFollowPos.y', lockY)

    dadBaseX = getProperty('dad.x')
    bfBaseX = getProperty('boyfriend.x')
    rayBaseX = getProperty('ray.x')
    peeBaseX = getProperty('pee.x')


		local sunOrder = getObjectOrder('sun')

		
		setObjectOrder('sun', sunOrder)

		
		setObjectOrder('b-lamp-high', sunOrder + 1)

		
		setObjectOrder('b-lamp-low', sunOrder + 2)

		
		for i = 1, MINION_COUNT do
		    setObjectOrder('minion'..i, sunOrder + 2 + i)
		end

		
		setObjectOrder('backcar', sunOrder + MINION_COUNT + 3)

		
		setObjectOrder('frontcar', getObjectOrder('backcar') + 2)

		
		local charOrder = math.max(
		    getObjectOrder('dadGroup'),
		    getObjectOrder('boyfriendGroup')
		)

		setObjectOrder('f-lamp-high', charOrder + 1)

end

local function idleOverlapTooLarge(index)
    local tag = minions[index].tag
    local x = getProperty(tag .. '.x') or 0
    local y = getProperty(tag .. '.y') or 0
    local w = getProperty(tag .. '.width') or 0
    local h = getProperty(tag .. '.height') or 0
    if w <= 0 or h <= 0 then return false end
    for otherIndex = 1, #minions do
        if otherIndex ~= index and not minions[otherIndex].dead then
            local otherTag = minions[otherIndex].tag
            local ox = getProperty(otherTag .. '.x') or 0
            local oy = getProperty(otherTag .. '.y') or 0
            local ow = getProperty(otherTag .. '.width') or 0
            local oh = getProperty(otherTag .. '.height') or 0
            local overlapW = math.max(0, math.min(x + w, ox + ow) - math.max(x, ox))
            local overlapH = math.max(0, math.min(y + h, oy + oh) - math.max(y, oy))
            if overlapW * overlapH > math.min(w * h, ow * oh) * 0.5 then return true end
        end
    end
    return false
end


function onUpdate(elapsed)


		
		if not getPropertyFromClass('MirrorMode', 'active') and not frontHighMoving and math.random() < chanceForElapsed(frontHighChance, elapsed) then
		    frontHighMoving = true
		    setProperty('f-lamp-high.x', -450)
		    setProperty('f-lamp-high.alpha', 1)
		end

		if not backHighMoving and math.random() < chanceForElapsed(backHighChance, elapsed) then
		    backHighMoving = true
		    setProperty('b-lamp-high.x', -300)
		    setProperty('b-lamp-high.alpha', 1)
		end

		
		if frontHighMoving then
		    local x = getProperty('f-lamp-high.x') + frontHighSpeed * elapsed

		    if x >= 2600 then
		        x = -450
		        frontHighMoving = false
		        setProperty('f-lamp-high.alpha', 0)
		    end

		    setProperty('f-lamp-high.x', x)
		end

		
		if backHighMoving then
		    local x = getProperty('b-lamp-high.x') + backHighSpeed * elapsed

		    if x >= 2650 then
		        x = -300
		        backHighMoving = false
		        setProperty('b-lamp-high.alpha', 0)
		    end

		    setProperty('b-lamp-high.x', x)
		end

    camTime = camTime + elapsed

    local offset = math.sin(camTime * swaySpeed) * swayDistance

		if lampMoving then
		    local x = getProperty('b-lamp-low.x')
		    x = x + lampSpeed * elapsed

		    if x >= lampEndX then
		         
		        awardHenchmenAchievementTick()
		        x = backLowStartX
		        lampMoving = false
		        lampCutsMinions = false
		        setProperty('b-lamp-low.alpha', 0)
		    end

		    setProperty('b-lamp-low.x', x)
		end

    
    setProperty('camFollow.x', lockX + offset)
    setProperty('camFollow.y', lockY)

    
    setProperty('backcar.x', 600 - offset * 0.4)
    setProperty('frontcar.x', 600 + offset * 0.8)

    setProperty('dad.x', dadBaseX + offset * 0.8)
    setProperty('boyfriend.x', bfBaseX + offset * 0.8)
    setProperty('ray.x', rayBaseX + offset * 0.8)
    setProperty('pee.x', peeBaseX + offset * 0.8)

    
    
    

    for i = 1,#minions do
        local m = minions[i]

        m.timer = m.timer - elapsed

        if m.state == 'walk' then
            m.walkOffset = m.walkOffset + (m.speed * m.direction * elapsed)

            if m.baseX + m.walkOffset < minionLeft then
                m.walkOffset = minionLeft - m.baseX
                m.direction = 1
            elseif m.baseX + m.walkOffset > minionRight then
                m.walkOffset = minionRight - m.baseX
                m.direction = -1
            end
        end

				if m.timer <= 0 then

				    if m.dead then

				        m.state = 'walk'
				        objectPlayAnimation(m.tag, 'dead-walk', true)
				        m.speed = math.random(700,900)
								m.baseY = 835

				    elseif m.state == 'idle' then

				        m.state = 'walk'
				        objectPlayAnimation(m.tag, 'walk', true)

				        m.direction = math.random(0,1) == 0 and -1 or 1
				        m.speed = math.random(180,300)

					else

					    m.state = 'idle'
					    objectPlayAnimation(m.tag, 'idle', true)
					    if idleOverlapTooLarge(i) then
					        m.state = 'walk'
					        objectPlayAnimation(m.tag, 'walk', true)
					    end

					end

				    m.timer = math.random(2,10)
				end

        if m.direction == 1 then
            setProperty(m.tag..'.flipX', true)
        else
            setProperty(m.tag..'.flipX', false)
        end

				if lampMoving and lampCutsMinions and not m.dead then
				    local lampX = getProperty('b-lamp-low.x')
				    local minionX = m.baseX + m.walkOffset - offset * 0.4

				    if math.abs(minionX - lampX) < 80 then
				        m.dead = true
				        m.state = 'walk'
				        m.speed = math.random(700,900)

								m.baseY = 835

				        objectPlayAnimation(m.tag, 'dead-walk', true)


								local half = deadHalfPool[nextDeadHalf]
								nextDeadHalf = nextDeadHalf % MINION_COUNT + 1
								local halfTag = half.tag

								local spawnX = m.baseX + m.walkOffset - offset * 0.4
								local spawnY = m.baseY - 150

								half.x = spawnX
								half.y = spawnY
								half.velX = -math.random(220,340)
								half.velY = -math.random(500,650)
								half.rotSpeed = -math.random(180,360)
								setProperty(halfTag .. '.x', spawnX)
								setProperty(halfTag .. '.y', spawnY)
								setProperty(halfTag .. '.angle', 0)
								setProperty(halfTag .. '.visible', true)

								
								setObjectOrder(halfTag, getObjectOrder('backcar') + 1)

								deadHalves[#deadHalves + 1] = half

								minionsCutThisPass = minionsCutThisPass + 1
								
								if minionsCutThisPass >= MINION_COUNT then recordHenchmenWipe() end
				    end
				end

				setProperty(m.tag..'.x', m.baseX + m.walkOffset - offset * 0.4)
        setProperty(m.tag..'.y', m.baseY)
    end

    
    
    

    for i = #deadHalves, 1, -1 do
        local h = deadHalves[i]

        h.velY = h.velY + h.gravity * elapsed

        h.x = h.x + h.velX * elapsed
        h.y = h.y + h.velY * elapsed

        setProperty(h.tag..'.x', h.x)
        setProperty(h.tag..'.y', h.y)

        setProperty(h.tag..'.angle',
            getProperty(h.tag..'.angle') + h.rotSpeed * elapsed)

		if h.y > 1500 then
			setProperty(h.tag .. '.visible', false)
			setProperty(h.tag .. '.x', -2000)
			setProperty(h.tag .. '.y', -2000)
			table.remove(deadHalves, i)
        end
    end
end


function onStepHit()
    local currentSong = string.lower(songName or '')
    if currentSong == 'high' and curStep == lampTriggerStep then
        lampMoving = true
        lampCutsMinions = true
		minionsCutThisPass = 0
		recordedHenchmenPass = false
        setProperty('b-lamp-low.x', backLowStartX)
        setProperty('b-lamp-low.alpha', 1)
    end
end
