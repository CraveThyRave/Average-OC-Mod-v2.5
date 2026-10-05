
trailEnabledDad = false;
trailEnabledBF = false;
timerStartedDad = false;
timerStartedBF = false;
local inactiveTicksDad = 0
local inactiveTicksBF = 0

trailLength = 5;
trailDelay = 0.05;

function onEvent(name, value1, value2)
	if name == "Toggle Trail" then
		if (tonumber(value1) or 0) > 0 then
			if not timerStartedDad then
				runTimer('timerTrailDad', trailDelay, 0);
				timerStartedDad = true;
			end
			trailEnabledDad = true;
			inactiveTicksDad = 0;
		else
			trailEnabledDad = false;
		end

		if (tonumber(value2) or 0) > 0 then
			if not timerStartedBF then
				runTimer('timerTrailBF', trailDelay, 0);
				timerStartedBF = true;
			end
			trailEnabledBF = true;
			inactiveTicksBF = 0;
		else
			trailEnabledBF = false;
		end
	end
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'timerTrailDad' then
		createTrailFrame('Dad');
		if not trailEnabledDad then
			inactiveTicksDad = inactiveTicksDad + 1
			if inactiveTicksDad >= trailLength then
				cancelTimer(tag)
				timerStartedDad = false
			end
		end
	end

	if tag == 'timerTrailBF' then
		createTrailFrame('BF');
		if not trailEnabledBF then
			inactiveTicksBF = inactiveTicksBF + 1
			if inactiveTicksBF >= trailLength then
				cancelTimer(tag)
				timerStartedBF = false
			end
		end
	end
end

curTrailDad = 0;
curTrailBF = 0;
function createTrailFrame(tag)
	num = 0;
	color = -1;
	image = '';
	frame = 'BF idle dance';
	x = 0;
	y = 0;
	scaleX = 0;
	scaleY = 0;
	offsetX = 0;
	offsetY = 0;
	flipX = false;

	if tag == 'BF' then
		num = curTrailBF;
		curTrailBF = curTrailBF + 1;
		if trailEnabledBF then
			color = getColorFromHex('00F7FF');
			image = getProperty('boyfriend.imageFile')
			frame = getProperty('boyfriend.animation.frameName');
			x = getProperty('boyfriend.x');
			y = getProperty('boyfriend.y');
			scaleX = getProperty('boyfriend.scale.x'); 
			scaleY = getProperty('boyfriend.scale.y'); 
			offsetX = getProperty('boyfriend.offset.x');
			offsetY = getProperty('boyfriend.offset.y');
			flipX = getProperty('boyfriend.flipX')
		end
	else
		num = curTrailDad;
		curTrailDad = curTrailDad + 1;
		if trailEnabledDad then
			color = getColorFromHex('FF0800');
			image = getProperty('dad.imageFile')
			frame = getProperty('dad.animation.frameName');
			x = getProperty('dad.x');
			y = getProperty('dad.y');
			scaleX = getProperty('dad.scale.x');
			scaleY = getProperty('dad.scale.y');
			offsetX = getProperty('dad.offset.x');
			offsetY = getProperty('dad.offset.y');
			flipX = getProperty('dad.flipX')
		end
	end

	if num - trailLength + 1 >= 0 then
		for i = (num - trailLength + 1), (num - 1) do
			local fadingTag = 'psychicTrail'..tag..i
			if luaSpriteExists(fadingTag) then
				setProperty(fadingTag..'.alpha', getProperty(fadingTag..'.alpha') - (0.6 / (trailLength - 1)))
			end
		end
	end
	removeLuaSprite('psychicTrail'..tag..(num - trailLength));

	if not (image == '') then
		trailTag = 'psychicTrail'..tag..num;
		makeAnimatedLuaSprite(trailTag, image, x, y);
		setProperty(trailTag..'.offset.x', offsetX);
		setProperty(trailTag..'.offset.y', offsetY);
		setProperty(trailTag..'.scale.x', scaleX);
		setProperty(trailTag..'.scale.y', scaleY);
		setProperty(trailTag..'.flipX', flipX);
		setProperty(trailTag..'.alpha', 0.6);
		setProperty(trailTag..'.color', color);
		setBlendMode(trailTag, 'add');
		addAnimationByPrefix(trailTag, 'stuff', frame, 0, false);
		addLuaSprite(trailTag, false);
	end
end
