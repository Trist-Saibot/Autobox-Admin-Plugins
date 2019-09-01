-----
-- Weeb Cull
-----

local PLUGIN = {}
PLUGIN.title = "Weeb Cull"
PLUGIN.author = "Trist"
PLUGIN.description = "Quizzes Weebs"
PLUGIN.perm = "Weeb Quizzing"
PLUGIN.command = "wcull"

function PLUGIN:Call(ply)
    if (!autobox:ValidatePerm(ply,PLUGIN.perm)) then return end
    net.Start("AAT_WeebChallenge")
    net.Broadcast()
end


autobox:RegisterPlugin(PLUGIN)