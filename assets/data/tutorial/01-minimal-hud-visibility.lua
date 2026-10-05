
function onCreatePost()
    
    setProperty('healthBar.visible', false)
    setProperty('healthBarBG.visible', false)
    if luaSpriteExists('bar-outline') then
        setProperty('bar-outline.visible', false)
    end
    if luaSpriteExists('aomFahDadBarFill') then
        setProperty('aomFahDadBarFill.visible', false)
    end
    if luaSpriteExists('aomFahBfBarFill') then
        setProperty('aomFahBfBarFill.visible', false)
    end
    if luaSpriteExists('bar-inline') then
        setProperty('bar-inline.visible', false)
    end

    
    setProperty('iconP1.visible', false)
    setProperty('iconP2.visible', false)
    setProperty('scoreTxt.visible', true)

    
    setProperty('timeBar.visible', false)
    setProperty('timeBarBG.visible', false)

    
    setProperty('timeTxt.visible', true)
end
