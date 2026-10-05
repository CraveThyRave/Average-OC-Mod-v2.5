local rootTag = 'songCreditAnchor'
local iconTag = 'songCreditIcon'
local objects = {}
local credits = {}
local settings = {}
local enabled = false
local built = false
local entered = false
local leaving = false
local finished = false
local songStarted = false
local introStep = 0
local outroStep = 48
local cardScale = 0.65
local homeX = 0
local homeY = 50
local hiddenX = -800
local panelHeight = 212
local iconFrames = nil
local iconName = ''
local iconColor = ''
local paletteKey = ''

local reserved = {
    introstep = true, outrostep = true, chibi = true, composer = true,
    composerlabel = true, composerx = true, composerwidth = true, color = true, scale = true, x = true, y = true,
    introduration = true, outroduration = true, titlefont = true, bodyfont = true
}

local function trim(value)
    return (value:gsub('^%s+', ''):gsub('%s+$', ''))
end

local function readSettings()
    local content = runHaxeCode([[
        var path = 'data/' + Paths.formatToSongPath(PlayState.SONG.song) + '/credits.txt';
        if (!Paths.fileExists(path, 'TEXT')) return null;
        return Paths.getTextFromFile(path);
    ]])
    if type(content) ~= 'string' then return false end
    content = content:gsub('^\239\187\191', '')
    for line in content:gmatch('[^\r\n]+') do
        line = trim(line)
        if line:sub(1, 1) ~= '#' and line:sub(1, 1) ~= ';' then
            local key, value = line:match('^([^=]+)=(.*)$')
            if key then
                key = trim(key)
                value = trim(value)
                local lower = key:lower()
                if reserved[lower] then
                    settings[lower] = value
                elseif key ~= '' and value ~= '' then
                    credits[#credits + 1] = {label = key, value = value}
                end
            end
        end
    end
    introStep = math.floor(tonumber(settings.introstep) or 0)
    outroStep = math.floor(tonumber(settings.outrostep) or 48)
    if outroStep <= introStep then outroStep = introStep + 48 end
    homeX = tonumber(settings.x) or 0
    homeY = tonumber(settings.y) or 50
    panelHeight = math.max(212, #credits * 39 + 44)
    cardScale = math.max(0.1, math.min(tonumber(settings.scale) or 0.65,
        (screenHeight - homeY - 20) / (401 + panelHeight)))
    hiddenX = homeX - 1129 * cardScale - 32
    return true
end

local function register(tag, x, y, isText)
    objects[#objects + 1] = {tag = tag, x = x, y = y, text = isText == true}
    setObjectCamera(tag, 'other')
    setScrollFactor(tag, 0, 0)
    setProperty(tag .. '.visible', false)
    if isText then addLuaText(tag) else addLuaSprite(tag, true) end
end

local function sprite(tag, asset, x, y, scaleX, scaleY)
    makeLuaSprite(tag, asset, 0, 0)
    scaleObject(tag, cardScale * (scaleX or 1), cardScale * (scaleY or 1))
    setProperty(tag .. '.antialiasing', true)
    register(tag, x, y, false)
end

local function text(tag, value, x, y, width, size, font, alignment, outlined)
    local density = 2
    makeLuaText(tag, value, width * density, 0, 0)
    setTextFont(tag, font)
    setTextSize(tag, size * density)
    setTextColor(tag, 'FFFFFF')
    setTextBorder(tag, outlined and density or 0, '000000')
    setProperty(tag .. '.borderSize', outlined and 1.2 or 0)
    setProperty(tag .. '.borderQuality', 1)
    setTextAlignment(tag, alignment)
    setProperty(tag .. '.bold', true)
    setProperty(tag .. '.wordWrap', false)
    setProperty(tag .. '.antialiasing', true)
    scaleObject(tag, cardScale / density, cardScale / density, false)
    setProperty(tag .. '.origin.x', 0)
    setProperty(tag .. '.origin.y', 0)
    setProperty(tag .. '.offset.x', 0)
    setProperty(tag .. '.offset.y', 0)
    register(tag, x, y, true)
end

local function getCreditIconName()
    if songName:lower() == 'tutorial' then return getProperty('boyfriend.healthIcon') end
    return getProperty('dad.healthIcon')
end

local function updateIcon()
    iconName = getCreditIconName()
    iconFrames = runHaxeCode([[
        var playerIcon = Paths.formatToSongPath(PlayState.SONG.song) == 'tutorial';
        var creditCharacter = playerIcon ? game.boyfriend : game.dad;
        var reference = new HealthIcon(creditCharacter.healthIcon, playerIcon);
        reference.setHealthState('win', true);
        var sprite = game.modchartSprites.get('songCreditIcon');
        var animation = reference.animation.curAnim;
        var indices = reference.isAnimated ? animation.frames.copy() : [reference.animation.frameIndex];
        var frameRate = reference.isAnimated ? animation.frameRate : 0;
        var liveIcon = game.getLuaObject(playerIcon ? 'animated-bf' : 'animated-dad', false);
        if (liveIcon != null && reference.isAnimated) {
            var liveWin = liveIcon.animation.getByName('win');
            if (liveWin != null) frameRate = liveWin.frameRate;
        }
        sprite.frames = reference.frames;
        sprite.animation.add('win', indices, frameRate, true);
        sprite.animation.play('win', true);
        sprite.flipX = false;
        sprite.antialiasing = reference.antialiasing;
        sprite.origin.set(0, 0);
        sprite.offset.set(0, 0);
        var bounds = [];
        var maximumWidth = 1.0;
        var maximumHeight = 1.0;
        for (index in indices) {
            var frameBounds = new SpriteFrameBounds(sprite.frames.frames[index]);
            if (frameBounds.width > maximumWidth) maximumWidth = frameBounds.width;
            if (frameBounds.height > maximumHeight) maximumHeight = frameBounds.height;
            bounds.push(frameBounds.centerX);
            bounds.push(frameBounds.centerY);
        }
        bounds.insert(0, 166 / (maximumWidth > maximumHeight ? maximumWidth : maximumHeight));
        reference.destroy();
        return bounds;
    ]])
	if type(iconFrames) == 'table' then
		local song = songName:lower()
		if song == 'stress' or song == 'pews' or song == 'bleh' then
			iconFrames[1] = iconFrames[1] * 1.1
		end
		setProperty(iconTag .. '.scale.x', iconFrames[1] * cardScale)
		setProperty(iconTag .. '.scale.y', iconFrames[1] * cardScale)
	end
end

local function getCreditIconColor()
	if songName:lower() == 'tutorial' then return getPlayerIconColor() end
	return getOpponentIconColor()
end

local function updateColors()
	iconColor = getCreditIconColor()
	local primaryColor = settings.color or iconColor
	local song = songName:lower()
	local detailColor = iconColor
	if song == 'stress' or song == 'pews' or song == 'bleh' then
		primaryColor = 'E5D13C'
		detailColor = primaryColor
	elseif song == 'spookeez' then
		detailColor = 'CBCBCB'
	end
    local key = primaryColor .. ':' .. detailColor
    if key == paletteKey then return end
    paletteKey = key
    setVar('songCreditPrimaryColor', primaryColor)
    setVar('songCreditDetailColor', detailColor)
    runHaxeCode([[
        var primary = LuaColor.parseHex(getVar('songCreditPrimaryColor'));
        var detail = LuaColor.parseHex(getVar('songCreditDetailColor'));
        var red = [];
        var green = [];
        var blue = [];
        for (value in 0...256) {
            var target = value < 240 ? detail : primary;
            var shade = value < 240 ? (value < 203 ? value / 203 : 1.0) : value / 255;
            red.push(Std.int(((target >> 16) & 255) * shade) << 16);
            green.push(Std.int(((target >> 8) & 255) * shade) << 8);
            blue.push(Std.int((target & 255) * shade));
        }
        var source = Paths.image('UI/credits/composer-panel').bitmap;
        var ribbon = source.clone();
        ribbon.paletteMap(source, source.rect, new Point(), red, green, blue);
        var sprite = game.modchartSprites.get('songCreditComposerPanel');
        sprite.pixels = ribbon;
        sprite.color = 0xFFFFFFFF;
        sprite.updateHitbox();
        source = Paths.image('UI/credits/credit-panel').bitmap;
        var panel = source.clone();
        panel.colorTransform(panel.rect, new ColorTransform(
            ((primary >> 16) & 255) / 255, ((primary >> 8) & 255) / 255, (primary & 255) / 255));
        var top = new Rectangle(0, 0, source.width, 407);
        panel.copyPixels(source, top, new Point());
        panel.colorTransform(top, new ColorTransform(
            ((detail >> 16) & 255) / 255, ((detail >> 8) & 255) / 255, (detail & 255) / 255));
        sprite = game.modchartSprites.get('songCreditPanel');
        sprite.pixels = panel;
        sprite.color = 0xFFFFFFFF;
        sprite.updateHitbox();
    ]])
end

local function layout()
    if not built then return end
    local x = getProperty(rootTag .. '.x')
    for _, object in ipairs(objects) do
        if object.tag ~= iconTag then
            setProperty(object.tag .. '.x', x + object.x * cardScale)
            setProperty(object.tag .. '.y', homeY + object.y * cardScale)
        end
    end
    if type(iconFrames) == 'table' then
        local frame = getProperty(iconTag .. '.animation.curAnim.curFrame') or 0
        local centerX = iconFrames[2 + frame * 2] or iconFrames[2]
        local centerY = iconFrames[3 + frame * 2] or iconFrames[3]
        setProperty(iconTag .. '.x', x + (103 - centerX * iconFrames[1]) * cardScale)
        setProperty(iconTag .. '.y', homeY + (401 + panelHeight * 0.5 - centerY * iconFrames[1]) * cardScale)
    end
end

local function visibility(value)
    for _, object in ipairs(objects) do setProperty(object.tag .. '.visible', value) end
end

local function hideOldCredits()
    if luaSpriteExists('credits') then setProperty('credits.visible', false) end
end

local function stopCard()
    if not built then return end
    cancelTween('songCreditSlide')
    finished = true
    visibility(false)
    setVar('songCreditVisible', false)
end

local function showCard()
    if entered or finished or not built then return end
    entered = true
    updateIcon()
    updateColors()
    setProperty(rootTag .. '.x', hiddenX)
    layout()
    visibility(true)
    setVar('songCreditVisible', true)
    doTweenX('songCreditSlide', rootTag, homeX, math.max(0.01, tonumber(settings.introduration) or 0.5), 'quadOut')
end

local function processStep(step)
    if not enabled or not built or finished then return end
    if step >= outroStep then
        if not entered then
            stopCard()
        elseif not leaving then
            leaving = true
            cancelTween('songCreditSlide')
            doTweenX('songCreditSlide', rootTag, hiddenX, math.max(0.01, tonumber(settings.outroduration) or 0.65), 'quadOut')
        end
    elseif step >= introStep then
        showCard()
    end
end

function onCreate()
    enabled = readSettings()
    if not enabled then close(true) return end
    addHaxeLibrary('HealthIcon')
    addHaxeLibrary('SpriteFrameBounds')
    addHaxeLibrary('Type')
    addHaxeLibrary('Std')
    addHaxeLibrary('LuaColor')
    addHaxeLibrary('Point', 'openfl.geom')
    addHaxeLibrary('Rectangle', 'openfl.geom')
    addHaxeLibrary('ColorTransform', 'openfl.geom')
    setVar('songCreditEnabled', true)
    setVar('songCreditVisible', false)
end

function onCreatePost()
    if not enabled then return end
    makeLuaSprite(rootTag, nil, hiddenX, homeY)
    local bodyFont = settings.bodyfont or 'Desc.ttf'
    sprite('songCreditComposerPanel', 'UI/credits/composer-panel', 0, 0)
    if settings.composer and settings.composer ~= '' then
        local composerX = tonumber(settings.composerx) or 256
        local composerWidth = tonumber(settings.composerwidth) or 440
        text('songCreditComposerHeading', settings.composerlabel or 'Composed by', composerX, 212, composerWidth, 44,
            settings.titlefont or 'pause.ttf', 'center')
        text('songCreditComposerName', settings.composer, composerX, 284, composerWidth, 32, bodyFont, 'center')
    end
    local chibi = (settings.chibi or ''):gsub('%.png$', '')
    if chibi ~= '' then
        if not chibi:find('/', 1, true) then chibi = 'UI/credits/chibis/' .. chibi end
        setVar('songCreditChibiAsset', chibi)
        if runHaxeCode("return Paths.fileExists('images/' + getVar('songCreditChibiAsset') + '.png', 'IMAGE');") then
            sprite('songCreditChibi', chibi, 0, 0)
        else
            debugPrint('Song credits: missing chibi ' .. chibi)
        end
    end
    local panelStretch = panelHeight / 212
    sprite('songCreditPanel', 'UI/credits/credit-panel', 0, 401 * (1 - panelStretch), 1, panelStretch)
    makeLuaSprite(iconTag, nil, 0, 0)
    register(iconTag, 0, 0, false)
    for index, credit in ipairs(credits) do
        local indent = math.min((index - 1) * 24, 72)
        text('songCreditRole' .. index, credit.label .. ' by ' .. credit.value,
            212 + indent, 414 + (index - 1) * 39, 586 - indent, 28, bodyFont, 'left', true)
    end
    runHaxeCode([[
        for (entry in game.modchartTexts.keys()) {
            if (StringTools.startsWith(entry, 'songCredit')) {
                var text = game.modchartTexts.get(entry);
                if (entry == 'songCreditComposerHeading' || entry == 'songCreditComposerName')
                    text.borderStyle = Type.createEnum(Type.resolveEnum('flixel.text.FlxTextBorderStyle'), 'NONE');
                var fit = 1.0;
                if (text.textField.textWidth > text.fieldWidth - 4) {
                    var contentWidth = text.textField.textWidth + 4;
                    fit = text.fieldWidth / contentWidth;
                    text.fieldWidth = contentWidth;
                    text.scale.x *= fit;
                    text.scale.y *= fit;
                }
                text.drawFrame();
                text.origin.set(0, 0);
                text.offset.set(0, -text.frameHeight * text.scale.y / fit * (1 - fit) * 0.5);
            }
        }
    ]])
    built = true
    updateIcon()
    updateColors()
    layout()
    hideOldCredits()
    if songStarted then processStep(curStep) end
end

function onSongStart()
    songStarted = true
    processStep(math.max(curStep, 0))
end

function onStepHit()
    if songStarted or introStep < 0 then processStep(curStep) end
end

function onUpdatePost(elapsed)
    if not enabled or not built then return end
    hideOldCredits()
    if finished then return end
    if songStarted or introStep < 0 then processStep(curStep) end
    if entered then
		if getCreditIconName() ~= iconName then updateIcon() end
		if getCreditIconColor() ~= iconColor then updateColors() end
        layout()
    end
end

function onTweenCompleted(tag)
    if tag == 'songCreditSlide' and leaving then stopCard() end
end

function onGameOverStart()
    stopCard()
end

function onEndSong()
    stopCard()
end

function onDestroy()
    if not built then return end
    cancelTween('songCreditSlide')
    for _, object in ipairs(objects) do
        if object.text then removeLuaText(object.tag, true) else removeLuaSprite(object.tag, true) end
    end
    removeLuaSprite(rootTag, true)
end
