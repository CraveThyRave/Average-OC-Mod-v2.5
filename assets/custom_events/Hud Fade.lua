local hudFade = 1
local targetHudFade = 1
local hudFadeSpeed = 0

function onEvent(name, value1, value2)

    if name == 'Hud Fade' then

        
        
        

        local duration = tonumber(value1) or 0

        
        
        

        targetHudFade = tonumber(value2) or 1

        
        
        

        if duration <= 0 then

            hudFade = targetHudFade
            setProperty('camHUD.alpha', hudFade)

        
        
        

        else

            hudFadeSpeed =
                math.abs(targetHudFade - hudFade) / duration
        end
    end
end

function onUpdate(elapsed)

    
    
    

    if hudFade ~= targetHudFade then

        hudFade = hudFade + (
            (targetHudFade - hudFade)
            * math.min(elapsed * 8, 1)
        )

        
        
        

        if math.abs(targetHudFade - hudFade) < 0.01 then
            hudFade = targetHudFade
        end

        setProperty('camHUD.alpha', hudFade)
    end
end
