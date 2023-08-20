if engine.ActiveGamemode() ~= "terrortown" then return end
ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName = "Milk"
ENT.Author = "mexikoedi"
ENT.Contact = "Steam"
ENT.Instructions = "Is only used for the milk gun."
ENT.Purpose = "Milk entity for the milk gun."
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.AdminOnly = false

if SERVER then
    AddCSLuaFile()

    function ENT:Initialize()
        self:SetModel("models/props_junk/garbage_milkcarton002a.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        local phys = self:GetPhysicsObject()

        if phys:IsValid() then -- Why?
            phys:Wake()
        end

        phys:SetMass(500)
        self:SetUseType(SIMPLE_USE)
    end
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end
end