local inGameOver = false
local baseClockX = 0
local baseTimeTxtX = 0
local lastMiddleScroll = nil
local hudPollElapsed = 0
local logoMustStayAboveDistractions = false

local function applyTimeTxtStyle()
	if getProperty('timeTxt') == nil then return end
	runHaxeCode([[
		if (game != null && game.timeTxt != null)
			game.timeTxt.color = 0xFF000000;
	]])
	setTextFont('timeTxt', 'fah.ttf')
	setProperty('timeTxt.borderSize', 0)
	setTextSize('timeTxt', 30)
end
local DARNELL_SWORD_STEPS = {
    575, 703, 1088, 1216
}
local DARNELL_SWORD_ASSET = 'fahmix/weekend1/darnell-sword'
local DARNELL_SWORD_SCALE = 0.25
local darnellSwordStepLookup = {}
local activeDarnellSwords = {}
local darnellSwordSerial = 0

for _, step in ipairs(DARNELL_SWORD_STEPS) do
    darnellSwordStepLookup[step] = true
end
local ENABLE_LOGO = true
local LOGO_ASSET = 'fahmix/weekend1/darnell-logo'
local LOGO_SHOW_STEP = 191
local LOGO_HIDE_STEP = 240


local function createLogo()

    if ENABLE_LOGO then
        makeLuaSprite('logo', LOGO_ASSET, 320, -570)
        setProperty('logo.flipX', getPropertyFromClass('MirrorMode', 'active'))
        scaleObject('logo', 0.4, 0.4)
        setObjectCamera('logo', 'other')
        addLuaSprite('logo', false)
    end
end

local function bringDarnellLogoToFront()
    if not ENABLE_LOGO or not luaSpriteExists('logo') then return end
    removeLuaSprite('logo', false)
    addLuaSprite('logo', true)
end

local function keepDarnellLogoAboveDistractions()
    if not logoMustStayAboveDistractions or not luaSpriteExists('logo') then return end

    local logoOrder = getObjectOrder('logo')
    for tag, _ in pairs(activeDarnellSwords) do
        if luaSpriteExists(tag) and getProperty(tag .. '.visible') and getObjectOrder(tag) > logoOrder then
            bringDarnellLogoToFront()
            return
        end
    end

    local paintTag = 'mechanicsDarnellPaintOverlay'
    if luaSpriteExists(paintTag) and getProperty(paintTag .. '.visible')
        and getObjectOrder(paintTag) > getObjectOrder('logo') then
        bringDarnellLogoToFront()
    end
end

local function spawnDarnellSword()
    darnellSwordSerial = darnellSwordSerial + 1
    local serial = darnellSwordSerial
    local tag = 'darnellFallingSword' .. serial

    setProperty(tag .. '.active', true)
    setProperty(tag .. '.visible', true)
    playAnim(tag, 'idle', true)

    local width = tonumber(getProperty(tag .. '.width')) or 0
    local height = tonumber(getProperty(tag .. '.height')) or 0
    local startX = getRandomFloat(0, math.max(0, screenWidth - width))
    local startY = -height - getRandomFloat(12, 55)
    local driftDirection = getRandomInt(0, 1) == 0 and -1 or 1
    local drift = getRandomFloat(35, 110) * driftDirection
    local endX = math.max(-width * 0.35,
        math.min(screenWidth - width * 0.65, startX + drift))
    local duration = getRandomFloat(0.85, 1)
    local spinDirection = getRandomInt(0, 1) == 0 and -1 or 1
    local spinDegrees = getRandomFloat(306, 414) * spinDirection
    local startAngle = getRandomFloat(-25, 25)

    setProperty(tag .. '.x', startX)
    setProperty(tag .. '.y', startY)
    setProperty(tag .. '.angle', startAngle)
    activeDarnellSwords[tag] = serial
    if logoMustStayAboveDistractions then
        bringDarnellLogoToFront()
    end

    doTweenY('darnellSwordFall' .. serial, tag,
        screenHeight + height + 35, duration, 'quadIn')
    doTweenX('darnellSwordDrift' .. serial, tag, endX, duration, 'sineOut')
    doTweenAngle('darnellSwordSpin' .. serial, tag,
        startAngle + spinDegrees, duration, 'linear')
end

local function clearDarnellSwords()
    for tag, serial in pairs(activeDarnellSwords) do
        cancelTween('darnellSwordFall' .. serial)
        cancelTween('darnellSwordDrift' .. serial)
        cancelTween('darnellSwordSpin' .. serial)
        if luaSpriteExists(tag) then
            setProperty(tag .. '.active', false)
            setProperty(tag .. '.visible', false)
            setProperty(tag .. '.y', screenHeight + 100)
        end
    end
    activeDarnellSwords = {}
end

