
function onCreate()
	close(true)
end

function onUpdatePost(elapsed)
	runHaxeCode([[
		var cams = [game.camGame, game.camHUD, game.camOther];

		for (cam in cams)
		{
			cam.flashSprite.scaleX = 2.8;
			cam.flashSprite.scaleY = 2.8;
			cam.setScale(cam.zoom / 2.8, cam.zoom / 2.8);
		}
	]]);
end
