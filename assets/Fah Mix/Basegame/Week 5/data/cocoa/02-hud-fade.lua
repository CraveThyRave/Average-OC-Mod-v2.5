function onUpdatePost(elapsed)
    if curDecStep >= 1149 then
        setProperty('camHUD.alpha', math.max(0, 1 - (curDecStep - 1149) / 10))
    end
end
