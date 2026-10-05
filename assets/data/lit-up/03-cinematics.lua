local opened = false
local closed = false

function onCreate()
    addLuaScript('custom_events/Cinematics (Fah)')
end

local function updateBars()
    if not opened and luaSpriteExists('Upperbar') and luaSpriteExists('LowerBar') then
        opened = true
        local upperY = getProperty('Upperbar.y') + 240
        local lowerY = getProperty('LowerBar.y') - 240
        triggerEvent('Cinematics (Fah)', '0', '240')
        cancelTween('FahCinematicUpper')
        cancelTween('FahCinematicLower')
        setProperty('Upperbar.y', upperY)
        setProperty('LowerBar.y', lowerY)
    end
    if opened and not closed and curStep >= 128 then
        closed = true
        triggerEvent('Cinematics (Fah)', '0.7', '0')
    end
end

function onUpdatePost(elapsed)
    updateBars()
end

function onStepHit()
    updateBars()
end