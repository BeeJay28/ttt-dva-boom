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
ENT.AlreadyHit = {}
ENT.Collided = 0
local CollisionsBeforeRemove = 20
local MinSpeed = 700

if SERVER then
    AddCSLuaFile()

    function ENT:Initialize()
        self:SetModel("models/props_junk/garbage_milkcarton002a.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        local phys = self:GetPhysicsObject()

        if phys:IsValid() then
            phys:Wake()
            phys:SetMass(5)
        end

        self:GetPhysicsObject():SetMass(2)
        self:SetUseType(SIMPLE_USE)
    end

    function ENT:PhysicsCollide(data, phys)
        self.Collided = self.Collided + 1

        if self.Collided <= CollisionsBeforeRemove then
            local Ent = data.HitEntity
            if not IsValid(self) or not IsValid(Ent) or not Ent:IsPlayer() then return end

            if not self.AlreadyHit[Ent:GetName()] and self:GetVelocity():LengthSqr() > MinSpeed * MinSpeed then
                local dmg = DamageInfo()

                if IsValid(self:GetOwner()) then
                    dmg:SetAttacker(self:GetOwner())
                end

                local inflictor = ents.Create("weapon_ttt_ttt2_milk_gun")
                dmg:SetInflictor(inflictor)
                local r = GetConVar("ttt_milkgun_randomDamage"):GetFloat()
                local rand = math.random(-r, r)
                local dm = GetConVar("ttt_milkgun_damage"):GetInt() + rand
                dmg:SetDamage(dm > 0 and dm or 0)
                dmg:SetDamageType(DMG_GENERIC)
                Ent:TakeDamageInfo(dmg)
                local effectdata = EffectData()
                effectdata:SetStart(data.HitPos)
                effectdata:SetOrigin(data.HitPos)
                effectdata:SetScale(1)
                util.Effect("BloodImpact", effectdata)
                self.AlreadyHit[Ent:GetName()] = true
            end
        else
            timer.Simple(0, function()
                if IsValid(self) then
                    self:Remove()
                end
            end)
        end
    end
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end
end