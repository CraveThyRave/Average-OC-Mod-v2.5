
local flashColors = {
	[1] = 'ff0000',
	[2] = 'ffffff',
	[3] = '000000',
	[4] = '0000ff',
	[5] = 'ffff00'
}

function onCreate()
	makeLuaSprite('flash', '', 0, 0)
	 
	 
	makeGraphic('flash', 4, 4, 'ffffff')
	scaleObject('flash', 500, 500)
	setScrollFactor('flash', 0, 0)
	setProperty('flash.alpha', 0)
	setObjectCamera('flash', 'other')
	addLuaSprite('flash', true)
end

function onEvent(name, value1, value2)
	if name == 'Flash' then
		local duration = tonumber(value2) or 0
		local color = tonumber(value1) or 2
		cancelTimer('flashDuration')
		cancelTween('flashDisapears')
		makeGraphic('flash', 4, 4, flashColors[color] or 'ffffff')
		scaleObject('flash', 500, 500)
		setProperty('flash.visible', true)
		setProperty('flash.alpha', 1)
		runTimer('flashDuration', duration, 1)
		
	end
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'flashDuration' then
		doTweenAlpha('flashDisapears', 'flash', 0, 1, 'linear')
	end
end
