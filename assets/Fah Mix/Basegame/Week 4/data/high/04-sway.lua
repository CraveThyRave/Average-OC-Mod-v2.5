

local SWAY_DISTANCE = 40
local SWAY_SPEED = 1.35

function onUpdatePost()
    if inGameOver then return end

    local offset = math.sin(getSongPosition() / 1000 * SWAY_SPEED) * SWAY_DISTANCE
    for lane = 0, 3 do
        setPropertyFromGroup('opponentStrums', lane, 'songOffsetX', offset)
    end
end
