
local lockEndHudZoom = false

function onStepHit()
    if curStep == 912 then
        doTweenZoom('dadbattleHudZoom912', 'camHUD', 2.5, 0.5, 'quadInOut')
    end
end

function onTweenCompleted(tag)
    if tag == 'dadbattleHudZoom912' then
        lockEndHudZoom = true
        setProperty('camHUD.zoom', 2.5)
    end
end

function onUpdatePost()
    if lockEndHudZoom then
        setProperty('camHUD.zoom', 2.5)
    end
end
