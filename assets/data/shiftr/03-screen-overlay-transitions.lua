local logoShown = false
local logoHidden = false
function onCreate()


  makeLuaSprite('logo', 'Freeplay-Chrs/gabriella/gabby/logo', 320, -500);
  setProperty('logo.flipX', getPropertyFromClass('MirrorMode', 'active'))
	scaleObject('logo', 0.47, 0.47);
	setObjectCamera('logo', 'other')
	addLuaSprite('logo', false);

end


function onStepHit()




    if curStep >= 795 and not logoShown then
      logoShown = true
      doTweenY('logo', 'logo', (screenHeight - getProperty('logo.height')) * 0.5, 1, 'Quartout')
    end

    if curStep >= 824 and not logoHidden then
      logoHidden = true
      doTweenX('logo2', 'logo.scale', 0, 0.9, 'quintIn')
      doTweenY('logo24', 'logo.scale', 0, 0.9, 'quintIn')
    end

end
