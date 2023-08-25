if engine.ActiveGamemode() ~= "terrortown" then return end
ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName = "D.Va Mech"
ENT.Author = "BeeJay28"
ENT.Contact = "Steam"
ENT.Instructions = "Is only used for the D.Va."
ENT.Purpose = "D.Va Mech-Entity for the D.Va Bomb."
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.AdminOnly = false

local primShootSound = Sound("dvaBombNorm.wav")






if SERVER then
    AddCSLuaFile()

    function ENT:Initialize()
        
        self:SetModel("models/Characters/overwatch/dva/mech.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)
        self:EmitSound(primShootSound, 350, 100, 1)

        -- Fix the mech falling over
        local phys = self:GetPhysicsObject()
        phys:SetDamping( 0, 1000 )






    end
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()

                -- Jamses cooles Lichtscript
                    local dlight = DynamicLight( self:EntIndex() )
                    if ( dlight ) then
                        dlight.pos = self:GetBonePosition(1)
                        dlight.r = 8
                        dlight.g = 64
                        dlight.b = 58
                        dlight.brightness = 2
                        dlight.decay = 1000
                        dlight.size = 800
                        dlight.dietime = CurTime() + 1
                    end

    end
end

