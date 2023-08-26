if engine.ActiveGamemode() ~= "terrortown" then return end

-- convars added with default values
CreateConVar("ttt_dvabomb_secondary_sound", "1", {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Sound of the taunt secondary attack")
CreateConVar("ttt_dvabomb_damage", "100", {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Damage dealt by explosion", 0, 1000)
CreateConVar("ttt_dvabomb_radius", "850", {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Radius of explosion", 0, 2500)

hook.Add("TTTUlxInitCustomCVar", "TTTDvaBombInitRWCVar", function(name)
    ULib.replicatedWritableCvar("ttt_dvabomb_secondary_sound", "rep_ttt_dvabomb_secondary_sound", GetConVar("ttt_dvabomb_secondary_sound"):GetBool(), true, false, name)
    ULib.replicatedWritableCvar("ttt_dvabomb_damage", "rep_ttt_dvabomb_damage", GetConVar("ttt_dvabomb_damage"):GetInt(), true, false, name)
    ULib.replicatedWritableCvar("ttt_dvabomb_radius", "rep_ttt_dvabomb_radius", GetConVar("ttt_dvabomb_radius"):GetInt(), true, false, name)
end)

if CLIENT then
    hook.Add("TTTUlxModifyAddonSettings", "TTTDvaBombModifySettings", function(name)
        local tttrspnl = xlib.makelistlayout{
            w = 415,
            h = 318,
            parent = xgui.null
        }

        -- General Settings
        local tttrsclp1 = vgui.Create("DCollapsibleCategory", tttrspnl)
        tttrsclp1:SetSize(390, 180)
        tttrsclp1:SetExpanded(1)
        tttrsclp1:SetLabel("General Settings")
        local tttrslst1 = vgui.Create("DPanelList", tttrsclp1)
        tttrslst1:SetPos(5, 25)
        tttrslst1:SetSize(390, 180)
        tttrslst1:SetSpacing(5)

        tttrslst1:AddItem(xlib.makecheckbox{
            label = "ttt_dvabomb_secondary_sound (Def. 1)",
            repconvar = "rep_ttt_dvabomb_secondary_sound",
            parent = tttrslst1
        })

        tttrslst1:AddItem(xlib.makeslider{
            label = "ttt_dvabomb_damage (Def. 100)",
            repconvar = "rep_ttt_dvabomb_damage",
            min = 0,
            max = 200,
            decimal = 0,
            parent = tttrslst1
        })
        
        tttrslst1:AddItem(xlib.makeslider{
            label = "ttt_dvabomb_radius (Def. 850)",
            repconvar = "rep_ttt_dvabomb_radius",
            min = 0,
            max = 2500,
            decimal = 0,
            parent = tttrslst1
        })

        -- add to ULX
        xgui.hookEvent("onProcessModules", nil, tttrspnl.processModules)
        xgui.addSubModule("D.Va Bomb", tttrspnl, nil, name)
    end)
end