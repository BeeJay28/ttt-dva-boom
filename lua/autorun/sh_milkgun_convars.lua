if engine.ActiveGamemode() ~= "terrortown" then return end

-- convars added with default values
CreateConVar("ttt_milkgun_secondary_sound", "1", {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Sound of the taunt secondary attack")

CreateConVar("ttt_milkgun_damage", "150", {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Damage dealt on impact")

CreateConVar("ttt_milkgun_randomDamage", "5", {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Applied on top of the normal damage (+/-)")

CreateConVar("ttt_milkgun_edmMode", "1", {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Enable EDM mode")

hook.Add("TTTUlxInitCustomCVar", "TTTMilkGunInitRWCVar", function(name)
    ULib.replicatedWritableCvar("ttt_milkgun_secondary_sound", "rep_ttt_milkgun_secondary_sound", GetConVar("ttt_milkgun_secondary_sound"):GetBool(), true, false, name)
    ULib.replicatedWritableCvar("ttt_milkgun_damage", "rep_ttt_milkgun_damage", GetConVar("ttt_milkgun_damage"):GetInt(), true, false, name)
    ULib.replicatedWritableCvar("ttt_milkgun_randomDamage", "rep_ttt_milkgun_randomDamage", GetConVar("ttt_milkgun_randomDamage"):GetInt(), true, false, name)
    ULib.replicatedWritableCvar("ttt_milkgun_edmMode", "rep_ttt_milkgun_edmMode", GetConVar("ttt_milkgun_edmMode"):GetBool(), true, false, name)
end)

if CLIENT then
    -- Use string or string.format("%.f",<steamid64>) 
    -- addon dev emblem in scoreboard
    hook.Add("TTT2FinishedLoading", "TTT2RegistermexikoediAddonDev", function()
        -- AddTTT2AddonDev("76561198279816989")
    end)

    hook.Add("TTTUlxModifyAddonSettings", "TTTMilkGunModifySettings", function(name)
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
            label = "ttt_milkgun_secondary_sound (Def. 1)",
            repconvar = "rep_ttt_milkgun_secondary_sound",
            parent = tttrslst1
        })

        tttrslst1:AddItem(xlib.makeslider{
            label = "ttt_milkgun_damage (Def. 150)",
            repconvar = "rep_ttt_milkgun_damage",
            min = 0,
            max = 200,
            decimal = 0,
            parent = tttrslst1
        })

        tttrslst1:AddItem(xlib.makeslider{
            label = "ttt_milkgun_randomDamage (Def. 5)",
            repconvar = "rep_ttt_milkgun_randomDamage",
            min = 0,
            max = 50,
            decimal = 0,
            parent = tttrslst1
        })

        -- add to ULX
        xgui.hookEvent("onProcessModules", nil, tttrspnl.processModules)
        xgui.addSubModule("Milk Gun", tttrspnl, nil, name)
    end)
end