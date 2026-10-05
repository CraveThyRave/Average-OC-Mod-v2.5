local camMode = 'default'

local camOffsetX = 0

local defaultCameraSpeed = 1

function onCreatePost()

    
    
    

    defaultCameraSpeed = getProperty('cameraSpeed')
end

function onEvent(name, value1, value2)

    if name == 'CameraControl' then

        
        
        

        local split = {}

        for str in string.gmatch(value1, '([^,]+)') do
            table.insert(split, str)
        end

        
        
        

        local mode = string.lower(split[1] or '')

        
        
        

        local offset = tonumber(split[2]) or 0

        
        
        setProperty('notePushX', 0)
        setProperty('notePushY', 0)
        setProperty('notePushTargetX', 0)
        setProperty('notePushTargetY', 0)
        setProperty('notePushTimer', 0)
        setProperty('notePushAngle', 0)
        setProperty('notePushAngleTarget', 0)
        setProperty('notePushAngleTimer', 0)

        
        
        

        value2 = tostring(value2 or '')
        value2 = string.lower(value2)

        
        
        

        if mode == 'dad' then

            camMode = 'dad'
            camOffsetX = offset
            setProperty('noteCameraMode', 0)

        elseif mode == 'bf' or mode == 'boyfriend' then

            camMode = 'bf'
            camOffsetX = offset
            setProperty('noteCameraMode', 1)

        elseif mode == 'middle' then

            camMode = 'middle'
            camOffsetX = offset
            setProperty('noteCameraMode', 2)

        elseif mode == 'default' then

            camMode = 'default'
            camOffsetX = 0
            setProperty('noteCameraMode', -1)

            triggerEvent('Camera Follow Pos', '', '')
            if value2 ~= 'snap' then return end
        end

        
        
        

        if value2 == 'snap' then

            
            
            

            setProperty('cameraSpeed', defaultCameraSpeed)
            onUpdate(0)
            snapCameraToFollow()

        else

            local speed = tonumber(value2)

            if speed ~= nil then
                setProperty('cameraSpeed', speed)
            end
        end
    end
end

function onUpdate(elapsed)

    
    
    

    
    
    

    if camMode == 'default' then
        return
    end

    
    
    

    local dadX
    local dadY

    if camMode ~= 'bf' then
        if getProperty('dad.curCharacter') == 'phoenix' then
            dadX = getMidpointX('dad') + getProperty('dad.cameraPosition[0]')
            dadY = getMidpointY('dad') + getProperty('dad.cameraPosition[1]') - 100
        else
            dadX = getMidpointX('dad') + 150
            dadY = getMidpointY('dad') - 100
        end
    end

    local bfX
    local bfY
    if camMode ~= 'dad' then
        bfX = getMidpointX('boyfriend') - 100
        bfY = getMidpointY('boyfriend') - 100
    end

    local targetX = 0
    local targetY = 0

    
    
    

    if camMode == 'dad' then

        targetX = dadX - camOffsetX
        targetY = dadY

    elseif camMode == 'bf' then

        targetX = bfX - camOffsetX
        targetY = bfY

    elseif camMode == 'middle' then

        targetX = ((dadX + bfX) / 2) - camOffsetX
        targetY = (dadY + bfY) / 2
    end

    
    
    

    triggerEvent('Camera Follow Pos', targetX, targetY)
end
