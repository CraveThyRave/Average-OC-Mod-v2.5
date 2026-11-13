local particleClock = 0
local particleIndex = 0
local particleAges = {}
local openingFocusActive = false

local function focusYoyai()
    runHaxeCode([[
        game.moveCamera(game.dad.curCharacter == 'yoyai');
        game.camFollowPos.setPosition(game.camFollow.x, game.camFollow.y);
        game.camGame.focusOn(game.camFollow);
    ]])
end

local function updatePresentation()
    local openingFocus = (getVar('hushOpeningFocus') or 0) >= 0.5
    if openingFocus and not openingFocusActive then focusYoyai() end
    openingFocusActive = openingFocus
    local background = getVar('hushBackgroundOpacity') or 0.65
    for _, tag in ipairs({'hushBackground', 'hushGradient', 'hushGradientTop', 'floor'}) do
        setProperty(tag .. '.alpha', background)
    end
    if not lowQuality then
        for i = 1, 25 do
            setProperty('hushParticle' .. i .. '.alpha', math.max(0, 1 - particleAges[i] / 2) * background)
        end
    end
    setProperty('hushWhiteFlash.alpha', getVar('hushWhiteOpacity') or 0)
    setProperty('hushEndingCover.alpha', getVar('hushBlackOpacity') or 0)
    setVar('hushNotesAboveFlash', (getVar('hushNotesOverlay') or 0) >= 0.5)
    setVar('hushFlashNoteOpacity', getVar('hushNoteOpacity') or 1)
end

function onCreate()
    setVar('hushBackgroundOpacity', 0.65)
    setVar('hushWhiteOpacity', 0)
    setVar('hushBlackOpacity', 0)
    setVar('hushNotesOverlay', 0)
    setVar('hushNoteOpacity', 1)
    setVar('hushYoyaiPhase', 0)
    setVar('hushYoyaiScared', 0)
    setVar('hushOpeningFocus', 0)
    setVar('songCreditCueVisible', 0)
    makeLuaSprite('hushBackground', '', -680, -200)
    makeGraphic('hushBackground', 16, 9, 'FFFFFF')
    setGraphicSize('hushBackground', 3840, 2360)
    addLuaSprite('hushBackground', false)
    if not lowQuality then
        initLuaShader('void')
        setSpriteShader('hushBackground', 'void')
        setShaderFloat('hushBackground', 'u_mix', 0.03)
        setShaderFloatArray('hushBackground', 'u_scale', {1, 2360 / 2160})
        setShaderFloatArray('hushBackground', 'u_offset', {0, 0})
        setShaderFloatArray('hushBackground', 'u_worldOffset', {0, -200 / 2160})
    end
    makeLuaSprite('hushGradient', 'Effects/gradient', -500, 0)
    scaleObject('hushGradient', 1.5, 1.5)
    addLuaSprite('hushGradient', false)
    makeLuaSprite('hushGradientTop', '', -500, -200)
    addLuaSprite('hushGradientTop', false)
    addHaxeLibrary('RepeatStageFloor')
    addHaxeLibrary('ThemeSurfaces')
    runHaxeCode([[
        var floor = new RepeatStageFloor(1200);
        floor.cameras = [game.camGame];
        game.variables.set('floor', floor);
        game.insert(game.members.indexOf(game.getLuaObject('hushGradientTop')) + 1, floor);
        ThemeSurfaces.applyStage(floor, 'floor');
    ]])
    if not lowQuality then
        for i = 1, 25 do
            particleAges[i] = 2
            local tag = 'hushParticle' .. i
            makeLuaSprite(tag, 'Freeplay-Chrs/gabriella/gabby/particle', 0, 0)
            setProperty(tag .. '.alpha', 0)
            addLuaSprite(tag, false)
            setObjectOrder(tag, getObjectOrder('hushGradientTop') + 1)
        end
    end
    makeAnimatedLuaSprite('hushBook', 'characters/yoyai-book', 0, 0)
    addAnimationByPrefix('hushBook', 'idle', 'book idle', 5, true)
    playAnim('hushBook', 'idle')
    scaleObject('hushBook', 0.65, 0.65)
    setProperty('hushBook.visible', false)
    addLuaSprite('hushBook', false)
    setObjectOrder('hushBook', getObjectOrder('gfGroup'))
    makeLuaSprite('hushWhiteFlash', '', 0, 0)
    makeGraphic('hushWhiteFlash', screenWidth, screenHeight, 'FFFFFF')
    setObjectCamera('hushWhiteFlash', 'other')
    setProperty('hushWhiteFlash.alpha', 0)
    addLuaSprite('hushWhiteFlash', true)
    makeLuaSprite('hushEndingCover', '', 0, 0)
    makeGraphic('hushEndingCover', screenWidth, screenHeight, '000000')
    setObjectCamera('hushEndingCover', 'other')
    setProperty('hushEndingCover.alpha', 0)
    addLuaSprite('hushEndingCover', true)
