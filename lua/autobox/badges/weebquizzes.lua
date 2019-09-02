autobox.badge:RegisterBadge("weeb","Weeb Level","Correctly answered Weeb Quiz questions",1,"materials/autobox/scoreboard/badges/weeb.png",true,function(ply)
    local badge = {}
    badge.Has = false
    badge.HasMax = false
    badge.GetVals = {5,10,25,50,100}
    local prog = ply:AAT_GetBadgeProgress("weeb")
    if (prog >= 100) then
        badge.Goal = 100
        badge.Desc = "Correctly answer 100 weeb quiz questions."
        badge.Icon = "materials/autobox/scoreboard/badges/turboweeb.png"
        badge.Name = "Weeb Level"
        badge.ProgName = "Turbo Weeaboo"
        badge.Has = true
        badge.HasMax = true
	elseif (prog >= 50) then
        badge.Goal = 100
        badge.Desc = "Correctly answer 50 weeb quiz questions."
        badge.Icon = "materials/autobox/scoreboard/badges/weeb.png"
        badge.Name = "Weeb Level"
        badge.ProgName = "Seasoned Weeb"
        badge.Has = true
        badge.HasMax = false
    elseif (prog >= 25) then
        badge.Goal = 50
        badge.Desc = "Correctly answer 25 weeb quiz questions."
        badge.Icon = "materials/autobox/scoreboard/badges/weeb.png"
        badge.Name = "Weeb Level"
        badge.ProgName = "Adept Weeb"
        badge.Has = true
        badge.HasMax = false
    elseif (prog >= 10) then
        badge.Goal = 25
        badge.Desc = "Correctly answer 10 weeb quiz questions."
        badge.Icon = "materials/autobox/scoreboard/badges/weeb.png"
        badge.Name = "Weeb Level"
        badge.ProgName = "Journeyman Weeb"
        badge.Has = true
        badge.HasMax = false
    elseif (prog >= 5) then
        badge.Goal = 10
        badge.Desc = "Correctly answer 5 weeb quiz questions."
        badge.Icon = "materials/autobox/scoreboard/badges/weeb.png"
        badge.Name = "Weeb Level"
        badge.ProgName = "Apprentice Weeb"
        badge.Has = true
        badge.HasMax = false
    else
        badge.Goal = 5
        badge.Desc = "Correctly answer a weeb quiz question."
        badge.Icon = "materials/autobox/scoreboard/badges/weeb.png"
        badge.Name = "Weeb Level"
        badge.ProgName = "Novice Weeb"
        badge.Has = false
        badge.HasMax = false
    end
    if (CLIENT) then badge.Icon = Material(badge.Icon) end
    return badge
end)