local ending = false
local enabled = true

function onCreate()
    makeLuaSprite('litUpEndingBlack', nil, 0, 0)
    makeGraphic('litUpEndingBlack', screenWidth, screenHeight, '000000')
    setObjectCamera('litUpEndingBlack', 'other')
    setProperty('litUpEndingBlack.visible', false)
    addLuaSprite('litUpEndingBlack', true)
end

local function updateEnding()
    if not enabled or ending or curStep < 1276 then return end
    ending = true
    setProperty('litUpEndingBlack.visible', true)
    setObjectOrder('litUpEndingBlack', getProperty('members.length') - 1)
end

function onStepHit()
    updateEnding()
end

function onUpdatePost(elapsed)
    updateEnding()
end

function onGameOverStart()
    enabled = false
    if luaSpriteExists('litUpEndingBlack') then setProperty('litUpEndingBlack.visible', false) end
end