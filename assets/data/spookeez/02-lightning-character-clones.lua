
local lastAnim = ''
local lastDadAnim = ''


local posX = -175
local posY = -113


local dadPosX = 55
local dadPosY = 220

function onCreate()

    
    
    

    makeAnimatedLuaSprite('lightning-fah', 'fahmix/week2/Spooky-fah', 0, 0)

    addAnimationByPrefix('lightning-fah', 'idle', 'idle', 8, true)
    addAnimationByPrefix('lightning-fah', 'hey', 'hey', 14, false)

    addAnimationByIndices('lightning-fah', 'singUP', 'up', '2,1,0', 18, false)
    addAnimationByIndices('lightning-fah', 'singDOWN', 'down', '2,1,0', 18, false)
    addAnimationByIndices('lightning-fah', 'singLEFT', 'right', '2,1,0', 18, false)
    addAnimationByIndices('lightning-fah', 'singRIGHT', 'left', '2,1,0', 18, false)

    addAnimationByIndices('lightning-fah', 'singUP-alt', 'up-alt', '2,1,0', 18, false)
    addAnimationByIndices('lightning-fah', 'singDOWN-alt', 'down-alt', '2,1,0', 18, false)
    addAnimationByIndices('lightning-fah', 'singLEFT-alt', 'left-alt', '2,1,0', 18, false)
    addAnimationByIndices('lightning-fah', 'singRIGHT-alt', 'right-alt', '2,1,0', 18, false)

    addAnimationByIndices('lightning-fah', 'singUPmiss', 'u-miss', '0,1', 12, false)
    addAnimationByIndices('lightning-fah', 'singDOWNmiss', 'd-miss', '0,1', 12, false)
    addAnimationByIndices('lightning-fah', 'singLEFTmiss', 'r-miss', '', 12, false)
    addAnimationByIndices('lightning-fah', 'singRIGHTmiss', 'l-miss', '0,1,2', 12, false)

    addAnimationByIndices('lightning-fah', 'shake-right', 'headshake', '0,1', 12, false)
    addAnimationByIndices('lightning-fah', 'shake-left', 'headshake', '1,2', 12, false)

    addAnimationByPrefix('lightning-fah', 'idle2', 'dance-idle', 8, true)
    addAnimationByPrefix('lightning-fah', 'brace', 'brace', 8, true)

    addOffset('lightning-fah', 'idle', 173,112)
    addOffset('lightning-fah', 'hey', 130,160)

    addOffset('lightning-fah', 'singUP', 110,139)
    addOffset('lightning-fah', 'singDOWN', 112,118)
    addOffset('lightning-fah', 'singLEFT', 181,103)
    addOffset('lightning-fah', 'singRIGHT', 100,123)

    addOffset('lightning-fah', 'singUP-alt', 170,120)
    addOffset('lightning-fah', 'singDOWN-alt', 140,90)
    addOffset('lightning-fah', 'singLEFT-alt', 230,70)
    addOffset('lightning-fah', 'singRIGHT-alt', 70,80)

    addOffset('lightning-fah', 'singUPmiss', 160,161)
    addOffset('lightning-fah', 'singDOWNmiss', 160,132)
    addOffset('lightning-fah', 'singLEFTmiss', 159,99)
    addOffset('lightning-fah', 'singRIGHTmiss', 124,155)

    addOffset('lightning-fah', 'shake-right', 130,90)
    addOffset('lightning-fah', 'shake-left', 130,90)

    addOffset('lightning-fah', 'idle2', 300,190)
    addOffset('lightning-fah', 'brace', 133,89)

    addLuaSprite('lightning-fah', false)

    setObjectOrder('lightning-fah', getObjectOrder('boyfriendGroup') + 1)

    setProperty('lightning-fah.alpha', 0)
    setProperty('lightning-fah.flipX', true)

    
    
    

    makeAnimatedLuaSprite('lightning-spookykids', 'fahmix/week2/fah-spookykids', 0, 0)

    addAnimationByIndices('lightning-spookykids', 'idle', 'idle', '1,2,3,4,5,6,7', 10, true)
    addAnimationByPrefix('lightning-spookykids', 'idle-dance', 'idle-dance', 10, true)

    addAnimationByIndices('lightning-spookykids', 'singLEFT', 'left', '1,0', 10, false)
    addAnimationByIndices('lightning-spookykids', 'singDOWN', 'down', '1,0', 10, false)
    addAnimationByIndices('lightning-spookykids', 'singUP', 'up', '1,0', 10, false)
    addAnimationByIndices('lightning-spookykids', 'singRIGHT', 'right', '1,0', 10, false)

    addAnimationByPrefix('lightning-spookykids', 'singUP-alt', 'laugh', 10, false)
    addAnimationByPrefix('lightning-spookykids', 'hey', 'hey', 10, false)

    addOffset('lightning-spookykids', 'idle', -55,-219)
    addOffset('lightning-spookykids', 'idle-dance', -50,-230)

    addOffset('lightning-spookykids', 'singLEFT', -49,-222)
    addOffset('lightning-spookykids', 'singDOWN', -51,-220)
    addOffset('lightning-spookykids', 'singUP', -49,-230)
    addOffset('lightning-spookykids', 'singRIGHT', -61,-214)

    addOffset('lightning-spookykids', 'singUP-alt', -26,-229)
    addOffset('lightning-spookykids', 'hey', -32,-210)

    addLuaSprite('lightning-spookykids', false)

    setObjectOrder('lightning-spookykids', getObjectOrder('dadGroup') + 1)

    setProperty('lightning-spookykids.alpha', 0)
