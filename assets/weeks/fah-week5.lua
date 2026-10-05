
local lockX = 1700
local lockY = 1000


local cocoaThrowStep = 115 

local throwLollyDelay = 0.1   
local throwEndDelay = 0.3     

local cocoaSong = false
local lollyFlying = false

function onCreate()

	cocoaSong = songName == 'Cocoa'


	makeAnimatedLuaSprite('paper', 'Freeplay-Chrs/fah/BG', 50, 50)
	addAnimationByPrefix('paper', 'idle', 'BG idle', 3, true)
	addLuaSprite('paper', false)
	scaleObject('paper', 1, 1);

	makeAnimatedLuaSprite('bg-merry', 'fahmix/week5/bg-merry', 80, -200)
	addAnimationByPrefix('bg-merry', 'idle', 'idle', 6, true)
	addLuaSprite('bg-merry', false)
	scaleObject('bg-merry', 1.1, 1.1);

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

end


function onCreatePost()
    setProperty('isCameraOnForcedPos', true)
    setProperty('camFollow.x', lockX)
    setProperty('camFollow.y', lockY)

end

function onStepHit()

	if curStep == cocoaThrowStep then
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
