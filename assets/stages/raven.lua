local lowQualityStaticVideos = {
	megalo = 'megalo', ddlc = 'ddlc', greenhill = 'greenhill',
	bigshot = 'bigshot', bigshot2 = 'bigshot2', fnaf = 'fnaf',
	gourmet = 'gourmet', crashBack = 'scratch', angel = 'angel',
	one = 'one', celeste = 'celeste', minecraft = 'minecraft',
	touhou = 'touhou', isaacbg = 'isaac', batim = 'batim',
    splatoon = 'splatoon', pizzatower = 'pizzatower', pokemon = 'pokemon'
}
local videoTweenOwners = {
    megalo = 'megalo', ddlc = 'ddlc', greenhill = 'greenhill',
    bigshot = 'bigshot', bigshot2 = 'bigshot2', fnaf = 'fnaf',
    crashBackaway = 'crashBack', gourmet = 'gourmet', angel = 'angel',
    one = 'one', celeste = 'celeste', minecraft = 'minecraft',
    touhou = 'touhou', isaacbgin = 'isaacbg', batimleft = 'batim',
    splatoon2 = 'splatoon', pizzatow3er = 'pizzatower', pokemon4 = 'pokemon'
}
local hodgepodgeIconTags = {
    'sans', 'monika', 'sonic', 'spamton', 'freddy', 'crash',
    'kirby', 'knuckles', 'mario', 'reddit', 'madelyn', 'steve',
    'reimu', 'isaac', 'bendy', 'peppino', 'inkling', 'pikachu'
}
local videoPrewarmLeadSteps = 16
local VIDEO_OPACITY = 0.5
local videoCueSequence = {
	{159, 'megalo'}, {227, 'ddlc'}, {291, 'greenhill'},
	{338, 'bigshot'}, {369, 'bigshot2'}, {417, 'fnaf'},
	{479, 'crashBack'}, {544, 'gourmet'}, {576, 'gourmet'},
	{671, 'angel'}, {735, 'one'}, {800, 'celeste'},
	{931, 'minecraft'}, {1040, 'touhou'}, {1100, 'isaacbg'},
	{1234, 'batim'}, {1304, 'splatoon'}, {1424, 'pizzatower'},
	{1488, 'pokemon'}
}
local videoPrewarmByStep = {}
for i = 2, #videoCueSequence do
	local cue = videoCueSequence[i]
	videoPrewarmByStep[cue[1] - videoPrewarmLeadSteps] = cue[2]
end
local videoPlaying = {}
local videoPausedByGame = {}
local function makeHodgepodgeVideoSprite(tag, video, x, y)
	if lowQuality and lowQualityStaticVideos[tag] then
		makeLuaSprite(tag,
			'Freeplay-Chrs/raven/videos-low-quality/' .. lowQualityStaticVideos[tag], x, y)
	else
		makeLuaVideoSprite(tag, 'raven/' .. video, x, y, 569, 320)
	end
	setScrollFactor(tag, 0.8, 0.8)
end

local function resetVideoFrame(tag)
	if not lowQuality then
		restartLuaVideoSprite(tag, 'raven/' .. lowQualityStaticVideos[tag])
		videoPlaying[tag] = true
	end
end

local function resumeVideoFrame(tag)
	if not lowQuality then
		resumeLuaVideoSprite(tag)
		videoPlaying[tag] = true
	end
end

