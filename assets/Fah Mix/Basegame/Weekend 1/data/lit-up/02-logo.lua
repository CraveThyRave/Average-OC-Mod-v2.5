local shown = false
local leaving = false
local enabled = true

function onCreate()
    makeLuaSprite('logo', 'fahmix/weekend1/lit-up-logo', 320, -570)
    setProperty('logo.flipX', getPropertyFromClass('MirrorMode', 'active'))
    scaleObject('logo', 0.4, 0.4)
    setObjectCamera('logo', 'other')
    addLuaSprite('logo', false)
end

local function updateLogo()
    if not enabled then return end
    if curStep >= 672 and not shown then
        shown = true
        removeLuaSprite('logo', false)
        addLuaSprite('logo', true)
        doTweenY('litUpLogoIn', 'logo', (screenHeight - getProperty('logo.height')) * 0.5, 1, 'quartOut')
    end
    if curStep >= 704 and not leaving then
        leaving = true
        doTweenX('litUpLogoScaleXOut', 'logo.scale', 0, 0.4, 'quintIn')
        doTweenY('litUpLogoScaleYOut', 'logo.scale', 0, 0.4, 'quintIn')
    end
end

function onStepHit()
    updateLogo()
end

function onUpdatePost(elapsed)
    updateLogo()
end

function onGameOverStart()
    enabled = false
    if luaSpriteExists('logo') then setProperty('logo.visible', false) end
end