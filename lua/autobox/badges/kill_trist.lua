autobox.badge:RegisterBadge("trist_kills","Slayer of Trist","You killed Trist 10 times!",10,"icon16/rosette.png")
hook.Add("PlayerDeath","AAT_Track_Trist_Kills",function(victim,inflictor,attacker)
    if (victim != attacker and attacker:IsPlayer() and !attacker:IsBot() and victim:SteamID() == "STEAM_0:0:41928574") then
        attacker:AAT_AddBadgeProgress("trist_kills",1)
    end
end)