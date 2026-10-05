
local lockX = 1700
local lockY = 1000


function onCreate()

	makeAnimatedLuaSprite('paper', 'Freeplay-Chrs/fah/BG', 50, 50)
	addAnimationByPrefix('paper', 'idle', 'BG idle', 3, true)
	addLuaSprite('paper', false)
	scaleObject('paper', 1.5, 1.5);

	makeAnimatedLuaSprite('brick', 'fahmix/week1/brick-dad-fah', 1000, 400)
	addAnimationByPrefix('brick', 'idle', 'brick-dad-fah idle', 6, true)
	addLuaSprite('brick', false)
	scaleObject('brick', 1.1, 1.1);



	makeAnimatedLuaSprite('floor', 'fahmix/week1/stage-dad-fah', 600, 1200)
	addAnimationByPrefix('floor', 'idle', 'stage-dad-fah idle', 6, true)
	addLuaSprite('floor', false)
	scaleObject('floor', 1.1, 1.1);
	setProperty('floor.flipY', true)

	makeAnimatedLuaSprite('ray', 'Freeplay-Chrs/fah/ray', 900, 500)
	addAnimationByPrefix('ray', 'idle', 'ray idle', 6, true)
	addLuaSprite('ray', false)
	scaleObject('ray', 1.1, 1.1);

	makeAnimatedLuaSprite('pee', 'Freeplay-Chrs/fah/pee', 900, 500)
	addAnimationByPrefix('pee', 'idle', 'pee idle', 6, true)
	addLuaSprite('pee', false)
	scaleObject('pee', 1.1, 1.1);


	makeLuaSprite('darkOverlay', 'dablack', 750, 400)
	addLuaSprite('darkOverlay', false)
	setObjectCamera('darkOverlay', 'camGame')
	setProperty('darkOverlay.alpha', 0)
	scaleObject('darkOverlay', 1.1, 1.1);


	makeAnimatedLuaSprite('spotlight', 'fahmix/week1/spotlight-dad-fah', 2100, 350)
	addAnimationByPrefix('spotlight', 'idle', 'spotlight-dad-fah idle', 6, true)
	addLuaSprite('spotlight', true)
	scaleObject('spotlight', 1.1, 1.1);

	makeAnimatedLuaSprite('spotlight2', 'fahmix/week1/spotlight-dad-fah', 1000, 350)
	addAnimationByPrefix('spotlight2', 'idle', 'spotlight-dad-fah idle', 6, true)
	addLuaSprite('spotlight2', true)
	scaleObject('spotlight2', 1.1, 1.1);
	setProperty('spotlight2.flipX', true)


	makeAnimatedLuaSprite('frontCurtain', 'fahmix/week1/curtain-dad-fah', 450, 200)
	addAnimationByPrefix('frontCurtain', 'idle', 'curtain-dad-fah idle', 6, true)
	addLuaSprite('frontCurtain', true)
	scaleObject('frontCurtain', 1.1, 1.1);
end


function onCreatePost()
    setProperty('isCameraOnForcedPos', true)
    setProperty('camFollow.x', lockX)
    setProperty('camFollow.y', lockY)
    setProperty('camFollowPos.x', lockX)
    setProperty('camFollowPos.y', lockY)
end
