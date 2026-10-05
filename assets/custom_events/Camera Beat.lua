local camBeat = false
local beatIntensity = 0.03
local beatDecay = 6

local beatZoom = 0
local lastBeatZoom = 0

function onEvent(name, value1, value2)

    if name == 'Camera Beat' then
        if getProperty('disableStandardHitEffects') then
            camBeat = false
            beatZoom = 0
            lastBeatZoom = 0
            return
        end

        if value1 == 'true' then
            camBeat = true

        elseif value1 == 'false' then
            camBeat = false
            beatZoom = 0
            lastBeatZoom = 0
        end

        if value2 ~= nil and value2 ~= '' then

            local intensity = tonumber(value2)

            if intensity then
                beatIntensity = intensity
            end
        end
    end
end

function onBeatHit()

    if camBeat and not getProperty('disableStandardHitEffects') then
        beatZoom = beatIntensity
    end
end

function onUpdate(elapsed)

    if camBeat and not getProperty('disableStandardHitEffects') then

        
        setProperty(
            'camGame.zoom',
            getProperty('camGame.zoom') - lastBeatZoom
        )

        
        beatZoom = lerp(beatZoom, 0, elapsed * beatDecay)

        
        setProperty(
            'camGame.zoom',
            getProperty('camGame.zoom') + beatZoom
        )

        
        lastBeatZoom = beatZoom
    end
end

function lerp(a, b, t)
    
    
    t = math.max(0, math.min(1, t))
    return a + (b - a) * t
end
