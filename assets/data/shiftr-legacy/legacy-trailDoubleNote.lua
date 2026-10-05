function getIconColor(chr)
	return getColorFromHex(rgbToHex(getProperty(chr .. ".healthColorArray")))
end

function rgbToHex(array)
	return string.format('%.2x%.2x%.2x', array[1], array[2], array[3])
end

function goodNoteHit(id, direction, noteType, isSustainNote)
	if _G['boyfriendGhostData.strumTime'] == getPropertyFromGroup('notes', id, 'strumTime') and not isSustainNote then
		createGhost('boyfriend')
	end
	if not isSustainNote then
		_G['boyfriendGhostData.strumTime'] = getPropertyFromGroup('notes', id, 'strumTime')
		updateGData('boyfriend')	
	end
end
function opponentNoteHit(id, direction, noteType, isSustainNote)
	if _G['dadGhostData.strumTime'] == getPropertyFromGroup('notes', id, 'strumTime') and not isSustainNote then
		createGhost('dad')
	end
	if not isSustainNote then
		_G['dadGhostData.strumTime'] = getPropertyFromGroup('notes', id, 'strumTime')
		updateGData('dad')	
	end
end

local ghostIndex = 0

function createGhost(char)
	ghostIndex = ghostIndex + 1
	local ghostTag = char..'Ghost'..ghostIndex
    makeAnimatedLuaSprite(ghostTag, getProperty(char..'.imageFile'),getProperty(char..'.x'),getProperty(char..'.y'))
    addLuaSprite(ghostTag, false)
    setProperty(ghostTag..'.scale.x',getProperty(char..'.scale.x'))
	setProperty(ghostTag..'.scale.y',getProperty(char..'.scale.y'))
	setProperty(ghostTag..'.flipX', getProperty(char..'.flipX'))
	 
	setProperty(ghostTag..'.alpha', 0.8)
	doTweenAlpha(ghostTag..'delete', ghostTag, 0, 0.4)
	setProperty(ghostTag..'.animation.frameName', _G[char..'GhostData.frameName'])
	setProperty(ghostTag..'.offset.x', _G[char..'GhostData.offsetX'])
	setProperty(ghostTag..'.offset.y', _G[char..'GhostData.offsetY'])
	setObjectOrder(ghostTag, getObjectOrder(char..'Group')-1)
end

function onTweenCompleted(tag)
	if (tag:sub(#tag- 5, #tag)) == 'delete' then
		removeLuaSprite(tag:sub(1, #tag - 6), true)
	end
end

function updateGData(char)
	_G[char..'GhostData.frameName'] = getProperty(char..'.animation.frameName')
	_G[char..'GhostData.offsetX'] = getProperty(char..'.offset.x')
	_G[char..'GhostData.offsetY'] = getProperty(char..'.offset.y')
end

 
