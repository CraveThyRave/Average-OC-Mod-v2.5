
local defaultX = {}
local defaultY = {}

function onCreatePost()
    for i = 4,7 do
        defaultX[i] = getPropertyFromGroup('strumLineNotes', i, 'x')
        defaultY[i] = getPropertyFromGroup('strumLineNotes', i, 'y')
    end
end

