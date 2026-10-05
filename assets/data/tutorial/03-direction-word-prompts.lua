
local arrowData = {
    left  = {x = 50,   y = 280, moveX = -50, moveY = 0,   path = 'fahmix/week0/left'},
    up    = {x = 560,  y = 50,  moveX = 0,   moveY = -50, path = 'fahmix/week0/up'},
    down  = {x = 560,  y = 520, moveX = 0,   moveY = 50,  path = 'fahmix/week0/down'},
    right = {x = 1060, y = 280, moveX = 50,  moveY = 0,   path = 'fahmix/week0/right'}
}


local events = {
    [64]  = "left",
    [71]  = "right",
    [80]  = "left",
    [88]  = "right",

    [127] = "up",
    [135] = "down",
    [144] = "up",
    [152] = "down",

    [192] = "left",
    [200] = "up",
    [208] = "down",
    [216] = "right",

    [256] = "down",
    [260] = "down",
    [263] = "up",

    [272] = "down",
    [276] = "down",
    [279] = "right",

    [319] = "down",
    [322] = "up",
    [324] = "right",
    [326] = "up",
    [331] = "right"
}


local messageSteps = {
    [246] = "I",
    [248] = "I think",
    [250] = "I think you",
    [252] = "I think you got",
    [255] = "I think you got it!"
}


local lastMessageStep = 255

local currentText = ""


local textBaseY = 0
local textMove = 50


local hideQueue = {}

function onCreate()

    
    for name, data in pairs(arrowData) do
        
        
        
        makeAnimatedLuaSprite(name, data.path, data.x, data.y)
        addAnimationByPrefix(name, 'idle', 'idle', 0, false)
        addLuaSprite(name, true)
        setObjectCamera(name, 'hud')
        scaleObject(name, 0.07, 0.07)
        setProperty(name .. '.alpha', 0)
    end

    
    makeLuaText('typeText', '', 1200, 0, 300)
    setTextAlignment('typeText', 'center')
    setTextFont('typeText', 'fah.ttf')
    setTextSize('typeText', 64)
    setObjectCamera('typeText', 'hud')
    screenCenter('typeText', 'xy')

    textBaseY = getProperty('typeText.y')

    setProperty('typeText.y', textBaseY + textMove)
    setProperty('typeText.alpha', 0)

    addLuaText('typeText')

end

function playArrow(name)
    local data = arrowData[name]

    cancelTween(name .. '_x')
    cancelTween(name .. '_y')
    cancelTween(name .. '_alpha')
    cancelTween(name .. '_returnX')
    cancelTween(name .. '_returnY')

    local moveTime = 0.3
    local life = 4

    if curStep >= 240 then
        moveTime = 0.15
        life = 2
    end

    setProperty(name .. '.alpha', 1)

    doTweenX(name .. '_x', name, data.x + data.moveX, moveTime, 'cubeOut')
    doTweenY(name .. '_y', name, data.y + data.moveY, moveTime, 'cubeOut')

    hideQueue[#hideQueue + 1] = {
        step = curStep + life,
        name = name
    }
end

function hideArrow(name)
    local data = arrowData[name]

    local returnTime = 0.2

    if curStep >= 240 then
        returnTime = 0.1
    end

    doTweenAlpha(name .. '_alpha', name, 0, 0.08, 'linear')
    doTweenX(name .. '_returnX', name, data.x, returnTime, 'cubeOut')
    doTweenY(name .. '_returnY', name, data.y, returnTime, 'cubeOut')
end

function onStepHit()

    
    local arrow = events[curStep]
    if arrow then
        playArrow(arrow)
    end

    
    for i = #hideQueue, 1, -1 do
        if hideQueue[i].step == curStep then
            hideArrow(hideQueue[i].name)
            table.remove(hideQueue, i)
        end
    end

		
    if messageSteps[curStep] then

        -- Set the authored phrase for this cue instead of appending. A repeated
        -- step callback must never duplicate a word in the subtitle.
        currentText = messageSteps[curStep]

        setTextString('typeText', currentText)
        screenCenter('typeText', 'x')

        
        cancelTween('textY')
        cancelTween('textHideY')
        cancelTween('textHideAlpha')

        setProperty('typeText.y', textBaseY + textMove)
        setProperty('typeText.alpha', 1)

        doTweenY('textY', 'typeText', textBaseY, 0.3, 'cubeOut')

        
        if curStep == lastMessageStep then
            runTimer('hideMessage', 1)
        end
    end

end

function onTimerCompleted(tag)
    if tag == 'hideMessage' then
        cancelTween('textY')
        cancelTween('textHideY')
        cancelTween('textHideAlpha')

        doTweenAlpha('textHideAlpha', 'typeText', 0, 0.3, 'linear')
        doTweenY('textHideY', 'typeText', textBaseY + textMove, 0.3, 'cubeIn')
    end
end


function onTweenCompleted(tag)
    if tag == 'textHideY' then
        currentText = ""
        setTextString('typeText', '')
        setProperty('typeText.y', textBaseY + textMove)
    end
end
