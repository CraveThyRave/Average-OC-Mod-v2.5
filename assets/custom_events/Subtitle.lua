local fullDialogue = ''
local currentDialogue = ''

local barHeight = 50
local padding = 50

local function getSubtitlePositions()

    local hpBarY = getProperty('healthBar.y')
    local hpBarHeight = getProperty('healthBar.height')

    local barY
    local textY

    if downscroll then
        
        barY = hpBarY + hpBarHeight + 80
        textY = barY + 8
    else
        
        barY = hpBarY - barHeight - 90
        textY = barY + 8
    end

    return barY, textY
end

function onCreatePost()

    local barY, textY = getSubtitlePositions()

    
    
    

    makeLuaSprite('subtitleBar', nil, 0, barY)
    makeGraphic('subtitleBar', 100, barHeight, 'FFFFFF')
    setObjectCamera('subtitleBar', 'other')
    setProperty('subtitleBar.alpha', 0)
    addLuaSprite('subtitleBar', true)

    runHaxeCode([[
        game.getLuaObject("subtitleBar").color = 0xFF000000;
    ]])

    
    
    

    makeLuaText('subtitleOutline', '', 0, 0, textY)
    setObjectCamera('subtitleOutline', 'other')
    setTextFont('subtitleOutline', 'vcr.ttf')
    setTextSize('subtitleOutline', 31)
    setTextBorder('subtitleOutline', 2, '000000')
    setProperty('subtitleOutline.alpha', 0)
    addLuaText('subtitleOutline')

    runHaxeCode([[
        var txt = game.getLuaObject("subtitleOutline");
        txt.color = 0xFFFFFFFF;
        txt.borderColor = 0xFF000000;
    ]])

    
    
    

    makeLuaText('subtitleText', '', 0, 0, textY)
    setObjectCamera('subtitleText', 'other')
    setTextFont('subtitleText', 'vcr.ttf')
    setTextSize('subtitleText', 31)
    setProperty('subtitleText.alpha', 0)
    addLuaText('subtitleText')

    runHaxeCode([[
        game.getLuaObject("subtitleText").color = 0xFF8e2d3e;
    ]])
end

function onEvent(name, value1, value2)

    if name ~= 'Subtitle' then
        return
    end

    
    
    

    if value1 == 'false' then

        doTweenAlpha('subBarOutA', 'subtitleBar', 0, 0.3, 'quadIn')
        doTweenAlpha('subTxtOutA', 'subtitleText', 0, 0.3, 'quadIn')
        doTweenAlpha('subOutOutA', 'subtitleOutline', 0, 0.3, 'quadIn')

        doTweenY('subBarOutY','subtitleBar',getProperty('subtitleBar.y') + 10,0.3,'quadIn')
        doTweenY('subTxtOutY','subtitleText',getProperty('subtitleText.y') + 10,0.3,'quadIn')
        doTweenY('subOutOutY','subtitleOutline',getProperty('subtitleOutline.y') + 10,0.3,'quadIn')

        return
    end

    
    
    

    local split = stringSplit(value1, ',')

    if split[1] == 'true' then

        fullDialogue = ''

        for i = 2, #split do
            if i == 2 then
                fullDialogue = split[i]
            else
                fullDialogue = fullDialogue .. ',' .. split[i]
            end
        end

        currentDialogue = ''

        
        
        

        setTextString('subtitleText', fullDialogue)

        local width = getProperty('subtitleText.width') + padding

        if width < 100 then
            width = 100
        end

        makeGraphic(
            'subtitleBar',
            math.floor(width),
            barHeight,
            'FFFFFF'
        )

        runHaxeCode([[
            game.getLuaObject("subtitleBar").color = 0xFF000000;
        ]])

        local centerX = (screenWidth - width) / 2

        setProperty('subtitleBar.x', centerX)

        
        
        

        setTextString('subtitleText', '')
        setTextString('subtitleOutline', '')

        
        
        

        setProperty('subtitleText.x', screenWidth / 2)
        setProperty('subtitleOutline.x', screenWidth / 2)

        
        
        

        local barY, textY = getSubtitlePositions()

        setProperty('subtitleBar.y', barY + 10)
        setProperty('subtitleText.y', textY + 10)
        setProperty('subtitleOutline.y', textY + 10)

        setProperty('subtitleBar.alpha', 0)
        setProperty('subtitleText.alpha', 0)
        setProperty('subtitleOutline.alpha', 0)

        
        
        

        doTweenY('subBarInY','subtitleBar',barY,0.3,'quadOut')
        doTweenAlpha('subBarInA','subtitleBar',1,0.3,'quadOut')

        doTweenY('subTxtInY','subtitleText',textY,0.3,'quadOut')
        doTweenY('subOutInY','subtitleOutline',textY,0.3,'quadOut')

        doTweenAlpha('subTxtInA','subtitleText',1,0.3,'quadOut')
        doTweenAlpha('subOutInA','subtitleOutline',1,0.3,'quadOut')

        return
    end

    
    
    

    if value1 == 'add' then

        if string.sub(value2,1,1) == '(' and string.sub(value2,-1) == ')' then
            value2 = string.sub(value2,2,#value2-1)
        end

        if currentDialogue == '' then
            currentDialogue = value2
        else
            currentDialogue = currentDialogue .. ' ' .. value2
        end

        doTweenAlpha('wordFade','subtitleText',0,0.15,'quadIn')
        doTweenAlpha('wordFade2','subtitleOutline',0,0.15,'quadIn')

        runTimer('subtitleUpdate', 0.15)
    end
end

function onTimerCompleted(tag)

    if tag == 'subtitleUpdate' then

        setTextString('subtitleText', currentDialogue)
        setTextString('subtitleOutline', currentDialogue)

        runHaxeCode([[
            game.getLuaObject("subtitleText").color = 0xFF8e2d3e;

            var txt = game.getLuaObject("subtitleOutline");
            txt.color = 0xFFFFFFFF;
            txt.borderColor = 0xFF000000;
        ]])

        local textWidth = getProperty('subtitleText.width')
        local centerX = (screenWidth - textWidth) / 2

        setProperty('subtitleText.x', centerX)
        setProperty('subtitleOutline.x', centerX)

        local _, textY = getSubtitlePositions()

        setProperty('subtitleText.y', textY + 10)
        setProperty('subtitleOutline.y', textY + 10)

        doTweenY('wordMove','subtitleText',textY,0.15,'quadOut')
        doTweenY('wordMove2','subtitleOutline',textY,0.15,'quadOut')

        doTweenAlpha('wordShow','subtitleText',1,0.15,'quadOut')
        doTweenAlpha('wordShow2','subtitleOutline',1,0.15,'quadOut')
    end
end

function stringSplit(str, sep)

    local result = {}

    for part in string.gmatch(
        str,
        '([^' .. sep .. ']+)'
    ) do
        table.insert(result, part)
    end

    return result
end
