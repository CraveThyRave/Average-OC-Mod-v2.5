function onCreate()
    
    if usesFahMixGameOver() then return end
    setPropertyFromClass('GameOverSubstate', 'characterName', 'fah-playable-gameover')
    setPropertyFromClass('GameOverSubstate', 'deathSoundName', 'fnf_loss_sfx')
    setPropertyFromClass('GameOverSubstate', 'loopSoundName', 'gameover-fah')
    setPropertyFromClass('GameOverSubstate', 'endSoundName', 'fah-gameover-enter')
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

    setProperty('camFollowPos.x', camX)
    setProperty('camFollowPos.y', camY)
end

function onGameOverStart()
    if usesFahMixGameOver() then return end
    
    setProperty('cameraSpeed', 100)

    
    setToCharCamPosition('boyfriend', 'bf')
    runTimer('fixCam', 0.001)
end

function onTimerCompleted(tag)
    if tag == 'fixCam' and not usesFahMixGameOver() then
        setToCharCamPosition('boyfriend', 'bf')
    end
end
