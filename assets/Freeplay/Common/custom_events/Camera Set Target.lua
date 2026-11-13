 
 
 
 
 

local onGF = false;

function onEvent(n,v1)
if n ~= 'Camera Set Target' then return end
if string.lower(songName or '') ~= 'shiftr-legacy' then return end
cameraSetTarget(v1)
if v1 == 'gf' then 
onGF = true;
            triggerEvent('Camera Follow Pos',getMidpointX('gf')+getProperty('gf.cameraPosition[0]'),getMidpointY('gf')+getProperty('gf.cameraPosition[1]'));
    end
end  

function opponentNoteHit()
    if (onGF) then
        triggerEvent('Camera Follow Pos',nil,nil);
        onGF = false;
    end
end

function goodNoteHit()
    if (onGF) then
        triggerEvent('Camera Follow Pos',nil,nil);
        onGF = false;
    end
end