end

function onCreatePost()
    setProperty('notePushAmount', 10)
    setProperty('notePushAngleAmount', 1.25)
    setProperty('camZoomingMult', 0.5)
    setProperty('iconBopMultiplier', 0.5)
    addCharacterToList('yoyai-happy', getPropertyFromClass('MirrorMode', 'active') and 'bf' or 'dad')
    addHaxeLibrary('FlxImageFrame', 'flixel.graphics.frames')
    addHaxeLibrary('FlxRect', 'flixel.math')
    runHaxeCode([[
        var actor = game.dad.curCharacter == 'yoyai' ? game.dad : game.boyfriend;
        var rgb = actor.healthColorArray;
        var tint = (rgb[0] << 16) | (rgb[1] << 8) | rgb[2];
        var gradient = game.getLuaObject('hushGradient');
        gradient.color = 0xFF000000 | tint;
        var top = game.getLuaObject('hushGradientTop');
        top.frames = FlxImageFrame.fromRectangle(gradient.graphic, FlxRect.get(0, 0, gradient.frameWidth, 1));
        top.color = gradient.color;
        top.scale.set(1.5, 200);
        top.updateHitbox();
        var isOpponent = actor == game.dad;
        var icon = isOpponent ? game.iconP2 : game.iconP1;
        var targetScale = isOpponent ? game.opponentIconTargetScale(false) : game.playerIconTargetScale();
        icon.characterSettings = actor.iconSettings;
        icon.settingsBaseScale = isOpponent ? 1 : game.playerIconTargetScale();
        icon.scale.set(targetScale, targetScale);
        icon.updateHitbox();
    ]])
    focusYoyai()
    updatePresentation()
end

function onSongStart()
    if (getVar('hushOpeningFocus') or 0) >= 0.5 then focusYoyai() end
end

function onMoveCamera()
    if (getVar('hushOpeningFocus') or 0) >= 0.5 then
        cameraSetTarget(getPropertyFromClass('MirrorMode', 'active') and 'boyfriend' or 'dad')
    end
end

function onUpdate(elapsed)
    if lowQuality then return end
    for i = 1, 25 do particleAges[i] = math.min(2, particleAges[i] + elapsed) end
    setShaderFloat('hushBackground', 'u_time', getSongPosition() / 1000 * 0.8)
    particleClock = particleClock + elapsed
    if particleClock >= 5 / 60 then
        particleClock = particleClock % (5 / 60)
        particleIndex = particleIndex % 25 + 1
        local tag = 'hushParticle' .. particleIndex
        particleAges[particleIndex] = 0
        setProperty(tag .. '.x', getRandomFloat(-1200, 2300))
        setProperty(tag .. '.y', 950)
        setProperty(tag .. '.velocity.x', getRandomFloat(-100, 100))
        setProperty(tag .. '.velocity.y', -400)
    end
end

function onUpdatePost(elapsed)
    updatePresentation()
end
