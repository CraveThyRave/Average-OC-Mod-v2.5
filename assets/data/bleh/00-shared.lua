 
 
local gunsSharedScripts = {
	'data/pews/04-gameover',
    'data/pews/05-hud'
}

function onCreate()
    for _, script in ipairs(gunsSharedScripts) do
        addLuaScript(script)
    end
    close(true)
end
