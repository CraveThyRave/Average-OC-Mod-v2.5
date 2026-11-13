local baseHeight = 0

function onCreate()
    setVar('hushLogoFall', 0)
    setVar('hushLogoScale', 1)
    setVar('hushLogoOpacity', 0)
    makeLuaSprite('hushUpLogo', 'Freeplay-Chrs/yoyai/logo', 0, 0)
    scaleObject('hushUpLogo', 0.47, 0.47)
    updateHitbox('hushUpLogo')
    baseHeight = getProperty('hushUpLogo.height')
    screenCenter('hushUpLogo')
    setProperty('hushUpLogo.flipX', getPropertyFromClass('MirrorMode', 'active'))
    setProperty('hushUpLogo.alpha', 0)
    setObjectCamera('hushUpLogo', 'other')
    addLuaSprite('hushUpLogo', false)
end

function onCreatePost()
    setObjectOrder('hushUpLogo', getObjectOrder('hushEndingCover') + 1)
end

function onUpdatePost(elapsed)
    local fall = getVar('hushLogoFall') or 0
    local scale = getVar('hushLogoScale') or 1
    setProperty('hushUpLogo.alpha', getVar('hushLogoOpacity') or 0)
    setProperty('hushUpLogo.scale.x', 0.47 * scale)
    setProperty('hushUpLogo.scale.y', 0.47 * scale)
    setProperty('hushUpLogo.y', -baseHeight + (screenHeight / 2 + baseHeight / 2) * fall)
end
