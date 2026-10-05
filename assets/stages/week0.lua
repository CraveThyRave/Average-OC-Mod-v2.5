local lockX = 1700
local lockY = 600


function onCreate()

	makeAnimatedLuaSprite('paper', 'Freeplay-Chrs/fah/BG', 50, 50)
	addAnimationByPrefix('paper', 'idle', 'BG idle', 3, true)
	addLuaSprite('paper', false)
	scaleObject('paper', 1.5, 1.5);



	makeAnimatedLuaSprite('clouds', 'Freeplay-Chrs/fah/clouds', 690, 50)
	addAnimationByPrefix('clouds', 'idle', 'clouds idle', 6, true)
	addLuaSprite('clouds', false)
	scaleObject('clouds', 1.3, 1);




	makeAnimatedLuaSprite('sun', 'Freeplay-Chrs/fah/sun', 690, 50)
	addAnimationByPrefix('sun', 'idle', 'sun idle', 6, true)
	addLuaSprite('sun', false)
	scaleObject('sun', 1, 1);



	makeAnimatedLuaSprite('floor', 'Freeplay-Chrs/fah/floor', 500, 710)
	addAnimationByPrefix('floor', 'idle', 'floor idle', 6, true)
	addLuaSprite('floor', false)
	scaleObject('floor', 1.5, 1.1);




end


function onCreatePost()
    setProperty('isCameraOnForcedPos', true)
    setProperty('camFollow.x', lockX)
    setProperty('camFollow.y', lockY)
    setProperty('camFollowPos.x', lockX)
    setProperty('camFollowPos.y', lockY)
end
