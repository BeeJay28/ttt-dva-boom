if engine.ActiveGamemode() ~= "terrortown" then return end

-- Resource handeling
if SERVER then
    AddCSLuaFile()
    resource.AddFile("materials/models/overwatch/dva/ultradva/stuffglass.vmt")
    resource.AddFile("materials/models/overwatch/dva/ultradva/stuffglass.vtf")
    resource.AddFile("materials/models/overwatch/dva/ultradva/stufflogo.vmt")
    resource.AddFile("materials/models/overwatch/dva/ultradva/stufflogo.vtf")
    resource.AddFile("materials/models/overwatch/dva/ultradva/stuffmech.vmt")
    resource.AddFile("materials/models/overwatch/dva/ultradva/stuffmech.vtf")
    resource.AddFile("materials/models/overwatch/dva/ultradva/stuffmecharms.vmt")
    resource.AddFile("materials/models/overwatch/dva/ultradva/stuffmecharms.vtf")
    resource.AddFile("materials/models/overwatch/dva/ultradva/stuffmecharms_blueberry.vmt")
    resource.AddFile("materials/models/overwatch/dva/ultradva/stuffmecharms_blueberry.vtf")
    resource.AddFile("materials/models/overwatch/dva/ultradva/stuffmecharms_carbon.vmt")
    resource.AddFile("materials/models/overwatch/dva/ultradva/stuffmecharms_carbon.vtf")
    resource.AddFile("materials/models/overwatch/dva/ultradva/stuffmecharms_lime.vmt")
    resource.AddFile("materials/models/overwatch/dva/ultradva/stuffmecharms_lime.vtf")
    resource.AddFile("materials/models/overwatch/dva/ultradva/stuffmecharms_n.vtf")
    resource.AddFile("materials/models/overwatch/dva/ultradva/stuffmecharms_orange.vmt")
    resource.AddFile("materials/models/overwatch/dva/ultradva/stuffmecharms_orange.vtf")
    resource.AddFile("materials/models/overwatch/dva/ultradva/stuffmecharms_watermelon.vmt")
    resource.AddFile("materials/models/overwatch/dva/ultradva/stuffmecharms_watermelon.vtf")
    resource.AddFile("materials/models/overwatch/dva/ultradva/stuffmecharms_whiterabbit.vmt")
    resource.AddFile("materials/models/overwatch/dva/ultradva/stuffmecharms_whiterabbit.vtf")
    resource.AddFile("materials/models/overwatch/dva/ultradva/stuffmech_blueberry.vmt")
    resource.AddFile("materials/models/overwatch/dva/ultradva/stuffglass_n.vtf")
    resource.AddFile("materials/models/overwatch/dva/ultradva/stuffmech_blueberry.vtf")
    resource.AddFile("materials/models/overwatch/dva/ultradva/stuffmech_carbon.vmt")
    resource.AddFile("materials/models/overwatch/dva/ultradva/stuffmech_carbon.vtf")
    resource.AddFile("materials/models/overwatch/dva/ultradva/stuffmech_lime.vmt")
    resource.AddFile("materials/models/overwatch/dva/ultradva/stuffmech_lime.vtf")
    resource.AddFile("materials/models/overwatch/dva/ultradva/stuffmech_n.vtf")
    resource.AddFile("materials/models/overwatch/dva/ultradva/stuffmech_orange.vmt")
    resource.AddFile("materials/models/overwatch/dva/ultradva/stuffmech_orange.vtf")
    resource.AddFile("materials/models/overwatch/dva/ultradva/stuffmech_watermelon.vmt")
    resource.AddFile("materials/models/overwatch/dva/ultradva/stuffmech_watermelon.vtf")
    resource.AddFile("materials/models/overwatch/dva/ultradva/stuffmech_whiterabbit.vmt")
    resource.AddFile("materials/models/overwatch/dva/ultradva/stuffmech_whiterabbit.vtf")
    resource.AddFile("materials/vgui/ttt/weapon_dva_mech.vmt")
    resource.AddFile("sound/dvaBombNorm.wav")
    resource.AddFile("sound/messYouUp.wav")
    resource.AddFile("sound/nerfThis.wav")
    resource.AddFile("models/Characters/overwatch/dva/mech.mdl")
    resource.AddFile("models/Characters/overwatch/dva/gun.mdl")
end

-- Setting the parameters for the Item
SWEP.PrintName = "D.Va Bomb"
SWEP.Author = "BeeJay28 & James"
SWEP.Contact = "Steam"
SWEP.Instructions = "You can shoot the mech-bomb with primary attack and taunt with secondary attack."
SWEP.Purpose = "Blow up everybody with a throwable D.Va Ult bomb. Radius and damage are configurable."
SWEP.Spawnable = false
SWEP.AdminOnly = false
SWEP.Icon = "vgui/ttt/weapon_dva_mech"
SWEP.Base = "weapon_tttbase"
SWEP.Kind = WEAPON_EQUIP1

SWEP.CanBuy = {ROLE_TRAITOR, ROLE_JACKAL}

SWEP.InLoadoutFor = nil
SWEP.LimitedStock = true

-- Changing what it says in the Equipmenu
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
SWEP.Primary.Ammo = "none"
SWEP.Weight = 7
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true
SWEP.ViewModel = "models/weapons/v_pist_fiveseven.mdl"
SWEP.WorldModel = "models/weapons/w_pist_fiveseven.mdl"

--- Initialize the variables.

-- This sets the soundeffects. Ripped directly from Overwatch
local primVoiceline = Sound("nerfThis.wav")
local secondVoiceline = Sound("messYouUp.wav")

