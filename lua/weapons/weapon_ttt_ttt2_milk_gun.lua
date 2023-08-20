if engine.ActiveGamemode() ~= "terrortown" then return end

if SERVER then
    AddCSLuaFile()
    resource.AddFile("materials/vgui/ttt/weapon_dva_mech.vmt")
    resource.AddFile("sound/dvaBombNorm.wav")
    resource.AddFile("sound/messYouUp.wav")
    resource.AddFile("sound/nerfThis.wav")
    resource.AddFile("models/Characters/overwatch/dva/mech.mdl")
    resource.AddFile("models/Characters/overwatch/dva/gun.mdl")
    resource.AddFile("models/Characters/overwatch/dva/dva.mdl")
end

SWEP.PrintName = "D.Va Bomb"
SWEP.Author = "BeeJay28"
SWEP.Contact = "Steam"
SWEP.Instructions = "You can shoot with primary attack and make a sound with secondary attack."
SWEP.Purpose = "Blow up everybody who has line-of-sight on the bomb."
SWEP.Spawnable = false
SWEP.AdminOnly = false
SWEP.Icon = "vgui/ttt/weapon_dva_mech"
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
SWEP.Primary.ClipSize = 150
SWEP.Primary.DefaultClip = 150
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Weight = 7
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true
SWEP.ViewModel = "models/weapons/v_pist_fiveseven.mdl"
SWEP.WorldModel = "models/weapons/w_pist_fiveseven.mdl"
local primVoiceline = Sound("nerfThis.wav")
local secondVoiceline = Sound("messYouUp.wav")

local shootVelocity = 800
local mass = 0
local explosionRadius = 800
local primaryCooldown = 0 -- in sec
local explosionDmg = GetConVar("ttt_dvabomb_damage"):GetInt()

function SWEP:PrimaryAttack()
    local ply = self:GetOwner()
    
    self:SetNextPrimaryFire(CurTime() + primaryCooldown)
    if not self:CanPrimaryAttack() then return end
    self:TakePrimaryAmmo(1)
    if SERVER then
        local bombEnt = self:BuildBomb(ply)
        if not bombEnt then return end
    end
    ply:EmitSound(primVoiceline, 350, 100, 1)
    local angle = Angle(-10, -5, 0)
    ply:ViewPunch(angle)
end

function SWEP:BuildBomb(ply)
    local ply = self:GetOwner()
    local bombEnt = ents.Create("ent_ttt_ttt2_milk_gun")
    if not IsValid(bombEnt) then return false end
    bombEnt:SetModel("models/Characters/overwatch/dva/mech.mdl")
    bombEnt:SetAngles(ply:EyeAngles())
    bombEnt:SetPos(ply:EyePos() + (ply:GetAimVector() * 16))
    bombEnt:SetOwner(ply)
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

        local entityTable = ents.FindInSphere(bombEnt:GetPos(), explosionRadius)
        for _, sphereEnt in pairs(entityTable) do
            if sphereEnt:IsValid() and sphereEnt:IsPlayer() then
                local traceResult = util.TraceLine(
                    {
                        start = bombEnt:GetBonePosition(3), -- 3 is a randomly chosen number....
                        --start = bombEnt:GetPos(),
                        endpos = sphereEnt:GetShootPos(),
                        filter = {},
                        mask = MASK_PLAYERSOLID,
                        collision = COLLISION_GROUP_NONE,
                        ignoreworld = false,
                        table = nil
                    }
                )
                if not traceResult then return end
                if traceResult.Entity == sphereEnt then
                    sphereEnt:TakeDamage(explosionDmg, ply, self)
                    -- TODO: Apply force Ausfallswinkel
                    -- TODO: Change bounding box to reflect custom model size
                end
            end
        end
    end
    -- 3.5 seconds is exactly the delay needed to sync up with the boom
    timer.Simple(3.5, explode)
end

function SWEP:SecondaryAttack()
    self:SetNextSecondaryFire(CurTime() + 2)

    if GetConVar("ttt_dvabomb_secondary_sound"):GetBool() then
        self:GetOwner():EmitSound(secondVoiceline, 75, 100, 0.4)
    end
end