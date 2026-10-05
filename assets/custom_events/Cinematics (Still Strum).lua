

HudAssets = {''}
Index = 1
local barsClosing = false
local barsActive = false

local function setBarsVisible(visible)
    setProperty('UpperBar(Still Strum).visible', visible)
    setProperty('LowerBar(Still Strum).visible', visible)
end

local function placeBarsUnderNotes()
    setObjectCamera('UpperBar(Still Strum)', 'hud')
    setObjectCamera('LowerBar(Still Strum)', 'hud')

    local noteOrder = math.min(
        getObjectOrder('notes'),
        getObjectOrder('strumLineNotes')
    )

    if getObjectOrder('UpperBar(Still Strum)') >= noteOrder then
        setObjectOrder('UpperBar(Still Strum)', noteOrder)
    end

    noteOrder = math.min(
        getObjectOrder('notes'),
        getObjectOrder('strumLineNotes')
    )

    if getObjectOrder('LowerBar(Still Strum)') >= noteOrder then
        setObjectOrder('LowerBar(Still Strum)', noteOrder)
    end

     
     
    local currentSong = string.lower(songName or '')
    if currentSong == 'roses' or currentSong == 'senpai' then
        runHaxeCode([[
            var hatred = game.variables.get('hatredTxt');
            var upper = game.getLuaObject('UpperBar(Still Strum)');
            var lower = game.getLuaObject('LowerBar(Still Strum)');
            if (hatred != null && (upper != null || lower != null))
            {
                game.remove(hatred, true);
                var upperIndex = upper == null ? -1 : game.members.indexOf(upper);
                var lowerIndex = lower == null ? -1 : game.members.indexOf(lower);
                game.insert((upperIndex > lowerIndex ? upperIndex : lowerIndex) + 1, hatred);
            }
        ]])
    end
end

function onCreatePost()
    local upperBarY = -1080
    local currentSong = string.lower(songName or '')
    if currentSong == 'roses' or currentSong == 'senpai' then
        upperBarY = upperBarY + 100
    end

    makeLuaSprite('UpperBar(Still Strum)', 'dablack', -110, upperBarY)
	setObjectCamera('UpperBar(Still Strum)', 'HUD')
	addLuaSprite('UpperBar(Still Strum)', false)

    makeLuaSprite('LowerBar(Still Strum)', 'dablack', -110, 720)
	setObjectCamera('LowerBar(Still Strum)', 'HUD')
	addLuaSprite('LowerBar(Still Strum)', false)

    placeBarsUnderNotes()
    setBarsVisible(false)

    UpperBar = getProperty('UpperBar(Still Strum).y')
	LowerBar = getProperty('LowerBar(Still Strum).y')

    for Notes = 0,7 do
        StrumY = getPropertyFromGroup('strumLineNotes', Notes, 'y')
    end
end

function onEvent(name, value1, value2)
	if name == 'Cinematics (Still Strum)' then
        placeBarsUnderNotes()

		Speed = tonumber(value1)
		Distance = tonumber(value2)
        if not Speed or not Distance then return end



		if Speed and Distance > 0 then
            barsClosing = false
            barsActive = true
            setBarsVisible(true)

			doTweenY('StillStrumCinematicUpper', 'UpperBar(Still Strum)', UpperBar + Distance, Speed, 'QuadOut')
			doTweenY('StillStrumCinematicLower', 'LowerBar(Still Strum)', LowerBar - Distance, Speed, 'QuadOut')

      runHaxeCode([[
          if (game.timeTxt != null)
          {
              game.remove(game.timeTxt);
              game.insert(game.members.indexOf(game.getLuaObject("fahclock")) + 1, game.timeTxt);
          }
      ]]);
      
			for Alphas = 1,8 do
                if HudAssets[Index] and HudAssets[Index] ~= '' then
                    doTweenAlpha('Alpha(Still Strum)'..Alphas, HudAssets[Index], 0, Speed - 0.1)
                end
				Index = Index + 1

				if Index > #HudAssets then
					Index = 1
				end
			end
		end

		if downscroll and Speed and Distance > 0 then

			doTweenY('StillStrumCinematicUpper', 'UpperBar(Still Strum)', UpperBar + Distance, Speed, 'QuadOut')
			doTweenY('StillStrumCinematicLower', 'LowerBar(Still Strum)', LowerBar - Distance, Speed, 'QuadOut')

			for Alphas = 1,8 do
				if HudAssets[Index] and HudAssets[Index] ~= '' then
					doTweenAlpha('Alpha(Still Strum)'..Alphas, HudAssets[Index], 0, Speed - 0.1)
				end
				Index = Index + 1

				if Index > #HudAssets then
					Index = 1

				end
			end
		end


		if Distance <= 0 then
            barsClosing = true

			doTweenY('StillStrumCinematicUpper', 'UpperBar(Still Strum)', UpperBar, Speed, 'QuadIn')
			doTweenY('StillStrumCinematicLower', 'LowerBar(Still Strum)', LowerBar, Speed, 'QuadIn')

			for Alphas = 1,8 do
                if HudAssets[Index] and HudAssets[Index] ~= '' then
                    doTweenAlpha('Alpha(Still Strum)'..Alphas, HudAssets[Index], 1, Speed + 0.1)
                end
				Index = Index + 1

				if Index > #HudAssets then
					Index = 1

				end
			end
		end
	end
end

function onTweenCompleted(tag)
    if barsClosing and (tag == 'StillStrumCinematicUpper' or tag == 'StillStrumCinematicLower') then
        barsClosing = false
        barsActive = false
        setBarsVisible(false)
    end
end
