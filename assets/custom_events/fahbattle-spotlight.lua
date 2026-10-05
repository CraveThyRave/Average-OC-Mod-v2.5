function onCreate()
	makeAnimatedLuaSprite('light', 'fahmix/week1/light-dad-fah', 1830, 590)
	addAnimationByPrefix('light', 'idle', 'light-dad-fah idle', 3, true)
	addLuaSprite('light', true)
  setProperty('light.alpha', 0)
	scaleObject('light', 0.8, 1);

  makeAnimatedLuaSprite('light2', 'fahmix/week1/light-dad-fah', 930, 616)
  addAnimationByPrefix('light2', 'idle', 'light-dad-fah idle', 3, true)
  addLuaSprite('light2', true)
  setProperty('light2.alpha', 0)
  scaleObject('light2', 1.05, 1);
end

function onCreatePost()
  
  if luaSpriteExists('frontCurtain') then
    setObjectOrder('light', getObjectOrder('frontCurtain'))
    setObjectOrder('light2', getObjectOrder('frontCurtain'))
  end
end





function onEvent(name, value1, value2)
    if name == 'fahbattle-spotlight' then
        if value1 == 'true' then
            doTweenAlpha('darkOverlayTween', 'darkOverlay', 0.9, 0.2, 'quadInOut')

		if value2 == 'both' then
			cancelTimer('spotlightFade')
			cancelTimer('spotlightFade2')
			doTweenAlpha('bfAlpha', 'boyfriend', 1, 1, 'quadInOut')
			doTweenAlpha('dadAlpha', 'dad', 1, 1, 'quadInOut')

			doTweenX('spotlightX', 'spotlight', 1920, 0.7, 'quadInOut')
			doTweenAngle('spotlightAngle', 'spotlight', -40, 0.7, 'quadInOut')
			doTweenX('spotlightX2', 'spotlight2', 1100, 0.7, 'quadInOut')
			doTweenAngle('spotlightAngle2', 'spotlight2', 40, 0.7, 'quadInOut')
			runTimer('spotlightFade', 0.7)
			runTimer('spotlightFade2', 0.7)
		elseif value2 == 'dad' then
                cancelTimer('spotlightFade')
                doTweenAlpha('light', 'light', 0, 0.2, 'quadInOut')
                doTweenAlpha('bfAlpha', 'boyfriend', 0.3, 1, 'quadInOut')
                doTweenAlpha('dadAlpha', 'dad', 1, 1, 'quadInOut')


                doTweenX('spotlightX', 'spotlight', 2100, 0.7, 'quadInOut')
                doTweenAngle('spotlightAngle', 'spotlight', 0, 0.7, 'quadInOut')



                doTweenX('spotlightX2', 'spotlight2', 1100, 0.7, 'quadInOut')
                doTweenAngle('spotlightAngle2', 'spotlight2', 40, 0.7, 'quadInOut')
                runTimer('spotlightFade2', 0.7)


            elseif value2 == 'bf' then
                cancelTimer('spotlightFade2')
                doTweenAlpha('light2', 'light2', 0, 0.2, 'quadInOut')

                doTweenX('spotlightX2', 'spotlight2', 1000, 0.7, 'quadInOut')
                doTweenAngle('spotlightAngle2', 'spotlight2', 0, 0.7, 'quadInOut')

                doTweenAlpha('dadAlpha', 'dad', 0.3, 1, 'quadInOut')
                doTweenAlpha('bfAlpha', 'boyfriend', 1, 1, 'quadInOut')

                doTweenX('spotlightX', 'spotlight', 1920, 0.7, 'quadInOut')
                doTweenAngle('spotlightAngle', 'spotlight', -40, 0.7, 'quadInOut')
                runTimer('spotlightFade', 0.7)

            end

        elseif value1 == 'false' then
            
            cancelTimer('spotlightFade')
            cancelTimer('spotlightFade2')

            
            doTweenAlpha('darkOverlayTween', 'darkOverlay', 0, 1, 'quadInOut')

            
            doTweenAlpha('bfAlpha', 'boyfriend', 1, 1, 'quadInOut')
            doTweenAlpha('dadAlpha', 'dad', 1, 1, 'quadInOut')

            
            doTweenAlpha('light', 'light', 0, 0.2, 'quadInOut')
            doTweenAlpha('light2', 'light2', 0, 0.2, 'quadInOut')

            
            doTweenX('spotlightX', 'spotlight', 2100, 0.7, 'quadInOut')
            doTweenAngle('spotlightAngle', 'spotlight', 0, 0.7, 'quadInOut')

            
            doTweenX('spotlightX2', 'spotlight2', 1000, 0.7, 'quadInOut')
            doTweenAngle('spotlightAngle2', 'spotlight2', 0, 0.7, 'quadInOut')

        end
    end
end


function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'spotlightFade' then
      doTweenAlpha('light', 'light', 1, 0.6, 'quadInOut')
    end

    if tag == 'spotlightFade2' then
      doTweenAlpha('light2', 'light2', 1, 0.6, 'quadInOut')
    end
end
