

local bfNoteTag = 'bfNoteSprite'
local dadNoteTag = 'dadNoteSprite'

local bfActive = false
local dadActive = false

local bfTime = 0
local dadTime = 0

local speed = 2.8 
local scale = 30

local visibleAlpha = 0.7

function onCreate()
    
    makeAnimatedLuaSprite(bfNoteTag, 'Freeplay-Chrs/fah/bf-note', 0, 0)
    addAnimationByPrefix(bfNoteTag, 'idle', 'bf-note idle', 4, true)
    addAnimationByPrefix(bfNoteTag, 'appear', 'bf-note appear', 8, false)
    setProperty(bfNoteTag..'.alpha', 0)
    addLuaSprite(bfNoteTag, true)

    
    makeAnimatedLuaSprite(dadNoteTag, 'Freeplay-Chrs/fah/fah-note', 0, 0)
    addAnimationByPrefix(dadNoteTag, 'idle', 'fah-note idle', 4, true)
    addAnimationByPrefix(dadNoteTag, 'appear', 'fah-note appear', 8, false)
    setProperty(dadNoteTag..'.alpha', 0)
    addLuaSprite(dadNoteTag, true)

end

function onEvent(name, value1, value2)
    if name == 'NoteSprites' then

        
        if value1 == 'on' then
            bfActive = true
            bfTime = 0

            setProperty(bfNoteTag..'.alpha', visibleAlpha)
            setProperty(bfNoteTag..'.x', getProperty('boyfriend.x') + 80)
            setProperty(bfNoteTag..'.y', getProperty('boyfriend.y') - 240)

            playAnim(bfNoteTag, 'appear', true)

        elseif value1 == 'off' then
            bfActive = false
            doTweenAlpha('bfFadeOut', bfNoteTag, 0, 0.4, 'linear')
        end

        
        if value2 == 'on' then
            dadActive = true
            dadTime = 0

            setProperty(dadNoteTag..'.alpha', visibleAlpha)
            setProperty(dadNoteTag..'.x', getProperty('dad.x') - 380)
            setProperty(dadNoteTag..'.y', getProperty('dad.y') - 200)

            playAnim(dadNoteTag, 'appear', true)

        elseif value2 == 'off' then
            dadActive = false
            doTweenAlpha('dadFadeOut', dadNoteTag, 0, 0.4, 'linear')
        end
    end
end

function onUpdate(elapsed)

    
    if bfActive then
        bfTime = bfTime + elapsed * speed

        local baseX = getProperty('boyfriend.x')
        local baseY = getProperty('boyfriend.y')

        local x = math.sin(bfTime) * scale
        local y = math.sin(bfTime * 2) * scale * 0.5

        setProperty(bfNoteTag..'.x', baseX + 80 + x)
        setProperty(bfNoteTag..'.y', baseY - 240 + y)
    end

    
    if dadActive then
        dadTime = dadTime + elapsed * speed

        local baseX = getProperty('dad.x')
        local baseY = getProperty('dad.y')

        local x = -math.sin(dadTime) * scale
        local y = -math.sin(dadTime * 2) * scale * 0.5

        setProperty(dadNoteTag..'.x', baseX - 380 + x)
        setProperty(dadNoteTag..'.y', baseY - 200 + y)
    end
end

function onAnimFinished(tag, anim)
    if tag == bfNoteTag and anim == 'appear' and bfActive then
        playAnim(bfNoteTag, 'idle', true)
    end

    if tag == dadNoteTag and anim == 'appear' and dadActive then
        playAnim(dadNoteTag, 'idle', true)
    end
end
