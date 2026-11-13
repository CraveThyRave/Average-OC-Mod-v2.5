 
 
local rosesHudScripts = {
    'data/roses/06-hud'
}

function onCreate()
    for _, script in ipairs(rosesHudScripts) do
        addLuaScript(script)
    end
end
