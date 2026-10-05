 
 
local gunsSharedScripts = {
	'data/pews/04-game-over-voice-lines',
    'data/pews/05-flyers-hud-overlay-and-transitions'
}

function onCreate()
    for _, script in ipairs(gunsSharedScripts) do
        addLuaScript(script)
    end
    close(true)
end
