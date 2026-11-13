
local deathLineSave = 'gunsDeathLines'

function onCreate()
    initSaveData(deathLineSave, 'psychenginemods')

    if not usesFahMixGameOver() then
        setPropertyFromClass('GameOverSubstate', 'characterName', 'tankfah-playable-gameover')
        setPropertyFromClass('GameOverSubstate', 'deathSoundName', 'fah_loss')
        setPropertyFromClass('GameOverSubstate', 'loopSoundName', 'gameover-fah')
        setPropertyFromClass('GameOverSubstate', 'endSoundName', 'fah-gameover-enter')
    end

    
    setDataFromSave(deathLineSave, 'lineCount', 9)
    flushSaveData(deathLineSave)
end

function onGameOverStart()
    if not usesFahMixGameOver() then scaleObject('boyfriend', 1.5, 1.5) end
end