function onCreate()
	
	makeLuaSprite('bg', 'dawhite', -680, 0)
	
	addLuaSprite('bg', false)
	initLuaShader('void')
	setSpriteShader('bg', 'void')
	setShaderFloat('bg', 'u_mix', 0.03)
	setShaderFloatArray('bg', 'u_scale', {1, 1})
	setShaderFloatArray('bg', 'u_offset', {0, 0})


	makeLuaSprite('black1', 'Freeplay-Chrs/raven/black', -500, 0);
	scaleObject('black1' ,1.5,1.5)
	addLuaSprite('black1', false);

	makeHodgepodgeVideoSprite('megalo', 'megalo', -180, 340)
	addLuaSprite('megalo', false)
	setProperty('megalo.alpha', 0)
	setObjectCamera('megalo', 'camgame')
	scaleObject('megalo', 5.35, 5.35);


	makeHodgepodgeVideoSprite('ddlc', 'ddlc', -180, 340)
	addLuaSprite('ddlc', false)
	setProperty('ddlc.alpha', 0)
	setObjectCamera('ddlc', 'camgame')
	scaleObject('ddlc', 5.35, 5.35);


	makeHodgepodgeVideoSprite('greenhill', 'greenhill', -250, 340)
	addLuaSprite('greenhill', false)
	setProperty('greenhill.alpha', 0)
	setObjectCamera('greenhill', 'camgame')
	scaleObject('greenhill', 5.35, 5.35);

	makeHodgepodgeVideoSprite('bigshot', 'bigshot', -180, 340)
	addLuaSprite('bigshot', false)
	setProperty('bigshot.alpha', 0)
	setObjectCamera('bigshot', 'camgame')
	scaleObject('bigshot', 5.35, 5.35);

	makeHodgepodgeVideoSprite('bigshot2', 'bigshot2', -180, 340)
	addLuaSprite('bigshot2', false)
	setProperty('bigshot2.alpha', 0)
	setObjectCamera('bigshot2', 'camgame')
	scaleObject('bigshot2', 5.35, 5.35);

	makeHodgepodgeVideoSprite('fnaf', 'fnaf', -180, 340)
	addLuaSprite('fnaf', false)
	setProperty('fnaf.alpha', 0)
	setObjectCamera('fnaf', 'camgame')
	scaleObject('fnaf', 5.35, 5.35);


	makeHodgepodgeVideoSprite('gourmet', 'gourmet', -180, 340)
	addLuaSprite('gourmet', false)
	setProperty('gourmet.alpha', 0)
	setObjectCamera('gourmet', 'camgame')
	scaleObject('gourmet', 5.35, 5.35);


	makeHodgepodgeVideoSprite('crashBack', 'scratch', -180, 340)
	addLuaSprite('crashBack', false)
	setProperty('crashBack.alpha', 0)
	setObjectCamera('crashBack', 'camgame')
	scaleObject('crashBack', 5.35, 5.35);

	makeHodgepodgeVideoSprite('angel', 'angel', -180, 340)
	addLuaSprite('angel', false)
	setProperty('angel.alpha', 0)
	setObjectCamera('angel', 'camgame')
	scaleObject('angel', 5.35, 5.35);

	makeHodgepodgeVideoSprite('one', 'one', -180, 340)
	addLuaSprite('one', false)
	setProperty('one.alpha', 0)
	setObjectCamera('one', 'camgame')
	scaleObject('one', 5.35, 5.35);

	makeLuaSprite('cbat', 'Freeplay-Chrs/raven/videos/cbat', -230, 550);
	scaleObject('cbat', 2.9, 2.9);
	setScrollFactor('cbat', 0.8, 0.8)
	addLuaSprite('cbat', false);
	setProperty('cbat.alpha', 0)
	setObjectCamera('cbat', 'camgame')

	makeHodgepodgeVideoSprite('celeste', 'celeste', -180, 340)
	addLuaSprite('celeste', false)
	setProperty('celeste.alpha', 0)
	setObjectCamera('celeste', 'camgame')
	scaleObject('celeste', 5.35, 5.35);

	makeHodgepodgeVideoSprite('minecraft', 'minecraft', -180, 340)
	addLuaSprite('minecraft', false)
	setProperty('minecraft.alpha', 0)
	setObjectCamera('minecraft', 'camgame')
	scaleObject('minecraft', 5.35, 5.35);

	makeHodgepodgeVideoSprite('touhou', 'touhou', -180, 340)
	addLuaSprite('touhou', false)
	setProperty('touhou.alpha', 0)
	setObjectCamera('touhou', 'camgame')
	scaleObject('touhou', 5.35, 5.35);

	makeHodgepodgeVideoSprite('isaacbg', 'isaac', -240, 340)
	addLuaSprite('isaacbg', false)
	setProperty('isaacbg.alpha', 0)
	setObjectCamera('isaacbg', 'camgame')
	scaleObject('isaacbg', 5.43, 5.43);

	makeHodgepodgeVideoSprite('batim', 'batim', -180, 340)
	addLuaSprite('batim', false)
	setProperty('batim.alpha', 0)
	setObjectCamera('batim', 'camgame')
	scaleObject('batim', 5.35, 5.35);

	makeHodgepodgeVideoSprite('splatoon', 'splatoon', -213, 340)
	addLuaSprite('splatoon', false)
	setProperty('splatoon.alpha', 0)
	setObjectCamera('splatoon', 'camgame')
	scaleObject('splatoon', 5.35, 5.35);

	makeHodgepodgeVideoSprite('pizzatower', 'pizzatower', -240, 340)
	addLuaSprite('pizzatower', false)
	setProperty('pizzatower.alpha', 0)
	setObjectCamera('pizzatower', 'camgame')
	scaleObject('pizzatower', 5.35, 5.35);

	makeHodgepodgeVideoSprite('pokemon', 'pokemon', -180, 340)
	addLuaSprite('pokemon', false)
	setProperty('pokemon.alpha', 0)
	setObjectCamera('pokemon', 'camgame')
	scaleObject('pokemon', 5.35, 5.35);

	makeLuaSprite('sans', 'Freeplay-Chrs/raven/icons/sans', 880, 620);
	scaleObject('sans', 0.8, 0.8)
	addLuaSprite('sans', true);
	setProperty('sans.scale.x', 0)
	setProperty('sans.scale.y', 0)

	makeLuaSprite('monika', 'Freeplay-Chrs/raven/icons/monika', 880, 620);
	scaleObject('monika', 0.8, 0.8)
	addLuaSprite('monika', true);
	setProperty('monika.scale.x', 0)
	setProperty('monika.scale.y', 0)

	makeLuaSprite('sonic', 'Freeplay-Chrs/raven/icons/sonic', 930, 650);
	scaleObject('sonic', 0.8, 0.8)
	addLuaSprite('sonic', true);
	setProperty('sonic.scale.x', 0)
	setProperty('sonic.scale.y', 0)

	makeLuaSprite('spamton', 'Freeplay-Chrs/raven/icons/spamton', 880, 620);
	scaleObject('spamton', 0.8, 0.8)
	addLuaSprite('spamton', true);
	setProperty('spamton.scale.x', 0)
	setProperty('spamton.scale.y', 0)


	makeLuaSprite('freddy', 'Freeplay-Chrs/raven/icons/freddy', 880, 620);
	scaleObject('freddy', 0.8, 0.8)
	addLuaSprite('freddy', true);
	setProperty('freddy.scale.x', 0)
	setProperty('freddy.scale.y', 0)

	makeLuaSprite('crash', 'Freeplay-Chrs/raven/icons/crash', 880, 620);
	scaleObject('crash', 0.8, 0.8)
	addLuaSprite('crash', true);
	setProperty('crash.scale.x', 0)
	setProperty('crash.scale.y', 0)

	makeLuaSprite('kirby', 'Freeplay-Chrs/raven/icons/kirby', 880, 620);
	scaleObject('kirby', 0.8, 0.8)
	addLuaSprite('kirby', true);
	setProperty('kirby.scale.x', 0)
	setProperty('kirby.scale.y', 0)

	makeLuaSprite('knuckles', 'Freeplay-Chrs/raven/icons/knuckles', 880, 620);
	scaleObject('knuckles', 0.8, 0.8)
	addLuaSprite('knuckles', true);
	setProperty('knuckles.scale.x', 0)
	setProperty('knuckles.scale.y', 0)

	makeLuaSprite('mario', 'Freeplay-Chrs/raven/icons/mario', 880, 620);
	scaleObject('mario', 0.8, 0.8)
	addLuaSprite('mario', true);
	setProperty('mario.scale.x', 0)
	setProperty('mario.scale.y', 0)

	makeLuaSprite('reddit', 'Freeplay-Chrs/raven/icons/reddit', 880, 620);
	scaleObject('reddit', 0.8, 0.8)
	addLuaSprite('reddit', true);
	setProperty('reddit.scale.x', 0)
	setProperty('reddit.scale.y', 0)

	makeLuaSprite('madelyn', 'Freeplay-Chrs/raven/icons/madelyn', 880, 620);
	scaleObject('madelyn', 0.8, 0.8)
	addLuaSprite('madelyn', true);
	setProperty('madelyn.scale.x', 0)
	setProperty('madelyn.scale.y', 0)

	makeLuaSprite('steve', 'Freeplay-Chrs/raven/icons/steve', 880, 620);
	scaleObject('steve', 0.8, 0.8)
	addLuaSprite('steve', true);
	setProperty('steve.scale.x', 0)
	setProperty('steve.scale.y', 0)

	makeLuaSprite('reimu', 'Freeplay-Chrs/raven/icons/reimu', 880, 620);
	scaleObject('reimu', 0.8, 0.8)
	addLuaSprite('reimu', true);
	setProperty('reimu.scale.x', 0)
	setProperty('reimu.scale.y', 0)

	makeLuaSprite('isaac', 'Freeplay-Chrs/raven/icons/isaac', 880, 620);
	scaleObject('isaac', 0.8, 0.8)
	addLuaSprite('isaac', true);
	setProperty('isaac.scale.x', 0)
	setProperty('isaac.scale.y', 0)

	makeLuaSprite('bendy', 'Freeplay-Chrs/raven/icons/bendy', 940, 620);
	scaleObject('bendy', 0.8, 0.8)
	addLuaSprite('bendy', true);
	setProperty('bendy.scale.x', 0)
	setProperty('bendy.scale.y', 0)

	makeLuaSprite('inkling', 'Freeplay-Chrs/raven/icons/inkling', 940, 620);
	scaleObject('inkling', 0.8, 0.8)
	addLuaSprite('inkling', true);
	setProperty('inkling.scale.x', 0)
	setProperty('inkling.scale.y', 0)

	makeLuaSprite('peppino', 'Freeplay-Chrs/raven/icons/peppino', 940, 620);
	scaleObject('peppino', 0.8, 0.8)
	addLuaSprite('peppino', true);
	setProperty('peppino.scale.x', 0)
	setProperty('peppino.scale.y', 0)

	makeLuaSprite('pikachu', 'Freeplay-Chrs/raven/icons/pika', 940, 620);
	scaleObject('pikachu', 0.8, 0.8)
	addLuaSprite('pikachu', true);
	setProperty('pikachu.scale.x', 0)
	setProperty('pikachu.scale.y', 0)
	for i = 1, #hodgepodgeIconTags do
		setScrollFactor(hodgepodgeIconTags[i], 1.07, 1.07)
	end

	makeLuaSprite('floor', 'Freeplay-Chrs/raven/floor2', -680, 1200)
	
	addLuaSprite('floor', false)
	setProperty('floor.alpha', 0.8)
	scaleObject('floor', 6.35, 0.7);

