


local currentSide = 'left'
local cameraMode = 'default'

function onCreatePost()
    setProperty('gf.stunned', true)
end





function onEvent(name, value1, value2)

    if name == 'CameraControl' then

        local split = {}

        for str in string.gmatch(value1, '([^,]+)') do
            table.insert(split, str)
        end

        local mode = string.lower(split[1] or '')

        cameraMode = mode


        


        if mode == 'dad' then


            


            if currentSide == 'middle' then

                characterPlayAnim('gf', 'mid2left', true)


            


            elseif currentSide == 'right' then

                characterPlayAnim('gf', 'right2left', true)


            


            else

                characterPlayAnim('gf', 'idle-left', true)
            end

            setProperty('gf.specialAnim', true)

            currentSide = 'left'
        end


        


        if mode == 'bf' or mode == 'boyfriend' then


            


            if currentSide == 'middle' then

                characterPlayAnim('gf', 'mid2right', true)


            


            elseif currentSide == 'left' then

                characterPlayAnim('gf', 'left2right', true)


            


            else

                characterPlayAnim('gf', 'idle-right', true)
            end

            setProperty('gf.specialAnim', true)

            currentSide = 'right'
        end


        


        if mode == 'middle' then


            


            if currentSide == 'left' then

                characterPlayAnim('gf', 'left2mid', true)


            


            elseif currentSide == 'right' then

                characterPlayAnim('gf', 'right2mid', true)


            


            else

                characterPlayAnim('gf', 'idle-middle', true)
            end

            setProperty('gf.specialAnim', true)

            currentSide = 'middle'
        end
    end
end





function onSectionHit()

    if cameraMode ~= 'default' then
        return
    end


    


    if mustHitSection then


        


        if currentSide == 'middle' then

            characterPlayAnim('gf', 'mid2right', true)


        


        elseif currentSide == 'left' then

            characterPlayAnim('gf', 'left2right', true)
        end

        currentSide = 'right'


    


    else


        


        if currentSide == 'middle' then

            characterPlayAnim('gf', 'mid2left', true)


        


        elseif currentSide == 'right' then

            characterPlayAnim('gf', 'right2left', true)
        end

        currentSide = 'left'
    end

    setProperty('gf.specialAnim', true)
end





function onBeatHit()

    
    if curBeat % 2 == 0 then

        local anim = getProperty('gf.animation.curAnim.name')

        
        if anim == 'left2right'
        or anim == 'right2left'
        or anim == 'left2mid'
        or anim == 'right2mid'
        or anim == 'mid2left'
        or anim == 'mid2right' then
            return
        end


        


        if currentSide == 'left' then
            characterPlayAnim('gf', 'idle-left', true)
        end


        


        if currentSide == 'right' then
            characterPlayAnim('gf', 'idle-right', true)
        end


        


        if currentSide == 'middle' then
            characterPlayAnim('gf', 'idle-middle', true)
        end

        setProperty('gf.specialAnim', true)
    end
end





function onUpdate()

    local anim = getProperty('gf.animation.curAnim.name')


    


    if anim == 'left2right' then

        if getProperty('gf.animation.curAnim.finished') then

            characterPlayAnim('gf', 'idle-right', true)
            setProperty('gf.specialAnim', true)
        end
    end


    


    if anim == 'right2left' then

        if getProperty('gf.animation.curAnim.finished') then

            characterPlayAnim('gf', 'idle-left', true)
            setProperty('gf.specialAnim', true)
        end
    end


    


    if anim == 'left2mid' then

        if getProperty('gf.animation.curAnim.finished') then

            characterPlayAnim('gf', 'idle-middle', true)
            setProperty('gf.specialAnim', true)
        end
    end


    


    if anim == 'right2mid' then

        if getProperty('gf.animation.curAnim.finished') then

            characterPlayAnim('gf', 'idle-middle', true)
            setProperty('gf.specialAnim', true)
        end
    end


    


    if anim == 'mid2left' then

        if getProperty('gf.animation.curAnim.finished') then

            characterPlayAnim('gf', 'idle-left', true)
            setProperty('gf.specialAnim', true)
        end
    end


    


    if anim == 'mid2right' then

        if getProperty('gf.animation.curAnim.finished') then

            characterPlayAnim('gf', 'idle-right', true)
            setProperty('gf.specialAnim', true)
        end
    end
end
