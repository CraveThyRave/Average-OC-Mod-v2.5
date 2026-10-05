

HudAssets = {''}
Index = 1
local barsClosing = false

local function setBarsVisible(visible)
    setProperty('Upperbar.visible', visible)
    setProperty('LowerBar.visible', visible)
end

local function placeBarsUnderNotes()
    setObjectCamera('Upperbar', 'hud')
    setObjectCamera('LowerBar', 'hud')

    local noteOrder = math.min(
        getObjectOrder('notes'),
        getObjectOrder('strumLineNotes')
    )

    if getObjectOrder('Upperbar') >= noteOrder then
        setObjectOrder('Upperbar', noteOrder)
    end

    noteOrder = math.min(
        getObjectOrder('notes'),
        getObjectOrder('strumLineNotes')
    )

    if getObjectOrder('LowerBar') >= noteOrder then
        setObjectOrder('LowerBar', noteOrder)
    end
end

function onCreatePost()

    makeAnimatedLuaSprite('Upperbar', 'Freeplay-Chrs/fah/eventstuff/bars', -100, -500)
    addAnimationByPrefix('Upperbar', 'idle', 'bars idle', 3, true)
    setObjectCamera('Upperbar', 'hud')
    addLuaSprite('Upperbar', false)
    scaleObject('Upperbar', 1.5, 1.5)

    makeAnimatedLuaSprite('LowerBar', 'Freeplay-Chrs/fah/eventstuff/bars', -100, 780)
    addAnimationByPrefix('LowerBar', 'idle', 'bars idle', 3, true)
    setObjectCamera('LowerBar', 'hud')
    addLuaSprite('LowerBar', false)
    scaleObject('LowerBar', 1.5, 1.5)
    setProperty('LowerBar.flipY', true)
    placeBarsUnderNotes()
    setBarsVisible(false)

    UpperBar = getProperty('Upperbar.y')
    LowerBar = getProperty('LowerBar.y')

    for Notes = 0,7 do
        StrumY = getPropertyFromGroup('strumLineNotes', Notes, 'y')
    end
end

function onEvent(name, value1, value2)
    if name == 'Cinematics (Fah)' then
        placeBarsUnderNotes()

        local Speed = tonumber(value1)
        local Distance = tonumber(value2)
        if not Speed or not Distance then return end




        if Speed and Distance > 0 then
            barsClosing = false
            setBarsVisible(true)

            doTweenY('FahCinematicUpper', 'Upperbar', UpperBar + Distance, Speed, 'QuadOut')
            doTweenY('FahCinematicLower', 'LowerBar', LowerBar - Distance, Speed, 'QuadOut')

            for Alphas = 1,8 do
                if HudAssets[Index] and HudAssets[Index] ~= '' then
                    doTweenAlpha('Alpha(Still Strum)'..Alphas, HudAssets[Index], 0, Speed - 0.1)
                end
                Index = Index + 1
                if Index > #HudAssets then
                    Index = 1
                end
            end
        end




        if downscroll and Speed and Distance > 0 then

            doTweenY('FahCinematicUpper', 'Upperbar', UpperBar + Distance, Speed, 'QuadOut')
            doTweenY('FahCinematicLower', 'LowerBar', LowerBar - Distance, Speed, 'QuadOut')

            for Alphas = 1,8 do
                if HudAssets[Index] and HudAssets[Index] ~= '' then
                    doTweenAlpha('Alpha(Still Strum)'..Alphas, HudAssets[Index], 0, Speed - 0.1)
                end
                Index = Index + 1
                if Index > #HudAssets then
                    Index = 1
                end
            end
        end




        if Distance <= 0 then
            barsClosing = true

            doTweenY('FahCinematicUpper', 'Upperbar', UpperBar, Speed, 'QuadIn')
            doTweenY('FahCinematicLower', 'LowerBar', LowerBar, Speed, 'QuadIn')

            for Alphas = 1,8 do
                if HudAssets[Index] and HudAssets[Index] ~= '' then
                    doTweenAlpha('Alpha(Still Strum)'..Alphas, HudAssets[Index], 1, Speed + 0.1)
                end
                Index = Index + 1
                if Index > #HudAssets then
                    Index = 1
                end
            end
        end
    end
end

function onTweenCompleted(tag)
    if barsClosing and (tag == 'FahCinematicUpper' or tag == 'FahCinematicLower') then
        barsClosing = false
        setBarsVisible(false)
    end
end
