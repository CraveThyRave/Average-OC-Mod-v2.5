local FIRST_START_STEP = 128
local FIRST_END_STEP = 256
local SECOND_START_STEP = 896
local SECOND_END_STEP = 1011
local SWAY_DISTANCE = 22
local SNAP_DURATION = 0.05
local RETURN_DURATION = 0.35

local movingRight = false
local currentOffset = 0
local targetOffset = 0
local tweenStartOffset = 0
local tweenElapsed = 0
local tweenDuration = 0

local function movePlayerStrums(offset, duration)
    tweenStartOffset = currentOffset
    targetOffset = offset
    tweenElapsed = 0
    tweenDuration = duration
end

function onUpdatePost(elapsed)
    if tweenElapsed < tweenDuration then
        tweenElapsed = math.min(tweenElapsed + elapsed, tweenDuration)
        local progress = tweenElapsed / tweenDuration
         
        currentOffset = tweenStartOffset + (targetOffset - tweenStartOffset)
            * (1 - (1 - progress) * (1 - progress))
    else
        currentOffset = targetOffset
    end

    for lane = 0, 3 do
        local defaultX = _G['defaultPlayerStrumX' .. lane]
        setPropertyFromGroup('playerStrums', lane, 'x', defaultX + currentOffset)
    end
end

function onStepHit()
    local swayActive = (curStep >= FIRST_START_STEP and curStep < FIRST_END_STEP)
        or (curStep >= SECOND_START_STEP and curStep < SECOND_END_STEP)

    if swayActive and curStep % 4 == 0 then
        movingRight = not movingRight
        movePlayerStrums(movingRight and SWAY_DISTANCE or -SWAY_DISTANCE, SNAP_DURATION)
    elseif curStep == FIRST_END_STEP or curStep == SECOND_END_STEP then
        movePlayerStrums(0, RETURN_DURATION)
    end
end
