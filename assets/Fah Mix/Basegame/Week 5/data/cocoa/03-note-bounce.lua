local baseY = nil

function onUpdatePost(elapsed)
    if curDecStep >= 128 and curDecStep < 256 then
        if baseY == nil then
            baseY = {}
            for i = 0, getProperty('strumLineNotes.length') - 1 do
                baseY[i] = getPropertyFromGroup('strumLineNotes', i, 'y')
            end
        end
        local phase = (curDecStep - 128) % 8
        local offset = phase < 4 and math.sin(phase / 4 * math.pi) * 24 or 0
        for i, y in pairs(baseY) do
            setPropertyFromGroup('strumLineNotes', i, 'y', y + offset)
        end
    elseif baseY ~= nil then
        for i, y in pairs(baseY) do
            setPropertyFromGroup('strumLineNotes', i, 'y', y)
        end
        baseY = nil
    end
end