end

function onBeatHit()
    if lowQuality then return end
    local beatAngle = curBeat % 2 == 0 and -10 or 10
    bopHodgepodgeIcons(beatAngle, crochet / 1000)
end

function onStepHit()
	if not lowQuality then
		local prewarmTag = videoPrewarmByStep[curStep]
		if prewarmTag ~= nil then
			prepareLuaVideoSprite(prewarmTag, 'raven/' .. lowQualityStaticVideos[prewarmTag])
		end
	end
  if curStep == 159 then
		doTweenAlpha('megalo', 'megalo', 0.5, 0.4, 'linear')
		resetVideoFrame('megalo')
		doTweenX('sansScaleX', 'sans.scale', 0.8, 0.4, 'backOut')
		doTweenY('sansScaleY', 'sans.scale', 0.8, 0.4, 'backOut')
	end
	if curStep == 184 then
		doTweenAlpha('megalo', 'megalo', 0, 0.5, 'linear')
		doTweenX('sansScaleX', 'sans.scale', 0, 0.5, 'backOut')
		doTweenY('sansScaleY', 'sans.scale', 0, 0.5, 'backOut')
	end

	if curStep == 227 then
		doTweenAlpha('ddlc', 'ddlc', 0.5, 0.4, 'linear')
		resetVideoFrame('ddlc')
		doTweenX('monikaScaleX', 'monika.scale', 0.8, 0.4, 'backOut')
		doTweenY('monikaScaleY', 'monika.scale', 0.8, 0.4, 'backOut')
	end
	if curStep == 252 then
		doTweenAlpha('ddlc', 'ddlc', 0, 0.5, 'linear')
		doTweenX('monikaScaleX', 'monika.scale', 0, 0.5, 'backOut')
		doTweenY('monikaScaleY', 'monika.scale', 0, 0.5, 'backOut')
	end

	if curStep == 291 then
		doTweenAlpha('greenhill', 'greenhill', 0.5, 0.4, 'linear')
		resetVideoFrame('greenhill')
		doTweenX('sonicScaleX', 'sonic.scale', 0.7, 0.4, 'backOut')
		doTweenY('sonicScaleY', 'sonic.scale', 0.7, 0.4, 'backOut')
	end
	if curStep == 320 then
		doTweenAlpha('greenhill', 'greenhill', 0, 0.5, 'linear')
		doTweenX('sonicScaleX', 'sonic.scale', 0, 0.5, 'backOut')
		doTweenY('sonicScaleY', 'sonic.scale', 0, 0.5, 'backOut')
	end

	if curStep == 338 then
		doTweenAlpha('bigshot', 'bigshot', 0.5, 0.4, 'linear')
		resetVideoFrame('bigshot')
		doTweenX('spamtonScaleX', 'spamton.scale', 0.7, 0.4, 'backOut')
		doTweenY('spamtonScaleY', 'spamton.scale', 0.7, 0.4, 'backOut')
	end
	if curStep == 351 then
		doTweenAlpha('bigshot', 'bigshot', 0, 0.5, 'linear')
		doTweenX('spamtonScaleX', 'spamton.scale', 0, 0.5, 'backOut')
		doTweenY('spamtonScaleY', 'spamton.scale', 0, 0.5, 'backOut')
	end

	if curStep == 369 then
		doTweenAlpha('bigshot2', 'bigshot2', 0.5, 0.4, 'linear')
		resetVideoFrame('bigshot2')
		doTweenX('spamtonScaleX', 'spamton.scale', 0.7, 0.4, 'backOut')
		doTweenY('spamtonScaleY', 'spamton.scale', 0.7, 0.4, 'backOut')
	end
	if curStep == 382 then
		doTweenAlpha('bigshot2', 'bigshot2', 0, 0.5, 'linear')
		doTweenX('spamtonScaleX', 'spamton.scale', 0, 0.5, 'backOut')
		doTweenY('spamtonScaleY', 'spamton.scale', 0, 0.5, 'backOut')
	end


	if curStep == 417 then
		doTweenAlpha('fnaf', 'fnaf', 0.5, 0.4, 'linear')
		resetVideoFrame('fnaf')
		doTweenX('freddyScaleX', 'freddy.scale', 0.7, 0.4, 'backOut')
		doTweenY('freddyScaleY', 'freddy.scale', 0.7, 0.4, 'backOut')
	end
	if curStep == 440 then
		doTweenAlpha('fnaf', 'fnaf', 0, 0.5, 'linear')
		doTweenX('freddyScaleX', 'freddy.scale', 0, 0.5, 'backOut')
		doTweenY('freddyScaleY', 'freddy.scale', 0, 0.5, 'backOut')
	end

	if curStep == 479 then
		doTweenAlpha('crashBack', 'crashBack', VIDEO_OPACITY, 0.4, 'linear')
		resetVideoFrame('crashBack')
		doTweenX('crashScaleX', 'crash.scale', 0.85, 0.4, 'backOut')
		doTweenY('crashScaleY', 'crash.scale', 0.85, 0.4, 'backOut')
	end
	if curStep == 505 then
		doTweenAlpha('crashBackaway', 'crashBack', 0, 0.5, 'linear')
		doTweenX('crashScaleX', 'crash.scale', 0, 0.5, 'backOut')
		doTweenY('crashScaleY', 'crash.scale', 0, 0.5, 'backOut')
	end

	if curStep == 544 then
		doTweenX('kirbyScaleX', 'kirby.scale', 0.8, 0.3, 'backOut')
		doTweenAlpha('gourmet', 'gourmet', 0.5, 0.4, 'linear')
		resetVideoFrame('gourmet')
		doTweenY('kirbyScaleY', 'kirby.scale', 0.8, 0.3, 'backOut')
	end

	if curStep == 548 then
		doTweenY('kirbydown', 'kirby', 1000, 0.8, 'quadOut')
		doTweenAlpha('gourmet', 'gourmet', 0, 0.25, 'linear')
		doTweenAlpha('kirbyalpha', 'kirby', 0, 0.5, 'linear')
	end

	if curStep == 576 then
		doTweenX('kirbyScaleX', 'kirby.scale', 0.0, 0.01, 'backOut')
		doTweenY('kirbyScaleY', 'kirby.scale', 0.0, 0.01, 'backOut')
		doTweenY('kirbyup', 'kirby', 620, 0.01, 'quadOut')
		doTweenAlpha('kirbyalpha', 'kirby', 1, 0.01, 'linear')
	end

	if curStep == 576 then
		doTweenAlpha('gourmet', 'gourmet', 0.5, 0.4, 'linear')
		resetVideoFrame('gourmet')
		doTweenX('kirbyScaleX', 'kirby.scale', 0.85, 0.4, 'backOut')
		doTweenY('kirbyScaleY', 'kirby.scale', 0.85, 0.4, 'backOut')
	end

	if curStep == 629 then
		doTweenAlpha('gourmet', 'gourmet', 0, 0.5, 'linear')
		doTweenX('kirbyScaleX', 'kirby.scale', 0, 0.5, 'backOut')
		doTweenY('kirbyScaleY', 'kirby.scale', 0, 0.5, 'backOut')
	end

	if curStep == 671 then
		doTweenAlpha('angel', 'angel', 0.5, 0.4, 'linear')
		resetVideoFrame('angel')
		doTweenX('knucklesScaleX', 'knuckles.scale', 0.85, 0.4, 'backOut')
		doTweenY('knucklesScaleY', 'knuckles.scale', 0.85, 0.4, 'backOut')
	end
	if curStep == 697 then
		doTweenAlpha('angel', 'angel', 0, 0.5, 'linear')
		doTweenX('knucklesScaleX', 'knuckles.scale', 0, 0.5, 'backOut')
		doTweenY('knucklesScaleY', 'knuckles.scale', 0, 0.5, 'backOut')
	end

	if curStep == 735 then
		doTweenAlpha('one', 'one', 0.5, 0.4, 'linear')
		resetVideoFrame('one')
		doTweenX('marioScaleX', 'mario.scale', 0.85, 0.4, 'backOut')
		doTweenY('marioScaleY', 'mario.scale', 0.85, 0.4, 'backOut')
	end
	if curStep == 749 then
		doTweenAlpha('one', 'one', 0, 0.5, 'linear')
		doTweenX('marioScaleX', 'mario.scale', 0, 0.5, 'backOut')
		doTweenY('marioScaleY', 'mario.scale', 0, 0.5, 'backOut')
	end

	if curStep == 770 then
		doTweenAlpha('onealpha', 'cbat', 1, 0.4, 'linear')
		doTweenY('cbat', 'cbat', -1200, 1.65, 'linear')
		doTweenX('redditScaleX', 'reddit.scale', 0.78, 0.4, 'backOut')
		doTweenY('redditScaleY', 'reddit.scale', 0.78, 0.4, 'backOut')
	end

	if curStep == 783 then
		doTweenAlpha('onealpha', 'cbat', 0, 0.5, 'linear')
		doTweenY('cbat', 'cbat', -1200, 1.65, 'linear')
		doTweenX('redditScaleX', 'reddit.scale', 0, 0.5, 'backOut')
		doTweenY('redditScaleY', 'reddit.scale', 0, 0.5, 'backOut')
	end

	if curStep == 800 then
		doTweenAlpha('celeste', 'celeste', 0.5, 0.4, 'linear')
		resetVideoFrame('celeste')
		doTweenX('madelynScaleX', 'madelyn.scale', 0.95, 0.4, 'backOut')
		doTweenY('madelynScaleY', 'madelyn.scale', 0.95, 0.4, 'backOut')
	end
	if curStep == 836 then
		doTweenAlpha('celeste', 'celeste', 0, 0.5, 'linear')
		doTweenX('madelynScaleX', 'madelyn.scale', 0, 0.5, 'backOut')
		doTweenY('madelynScaleY', 'madelyn.scale', 0, 0.5, 'backOut')
	end

	if curStep == 931 then
		doTweenAlpha('minecraft', 'minecraft', 0.5, 0.4, 'linear')
		resetVideoFrame('minecraft')
		doTweenX('steveScaleX', 'steve.scale', 0.85, 0.4, 'backOut')
		doTweenY('steveScaleY', 'steve.scale', 0.85, 0.4, 'backOut')
	end
	if curStep == 947 then
		doTweenAlpha('minecraft', 'minecraft', 0, 0.5, 'linear')
		doTweenX('steveScaleX', 'steve.scale', 0, 0.5, 'backOut')
		doTweenY('steveScaleY', 'steve.scale', 0, 0.5, 'backOut')
	end

	if curStep == 1040 then
		doTweenAlpha('touhou', 'touhou', 0.5, 0.4, 'linear')
		resetVideoFrame('touhou')
		doTweenX('reimuScaleX', 'reimu.scale', 0.85, 0.4, 'backOut')
		doTweenY('reimuScaleY', 'reimu.scale', 0.85, 0.4, 'backOut')
	end
	if curStep == 1070 then
		doTweenAlpha('touhou', 'touhou', 0, 0.5, 'linear')
		doTweenX('reimuScaleX', 'reimu.scale', 0, 0.5, 'backOut')
		doTweenY('reimuScaleY', 'reimu.scale', 0, 0.5, 'backOut')
	end

	if curStep == 1100 then
		doTweenAlpha('isaacbgfghfg', 'isaacbg', 0.5, 0.4, 'linear')
		resetVideoFrame('isaacbg')
		doTweenX('isaacScaleX', 'isaac.scale', 0.85, 0.4, 'backOut')
		doTweenY('isaacScaleY', 'isaac.scale', 0.85, 0.4, 'backOut')
	end
	if curStep == 1175 then
		doTweenAlpha('isaacbgin', 'isaacbg', 0, 0.5, 'linear')
		doTweenX('isaacScaleX', 'isaac.scale', 0, 0.5, 'backOut')
		doTweenY('isaacScaleY', 'isaac.scale', 0, 0.5, 'backOut')
	end

	if curStep == 1234 then
		doTweenAlpha('batim', 'batim', 0.5, 0.2, 'linear')
		resetVideoFrame('batim')
		doTweenX('bendyScaleX', 'bendy.scale', 0.7, 0.2, 'backOut')
		doTweenY('bendyScaleY', 'bendy.scale', 0.7, 0.2, 'backOut')
	end

	if curStep == 1239 then
		doTweenAlpha('batimleft', 'batim', 0, 0.2, 'linear')
		doTweenY('bendydown', 'bendy', 1000, 0.3, 'quadOut')
		doTweenAlpha('bendyalpha', 'bendy', 0, 0.2, 'linear')
	end

	if curStep == 1250 then
		doTweenX('bendyScaleX', 'bendy.scale', 0.0, 0.1, 'backOut')
		doTweenY('bendyScaleY', 'bendy.scale', 0.0, 0.1, 'backOut')
		doTweenY('bendyup', 'bendy', 620, 0.1, 'quadOut')
		doTweenAlpha('bendyalpha', 'bendy', 1, 0.01, 'linear')
	end

	if curStep == 1250 then
		doTweenAlpha('batim', 'batim', 0.5, 0.2, 'linear')
		resumeVideoFrame('batim')
		doTweenX('bendyScaleX', 'bendy.scale', 0.7, 0.2, 'backOut')
		doTweenY('bendyScaleY', 'bendy.scale', 0.7, 0.2, 'backOut')
	end

	if curStep == 1260 then
		doTweenAlpha('batimleft', 'batim', 0, 0.2, 'linear')
		doTweenY('bendydown', 'bendy', 1000, 0.3, 'quadOut')
		doTweenAlpha('bendyalpha', 'bendy', 0, 0.2, 'linear')
	end

	if curStep == 1267 then
		doTweenX('bendyScaleX', 'bendy.scale', 0.0, 0.1, 'backOut')
		doTweenY('bendyScaleY', 'bendy.scale', 0.0, 0.1, 'backOut')
		doTweenY('bendyup', 'bendy', 620, 0.1, 'quadOut')
		doTweenAlpha('bendyalpha', 'bendy', 1, 0.01, 'linear')
	end


	if curStep == 1267 then
		doTweenAlpha('batim', 'batim', 0.5, 0.2, 'linear')
		resumeVideoFrame('batim')
		doTweenX('bendyScaleX', 'bendy.scale', 0.7, 0.2, 'backOut')
		doTweenY('bendyScaleY', 'bendy.scale', 0.7, 0.2, 'backOut')
	end

	if curStep == 1271 then
		doTweenAlpha('batimleft', 'batim', 0, 0.2, 'linear')
		doTweenY('bendydown', 'bendy', 1000, 0.3, 'quadOut')
		doTweenAlpha('bendyalpha', 'bendy', 0, 0.2, 'linear')
	end

	if curStep == 1279 then
		doTweenX('bendyScaleX', 'bendy.scale', 0.0, 0.1, 'backOut')
		doTweenY('bendyScaleY', 'bendy.scale', 0.0, 0.1, 'backOut')
		doTweenY('bendyup', 'bendy', 620, 0.1, 'quadOut')
		doTweenAlpha('bendyalpha', 'bendy', 1, 0.01, 'linear')
	end


	if curStep == 1279 then
		doTweenAlpha('batim', 'batim', 0.5, 0.2, 'linear')
		resumeVideoFrame('batim')
		doTweenX('bendyScaleX', 'bendy.scale', 0.7, 0.2, 'backOut')
		doTweenY('bendyScaleY', 'bendy.scale', 0.7, 0.2, 'backOut')
	end

	if curStep == 1292 then
		doTweenAlpha('batimleft', 'batim', 0, 0.2, 'linear')
		doTweenY('bendydown', 'bendy', 1000, 0.2, 'quadOut')
		doTweenAlpha('bendyalpha', 'bendy', 0, 0.15, 'linear')
	end

	if curStep == 1296 then
		doTweenX('bendyScaleX', 'bendy.scale', 0.0, 0.01, 'backOut')
		doTweenY('bendyScaleY', 'bendy.scale', 0.0, 0.01, 'backOut')
		doTweenY('bendyup', 'bendy', 620, 0.01, 'quadOut')
		doTweenAlpha('bendyalpha', 'bendy', 1, 0.01, 'linear')
	end


	if curStep == 1296 then
		doTweenAlpha('batim', 'batim', 0.5, 0.2, 'linear')
		resumeVideoFrame('batim')
		doTweenX('bendyScaleX', 'bendy.scale', 0.7, 0.2, 'backOut')
		doTweenY('bendyScaleY', 'bendy.scale', 0.7, 0.2, 'backOut')
	end

	if curStep == 1299 then
		doTweenAlpha('batimleft', 'batim', 0, 0.2, 'linear')
		doTweenY('bendydown', 'bendy', 1000, 0.3, 'quadOut')
		doTweenAlpha('bendyalpha', 'bendy', 0, 0.2, 'linear')
	end

	if curStep == 1304 then
		doTweenAlpha('splatoon', 'splatoon', 0.5, 0.4, 'linear')
		resetVideoFrame('splatoon')
		doTweenX('inklingScaleX', 'inkling.scale', 0.85, 0.4, 'backOut')
		doTweenY('inklingScaleY', 'inkling.scale', 0.85, 0.4, 'backOut')
	end
	if curStep == 1357 then
		doTweenAlpha('splatoon2', 'splatoon', 0, 0.8, 'linear')
		doTweenX('inklingScaleX', 'inkling.scale', 0, 0.8, 'backOut')
		doTweenY('inklingScaleY', 'inkling.scale', 0, 0.8, 'backOut')
	end

	if curStep == 1424 then
		doTweenAlpha('pizzatower', 'pizzatower', 0.5, 0.4, 'linear')
		resetVideoFrame('pizzatower')
		doTweenX('peppinoScaleX', 'peppino.scale', 0.85, 0.4, 'backOut')
		doTweenY('peppinoScaleY', 'peppino.scale', 0.85, 0.4, 'backOut')
	end
	if curStep == 1485 then
		doTweenAlpha('pizzatow3er', 'pizzatower', 0, 0.8, 'linear')
		doTweenX('peppinoScaleX', 'peppino.scale', 0, 0.8, 'backOut')
		doTweenY('peppinoScaleY', 'peppino.scale', 0, 0.8, 'backOut')
	end

	if curStep == 1488 then
		doTweenAlpha('pokemon', 'pokemon', 0.5, 0.4, 'linear')
		resetVideoFrame('pokemon')
		doTweenX('pikachuScaleX', 'pikachu.scale', 0.85, 0.4, 'backOut')
		doTweenY('pikachuScaleY', 'pikachu.scale', 0.85, 0.4, 'backOut')
	end
	if curStep == 1553 then
		doTweenAlpha('pokemon4', 'pokemon', 0, 0.8, 'linear')
		doTweenX('pikachuScaleX', 'pikachu.scale', 0, 0.8, 'backOut')
		doTweenY('pikachuScaleY', 'pikachu.scale', 0, 0.8, 'backOut')
	end

