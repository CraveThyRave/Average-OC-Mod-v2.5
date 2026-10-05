function onEvent(name, value1, value2)
	if name == 'cameraZoomerios' then
		zoom = tonumber(value1) or 1;
		time = tonumber(value2) or 0;
		if time <= 0 then
			cancelTween('cameraZoom');
			setProperty('camGame.zoom', zoom);
			setProperty('defaultCamZoom', zoom);
		else
			doTweenZoom('cameraZoom', 'camGame', zoom, time, 'quadOut');
		end
	end
end

function onTweenCompleted(name)
    if name == 'cameraZoom' then
        setProperty('defaultCamZoom', zoom)
    end
end
