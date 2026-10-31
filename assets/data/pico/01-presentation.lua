local enabled = false
local started = false
local shrinking = false
local finished = false
local startsAt = 0

local function stopLogo()
    finished = true
    cancelTween('picoLogoDrop')
    cancelTween('picoLogoShrinkX')
    cancelTween('picoLogoShrinkY')
    if luaSpriteExists('picoLogo') then setProperty('picoLogo.visible', false) end
end

function onCreate()
    enabled = not getPropertyFromClass('MirrorMode', 'active')
    if not enabled then return end
    makeLuaSprite('picoLogo', 'fahmix/week3/pico-logo', 0, 0)
    scaleObject('picoLogo', 0.4, 0.4)
    setProperty('picoLogo.x', (screenWidth - getProperty('picoLogo.width')) * 0.5)
    setProperty('picoLogo.y', -getProperty('picoLogo.height') - 30)
    setProperty('picoLogo.visible', false)
    setObjectCamera('picoLogo', 'other')
    addLuaSprite('picoLogo', true)
end

function onCreatePost()
    if enabled then startsAt = runHaxeCode('return Conductor.beatToSeconds(48);') end
end

local function updateLogo()
    if not enabled or finished or curStep < 192 then return end
    local elapsed = getSongPosition() - startsAt
    if elapsed < 0 then return end
    if elapsed >= 6000 then stopLogo() return end
    if not started then
        started = true
        setProperty('picoLogo.visible', true)
        doTweenY('picoLogoDrop', 'picoLogo', (screenHeight - getProperty('picoLogo.height')) * 0.5, 1, 'quartOut')
    end
    if elapsed >= 5600 and not shrinking then
        shrinking = true
        local duration = math.max(0.01, (6000 - elapsed) / 1000)
        doTweenX('picoLogoShrinkX', 'picoLogo.scale', 0, duration, 'quintIn')
        doTweenY('picoLogoShrinkY', 'picoLogo.scale', 0, duration, 'quintIn')
    end
end

function onStepHit()
    updateLogo()
end

function onUpdatePost(elapsed)
    updateLogo()
end

function onGameOverStart()
    stopLogo()
end

function onEndSong()
    stopLogo()
end

function onDestroy()
    stopLogo()
end