end




function colorFromString(color) 
    val = 0xFFFFFFFF
    if color:lower() == 'white' then val = 0xFFFFFF end
    if color:lower() == 'gray' then val = 0x808080 end
    if color:lower() == 'black' then val = 0x000000 end

    if color:lower() == 'green' then val = 0x008000 end
    if color:lower() == 'lime' then val = 0x00FF00 end
    if color:lower() == 'yellow' then val = 0xFFFF00 end
    if color:lower() == 'orange' then val = 0xFFA500 end
    if color:lower() == 'red' then val = 0xFF0000 end
    if color:lower() == 'purple' then val = 0x800080 end
    if color:lower() == 'blue' then val = 0x0000FF end
    if color:lower() == 'brown' then val = 0x8B4513 end
    if color:lower() == 'pink' then val = 0xFFC0CB end
    if color:lower() == 'magenta' then val = 0xFF00FF end
    if color:lower() == 'cyan' then val = 0x00FFFF end

    return val
end






        
particlePath = "Freeplay-Chrs/raven/particle" 
defParticleScaleX = 1 
defParticleScaleY = 1 
defParticleOpacity = 1  

defParticleAngle = 0 
waitingTicks = 5 
randomScale = false 


scaleDependantAlpha = false 
maxParticles = 25 
colorParticle = false 
defParticleColor = colorFromString('white')



