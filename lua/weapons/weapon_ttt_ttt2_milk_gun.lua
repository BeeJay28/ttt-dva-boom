if engine.ActiveGamemode() ~= "terrortown" then return end

if SERVER then
    AddCSLuaFile()
    resource.AddFile("materials/vgui/ttt/weapon_milk_gun.vmt")
    resource.AddFile("sound/dvaBombNorm.wav")
    resource.AddFile("sound/messYouUp.wav")
end

SWEP.PrintName = "D.Va Bomb"
SWEP.Author = "BeeJay28"
SWEP.Contact = "Steam"
SWEP.Instructions = "You can shoot with primary attack and make a sound with secondary attack."
SWEP.Purpose = "Blow up everybody who has line-of-sight on the bomb."
SWEP.Spawnable = false
SWEP.AdminOnly = false
SWEP.Icon = "vgui/ttt/weapon_milk_gun"
SWEP.Base = "weapon_tttbase"
SWEP.Kind = WEAPON_EQUIP1

SWEP.CanBuy = {ROLE_TRAITOR}

SWEP.InLoadoutFor = nil
SWEP.LimitedStock = true

SWEP.EquipMenuData = {
    type = "item_weapon",
    name = "D.Va Bomb",
    desc = "Shoot D.Va-Mech Bomb with primary attack. Use secondary attack to taunt."
}

SWEP.AllowDrop = true
SWEP.IsSilent = false
SWEP.NoSights = false
SWEP.AutoSpawnable = false
SWEP.HoldType = "pistol"
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = false
SWEP.Primary.RPS = 1
SWEP.Primary.Ammo = "none"
SWEP.Weight = 7
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true
SWEP.ViewModel = "models/weapons/v_pist_fiveseven.mdl"
SWEP.WorldModel = "models/weapons/w_pist_fiveseven.mdl"
local ShootSound = Sound("dvaBombNorm.wav")
local SecondSound = Sound("messYouUp.wav")

local shootVelocity = 10000
local mass = 200
local explosionRadius = 200
local explosionDmg = GetConVar("ttt_dvabomb_damage")

if SERVER then
    function SWEP:PrimaryAttack()
        local ply = self:getOwner()
        self:SetNextPrimaryFire(CurTime()) -- Delete?
        if not self:CanPrimaryAttack() then return end
        self:TakePrimaryAmmo(1)

        local bombEnt = self:BuildBomb()
        if not bombEnt then return end
        bombEnt:EmitSound(ShootSound)

        local angle = Angle(-10, -5, 0)
        ply:ViewPunch(angle)
    end

    function SWEP:BuildBomb()
        local ply = self:getOwner()
        local bombEnt = ents.Create("ent_ttt_ttt2_milk_gun")
        if (not IsValid(bombEnt)) then return false end
        bombEnt:SetModel("models/props_junk/garbage_milkcarton002a.mdl")
        bombEnt:SetAngles(ply:EyeAngles())
        bombEnt:SetPos(ply:EyePos() + (ply:GetAimVector() * 16))
        bombEnt:SetOwner(ply) -- Prevents all normal phys damage to all entities for whatever reason, but we actually want this to be the case
        bombEnt:Spawn()
        bombEnt:Activate()
        local phys = bombEnt:GetPhysicsObject()

        if (not IsValid(phys)) then
            bombEnt:Remove()
            return false
        end

        phys:Wake()
        phys:SetMass(mass)
        phys:SetVelocity(ply:GetAimVector() * shootVelocity)

        local function explode()
            local entities = ents.FindInSphere(bombEnt, explosionRadius)
            for _, ent in pairs(entities) do
                if ent:IsValid() and ent:IsPlayer() then
                    ent:TakeDamage(explosionDmg, ply, self)
                end
            end
        end

        timer.Simple(2, explode)
    end

    function SWEP:SecondaryAttack()
        self:SetNextSecondaryFire(CurTime() + 2)

        if GetConVar("ttt_dvabomb_secondary_sound"):GetBool() then
            self:getOwner():EmitSound(SecondSound)
        end
    end
end