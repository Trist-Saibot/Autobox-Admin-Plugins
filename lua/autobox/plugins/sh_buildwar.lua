-----
--Shortcuts for build and war mode
-----
local PLUGIN = {}
PLUGIN.title = "Mode"
PLUGIN.author = "Trist"
PLUGIN.description = "Shortcut for Build/War mode"
PLUGIN.perm = "Mode Change"
PLUGIN.command = "mode"
PLUGIN.usage = "[1/0]"

function PLUGIN:Call(ply,args)
    if (!autobox:ValidatePerm(ply,PLUGIN.perm)) then return end
    local enabled = (tonumber(args[#args]) or 1) > 0

    if (enabled) then
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has enabled ",autobox.colors.red,"war mode",autobox.colors.white,".")
        RunConsoleCommand( "sbox_godmode", 0 )
        RunConsoleCommand( "sbox_noclip", 0 )
    else
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has enabled ",autobox.colors.red,"build mode",autobox.colors.white,".")
        RunConsoleCommand( "sbox_godmode", 1 )
        RunConsoleCommand( "sbox_noclip", 1 )
    end
end

autobox:RegisterPlugin(PLUGIN)