-- How fast should the mech fly out of the gun?
local shootVelocity = 800

-- What's the mass of this thing?

-- Test results show, that higher mass
-- allows players to throw this thing
-- against a player and kill them with it.
-- Also factor in aerial drag... wind drag...
-- drag races... drag queens... factor them in!
local mass = 0

-- Anti James Spam protection
local primaryCooldown = 1 -- in sec

-- How strongly should people be able to "Rocketjump" off of dvas mech
local explosionForce = 20000


function SWEP:PrimaryAttack()
    local ply = self:GetOwner()
    
    self:SetNextPrimaryFire(CurTime() + primaryCooldown)
    
    if not self:CanPrimaryAttack() then return end
    self:TakePrimaryAmmo(1)

    if SERVER then
        local success = self:ExplodeBomb(ply)
        if not success then return end
        ply:EmitSound(primVoiceline, 350, 100, 1)
        local angle = Angle(-10, -5, 0)
        ply:ViewPunch(angle)
    end
end

function SWEP:ExplodeBomb(ply)
    -- Create mech entity, including model and explosive code
    local bombEnt = ents.Create("ent_ttt_ttt2_dva_bomb")

    if not IsValid(bombEnt) then return false end

    -- Yaw and Roll of player, Pitch = 0
    local eyeAngles = ply:EyeAngles()
    bombEnt:SetAngles(Angle(0, eyeAngles[2], eyeAngles[3]))

    bombEnt:SetPos(ply:EyePos() + (ply:GetAimVector() * 16)) -- 16/2 Burgers away from your face
    bombEnt:SetOwner(ply)
    bombEnt:Spawn()
    bombEnt:Activate()
    local phys = bombEnt:GetPhysicsObject()

    -- Check if our little bomb is physic-able
    if (not IsValid(phys)) then
        bombEnt:Remove()
        return false
    end

    phys:Wake()
    phys:SetMass(mass)
    phys:SetVelocity(ply:GetAimVector() * shootVelocity)

    local function explode()
        local explosionRadius = GetConVar("ttt_dvabomb_radius"):GetInt()
        -- Find ANYTHING (Actually only entitties) inside the sphere of the explosion radius
        local entityTable = ents.FindInSphere(bombEnt:GetPos(), explosionRadius)
        for _, sphereEnt in pairs(entityTable) do
            if sphereEnt:IsValid() 
                and sphereEnt:IsPlayer()
                -- Because spectators are apparently entities too
                and sphereEnt:GetObserverMode() == OBS_MODE_NONE
            then
                -- Trace for head, shoulders, knees and toes... without the shoulders, knees and toes
                local traces = {}
                sphereEnt:LagCompensation(true)
                table.insert(traces, self:CalcTrace(bombEnt:GetBonePosition(1), sphereEnt:GetBonePosition(6)))
                table.insert(traces, self:CalcTrace(bombEnt:GetBonePosition(1), sphereEnt:EyePos()))
                table.insert(traces, self:CalcTrace(bombEnt:GetPos(), sphereEnt:GetBonePosition(6)))
                table.insert(traces, self:CalcTrace(bombEnt:GetPos(), sphereEnt:EyePos()))
                sphereEnt:LagCompensation(false)

                for i, trace in ipairs(traces) do
                    if trace.Entity == sphereEnt then
                        local forceVector = self:GetForceVector(sphereEnt, bombEnt, explosionRadius)
                        sphereEnt:SetVelocity(forceVector)
                        local dmgInfo = DamageInfo()
                        local explosionDmg = GetConVar("ttt_dvabomb_damage"):GetInt()
                        dmgInfo:SetAttacker(ply)
                        dmgInfo:SetInflictor(self)
                        dmgInfo:SetDamage(explosionDmg)
                        dmgInfo:SetDamageType(DMG_BLAST)
                        sphereEnt:TakeDamageInfo(dmgInfo)
                        break
                    end
                end

            end
        end
        bombEnt:Remove()
    end
    -- 3.5 seconds is exactly the delay needed to sync up with the boom sound
    timer.Simple(3.5, explode)
    return true
end

function SWEP:SecondaryAttack()
    if not GetConVar("ttt_dvabomb_secondary_sound"):GetBool() then return end
    -- More James inhibition code
    if SERVER then
        self:SetNextSecondaryFire(CurTime() + 2)
        self:GetOwner():EmitSound(secondVoiceline, 75, 100, 0.4)
    end
end

function SWEP:GetForceVector(hitPly, bombEnt, explosionRadius)
    local localVecFromBombToRadius = (hitPly:GetPos() - bombEnt:GetPos()):GetNormalized() * explosionRadius
    local forceVec = (bombEnt:GetPos() + localVecFromBombToRadius) - hitPly:GetPos()
    local posVec = self:GetPositiveVector(forceVec)
    -- for jumpy fun
    posVec.z = 600
    forceVec = (posVec * forceVec)/300
    return forceVec
end

function SWEP:CalcTrace(startVector, stopVector)
    return util.TraceLine(
        {
            start = startVector,
            endpos = stopVector,
            filter = {},
            mask = MASK_PLAYERSOLID,
            collision = COLLISION_GROUP_NONE,
            ignoreworld = false,
            output = nil
        }
    )
end

-- Get math.abs version of vector
function SWEP:GetPositiveVector(vector)
    local posVec = Vector()
    posVec.x = math.abs(vector.x)
    posVec.y = math.abs(vector.y)
    posVec.z = math.abs(vector.z)
    return posVec
end