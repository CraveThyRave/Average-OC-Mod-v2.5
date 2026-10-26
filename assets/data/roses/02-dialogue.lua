
function onCountdownStarted()
    runHaxeCode([[
        for (note in game.playerStrums.members)
        {
            if (note != null)
                note.antialiasing = false;
        }

        for (note in game.opponentStrums.members)
        {
            if (note != null)
                note.antialiasing = false;
        }
    ]])
end