end

function onUpdatePost(elapsed)

    
    
    

    local anim = getProperty('boyfriend.animation.curAnim.name')

    if anim ~= lastAnim then
        objectPlayAnimation('lightning-fah', anim, true)
        lastAnim = anim
    end

    if getProperty('boyfriend.animation.curAnim') ~= nil then
        setProperty('lightning-fah.animation.curAnim.curFrame',
            getProperty('boyfriend.animation.curAnim.curFrame'))
    end

    local idle2X = -125
    local idle2Y = -75

    if anim == 'idle2' then
        setProperty('lightning-fah.x', getProperty('boyfriend.x') + posX + idle2X)
        setProperty('lightning-fah.y', getProperty('boyfriend.y') + posY + idle2Y)
    else
        setProperty('lightning-fah.x', getProperty('boyfriend.x') + posX)
        setProperty('lightning-fah.y', getProperty('boyfriend.y') + posY)
    end

    setProperty('lightning-fah.angle', getProperty('boyfriend.angle'))
    setProperty('lightning-fah.scale.x', getProperty('boyfriend.scale.x'))
    setProperty('lightning-fah.scale.y', getProperty('boyfriend.scale.y'))

    setProperty('lightning-fah.flipX', getProperty('boyfriend.flipX'))
    setProperty('lightning-fah.flipY', getProperty('boyfriend.flipY'))

    setProperty('lightning-fah.visible', getProperty('boyfriend.visible'))

    setScrollFactor('lightning-fah',
        getProperty('boyfriend.scrollFactor.x'),
        getProperty('boyfriend.scrollFactor.y'))

    
    
    

    local dadAnim = getProperty('dad.animation.curAnim.name')

    if dadAnim ~= lastDadAnim then
        objectPlayAnimation('lightning-spookykids', dadAnim, true)
        lastDadAnim = dadAnim
    end

    if getProperty('dad.animation.curAnim') ~= nil then
        setProperty('lightning-spookykids.animation.curAnim.curFrame',
            getProperty('dad.animation.curAnim.curFrame'))
    end

    setProperty('lightning-spookykids.x', getProperty('dad.x') + dadPosX)
    setProperty('lightning-spookykids.y', getProperty('dad.y') + dadPosY)

    setProperty('lightning-spookykids.angle', getProperty('dad.angle'))
    setProperty('lightning-spookykids.scale.x', getProperty('dad.scale.x'))
    setProperty('lightning-spookykids.scale.y', getProperty('dad.scale.y'))

    setProperty('lightning-spookykids.flipX', getProperty('dad.flipX'))
    setProperty('lightning-spookykids.flipY', getProperty('dad.flipY'))

    setProperty('lightning-spookykids.visible', getProperty('dad.visible'))

    setScrollFactor('lightning-spookykids',
        getProperty('dad.scrollFactor.x'),
        getProperty('dad.scrollFactor.y'))
end
