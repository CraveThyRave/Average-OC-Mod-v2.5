local entered = false
local exited = false

function onCreate()
    makeLuaSprite('logo', 'fahmix/week6/thorns-logo', 320, -550)
    scaleObject('logo', 0.6, 0.6)
    setObjectCamera('logo', 'other')
    setProperty('logo.flipX', getPropertyFromClass('MirrorMode', 'active'))
    setProperty('logo.antialiasing', false)
    setProperty('logo.visible', false)
    addLuaSprite('logo', false)
end

function onStepHit()
    if curStep >= 319 and not exited then
        exited = true
        if entered then
            cancelTween('thornsLogoEnter')
            doTweenX('thornsLogoExitX', 'logo.scale', 0, 0.4, 'quintIn')
            doTweenY('thornsLogoExitY', 'logo.scale', 0, 0.4, 'quintIn')
        end
    elseif curStep >= 288 and not entered and not exited then
        entered = true
        setProperty('logo.visible', true)
        doTweenY('thornsLogoEnter', 'logo', (screenHeight - getProperty('logo.height')) * 0.5, 1, 'quartOut')
    end
end

function onTweenCompleted(tag)
    if tag == 'thornsLogoExitY' then setProperty('logo.visible', false) end
end

function onGameOverStart()
    cancelTween('thornsLogoEnter')
    cancelTween('thornsLogoExitX')
    cancelTween('thornsLogoExitY')
    setProperty('logo.visible', false)
    exited = true
end

function onDestroy()
    cancelTween('thornsLogoEnter')
    cancelTween('thornsLogoExitX')
    cancelTween('thornsLogoExitY')
end
