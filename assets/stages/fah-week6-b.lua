
local lockX = 1700
local lockY = 1200
local isSenpai = false
local crowdSuffix = '-sad'
local tallie2SpecialPrefix = 'cry'
local shortie2SpecialPrefix = 'hands'
local inGameOver = false

local specialAnims = {
    tallie = 'heave',
    tallie2 = 'heave',
    shortie = 'clap',
    shortie2 = 'clap'
}
local activeSpecials = {}
local specialFinishedProperties = {
    tallie = 'tallie.animation.curAnim.finished',
    tallie2 = 'tallie2.animation.curAnim.finished',
    shortie = 'shortie.animation.curAnim.finished',
    shortie2 = 'shortie2.animation.curAnim.finished'
}

local minWait = 2
local maxWait = 5
local chance = 50
local paintAnimation = 'dad'



function onCreate()
	 
	 
	local currentSong = string.lower(songPath or songName or ''):gsub('[%s_]+', '-')
	isSenpai = currentSong == 'senpai'
	crowdSuffix = isSenpai and '' or '-sad'
	tallie2SpecialPrefix = isSenpai and 'heave' or 'cry'
	shortie2SpecialPrefix = isSenpai and 'clap' or 'hands'

	makeLuaSprite('white', 'dawhite', 400, 200)
	addLuaSprite('white', false)
	scaleObject('white', 1.15, 1.15)


	makeAnimatedLuaSprite('school', 'fahmix/week6/school', 500, 300)
  addAnimationByPrefix('school', 'idle', 'idle', 4, true)
  scaleObject('school', 1.2, 1.2)
  setProperty('school.antialiasing', true)
  addLuaSprite('school', false)
  objectPlayAnimation('school', 'idle', true)



	makeAnimatedLuaSprite('tallie', 'fahmix/week6/tallie' .. crowdSuffix, 1000, 850)
	addAnimationByPrefix('tallie', 'idle', 'idle', 6, true)
	addAnimationByPrefix('tallie', 'heave', 'heave', 6, false)
	scaleObject('tallie', 0.8, 0.8)
	setProperty('tallie.antialiasing', true)
	addLuaSprite('tallie', false)
	objectPlayAnimation('tallie', 'idle', true)


	makeAnimatedLuaSprite('shortie', 'fahmix/week6/shortie' .. crowdSuffix, 1000, 850)
	addAnimationByPrefix('shortie', 'idle', 'idle', 6, true)
	addAnimationByPrefix('shortie', 'clap', 'clap', 6, false)
	scaleObject('shortie', 0.8, 0.8)
	setProperty('shortie.antialiasing', true)
	addLuaSprite('shortie', false)
	objectPlayAnimation('shortie', 'idle', true)



	makeAnimatedLuaSprite('tallie2', 'fahmix/week6/tallie' .. crowdSuffix, 1840, 850)
	addAnimationByPrefix('tallie2', 'idle', 'idle', 6, true)
	addAnimationByPrefix('tallie2', 'heave', tallie2SpecialPrefix, 6, false)
	scaleObject('tallie2', 0.8, 0.8)
	setProperty('tallie2.antialiasing', true)
	addLuaSprite('tallie2', false)
	objectPlayAnimation('tallie2', 'idle', true)
	setProperty('tallie2.flipX', true)


	makeAnimatedLuaSprite('shortie2', 'fahmix/week6/shortie' .. crowdSuffix, 1840, 850)
	addAnimationByPrefix('shortie2', 'idle', 'idle', 6, true)
	addAnimationByPrefix('shortie2', 'clap', shortie2SpecialPrefix, 6, false)
	scaleObject('shortie2', 0.8, 0.8)
	setProperty('shortie2.antialiasing', true)
	addLuaSprite('shortie2', false)
	objectPlayAnimation('shortie2', 'idle', true)
	setProperty('shortie2.flipX', true)






	makeAnimatedLuaSprite('ray', 'fahmix/week6/msray', 1380, 850)
	addAnimationByPrefix('ray', 'idle', 'idle', 4, true)
	scaleObject('ray', 1.07, 1.07)
	setProperty('ray.antialiasing', true)
	addLuaSprite('ray', false)
	objectPlayAnimation('ray', 'idle', true)

	makeAnimatedLuaSprite('pee', 'fahmix/week6/mspee', 1580, 850)
	addAnimationByPrefix('pee', 'idle', 'idle', 4, true)
	scaleObject('pee', 1.07, 1.07)
	setProperty('pee.antialiasing', true)
	addLuaSprite('pee', false)
	objectPlayAnimation('pee', 'idle', true)


  if not isSenpai then
    makeAnimatedLuaSprite('bag', 'fahmix/week6/bag', 1050, 1500)
    addAnimationByPrefix('bag', 'idle', 'idle', 4, true)
    scaleObject('bag', 0.9, 0.9)
    setProperty('bag.antialiasing', true)
    addLuaSprite('bag', true)
    objectPlayAnimation('bag', 'idle', true)
  end

	makeAnimatedLuaSprite('trees', 'fahmix/week6/trees', 530, 500)
	addAnimationByPrefix('trees', 'idle', 'idle', 4, true)
	scaleObject('trees', 0.9, 0.9)
	setProperty('trees.antialiasing', true)
	addLuaSprite('trees', true)
	objectPlayAnimation('trees', 'idle', true)




  makeAnimatedLuaSprite('paint', 'fahmix/week6/MSPaint', 0, 0)
  addAnimationByPrefix('paint', 'dad', 'MSPaint dad', 4, true)
  addAnimationByPrefix('paint', 'bf', 'MSPaint bf', 4, true)
  addLuaSprite('paint', true)
  setObjectCamera('paint', 'other')
  setProperty('paint.antialiasing', true)
  objectPlayAnimation('paint', 'dad', true)
	startRandomTimer('tallie')
	startRandomTimer('tallie2')
	startRandomTimer('shortie')
	startRandomTimer('shortie2')


end


function onCreatePost()
    setProperty('isCameraOnForcedPos', true)
    setProperty('camFollow.x', lockX)
    setProperty('camFollow.y', lockY)
    setProperty('camFollowPos.x', lockX)
    setProperty('camFollowPos.y', lockY)
end


function startRandomTimer(tag)
	if inGameOver then return end
    runTimer(tag .. '_random', getRandomFloat(minWait, maxWait))
end

function onTimerCompleted(tag)
	if inGameOver then return end
    if string.sub(tag, -7) == '_random' then
        local sprite = string.sub(tag, 1, -8)

        if math.random(100) <= chance then
            objectPlayAnimation(sprite, specialAnims[sprite], true)
            activeSpecials[sprite] = true
        else
            startRandomTimer(sprite)
        end
    end
end


function onUpdate(elapsed)
	if inGameOver then return end
    for tag in pairs(activeSpecials) do
        if getProperty(specialFinishedProperties[tag]) then
            activeSpecials[tag] = nil
            objectPlayAnimation(tag, 'idle', true)
            startRandomTimer(tag)
        end
    end
end

function onGameOverStart()
	inGameOver = true
	activeSpecials = {}
	for _, tag in ipairs({'tallie', 'tallie2', 'shortie', 'shortie2'}) do
		cancelTimer(tag .. '_random')
	end
end

 
 
 
function onSectionHit()
    local nextAnimation = mustHitSection and 'bf' or 'dad'
    if nextAnimation == paintAnimation then
        return
    end

    paintAnimation = nextAnimation
    objectPlayAnimation('paint', paintAnimation, true)
end
