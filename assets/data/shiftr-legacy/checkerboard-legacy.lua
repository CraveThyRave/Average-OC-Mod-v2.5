function onCreatePost()
   initLuaShader("checkerboard-legacy")

end


function onUpdate()
 setShaderFloat("checkerboard-legacy", "iTime", os.clock())
end



function onCreate()

	makeLuaSprite('checkerboard-legacy', 'Freeplay-Chrs/gabriella/legacy-shiftr/gabby/checkerboard', -310, 200);
	scaleObject('checkerboard-legacy', 3.3, 3.3);
	setSpriteShader('checkerboard-legacy',"checkerboard-legacy")
  setProperty('checkerboard-legacy.alpha', 0)
	addLuaSprite('checkerboard-legacy', false);
  setObjectCamera('checkerboard-legacy', 'camgame');


end


function onStepHit()
  if curStep == 1295 then
    doTweenAlpha('checkerboard-legacy','checkerboard-legacy',0.35,0.7,'quadIn')
  end
  if curStep == 1513 then
    doTweenAlpha('checkerboard-legacy','checkerboard-legacy',0.30,0.5,'quadIn')
  end
  if curStep == 1696 then
    doTweenAlpha('checkerboard-legacy','checkerboard-legacy',0.20,0.2,'quadIn')
  end
  if curStep == 1792 then
    doTweenAlpha('checkerboard-legacy','checkerboard-legacy',0,2.7,'quadIn')
  end
end

