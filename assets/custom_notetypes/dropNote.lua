


local NOTE_TYPE = 'dropNote'
local NOTE_TEXTURE = 'fahmix/week 3/drop-note'
local NOTE_FRAME_RATE = 4

local function configureDropNotes()
    for i = 0, getProperty('unspawnNotes.length') - 1 do
        if getPropertyFromGroup('unspawnNotes', i, 'noteType') == NOTE_TYPE then
            setPropertyFromGroup('unspawnNotes', i, 'texture', NOTE_TEXTURE)
            setPropertyFromGroup('unspawnNotes', i,
                'animation.curAnim.frameRate', NOTE_FRAME_RATE)
        end
    end
end

function onCreatePost()
    
    configureDropNotes()
end

function onSpawnNote(id, direction, noteType)
    if noteType == NOTE_TYPE then
        setPropertyFromGroup('notes', id, 'animation.curAnim.frameRate',
            NOTE_FRAME_RATE)
    end
end
