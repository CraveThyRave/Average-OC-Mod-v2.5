
local deathSounds = {}
local deathSoundIDs = {}
local selectedDeathSound = nil
local selectedDeathLine = nil
local queuedVoice = false
local deathLineSave = 'sunburntDeathLines'
local deathVoiceDelay = 1
local deathVoiceVolume = 2.5

function onCreate()
    addHaxeLibrary('GameOverSubstate')
    initSaveData(deathLineSave, 'psychenginemods')

    setPropertyFromClass('GameOverSubstate', 'characterName', 'aom-bf-gameover')
    setPropertyFromClass('GameOverSubstate', 'deathSoundName', 'fnf_loss_sfx')
    setPropertyFromClass('GameOverSubstate', 'loopSoundName', 'gameover')
    setPropertyFromClass('GameOverSubstate', 'endSoundName', 'gameOverEnd')

    
    local i = 1

    while true do
        local path = 'sounds/deathlines/' .. i .. '.ogg'

        if checkFileExists(path) and i ~= 11 then
            table.insert(deathSounds, 'deathlines/' .. i)
            table.insert(deathSoundIDs, i)
        else
            break
        end

        i = i + 1
    end

    
    
    setDataFromSave(deathLineSave, 'lineCount', #deathSounds)
    flushSaveData(deathLineSave)
end

function setToCharCamPosition(char, offset)
    char = tostring(char)
    offset = tostring(offset)

    local baseX = getMidpointX(char)
    local baseY = getMidpointY(char)

    if baseX == nil then baseX = getProperty(char .. '.x') or 0 end
    if baseY == nil then baseY = getProperty(char .. '.y') or 0 end

    local offsetX = (offset == 'dad' and 150 or offset == 'gf' and 0 or offset == 'bf' and -100 or 0)
    local offsetY = (offset == 'dad' and -100 or offset == 'gf' and 0 or offset == 'bf' and -100 or 0)

    local camX = baseX + offsetX
    local camY = baseY + offsetY

    local camPosX = 0
    local camPosY = 0

    if getProperty(char .. '.cameraPosition') ~= nil then
        camPosX = getProperty(char .. '.cameraPosition[0]') or 0
        camPosY = getProperty(char .. '.cameraPosition[1]') or 0
    end

    if offset == 'bf' then
        camX = camX - camPosX
    else
        camX = camX + camPosX
    end

    camY = camY + camPosY

    
    setProperty('camFollow.x', camX)
    setProperty('camFollow.y', camY)
end

function onGameOverStart()
    queuedVoice = false
    selectedDeathLine = nil
    selectedDeathSound = nil

    if #deathSounds > 0 then
        local selectedDeathIndex = getRandomInt(1, #deathSounds)
        selectedDeathLine = deathSoundIDs[selectedDeathIndex]
        selectedDeathSound = deathSounds[selectedDeathIndex]
    end

    setProperty('cameraSpeed', 100)

    
    setToCharCamPosition('boyfriend', 'bf')
    runTimer('fixCam', 0.001)
end

function onTimerCompleted(tag)
    if tag == 'fixCam' then
        setToCharCamPosition('boyfriend', 'bf')
    elseif tag == 'playPhoenixDeathLine' then
        if selectedDeathSound ~= nil then
            
            playSound(selectedDeathSound, deathVoiceVolume, 'deathVoice')

            
            
            setDataFromSave(deathLineSave, 'line' .. selectedDeathLine, true)
            flushSaveData(deathLineSave)
            runHaxeCode([[
                if (GameOverSubstate.instance != null) {
                    GameOverSubstate.instance.recordPhoenixDeathLine(]] .. selectedDeathLine .. [[);
                }
            ]])
        end
    end
end

function onUpdate()
    
    
end
