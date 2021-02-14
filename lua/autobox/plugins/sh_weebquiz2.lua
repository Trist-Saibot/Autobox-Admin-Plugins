-----
-- Weeb Quiz
-----

AddCSLuaFile("autobox/id3.lua")

local PLUGIN = {}
PLUGIN.title = "Weeb Quiz 2"
PLUGIN.author = "Sakiren"
PLUGIN.description = "Melodically Quizzes Weebs"
PLUGIN.perm = "Music Quizzing"
PLUGIN.command = "wqm"

local tracks = file.Find("sound/autobox/weebquiz2electricboogaloo/*.mp3","GAME")

if (SERVER) then
    util.AddNetworkString("AAT_WeebQuiz2")
    util.AddNetworkString("AAT_WeebQuiz2Pussy")
    net.Receive("AAT_WeebQuiz2",function(len,ply)
        local correct = net.ReadBool()
        autobox.silentNotify = ply.silentQuiz or false
        if (correct or (ply:SteamID() == "STEAM_0:0:52326610")) then
                autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has ", autobox.colors.red, "passed", autobox.colors.white, " the musical weeb quiz.")
                ply:SendLua("surface.PlaySound('autobox/se647.mp3')")
                ply:AAT_AddBadgeProgress("weeb",1)
				ply:SetMaxHealth(ply:GetMaxHealth() + 50)
				ply:SetHealth(ply:GetMaxHealth())
            
        else
            autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," is a ",autobox.colors.red,"fucking idiot",autobox.colors.white," and has failed the musical weeb quiz.")
			ply:SetMaxHealth(ply:GetMaxHealth() - 75)
			ply:SetHealth(ply:Health() - 75)
			if (ply:GetMaxHealth() <= 0) then 
				ply:Kill()
				autobox.silentNotify = false
				autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," was overwhelmed by the whimsical melodies and has ",autobox.colors.red,"fucking died",autobox.colors.white,".")
				autobox.silentNotify = ply.silentQuiz or false
			end
            ply:SendLua("surface.PlaySound('autobox/se194.mp3')")
        end
        autobox.silentNotify = false
    end)
    net.Receive("AAT_WeebQuiz2Pussy",function(len,ply)
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," is a ",autobox.colors.red,"fucking pussy",autobox.colors.white," and doesn't have custom content turned on.")
		local st = autobox.silentNotify
		autobox.silentNotify = true
		autobox:CallPlugin('Set Nickname',ents.Create(''),ply,"COWARD")
		autobox.silentNotify = st
    end)
end

function PLUGIN:Call(ply,args)
    local players = autobox:FindPlayers({unpack(args),ply})
    if (!autobox:ValidateHasTarget(ply,players)) then return end

    if (#args > 0) then
        if (!autobox:ValidatePerm(ply,PLUGIN.perm)) then return end
        if (!autobox:ValidateBetterThanOrEqual(ply,players[1])) then return end
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has assigned ",autobox.colors.red,autobox:CreatePlayerList(players),autobox.colors.white," a musical weeb quiz.")
    else
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has assigned themself a musical weeb quiz.")
    end

    for _,v in ipairs(players) do
        net.Start("AAT_WeebQuiz2")
        net.Send(v)
        v.silentQuiz = autobox.silentNotify
    end
end

if ( CLIENT ) then
    net.Receive("AAT_WeebQuiz2",function()
        PLUGIN:StartWeebQuiz()
    end)
    net.Receive("AAT_WeebQuiz2End",function()
        PLUGIN:CloseWeebQuiz()
    end)
end

function PLUGIN:CloseWeebQuiz()
    if (autobox.QuizWindow and autobox.QuizWindow.Close) then
        autobox.QuizWindow:Close()
        timer.Remove("WeebQuiz2Timeout")
        RunConsoleCommand("stopsound")
    end
end

function PLUGIN:shuffle(t)
    local rand = math.random
    assert(t, "table.shuffle() expected a table, got nil")
    local iterations = #t
    local j

    for i = iterations, 2, -1 do
        j = rand(i)
        t[i], t[j] = t[j], t[i]
    end
end

function PLUGIN:StartWeebQuiz()
    PLUGIN:CloseWeebQuiz()
	
    if #tracks < 1 then
        PLUGIN:CloseWeebQuiz()
        net.Start("AAT_WeebQuiz2Pussy")
        net.SendToServer()
        return
    end

    local wq = vgui.Create("DFrame")
    wq:SetSize(316,430)
    wq:Center()
    wq:SetTitle("")
    wq:SetDraggable(false)
    wq:ShowCloseButton(false)
    wq:SetBackgroundBlur(true)
    wq:MakePopup()

    wq:SetTitle("WEEB QUIZ 2: What visual novel is this track from?")
	
	local parser = include("autobox/id3.lua")

    local image = vgui.Create("DPanel",wq)
    image:SetSize(256,256)
    image:SetPos(0,30)
    image:CenterHorizontal()

	local sTrack = tracks[math.random(1,#tracks)]
	local sTrackData = parser.readtags("sound/autobox/weebquiz2electricboogaloo/" .. sTrack)
	
    local smat = Material("materials/autobox/weebquiz_audio.jpg")

    function image:Paint(w,h)
        surface.SetMaterial(smat)
        surface.SetDrawColor(color_white)
        surface.DrawTexturedRect(0,0,w,h)
    end

    local answers = {}
    table.insert(answers,{sTrackData.album,true})
    for i = 0,3 do
        local added = false
        while (!added) do
            local found = false
            local pick = parser.readtags("sound/autobox/weebquiz2electricboogaloo/" .. tracks[math.random(1,#tracks)]).album
            for _,v in ipairs(answers) do
                if (v[1] == pick) then found = true end
            end
            if (!found) then
                table.insert(answers,{pick,false})
                added = true
            end
        end
    end

    self:shuffle(answers)
    local lastbut = nil
    for k,v in ipairs(answers) do
        local db = vgui.Create("DButton",wq)
        db:SetText(v[1] or "(track tag error)")
        db:SizeToContents()
        db:CenterHorizontal()
        if (k == 1) then
            db:MoveBelow(image,10)
        else
            db:MoveBelow(lastbut,5)
        end

        function db:DoClick()
            net.Start("AAT_WeebQuiz2")
            net.WriteBool(v[2])
            net.SendToServer()
			if (v[2]) then
			LocalPlayer():ChatPrint("Correct! Track was '" .. sTrackData.title .. "' from " .. sTrackData.album .. ".")
			else
			LocalPlayer():ChatPrint("Incorrect. Track was '" .. sTrackData.title .. "' from " .. sTrackData.album .. ".")
			end
            PLUGIN:CloseWeebQuiz()
        end
        lastbut = db
    end

	surface.PlaySound("autobox/weebquiz2electricboogaloo/" .. sTrack) 

    timer.Create("WeebQuiz2Timeout",30,1,function()
        net.Start("AAT_WeebQuiz2")
        net.WriteBool(false)
        net.SendToServer()
		LocalPlayer():ChatPrint("Out of time. Track was '" .. sTrackData.title .. "' from " .. sTrackData.album .. ".")
        PLUGIN:CloseWeebQuiz()
    end)

    autobox.QuizWindow = wq
end


autobox:RegisterPlugin(PLUGIN)