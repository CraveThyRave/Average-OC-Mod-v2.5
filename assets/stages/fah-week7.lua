

math.randomseed(os.time())
math.random()
math.random()
math.random()



local lockX = 1800
local lockY = 1100


local tankPasses = 0
local passTime = 10 

local steveWalking = false
local steveWalkLeft = false

local steveMoveTime = 15
local steveWalkStarted = 0
local steveBounce = {0, 2, 14, 15, 12, 0}
local steveAchievementAwarded = false


function onCreate()
	precacheSound('fail')


	makeAnimatedLuaSprite('paper', 'fahmix/week7/BG', 50, 50)
	addAnimationByPrefix('paper', 'idle', 'BG idle', 3, true)
	addLuaSprite('paper', false)
	scaleObject('paper', 1.5, 1.5);

	makeAnimatedLuaSprite('bg-tank', 'fahmix/week7/bg-tank', 300, 400)
	addAnimationByPrefix('bg-tank', 'idle', 'idle', 6, true)
	addLuaSprite('bg-tank', false)
	scaleObject('bg-tank', 1, 1);


	makeAnimatedLuaSprite('tank', 'fahmix/week7/tank', 300, 1200)
	addAnimationByPrefix('tank', 'idle', 'idle', 3, true)
	addLuaSprite('tank', false)
	scaleObject('tank', 1, 1);


	makeAnimatedLuaSprite('paper2', 'fahmix/week7/BG', 50, 1450)
	addAnimationByPrefix('paper2', 'idle', 'BG idle', 3, true)
	addLuaSprite('paper2', false)
	scaleObject('paper2', 1.5, 1.5);

	makeAnimatedLuaSprite('floor', 'fahmix/week7/floor', 600, 1230)
	addAnimationByPrefix('floor', 'idle', 'idle', 6, true)
	addLuaSprite('floor', false)
	scaleObject('floor', 0.94, 0.94);


	makeAnimatedLuaSprite('ray', 'fahmix/week7/ray', 1250, 875)
	addAnimationByPrefix('ray', 'idle', 'idle', 6, true)
	addLuaSprite('ray', false)
	scaleObject('ray', 1.1, 1.1);

	makeAnimatedLuaSprite('pee', 'fahmix/week7/pee', 1720, 875)
	addAnimationByPrefix('pee', 'idle', 'idle', 6, true)
	addLuaSprite('pee', false)
	scaleObject('pee', 1.15, 1.15);


	steveWalkLeft = string.lower(songName) == 'pews'
	makeAnimatedLuaSprite('steve', 'fahmix/week7/steve', steveWalkLeft and 3500 or -600, 0)
	setProperty('steve.flipX', steveWalkLeft)
	addAnimationByPrefix('steve', 'idle', 'idle', 6, true)
	addLuaSprite('steve', true)
	scaleObject('steve', 1.1, 1.1)
	anchorSpriteToScreenBottom('steve')
	setProperty('steve.visible', false)
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
        local minSteveTime = 10
        local maxSteveTime = math.max(songLength - steveMoveTime - 1, minSteveTime)
        local steveTime
        repeat
            steveTime = minSteveTime + math.random() * (maxSteveTime - minSteveTime)
        until math.abs(steveTime - time1) > (passTime + 2)
            and math.abs(steveTime - time2) > (passTime + 2)
        schedule = {tank1 = time1, tank2 = time2, steve = steveTime}
    end
    recordSceneValue('week7.schedule', schedule)
    runTimer('tankPass1', schedule.tank1 / playbackRate)
    runTimer('tankPass2', schedule.tank2 / playbackRate)
    runTimer('steveWalk', schedule.steve / playbackRate)
end

function startTankPass()
    tankPasses = tankPasses + 1


    setProperty('tank.x', 300)
    doTweenX('tankMove'..tankPasses, 'tank', 3100, passTime / playbackRate, 'linear')
end


function onTimerCompleted(tag)

    if tag == 'tankPass1' or tag == 'tankPass2' then
        startTankPass()

    elseif tag == 'steveWalk' then

        local zoom = math.min(getProperty('defaultCamZoom'), getProperty('camGame.zoom'))
        local halfView = screenWidth / (2 * zoom)
        local leftEdge = math.min(-450, lockX - halfView - getProperty('steve.width') - math.abs(getProperty('steve.offset.x')) - 100)
        local rightEdge = math.max(3500, lockX + halfView + math.abs(getProperty('steve.offset.x')) + 100)
        setProperty('steve.x', steveWalkLeft and rightEdge or leftEdge)
        setProperty('steve.visible', true)
        setProperty('steve.bottomAnchor.y', 0)
        playAnim('steve', 'idle', true, false, 1)
        steveWalkStarted = getSongPosition()
        steveWalking = true
        doTweenX('steveWalk', 'steve', steveWalkLeft and leftEdge or rightEdge, steveMoveTime / playbackRate, 'linear')
    end
end

function onUpdate(elapsed)

    if steveWalking then
        local phase = math.floor(math.max(0, getSongPosition() - steveWalkStarted) * 12 / 1000) % #steveBounce + 1
        setProperty('steve.bottomAnchor.y', steveBounce[phase] * 18 / 15)
		if not getPropertyFromClass('MirrorMode', 'active') and getVar('pewCursorDisabled') ~= true and mouseClicked('left') then
			if mouseOverlapsObjectPixels('steve', 'game', 1) then
				playSound('fail', 1, 'steveShootFail')
				setVar('pewCursorDisabled', true)
				setVar('pewCursorDisableRequested', true)
				if not steveAchievementAwarded then
					steveAchievementAwarded = true
					runHaxeCode([[game.unlockQueuedAchievement('Steve');]])
				end
			end
		end
    end

end

function onTweenCompleted(tag)
    if tag == 'steveWalk' then
        steveWalking = false
        setProperty('steve.bottomAnchor.y', 0)
        setProperty('steve.visible', false)
    end
end
