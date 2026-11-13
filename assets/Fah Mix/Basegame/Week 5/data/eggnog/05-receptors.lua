
local startStep = 254
local endStep = 446
local pairStartStep = 640
local pairEndStep = 774
local pulseAngle = 25
local active = false
local sequenceIndex = 1
local pairSequenceIndex = 1
local pairSectionActive = false



local sequence = {
    {direction = 0, angle = -pulseAngle},
    {direction = 3, angle = pulseAngle},
    {direction = 2, angle = -pulseAngle},
    {direction = 1, angle = pulseAngle}
}

local function resetAllAngles()
    for i = 0, 7 do
        cancelTween('eggnogPulseOut' .. i)
        cancelTween('eggnogPulseBack' .. i)
        setPropertyFromGroup('strumLineNotes', i, 'angle', 0)
    end
end

local function updateActiveState()
    local singleSectionActive = curStep >= startStep and curStep < endStep
    pairSectionActive = curStep >= pairStartStep and curStep < pairEndStep
    local shouldBeActive = singleSectionActive or pairSectionActive

    if shouldBeActive and not active then
        active = true
        sequenceIndex = 1
        pairSequenceIndex = 1
        resetAllAngles()
    elseif not shouldBeActive and active then
        active = false
        resetAllAngles()
    end
end

function onStepHit()
    updateActiveState()
end

function onBeatHit()
    if not active then return end

    
    
    resetAllAngles()

    local tiltDuration = math.min((crochet / 1000) * 0.18, 0.09)

    local function pulseDirection(direction, angle)
        
        local opponentIndex = direction
        local playerIndex = direction + 4

        noteTweenAngle('eggnogPulseOut' .. opponentIndex, opponentIndex, angle, tiltDuration, 'quadOut')
        noteTweenAngle('eggnogPulseOut' .. playerIndex, playerIndex, angle, tiltDuration, 'quadOut')
    end

    if pairSectionActive then
        if pairSequenceIndex == 1 then
            
            pulseDirection(0, -pulseAngle)
            pulseDirection(3, pulseAngle)
        else
            
            pulseDirection(2, -pulseAngle)
            pulseDirection(1, pulseAngle)
        end

        pairSequenceIndex = pairSequenceIndex == 1 and 2 or 1
    else
        local pulse = sequence[sequenceIndex]
        pulseDirection(pulse.direction, pulse.angle)

        sequenceIndex = sequenceIndex + 1
        if sequenceIndex > #sequence then sequenceIndex = 1 end
    end
end

function onTweenCompleted(tag)
    local noteIndex = string.match(tag, '^eggnogPulseOut(%d+)$')
    if noteIndex == nil or not active then return end

    noteIndex = tonumber(noteIndex)
    noteTweenAngle('eggnogPulseBack' .. noteIndex, noteIndex, 0,
        (crochet / 1000) * 0.42, 'quadInOut')
end

function onDestroy()
    resetAllAngles()
end
