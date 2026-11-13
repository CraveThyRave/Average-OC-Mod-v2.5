
local shaderTime = 0
local shaderRunning = true
local checkerboardShown = false
local checkerboardHidden = false

function onCreatePost()
  if lowQuality then
    setProperty('checkerboard.alpha', 0)
    shaderRunning = false
    return
  end
  
  
  runTimer('shiftrCheckerboardPrewarmEnd', 0.1)
end

function onUpdate(elapsed)
  if not shaderRunning then return end
  shaderTime = shaderTime + elapsed
  setShaderFloat('checkerboard', 'iTime', shaderTime)
end

function onUpdatePost()
  setProperty('checkerboardTop.alpha', getProperty('checkerboard.alpha'))
  setProperty('checkerboardTop.color', getProperty('checkerboard.color'))
  setProperty('checkerboardTop.visible', getProperty('checkerboard.visible'))
  setProperty('checkerboardTop.angle', getProperty('checkerboard.angle'))
end



function onCreate()

	makeLuaSprite('checkerboard', 'Freeplay-Chrs/gabriella/gabby/catboard2', -310, 200);
	scaleObject('checkerboard', 3.3, 3.3);
  setScrollFactor('checkerboard', 0.85, 0.85)
  if not lowQuality then
    initLuaShader('checkerboard')
    setSpriteShader('checkerboard', 'checkerboard')
  end
  setProperty('checkerboard.alpha', 0.001)
	makeLuaSprite('checkerboardTop', 'Freeplay-Chrs/gabriella/gabby/catboard2', -310, 0)
  runHaxeCode([[
    var board = game.getLuaObject('checkerboard');
    var top = game.getLuaObject('checkerboardTop');
    top.scale.set(board.scale.x, board.scale.y);
    top.updateHitbox();
    top.x = board.x;
    top.y = board.y - board.frameHeight * board.scale.y;
    top.origin.set(board.origin.x, board.origin.y + board.frameHeight);
    top.offset.set(board.offset.x, board.offset.y + board.frameHeight * (1 - board.scale.y));
    top.shader = board.shader;
    top.scrollFactor.set(board.scrollFactor.x, board.scrollFactor.y);
    top.antialiasing = board.antialiasing;
    top.alpha = board.alpha;
  ]])
  addLuaSprite('checkerboardTop', false)
	addLuaSprite('checkerboard', false);
  setBlendMode('checkerboardTop', 'add')
  setObjectCamera('checkerboardTop', 'camgame')
  setBlendMode('checkerboard', 'add')
  setObjectCamera('checkerboard', 'camgame');


end


function onStepHit()
    if curStep >= 2080 and not checkerboardShown then
      checkerboardShown = true
      shaderRunning = not lowQuality
      setProperty('checkerboard.alpha', 1)
    end

    if curStep >= 2592 and not checkerboardHidden then
      checkerboardHidden = true
      doTweenAlpha('shiftrCheckerboardFadeOut', 'checkerboard', 0, 1.5, 'quadInOut')
    end
end

function onTimerCompleted(tag)
  if tag == 'shiftrCheckerboardPrewarmEnd' then
    setProperty('checkerboard.alpha', 0)
    shaderRunning = false
  end
end

function onTweenCompleted(tag)
  if tag == 'shiftrCheckerboardFadeOut' then
    shaderRunning = false
  end
end


function onBeatHit()
    if lowQuality or not shaderRunning then return end
    if curBeat % 2 == 0 then
			setProperty('checkerboard.angle', -4)
			doTweenAngle('checkerboardBack', 'checkerboard', 0, crochet / 1000, 'cubeOut')
		else
			setProperty('checkerboard.angle', 4)
			doTweenAngle('checkerboardBack', 'checkerboard', 0, crochet / 1000, 'cubeOut')
		end
end
