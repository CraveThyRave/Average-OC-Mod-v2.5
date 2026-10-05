local NOTE_TYPE = 'MicNote'
local NOTE_TEXTURE = 'fahmix/week1/MicNotes'
local NOTE_FRAME_RATE = 4

local function configureMicNote(group, index)
    if getPropertyFromGroup(group, index, 'noteType') ~= NOTE_TYPE then
        return
    end

    setPropertyFromGroup(group, index, 'texture', NOTE_TEXTURE)
    setPropertyFromGroup(group, index, 'animation.curAnim.frameRate',
        NOTE_FRAME_RATE)
    local animSuffix = '-alt'
    local fahNote = getPropertyFromGroup(group, index, 'mustPress')
    if getPropertyFromClass('MirrorMode', 'active') then
        fahNote = getPropertyFromGroup(group, index, 'chartPlayer')
    end
    if fahNote then
        animSuffix = '-mic'
    end

    setPropertyFromGroup(group, index, 'animSuffix', animSuffix)

    setPropertyFromGroup(group, index, 'missAnimSuffix', '')
end

function onCreate()
    for i = 0, getProperty('unspawnNotes.length') - 1 do
        configureMicNote('unspawnNotes', i)
    end
end

function onSpawnNote(id, direction, noteType, isSustainNote)
    if noteType == NOTE_TYPE then
        setPropertyFromGroup('notes', id, 'animation.curAnim.frameRate',
            NOTE_FRAME_RATE)
    end
end

function goodNoteHit(id, direction, noteType, isSustainNote)
    if noteType == NOTE_TYPE then
        setPropertyFromGroup('notes', id, 'animation.curAnim.frameRate',
            NOTE_FRAME_RATE)
    end
end
