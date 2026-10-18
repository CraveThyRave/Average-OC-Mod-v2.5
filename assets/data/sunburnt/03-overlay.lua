
function onCreate()


  makeLuaSprite('dablackcam', 'dablack', 0, 0)
  setObjectCamera('dablackcam', 'camHUD')
  setProperty('dablackcam.alpha', 0)
  addLuaSprite('dablackcam', true)

  makeLuaSprite('logo', 'Freeplay-Chrs/phoenix/logo', 320, -500);
  setProperty('logo.flipX', getPropertyFromClass('MirrorMode', 'active'))
	scaleObject('logo', 0.47, 0.47);
	setObjectCamera('logo', 'other')
	addLuaSprite('logo', false);


  makeLuaSprite('dablack', 'dablack', 0, 0)
  setObjectCamera('dablack', 'other')
  setProperty('dablack.alpha', 0)
  addLuaSprite('dablack', true)


  makeLuaSprite('dawhitefront', 'dawhite', 0, 0)
  setObjectCamera('dawhitefront', 'other')
  setProperty('dawhitefront.alpha', 0)
  addLuaSprite('dawhitefront', true)
end


function onStepHit()

    if curStep == 1398 then
      doTweenAlpha('dablack', 'dablack', 1, 0.1, 'quadInOut')
    end

    if curStep == 1025 then
      doTweenY('logo', 'logo', (screenHeight - getProperty('logo.height')) * 0.5, 1, 'Quartout')
    end

    if curStep == 1049 then
      doTweenX('logo2', 'logo.scale', 0, 0.9, 'quintIn')
      doTweenY('logo24', 'logo.scale', 0, 0.9, 'quintIn')
    end

end
