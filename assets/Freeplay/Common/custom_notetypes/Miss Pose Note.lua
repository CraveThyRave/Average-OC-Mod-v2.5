local holdTime = 0.1

local bfHolding = false
local dadHolding = false

local bfMissAnim = ''
local dadMissAnim = ''

function goodNoteHit(id, direction, noteType, isSustainNote)
    if noteType == 'Miss Pose Note' and not bfHolding then
        local singAnims = {'singLEFT', 'singDOWN', 'singUP', 'singRIGHT'}
        local missAnims = {'singLEFTmiss', 'singDOWNmiss', 'singUPmiss', 'singRIGHTmiss'}

        bfHolding = true
        bfMissAnim = missAnims[direction + 1]

        
        characterPlayAnim('boyfriend', singAnims[direction + 1], true)

        
        runTimer('bfStartMiss', 0.08)

        runTimer('releaseBF', holdTime)
    end
end

function opponentNoteHit(id, direction, noteType, isSustainNote)
    if noteType == 'Miss Pose Note' and not dadHolding then
        local singAnims = {'singLEFT', 'singDOWN', 'singUP', 'singRIGHT'}
        local missAnims = {'singLEFTmiss', 'singDOWNmiss', 'singUPmiss', 'singRIGHTmiss'}

        dadHolding = true
        dadMissAnim = missAnims[direction + 1]

        
        characterPlayAnim('dad', singAnims[direction + 1], true)

        
        runTimer('dadStartMiss', 0.08)

        runTimer('releaseDad', holdTime)
    end
end

function onTimerCompleted(tag)
    if tag == 'bfStartMiss' then
        characterPlayAnim('boyfriend', bfMissAnim, true)

        local lastFrame = getProperty('boyfriend.animation.curAnim.numFrames') - 1

        setProperty('boyfriend.animation.curAnim.curFrame', lastFrame)
        setProperty('boyfriend.animation.curAnim.paused', true)
        setProperty('boyfriend.specialAnim', true)
    end

    if tag == 'dadStartMiss' then
        characterPlayAnim('dad', dadMissAnim, true)

        local lastFrame = getProperty('dad.animation.curAnim.numFrames') - 1

        setProperty('dad.animation.curAnim.curFrame', lastFrame)
        setProperty('dad.animation.curAnim.paused', true)
        setProperty('dad.specialAnim', true)
    end

    if tag == 'releaseBF' then
        bfHolding = false

        setProperty('boyfriend.animation.curAnim.paused', false)
        setProperty('boyfriend.specialAnim', false)
    end

    if tag == 'releaseDad' then
        dadHolding = false

        setProperty('dad.animation.curAnim.paused', false)
        setProperty('dad.specialAnim', false)
    end
end

function onUpdatePost()
    if bfHolding then
        setProperty('boyfriend.specialAnim', true)
    end

    if dadHolding then
        setProperty('dad.specialAnim', true)
    end
end
