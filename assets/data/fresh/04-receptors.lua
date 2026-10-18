

local ACTIVE_RANGES = {
    {startStep = 319, endStep = 447},
    {startStep = 739, endStep = 831}
}
local OUTER_DISTANCE = 8
local OUT_DURATION = 0.08
local RETURN_DURATION = 0.12
local INNER_PULSE_SCALE = 1.13
local BEAT_TWO_ANGLES = {-9, -5, 5, 9}

local returnX = {}
local returnScale = {}
local returnAngle = {}

function onCreate()
    if lowQuality then
        close(true)
    end
end

local function pulseOuterLane(lane, distance)
    local member = 'playerStrums.members[' .. lane .. ']'
    returnX[lane] = getProperty(member .. '.x')
    noteTweenX('freshOuterOut' .. lane, lane + 4,
        returnX[lane] + distance, OUT_DURATION, 'quadOut')
end

local function pulseInnerLane(lane)
    local member = 'playerStrums.members[' .. lane .. ']'
    returnScale[lane] = {
        x = getProperty(member .. '.scale.x'),
        y = getProperty(member .. '.scale.y')
    }
    doTweenX('freshInnerScaleXOut' .. lane, member .. '.scale',
        returnScale[lane].x * INNER_PULSE_SCALE, OUT_DURATION, 'quadOut')
    doTweenY('freshInnerScaleYOut' .. lane, member .. '.scale',
        returnScale[lane].y * INNER_PULSE_SCALE, OUT_DURATION, 'quadOut')
end

local function tiltLane(lane)
    local member = 'playerStrums.members[' .. lane .. ']'
    returnAngle[lane] = getProperty(member .. '.angle')
    noteTweenAngle('freshAngleOut' .. lane, lane + 4,
        returnAngle[lane] + BEAT_TWO_ANGLES[lane + 1],
        OUT_DURATION, 'quadOut')
end

function onStepHit()
    local rangeStart = nil
    for _, range in ipairs(ACTIVE_RANGES) do
        if curStep >= range.startStep and curStep <= range.endStep then
            rangeStart = range.startStep
            break
        end
    end

    if rangeStart == nil then
        return
    end

    local measureStep = (curStep - rangeStart) % 16
    if measureStep == 0 then
        pulseOuterLane(0, -OUTER_DISTANCE)
        pulseOuterLane(3, OUTER_DISTANCE)
    elseif measureStep == 4 then
        for lane = 0, 3 do
            tiltLane(lane)
        end
    elseif measureStep == 8 then
        pulseInnerLane(1)
        pulseInnerLane(2)
    end
end

function onTweenCompleted(tag)
    local outerLane = tonumber(string.match(tag, '^freshOuterOut(%d)$'))
    if outerLane ~= nil and returnX[outerLane] ~= nil then
        noteTweenX('freshOuterBack' .. outerLane, outerLane + 4,
            returnX[outerLane], RETURN_DURATION, 'quadInOut')
        return
    end

    local angleLane = tonumber(string.match(tag, '^freshAngleOut(%d)$'))
    if angleLane ~= nil and returnAngle[angleLane] ~= nil then
        noteTweenAngle('freshAngleBack' .. angleLane, angleLane + 4,
            returnAngle[angleLane], RETURN_DURATION, 'quadInOut')
        return
    end

    local innerLane = tonumber(string.match(tag, '^freshInnerScaleXOut(%d)$'))
    if innerLane ~= nil and returnScale[innerLane] ~= nil then
        local member = 'playerStrums.members[' .. innerLane .. ']'
        doTweenX('freshInnerScaleXBack' .. innerLane, member .. '.scale',
            returnScale[innerLane].x, RETURN_DURATION, 'quadInOut')
        doTweenY('freshInnerScaleYBack' .. innerLane, member .. '.scale',
            returnScale[innerLane].y, RETURN_DURATION, 'quadInOut')
    end
end