function onCreate()
    precacheImage(DARNELL_SWORD_ASSET)
    createLogo()
    for poolIndex = 1, #DARNELL_SWORD_STEPS do
        local tag = 'darnellFallingSword' .. poolIndex
        makeAnimatedLuaSprite(tag, DARNELL_SWORD_ASSET, -9999, screenHeight + 100)
        addAnimationByPrefix(tag, 'idle', 'darnell-sword idle', 12, true)
        scaleObject(tag, DARNELL_SWORD_SCALE, DARNELL_SWORD_SCALE)
        setObjectCamera(tag, 'other')
        setProperty(tag .. '.active', false)
        setProperty(tag .. '.visible', false)
        addLuaSprite(tag, true)
    end

    makeLuaSprite('dablack', 'dablack', 0, 0)
    setObjectCamera('dablack', 'other')
    setProperty('dablack.alpha', 0)
    addLuaSprite('dablack', true)

    makeLuaSprite('dawhite', 'dawhite', 0, 0)
    setObjectCamera('dawhite', 'other')
    setProperty('dawhite.alpha', 0)
    addLuaSprite('dawhite', true)

end

function onCreatePost()
	baseClockX = getProperty('fahclock.x')
	baseTimeTxtX = getProperty('timeTxt.x')
	applyTimeTxtStyle()
	runTimer('darnellApplyTimeStyle', 0.1)
end

function onSongStart()
	runTimer('darnellApplyTimeStyle', 0.01)
end

function onTimerCompleted(tag)
	if tag == 'darnellApplyTimeStyle' and not inGameOver then
		applyTimeTxtStyle()
	end
end

function onStepHit()
    if darnellSwordStepLookup[curStep] then
        spawnDarnellSword()
    end

    if curStep == 1344 then
        setProperty('dablack.visible', true)
        setProperty('dablack.alpha', 0)
        doTweenAlpha('darnellBlackFadeIn', 'dablack', 1, 0.4, 'linear')
    end
    if ENABLE_LOGO and LOGO_SHOW_STEP ~= nil and curStep == LOGO_SHOW_STEP then
        logoMustStayAboveDistractions = true
        bringDarnellLogoToFront()
        doTweenY('darnellLogoIn', 'logo', (screenHeight - getProperty('logo.height')) * 0.5, 1, 'quartOut')
    elseif ENABLE_LOGO and LOGO_HIDE_STEP ~= nil and curStep == LOGO_HIDE_STEP then
        doTweenX('darnellLogoScaleXOut', 'logo.scale', 0, 0.4, 'quintIn')
        doTweenY('darnellLogoScaleYOut', 'logo.scale', 0, 0.4, 'quintIn')
    end

end

function onTweenCompleted(tag)
    if tag == 'darnellLogoScaleYOut' then
        logoMustStayAboveDistractions = false
        return
    end

    local serial = tonumber(string.match(tag, '^darnellSwordFall(%d+)$'))
    if serial == nil then return end

    local spriteTag = 'darnellFallingSword' .. serial
    activeDarnellSwords[spriteTag] = nil
    cancelTween('darnellSwordDrift' .. serial)
    cancelTween('darnellSwordSpin' .. serial)
    if luaSpriteExists(spriteTag) then
        setProperty(spriteTag .. '.active', false)
        setProperty(spriteTag .. '.visible', false)
        setProperty(spriteTag .. '.y', screenHeight + 100)
    end
end

function onUpdatePost(elapsed)
    if inGameOver then return end

    keepDarnellLogoAboveDistractions()

	hudPollElapsed = hudPollElapsed + (elapsed or 0)
    if hudPollElapsed < 0.1 then return end
    hudPollElapsed = 0

    local middleScroll = getPropertyFromClass('ClientPrefs', 'middleScroll')
	if middleScroll ~= lastMiddleScroll then
		lastMiddleScroll = middleScroll
		setProperty('fahclock.x', baseClockX + (middleScroll and -320 or 0))
		setProperty('timeTxt.x', baseTimeTxtX + (middleScroll and -285 or 38))
	end
end

function onGameOverStart()
    inGameOver = true
    logoMustStayAboveDistractions = false
    clearDarnellSwords()
    if luaSpriteExists('logo') then setProperty('logo.visible', false) end
    if luaSpriteExists('fahclock') then setProperty('fahclock.visible', false) end
    if luaSpriteExists('dablack') then setProperty('dablack.visible', false) end
    if luaSpriteExists('dawhite') then setProperty('dawhite.visible', false) end
end

function onDestroy()
    clearDarnellSwords()
    for poolIndex = 1, #DARNELL_SWORD_STEPS do
        local tag = 'darnellFallingSword' .. poolIndex
        if luaSpriteExists(tag) then removeLuaSprite(tag, true) end
    end
end
