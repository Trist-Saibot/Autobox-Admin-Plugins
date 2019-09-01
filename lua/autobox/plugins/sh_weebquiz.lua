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
    util.AddNetworkString("AAT_WeebQuizEnd") --unused
    net.Receive("AAT_WeebQuiz",function(len,ply)
        local correct = net.ReadBool()
        if (correct) then
            autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has passed the weeb quiz.")
        else
            autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," is a ",autobox.colors.red,"fucking idiot",autobox.colors.white,".")
        end
    end)
end

function PLUGIN:Call(ply,args)
    if (!autobox:ValidatePerm(ply,PLUGIN.perm)) then return end
    local players = autobox:FindPlayers({args[1]})
    if (!autobox:ValidateSingleTarget(ply,players)) then return end
    if (!autobox:ValidateBetterThanOrEqual(ply,players[1])) then return end
    net.Start("AAT_WeebQuiz")
    net.Send(players[1])
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
    if (autobox.QuizWindow and autobox.QuizWindow.Close) then autobox.QuizWindow:Close() end
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
    wq:SetSize(600,425)
    wq:Center()
    wq:SetTitle("")
    wq:SetDraggable(false)
    wq:ShowCloseButton(false)
    wq:SetBackgroundBlur(true)
    wq:MakePopup()

    --[[
    function wq:Paint(w,h)
        surface.SetDrawColor(0,0,0)
        surface.DrawRect(0,0,w,25)
        surface.SetDrawColor(color_white)
        surface.DrawRect(0,25,w,h-25)
    end
    ]]

    local dl = vgui.Create("DLabel",wq)
    dl:SetText("WEEB QUIZ")
    dl:SetPos(0,3)
    dl:CenterHorizontal()


    local chars = {}
    local pics = file.Find("materials/autobox/weebquiz/*.jpg","GAME")
    for _,v in ipairs(pics) do
        local char = {} --temp table for this character
        char.hasMusic = true

        local name = string.Split(v,".jpg")[1]
        if (string.EndsWith(name,"~")) then
            name = string.sub(name,0,#name - 1)
            char.hasMusic = false
        end
        char.name = name
        char.file = v

        table.insert(chars,char)
    end


    local image = vgui.Create("DPanel",wq)
    image:SetSize(256,256)
    image:SetPos(0,30)
    image:CenterHorizontal()

    local sChar = chars[math.random(1,#chars)]
    local smat = Material("materials/autobox/weebquiz/" .. sChar.file)

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
            db:MoveBelow(image,5)
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
    autobox.QuizWindow = wq
end


autobox:RegisterPlugin(PLUGIN)