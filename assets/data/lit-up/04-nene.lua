local dropped = false
local groundY = 0
local centerX = 0

function onCreate()
    precacheSound('nene-arrival')
    precacheSound('nene-boing')
    makeAnimatedLuaSprite('litUpNene', 'fahmix/weekend1/nene', 0, 0)
    addAnimationByPrefix('litUpNene', 'fall', 'nene fall', 12, true)
    addAnimationByPrefix('litUpNene', 'idle', 'nene idle', 6, true)
    playAnim('litUpNene', 'fall', true)
    setObjectCamera('litUpNene', 'game')
    setProperty('litUpNene.visible', false)
    addLuaSprite('litUpNene', true)
end

function onCreatePost()
    addHaxeLibrary('CoolUtil')
    runHaxeCode([[
        var sprite = game.modchartSprites.get('litUpNene');
        var bounds = CoolUtil.opaqueSpriteBounds(game.dad);
        var ground = game.dad.y - game.dad.offset.y + game.dad.origin.y
            + (bounds.y + bounds.height - game.dad.origin.y) * game.dad.scale.y - 85;
        var center = game.dad.x - game.dad.offset.x + game.dad.origin.x
            + (bounds.x + bounds.width * 0.5 - game.dad.origin.x) * game.dad.scale.x;
        var bfBounds = CoolUtil.opaqueSpriteBounds(game.boyfriend);
        var bfCenter = game.boyfriend.x - game.boyfriend.offset.x + game.boyfriend.origin.x
            + (bfBounds.x + bfBounds.width * 0.5 - game.boyfriend.origin.x) * game.boyfriend.scale.x;
        center = (center + bfCenter) * 0.5;
        var scale = bounds.height * game.dad.scale.y / 332 * 0.6;
        sprite.scale.set(scale, scale);
        sprite.updateHitbox();
        game.variables.set('litUpNeneGround', ground);
        game.variables.set('litUpNeneCenter', center);
    ]])
    groundY = getVar('litUpNeneGround')
    centerX = getVar('litUpNeneCenter')
    setObjectOrder('litUpNene', getObjectOrder('dadGroup') + 1)
end

local function dropNene()
    if dropped or curStep < 717 then return end
    dropped = true
    playSound('nene-arrival', 1)
    setProperty('litUpNene.x', centerX - getProperty('litUpNene.width') * 0.5)
    setProperty('litUpNene.y', getProperty('camGame.scroll.y') - getProperty('litUpNene.height') - screenHeight)
    setProperty('litUpNene.visible', true)
    doTweenY('litUpNeneFall', 'litUpNene', groundY - getProperty('litUpNene.height'), 0.55, 'quadIn')
end

function onStepHit()
    dropNene()
end

function onUpdatePost(elapsed)
    dropNene()
end

function onTweenCompleted(tag)
    if tag == 'litUpNeneFall' then
        playSound('nene-boing', 0.8)
        doTweenY('litUpNeneBounceUp', 'litUpNene', groundY - getProperty('litUpNene.height') * 1.7, 0.3, 'quadOut')
    elseif tag == 'litUpNeneBounceUp' then
        doTweenY('litUpNeneSettle', 'litUpNene', groundY - getProperty('litUpNene.height'), 0.38, 'quadIn')
    elseif tag == 'litUpNeneSettle' then
        playAnim('litUpNene', 'idle', true)
        updateHitbox('litUpNene')
        setProperty('litUpNene.x', centerX - getProperty('litUpNene.width') * 0.5)
        setProperty('litUpNene.y', groundY - getProperty('litUpNene.height'))
    end
end
