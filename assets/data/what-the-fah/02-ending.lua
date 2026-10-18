

local playedVideo = false

function onEndSong()
    if not shouldRepeatStoryBeats()
        and hasSeenStoryBeat('what-the-fah-cutscene') then
        return Function_Continue
    end

    
    if not playedVideo then
        playedVideo = true

        markStoryBeatSeen('what-the-fah-cutscene')

        startVideo('fahscene') 

        return Function_Stop 
    end

    
    return Function_Continue
end


function onVideoEnd()
    
    endSong()
end
