
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



function onCreate()

	makeLuaSprite('checkerboard', 'Freeplay-Chrs/gabriella/gabby/catboard2', -310, 200);
	scaleObject('checkerboard', 3.3, 3.3);
  setScrollFactor('checkerboard', 0.85, 0.85)
  if not lowQuality then
    initLuaShader('checkerboard')
    setSpriteShader('checkerboard', 'checkerboard')
  end
  setProperty('checkerboard.alpha', 0.001)
	addLuaSprite('checkerboard', false);
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
    if lowQuality then return end
    if curBeat % 2 == 0 then
			setProperty('checkerboard.angle', -4)
			doTweenAngle('checkerboardBack', 'checkerboard', 0, crochet / 1000, 'cubeOut')
		else
			setProperty('checkerboard.angle', 4)
			doTweenAngle('checkerboardBack', 'checkerboard', 0, crochet / 1000, 'cubeOut')
		end
end
