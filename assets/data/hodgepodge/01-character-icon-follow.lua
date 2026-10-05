

local sprites = {

    'sans',
    'monika',
    'sonic',
    'spamton',
    'freddy',
    'crash',
    'kirby',
    'knuckles',
    'mario',
    'reddit',
    'madelyn',
    'steve',
    'reimu',
    'isaac',
    'bendy',
    'inkling',
    'peppino',
    'pikachu'

}

local DEFAULT_X = 800
local DEFAULT_Y = 620



local TWEEN_TIME = 0.1
local EASE = 'quadOut'


local charPositions = {

    

    ['raven-active'] = {

        idle = {800, 620},
        left = {660, 620},
        down = {800, 720},
        up = {800, 520},
        right = {960, 620}
    },

    ['raven-super-active'] = {

        idle = {800, 620},
        left = {660, 620},
        down = {800, 720},
        up = {800, 520},
        right = {960, 620}
    },

    ['raven-glitch'] = {

        idle = {800, 620},
        left = {660, 620},
        down = {800, 720},
        up = {800, 520},
        right = {960, 620}
    },


    ['raven-active-annoyrf'] = {

        idle = {800, 620},
        left = {660, 620},
        down = {800, 720},
        up = {800, 520},
        right = {960, 620}
    },

    

    ['raven'] = {

        idle = {780, 630},
        left = {670, 620},
        down = {810, 720},
        up = {780, 570},
        right = {900, 620}
    }
}



local currentAnim = 'idle'
local lastTargetX = nil
local lastTargetY = nil



local extraOffsetX = 0
local extraOffsetY = 0



function onUpdate(elapsed)
    if lowQuality then
        local targetX = DEFAULT_X + extraOffsetX
        local targetY = DEFAULT_Y + extraOffsetY
        if targetX == lastTargetX and targetY == lastTargetY then return end
        lastTargetX = targetX
        lastTargetY = targetY
        updateHodgepodgeIconFollowers(targetX, targetY, TWEEN_TIME, false)
        return
    end

    local charName = dadName

    local targetX = DEFAULT_X + extraOffsetX
    local targetY = DEFAULT_Y + extraOffsetY

    

    local data = charPositions[charName]

    if data ~= nil then

        local animData = data[currentAnim]

        if animData ~= nil then

            targetX = animData[1] + extraOffsetX
            targetY = animData[2] + extraOffsetY
        end
    end

    
    
    if targetX == lastTargetX and targetY == lastTargetY then
        return
    end
    lastTargetX = targetX
    lastTargetY = targetY

    

    updateHodgepodgeIconFollowers(targetX, targetY, TWEEN_TIME, true)
end



function opponentNoteHit(id, direction, noteType, isSustainNote)
    if lowQuality then return end

    if direction == 0 then

        currentAnim = 'left'

    elseif direction == 1 then

        currentAnim = 'down'

    elseif direction == 2 then

        currentAnim = 'up'

    elseif direction == 3 then

        currentAnim = 'right'
    end
end



function onUpdatePost()
    if lowQuality then return end

    local anim = getProperty('dad.animation.curAnim.name')

    


    if type(anim) == 'string' and (string.find(anim, 'idle')
    or string.find(anim, 'dance')) then

        currentAnim = 'idle'
    end
end


function setFollowOffset(x, y)

    extraOffsetX = x
    extraOffsetY = y
end

function resetFollowOffset()

    extraOffsetX = 0
    extraOffsetY = 0
end
