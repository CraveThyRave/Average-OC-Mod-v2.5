



local shaderTime = 0
local shaderRunning = false

function onUpdate(elapsed)
  if not shaderRunning then return end
  shaderTime = shaderTime + elapsed
  setShaderFloat('checkerboard', 'iTime', shaderTime)
end



function onCreate()

	makeLuaSprite('checkerboard', 'Freeplay-Chrs/phoenix/bf-checkerboard', -310, -400);
	scaleObject('checkerboard', 3.3, 3.3);
  if not lowQuality then
    initLuaShader('checkerboard')
    setSpriteShader('checkerboard', 'checkerboard')
  end
  setProperty('checkerboard.alpha', 0)
	addLuaSprite('checkerboard', false);
  setObjectCamera('checkerboard', 'camgame');
  setObjectOrder('checkerboard', getObjectOrder('stageback') + 1)


end


function onStepHit()
  if curStep == 768 then
    shaderRunning = not lowQuality
    doTweenAlpha('checkerboard','checkerboard',0.35,0.3,'quadIn')
    doTweenAlpha('stagefront','stagefront',0.3,0.3,'quadIn')
    doTweenAlpha('stagecurtains','stagecurtains',0.8,0.3,'quadIn')
    doTweenAlpha('burnmark1','burnmark1',0.3,0.3,'quadIn')

    doTweenAlpha('stage_light1','stage_light1',0.8,0.3,'quadIn')
    doTweenAlpha('stage_light2','stage_light2',0.8,0.3,'quadIn')
  end

  if curStep == 870 then
    doTweenAlpha('checkerboard','checkerboard',0.40,0.3,'quadIn')
  end
  if curStep == 886 then
    doTweenAlpha('checkerboard','checkerboard',0.43,0.3,'quadIn')
  end

  if curStep == 960 then
    doTweenAlpha('checkerboard','checkerboard',0.15,0.9,'quadIn')
    doTweenAlpha('stagefront','stagefront',0.85,0.9,'quadIn')
    doTweenAlpha('stagecurtains','stagecurtains',0.9,0.9,'quadIn')
    doTweenAlpha('burnmark1','burnmark1',0.85,0.9,'quadIn')
    doTweenAlpha('stage_light1','stage_light1',0.85,0.9,'quadIn')
    doTweenAlpha('stage_light2','stage_light2',0.85,0.9,'quadIn')
  end

  if curStep == 1016 then
    doTweenAlpha('checkerboard','checkerboard',0.30,0.3,'quadIn')
    doTweenAlpha('stagefront','stagefront',0.3,0.3,'quadIn')
    doTweenAlpha('stagecurtains','stagecurtains',0.5,0.3,'quadIn')
    doTweenAlpha('burnmark1','burnmark1',0.3,0.3,'quadIn')
    doTweenAlpha('stage_light1','stage_light1',0.3,0.3,'quadIn')
    doTweenAlpha('stage_light2','stage_light2',0.3,0.3,'quadIn')
  end

  if curStep == 1024 then
    doTweenAlpha('checkerboard','checkerboard',0,0.5,'quadIn')
    doTweenAlpha('stagefront','stagefront',1,0.5,'quadIn')
    doTweenAlpha('stagecurtains','stagecurtains',1,0.5,'quadIn')
    doTweenAlpha('burnmark1','burnmark1',1,0.5,'quadIn')
    doTweenAlpha('stage_light1','stage_light1',1,0.5,'quadIn')
    doTweenAlpha('stage_light2','stage_light2',1,0.5,'quadIn')
  end

  if curStep == 1055 then
    doTweenAlpha('checkerboard','checkerboard',0.40,0.2,'quadIn')
    doTweenAlpha('stagefront','stagefront',0.3,0.2,'quadIn')
    doTweenAlpha('stagecurtains','stagecurtains',0.5,0.2,'quadIn')
    doTweenAlpha('burnmark1','burnmark1',0.3,0.2,'quadIn')
    doTweenAlpha('stage_light1','stage_light1',0.3,0.2,'quadIn')
    doTweenAlpha('stage_light2','stage_light2',0.3,0.2,'quadIn')
  end

  if curStep == 1120 then
    doTweenAlpha('checkerboard','checkerboard',0.55,0.25, 'quadIn')
  end

  if curStep == 1216 then
    doTweenAlpha('checkerboard','checkerboard',0.65,0.25, 'quadIn')
  end

  if curStep == 1316 then
    doTweenAlpha('sunburntCheckerboardFadeOut','checkerboard',0,0.25,'quadIn')
    doTweenAlpha('stagefront','stagefront',1,0.25,'quadIn')
    doTweenAlpha('stagecurtains','stagecurtains',1,0.25,'quadIn')
    doTweenAlpha('burnmark1','burnmark1',1,0.25,'quadIn')
    doTweenAlpha('stage_light1','stage_light1',1,0.25,'quadIn')
    doTweenAlpha('stage_light2','stage_light2',1,0.25,'quadIn')
  end
end

function onTweenCompleted(tag)
  if tag == 'sunburntCheckerboardFadeOut' then
    shaderRunning = false
  end
end
