local steps = {375, 444}
local nextPass = 1
local stopped = false
local margin = 0

function onCreate()
    makeAnimatedLuaSprite('litUpFar', 'fahmix/weekend1/far', 0, 0)
    addAnimationByPrefix('litUpFar', 'idle', 'far idle', 6, true)
    playAnim('litUpFar', 'idle', true)
    local scale = screenHeight * 0.8 * 0.4 / getProperty('litUpFar.height')
    scaleObject('litUpFar', scale, scale)
    margin = math.max(getProperty('litUpFar.width'), getProperty('litUpFar.height')) + 20
    setObjectCamera('litUpFar', 'other')
    setProperty('litUpFar.visible', false)
    addLuaSprite('litUpFar', true)
end

local function updateFar()
    if stopped then return end
    while nextPass <= #steps and curStep >= steps[nextPass] do
        local pass = nextPass
        nextPass = nextPass + 1
        if curStep < steps[pass] + 4 then
            local reverse = pass == 2
            setProperty('litUpFar.x', reverse and screenWidth + margin or -margin)
            setProperty('litUpFar.y', reverse and screenHeight + margin or -margin)
            setProperty('litUpFar.angle', 0)
            setProperty('litUpFar.visible', true)
            setObjectOrder('litUpFar', getProperty('members.length') - 1)
            if luaSpriteExists('logo') then
                setObjectOrder('logo', getObjectOrder('litUpFar') + 1)
            end
            doTweenX('litUpFarX', 'litUpFar', reverse and -margin or screenWidth + margin, 0.6, 'linear')
            doTweenY('litUpFarY', 'litUpFar', reverse and -margin or screenHeight + margin, 0.6, 'linear')
            doTweenAngle('litUpFarSpin', 'litUpFar', reverse and -360 or 360, 0.6, 'linear')
        end
    end
end

function onStepHit()
    updateFar()
end

function onUpdatePost(elapsed)
    updateFar()
end

function onTweenCompleted(tag)
    if tag == 'litUpFarSpin' then setProperty('litUpFar.visible', false) end
end

function onGameOverStart()
    stopped = true
    cancelTween('litUpFarX')
    cancelTween('litUpFarY')
    cancelTween('litUpFarSpin')
    if luaSpriteExists('litUpFar') then setProperty('litUpFar.visible', false) end
end