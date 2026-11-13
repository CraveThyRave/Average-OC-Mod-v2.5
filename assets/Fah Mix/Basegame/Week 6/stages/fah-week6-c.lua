local paintAnimation = 'dad'
local inGameOver = false

function onCreate()
    makeLuaSprite('white', 'dablack', -screenWidth, -screenHeight)
    scaleObject('white', screenWidth * 3 / getProperty('white.width'), screenHeight * 3 / getProperty('white.height'))
    setScrollFactor('white', 0, 0)
    addLuaSprite('white', false)

    makeAnimatedLuaSprite('school', 'fahmix/week6/spirit-school', 500, 300)
    addAnimationByPrefix('school', 'idle', 'idle', 4, true)
    scaleObject('school', 1.2, 1.2)
    setProperty('school.antialiasing', false)
    addLuaSprite('school', false)
    objectPlayAnimation('school', 'idle', true)

    makeAnimatedLuaSprite('trees', 'fahmix/week6/spirit-trees', 530, 500)
    addAnimationByPrefix('trees', 'idle', 'idle', 4, true)
    scaleObject('trees', 0.9, 0.9)
    setProperty('trees.antialiasing', false)
    addLuaSprite('trees', true)
    objectPlayAnimation('trees', 'idle', true)

    makeAnimatedLuaSprite('paint', 'fahmix/week6/MSPaint-spirit', 0, 0)
    addAnimationByPrefix('paint', 'dad', 'MSPaint dad', 4, true)
    addAnimationByPrefix('paint', 'bf', 'MSPaint bf', 4, true)
    addLuaSprite('paint', true)
    setObjectCamera('paint', 'other')
    setProperty('paint.antialiasing', false)
    objectPlayAnimation('paint', paintAnimation, true)
end

function onCreatePost()
    setProperty('isCameraOnForcedPos', true)
    setProperty('camFollow.x', 1700)
    setProperty('camFollow.y', 1200)
    setProperty('camFollowPos.x', 1700)
    setProperty('camFollowPos.y', 1200)
end

function onSectionHit()
    if inGameOver then return end
    local nextAnimation = mustHitSection and 'bf' or 'dad'
    if nextAnimation == paintAnimation then return end
    paintAnimation = nextAnimation
    objectPlayAnimation('paint', paintAnimation, true)
end

function onGameOverStart()
    inGameOver = true
end
