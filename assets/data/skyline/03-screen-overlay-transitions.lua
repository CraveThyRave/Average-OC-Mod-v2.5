local creditsShown = false
local creditsHidden = false
local logoShown = false
local logoHidden = false
function onCreate()

  makeLuaSprite('credits', 'Freeplay-Chrs/nola/credits', -630, 50);
	scaleObject('credits', 0.65, 0.65);
	setObjectCamera('credits', 'other')
	addLuaSprite('credits', false);

  makeLuaSprite('logo', 'Freeplay-Chrs/nola/logo', 320, -800);
  setProperty('logo.flipX', getPropertyFromClass('MirrorMode', 'active'))
	scaleObject('logo', 0.47, 0.47);
	setObjectCamera('logo', 'other')
	addLuaSprite('logo', false);

end


function onStepHit()


    if curStep >= 1462 and not creditsShown then
      creditsShown = true
      doTweenX('credits', 'credits', 0, 0.5, 'Quadout')
    end

    if curStep >= 1500 and not creditsHidden then
      creditsHidden = true
      doTweenX('credits', 'credits', -630, 0.65, 'Quadout')
    end

    if curStep >= 1 and not logoShown then
      logoShown = true
      doTweenY('logo', 'logo', (screenHeight - getProperty('logo.height')) * 0.5, 1, 'Quartout')
    end

    if curStep >= 35 and not logoHidden then
      logoHidden = true
      doTweenX('logo2', 'logo.scale', 0, 0.9, 'quintIn')
      doTweenY('logo24', 'logo.scale', 0, 0.9, 'quintIn')
    end

end
