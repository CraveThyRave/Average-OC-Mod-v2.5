local ending = false

function onCreate()
    makeLuaSprite('picoEndingBlack', nil, 0, 0)
    makeGraphic('picoEndingBlack', screenWidth, screenHeight, '000000')
    setObjectCamera('picoEndingBlack', 'other')
    setScrollFactor('picoEndingBlack', 0, 0)
    setProperty('picoEndingBlack.alpha', 0)
    addLuaSprite('picoEndingBlack', true)
end

local function updateEnding()
    if not ending and curStep >= 1471 then
        ending = true
        setObjectOrder('picoEndingBlack', getProperty('members.length') - 1)
        doTweenAlpha('picoBlackFadeIn', 'picoEndingBlack', 1, 0.3, 'linear')
    end
end

function onStepHit()
    updateEnding()
end

function onUpdatePost(elapsed)
    updateEnding()
end

function onGameOverStart()
    ending = true
    cancelTween('picoBlackFadeIn')
    setProperty('picoEndingBlack.visible', false)
end
