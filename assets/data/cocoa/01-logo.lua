local stopped = false

function onCreate()
    makeLuaSprite('cocoaLogo', 'fahmix/week5/cocoa-logo', 320, -700)
    setProperty('cocoaLogo.flipX', getPropertyFromClass('MirrorMode', 'active'))
    scaleObject('cocoaLogo', 0.47, 0.47)
    setObjectCamera('cocoaLogo', 'other')
    addLuaSprite('cocoaLogo', false)
end

function onStepHit()
    if stopped then return end
    if curStep == 128 then
        doTweenY('cocoaLogoEntrance', 'cocoaLogo', (screenHeight - getProperty('cocoaLogo.height')) * 0.5, 1, 'quartOut')
    elseif curStep == 159 then
        doTweenX('cocoaLogoExitX', 'cocoaLogo.scale', 0, 0.4, 'quintIn')
        doTweenY('cocoaLogoExitY', 'cocoaLogo.scale', 0, 0.4, 'quintIn')
    end
end

function onGameOverStart()
    stopped = true
    cancelTween('cocoaLogoEntrance')
    cancelTween('cocoaLogoExitX')
    cancelTween('cocoaLogoExitY')
    setProperty('cocoaLogo.visible', false)
end