-----
-- Weeb Quiz
-----



local PLUGIN = {}
PLUGIN.title = "Weeb Quiz"
PLUGIN.author = "Trist"
PLUGIN.description = "Quizzes Weebs"
PLUGIN.perm = "Weeb Quizzing"
PLUGIN.command = "wquiz"

if (SERVER) then
    util.AddNetworkString("AAT_WeebQuiz")
    util.AddNetworkString("AAT_WeebQuizPussy")
    AddCSLuaFile("autobox/id3.lua")
    net.Receive("AAT_WeebQuiz",function(len,ply)
        local correct = net.ReadBool()
        autobox.silentNotify = ply.silentQuiz or false
        if (correct or (ply:SteamID() == "STEAM_0:0:52326610")) then
            if (ply:SteamID() == "STEAM_0:1:33216124" and math.random(1,2) % 2 == 0) then
                autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has ", autobox.colors.red, "passed", autobox.colors.white, " the weeb quiz, however fate decided that she's a ",autobox.colors.red,"fucking idiot",autobox.colors.white," and therefore fails.")
                ply:SendLua("surface.PlaySound('autobox/se647.mp3')")
            else
                autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has ", autobox.colors.red, "passed", autobox.colors.white, " the weeb quiz.")
                ply:SendLua("surface.PlaySound('autobox/se647.mp3')")
                ply:AAT_AddBadgeProgress("weeb",1)
            end
        else
            autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," is a ",autobox.colors.red,"fucking idiot",autobox.colors.white," and has failed the weeb quiz.")
            ply:SendLua("surface.PlaySound('autobox/se194.mp3')")
        end
        autobox.silentNotify = false
    end)
    net.Receive("AAT_WeebQuizPussy",function(len,ply)
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," is a ",autobox.colors.red,"fucking pussy",autobox.colors.white," and doesn't have custom content turned on.")
    end)
end

function PLUGIN:Call(ply,args)
    local players = autobox:FindPlayers({unpack(args),ply})
    if (!autobox:ValidateHasTarget(ply,players)) then return end

    if (#args > 0) then
        if (!autobox:ValidatePerm(ply,PLUGIN.perm)) then return end
        if (!autobox:ValidateBetterThanOrEqual(ply,players[1])) then return end
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has assigned ",autobox.colors.red,autobox:CreatePlayerList(players),autobox.colors.white," a weeb quiz.")
    else
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has assigned themself a weeb quiz.")
    end

    for _,v in ipairs(players) do
        net.Start("AAT_WeebQuiz")
        net.Send(v)
        v.silentQuiz = autobox.silentNotify
    end
end

if ( CLIENT ) then
    net.Receive("AAT_WeebQuiz",function()
        PLUGIN:StartWeebQuiz()
    end)
    net.Receive("AAT_WeebQuizEnd",function()
        PLUGIN:CloseWeebQuiz()
    end)
end

function PLUGIN:CloseWeebQuiz()
    if (autobox.QuizWindow and autobox.QuizWindow.Close) then
        autobox.QuizWindow:Close()
        timer.Remove("WeebQuizTimeout")
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

    local wq = vgui.Create("DFrame")
    wq:SetSize(316,430)
    wq:Center()
    wq:SetTitle("")
    wq:SetDraggable(false)
    wq:ShowCloseButton(false)
    wq:SetBackgroundBlur(true)
    wq:MakePopup()

    local variant = math.random(1,2) -- variant 1 is the image test, variant 2 is the theme test

    if (variant == 1) then -- ideally the entire thing would be structured differently to make adding variants less spaghetti. off the top of my head we'd want to make each variant its own function. idk, cbf right now
        wq:SetTitle("WEEB QUIZ: What is this character's name?")
    elseif (variant == 2) then
        wq:SetTitle("WEEB QUIZ: What character's theme is this?")
    end

    local chars = {}
    local pics = file.Find("materials/autobox/weebquiz/*.jpg","GAME")
    if #pics < 1 then
        PLUGIN:CloseWeebQuiz()
        net.Start("AAT_WeebQuizPussy")
        net.SendToServer()
        return
    end
    for _,v in ipairs(pics) do
        local char = {} --temp table for this character
        char.hasMusic = true

        local name = string.Split(v,".jpg")[1]
        if (string.EndsWith(name,"~")) then
            name = string.sub(name,0,#name - 1)
            char.hasMusic = false
        end
        char.name = ""
        local n = string.Split(name,"_")
        for k,s in ipairs(n) do
            char.name = char.name .. s:gsub("^%l", string.upper)
            if (k < #n) then
                char.name = char.name .. " "
            end
        end
        char.file = v
        char.musicfile = name .. ".mp3"

        table.insert(chars,char)
    end


    local image = vgui.Create("DPanel",wq)
    image:SetSize(256,256)
    image:SetPos(0,30)
    image:CenterHorizontal()

    local sChar = chars[math.random(1,#chars)]
    if (variant == 2 and !sChar.hasMusic) then
        while (!sChar.hasMusic) do
            sChar = chars[math.random(1,#chars)] -- can do this more elegantly by placing the characters that have music in a separate table, but cbf right now
        end
    end
    local smat = Material("materials/autobox/weebquiz/" .. sChar.file)
    if (variant == 2) then
        smat = Material("materials/autobox/weebquiz_audio.jpg")
    end

    function image:Paint(w,h)
        surface.SetMaterial(smat)
        surface.SetDrawColor(color_white)
        surface.DrawTexturedRect(0,0,w,h)
    end

    local answers = {}
    table.insert(answers,{sChar.name,true})
    for i = 0,3 do
        local added = false
        while (!added) do
            local found = false
            local pick = chars[math.random(1,#chars)].name
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
        db:SetText(v[1])
        db:SizeToContents()
        db:CenterHorizontal()
        if (k == 1) then
            db:MoveBelow(image,10)
        else
            db:MoveBelow(lastbut,5)
        end

        function db:DoClick()
            net.Start("AAT_WeebQuiz")
            net.WriteBool(v[2])
            net.SendToServer()
            PLUGIN:CloseWeebQuiz()
        end
        lastbut = db
    end

    if (variant == 2) then
		surface.PlaySound("autobox/weebthemes/" .. sChar.musicfile)
		local metadata = include("autobox/id3.lua").readtags("sound/autobox/weebthemes/" .. sChar.musicfile)
		local musiclabel = vgui.Create("DLabel",wq)
		musiclabel:Dock( BOTTOM )
		musiclabel:SetText("♫ " .. metadata.title)
	end

    timer.Create("WeebQuizTimeout",30,1,function()
        net.Start("AAT_WeebQuiz")
        net.WriteBool(false)
        net.SendToServer()
        PLUGIN:CloseWeebQuiz()
    end)

    autobox.QuizWindow = wq
end


autobox:RegisterPlugin(PLUGIN)