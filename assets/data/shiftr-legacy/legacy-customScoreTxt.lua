 
 
 

 
noRatingScoreFormat =  'Misses: %misses | Accuracy: %rating'
scoreFormat = 'Misses: %misses | Rating: %rating (%percent%)'
percentDecimals = 2

 
noRatingName = '?'
ratingNames = {
	{100, "FC"},
	{90, "Doing Fine."},
	{70, "Decent"},
	{40, "Try Botplay."},
	{20, "Try Botplay."},
	{0, "Try Botplay."}
}

local errors
function updateRating()
	luaDebugMode = true
	local percent, rating = tonumber(getProperty("ratingPercent")) * 100, noRatingName
	local health = math.max(0, math.min(getHealth() * 50, 100))
	local showAcc = hits ~= 0

	if showAcc then
		local v
		for i = #ratingNames, 1, -1 do
			v = ratingNames[i]
			if (percent >= v[1]) then
				rating = v[2]
			else
				break
			end
		end
	end

	local decimals = 10 ^ percentDecimals
	percent = math.floor(percent * decimals) / decimals

	local str = showAcc and scoreFormat or noRatingScoreFormat
	str = str:gsub('%%misses', misses)
	str = str:gsub('%%rating', rating)
	str = str:gsub('%%percent', percent)

	setTextString("scoreTxt", str)
end

 
function onUpdateScore()
	onUpdate = nil; onUpdateScore = updateRating
	return updateRating()
end

onUpdate = updateRating
