
local t = 0
local speed = 1.6
local spinSpeed = 400
local guitarScale = 0.4

local introDone = false
local exiting = false
local introStarted = false
local outroStarted = false

local introStep = 2336
local outroStep = 2592

local scaleEnabled = false

local points = {
    {x = 200, y = 700}, 
    {x = 1250, y = 700}, 
    {x = 2200, y = 700} 
}
local cycle = {1, 2, 2, 3, 3, 2, 2, 1}

function onCreate()
    makeLuaSprite(
        'guitar',
        'Freeplay-Chrs/gabriella/gabby/guitar',
        points[2].x,
        points[2].y - 700
    )

    addLuaSprite('guitar', false)

    scaleObject('guitar', guitarScale, guitarScale)
    setScrollFactor('guitar', 0.87, 0.87)

    setProperty('guitar.alpha', 0)
end

function onCreatePost()
    setObjectOrder('guitar', getObjectOrder('black1') + 1)
    setObjectOrder('guitar', getObjectOrder('checkerboard') + 1)
end

function startIntro()
    setProperty('guitar.alpha', 1)

    setProperty('guitar.x', points[2].x)
    setProperty('guitar.y', points[2].y - 700)

    doTweenY(
        'guitarIntro',
        'guitar',
        points[2].y,
        1,
        'bounceOut'
    )
end

function startOutro()
    exiting = true

    doTweenY(
        'guitarOutro',
        'guitar',
        getProperty('guitar.y') + 1000,
        1,
        'cubeIn'
    )

    doTweenAlpha(
        'guitarFade',
        'guitar',
        0,
        1,
        'linear'
    )
end

function onTweenCompleted(tag)
    if tag == 'guitarIntro' then
        introDone = true

        
        t = 1
    end
end

function onStepHit()

    if curStep >= introStep and not introStarted then
        introStarted = true
        startIntro()
    end

    if curStep >= outroStep and not outroStarted then
        outroStarted = true
        startOutro()
    end

end

function onUpdate(elapsed)

    
    setProperty(
        'guitar.angle',
        getProperty('guitar.angle') + elapsed * spinSpeed
    )

    
    if not introDone or exiting then
        return
    end

    t = t + elapsed * speed

    local seg = math.floor(t) % 4
    local progress = t - math.floor(t)

    local startIndex = cycle[seg * 2 + 1]
    local endIndex = cycle[seg * 2 + 2]

    
    if not scaleEnabled
    and startIndex == 2
    and endIndex == 3
    and progress > 0.98 then
        scaleEnabled = true
    end

    local startPos = points[startIndex]
    local endPos = points[endIndex]

    local x = startPos.x + (endPos.x - startPos.x) * progress

    local arcHeight = 150
    local y = startPos.y - math.sin(progress * math.pi) * arcHeight

    
    local currentScale = guitarScale

    if scaleEnabled then

        local scaleProgress = 0

        
        if endIndex == 2 then
            scaleProgress = progress

        
        elseif startIndex == 2 then
            scaleProgress = 1 - progress
        end

        currentScale =
            guitarScale *
            (1 + (1.34 - 1) * scaleProgress)

    end

    setProperty('guitar.scale.x', currentScale)
    setProperty('guitar.scale.y', currentScale)

    setProperty('guitar.x', x)
    setProperty('guitar.y', y)
end