enabled = true 
modeName = 'Embers' 






        
           

           
BetaPathing = false 
VelocityXMod = 0 
VelocityYMod = 0 

           
camera = 'camGame' 
particleWidth = 3500 
particleHeight = 350 
particleX = -1200 
particleY = 500 





local mode = 1
local particleSlotsCreated = 0
local activeParticleCount = 0
local processedTicks = waitingTicks
local spawnClock = 0
local particleFrames = 0
local modes = {'Blizzard', 'Fireflies', 'Embers', 'Snow', 'Wind Left', 'Wind Right'}
local activeParticles = {}
local freeParticles = {}
local particleFadeOwners = {}



local particlePoolSize = 25

local function resolveParticleMode()
    for index, name in ipairs(modes) do
        if name == modeName then
            mode = index
            break
        end
    end
    processedTicks = mode == 1 and math.max(1, waitingTicks)
        or mode == 4 and math.max(1, waitingTicks * 2)
        or math.max(1, waitingTicks)
end

local function acquireParticle()
    local freeCount = #freeParticles
    if freeCount > 0 then
        local tag = freeParticles[freeCount]
        freeParticles[freeCount] = nil
        return tag, false
    end

    return nil, false
end

local function prewarmParticlePoolChunk(count)
    local lastIndex = math.min(particlePoolSize, particleSlotsCreated + count)
    for index = particleSlotsCreated + 1, lastIndex do
        local tag = 'ravenParticle' .. index
        makeLuaSprite(tag, particlePath, particleX, particleY)
        setObjectCamera(tag, camera)
        addLuaSprite(tag, false)
        setObjectOrder(tag, math.max(0, getObjectOrder('floor') - 1))
        setProperty(tag .. '.visible', false)
        setProperty(tag .. '.alpha', 0)
        freeParticles[#freeParticles + 1] = tag
    end
    particleSlotsCreated = lastIndex
end

local function releaseParticle(tag)
    if activeParticles[tag] == nil then return end
    activeParticles[tag] = nil
    activeParticleCount = math.max(0, activeParticleCount - 1)
    setProperty(tag .. '.visible', false)
    setProperty(tag .. '.alpha', 0)
    setProperty(tag .. '.velocity.x', 0)
    setProperty(tag .. '.velocity.y', 0)
    freeParticles[#freeParticles + 1] = tag
end

function onCreatePost()
    resolveParticleMode()
    if not lowQuality then
		 
		 
		 
		prepareLuaVideoSprite('megalo', 'raven/megalo')
		runTimer('ravenParticlePrewarm', 0.15, 8)
    end
end

function onTimerCompleted(tag)
	if lowQuality then return end
    if tag == 'ravenParticlePrewarm' then
        prewarmParticlePoolChunk(12)
    end
end

function onUpdate(elapsed)
    if lowQuality then
        enabled = false
        return
	end
	setShaderFloat('bg', 'u_time', (getSongPosition() / 1000) * 0.8)

	local elapsedFrames = math.max(0, elapsed) * 60
	spawnClock = spawnClock + elapsedFrames
    particleFrames = particleFrames + elapsedFrames
    if enabled and activeParticleCount < maxParticles and spawnClock >= processedTicks then
        spawnClock = spawnClock % processedTicks
        spawnParticle()
    end

    if BetaPathing and enabled then
        particleTick(elapsed)
    end
end

function particleTick(elapsed)
    for tag, data in pairs(activeParticles) do
        if mode == 1 then
            setProperty(tag .. '.x', getProperty(tag .. '.x') + (2500 + VelocityXMod) * elapsed)
            setProperty(tag .. '.y', getProperty(tag .. '.y') + (2000 + VelocityYMod) * elapsed)
        elseif mode == 2 then
            setProperty(tag .. '.x', getProperty(tag .. '.x') + (data.pathVelocity + VelocityXMod) * elapsed)
            setProperty(tag .. '.y', getProperty(tag .. '.y') + (data.pathVelocity + VelocityYMod) * elapsed)
        elseif mode == 5 or mode == 6 then
            setProperty(tag .. '.x', getProperty(tag .. '.x') + (data.pathVelocity + VelocityXMod) * elapsed)
            setProperty(tag .. '.y', getProperty(tag .. '.y') + VelocityYMod * elapsed)
        elseif mode == 3 or mode == 4 then
            local velocityY = mode == 3 and -400 or 800
            local originX = data.originX
            local waveX
            setProperty(tag .. '.y', getProperty(tag .. '.y') + (velocityY + VelocityYMod) * elapsed)
            if originX > screenWidth / 2 then
                waveX = math.sin(particleFrames * (originX / 16000)) * 80 + originX
            elseif originX < 10 then
                setProperty(tag .. '.visible', false)
            elseif originX < 30 then
                waveX = math.sin(particleFrames / (originX / 1.05)) * 80 + originX
            elseif originX < 100 then
                waveX = math.sin(particleFrames / (originX / 1.3)) * 80 + originX
            elseif originX < 300 then
                waveX = math.sin(particleFrames / (originX / 10)) * 80 + originX
            else
                waveX = math.sin(particleFrames / (originX / 40)) * 80 + originX
            end
            if waveX ~= nil then setProperty(tag .. '.x', waveX) end
        end
    end
end

function spawnParticle()
    local tag, isNew = acquireParticle()
    if tag == nil then return end
    local x, y, velocityX, velocityY, pathVelocity

    if mode == 1 then
        x = particleX - 200
        y = getRandomInt(particleY - 1500, particleY + particleHeight + 300)
        velocityX, velocityY, pathVelocity = 2500, 2000, x
    elseif mode == 2 then
        x = getRandomInt(particleX, particleX + particleWidth)
        y = getRandomInt(particleY, particleY + particleHeight)
        pathVelocity = getRandomInt(-20, 20)
        velocityX, velocityY = getRandomInt(-20, 20), getRandomInt(-20, 20)
    elseif mode == 3 then
        x = getRandomInt(particleX, particleX + particleWidth)
        y = particleY + particleHeight + 100
        velocityX, velocityY, pathVelocity = getRandomInt(-100, 100), -400, x
    elseif mode == 4 then
        x = getRandomInt(particleX, particleX + particleWidth)
        y = particleY - 100
        velocityX, velocityY, pathVelocity = getRandomInt(-100, 100), 800, x
    elseif mode == 5 then
        x = particleX + particleWidth + 100
        y = getRandomInt(particleY, particleY + particleHeight)
        pathVelocity = getRandomInt(-1300, -700)
        velocityX, velocityY = pathVelocity, 0
    else
        x = particleX - 100
        y = getRandomInt(particleY, particleY + particleHeight)
        pathVelocity = getRandomInt(700, 1300)
        velocityX, velocityY = pathVelocity, 0
    end

    setProperty(tag .. '.x', x)
    setProperty(tag .. '.y', y)
    setProperty(tag .. '.visible', true)

    local scale = randomScale and getRandomFloat(defParticleScaleY / 2, defParticleScaleY)
        or defParticleScaleY
    scaleObject(tag, scale, scale)
    setProperty(tag .. '.alpha', scaleDependantAlpha and scale or defParticleOpacity)
    setProperty(tag .. '.angle', defParticleAngle)
    setProperty(tag .. '.velocity.x', BetaPathing and 0 or velocityX)
    setProperty(tag .. '.velocity.y', BetaPathing and 0 or velocityY)
    if colorParticle then setProperty(tag .. '.color', defParticleColor) end

    activeParticles[tag] = {originX = x, pathVelocity = pathVelocity}
    activeParticleCount = activeParticleCount + 1

    local duration = mode == 1 and 1.8
        or mode == 2 and 1
        or (mode == 3 or mode == 4) and 2
        or 4
    local fadeTag = 'ravenParticleFade' .. tag
    particleFadeOwners[fadeTag] = tag
    doTweenAlpha(fadeTag, tag, 0, duration, 'linear')
end

function onTweenCompleted(tweenTag)
    local videoTag = videoTweenOwners[tweenTag]
    if videoTag ~= nil and getProperty(videoTag .. '.alpha') <= 0.001 then
		-- Do not retain every finished native decoder and its final frame for the
		-- rest of this long montage. Batim alone is reused before its final exit.
		if videoTag ~= 'batim' or curStep >= 1299 then
			releaseLuaVideoSprite(videoTag)
		else
			pauseLuaVideoSprite(videoTag)
		end
		videoPlaying[videoTag] = nil
    end

    local particleTag = particleFadeOwners[tweenTag]
    if particleTag ~= nil then
        particleFadeOwners[tweenTag] = nil
        releaseParticle(particleTag)
    end
end

function onPause()
	if lowQuality then return Function_Continue end
	videoPausedByGame = {}
	for tag in pairs(videoPlaying) do
		pauseLuaVideoSprite(tag)
		videoPausedByGame[tag] = true
	end
	return Function_Continue
end

function onResume()
	if lowQuality then return end
	for tag in pairs(videoPausedByGame) do
		
		
		resumeLuaVideoSprite(tag)
	end
	videoPausedByGame = {}
end

function onGameOverStart()
    enabled = false
	for tag in pairs(videoPlaying) do
		pauseLuaVideoSprite(tag)
	end
	videoPlaying = {}
	videoPausedByGame = {}
    for tag in pairs(activeParticles) do
        setProperty(tag .. '.visible', false)
    end
end
