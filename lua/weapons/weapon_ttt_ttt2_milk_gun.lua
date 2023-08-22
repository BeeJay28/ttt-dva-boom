if engine.ActiveGamemode() ~= "terrortown" then return end

-- Resource handeling
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

-- Setting the parameters for the Item
SWEP.PrintName = "D.Va Bomb"
SWEP.Author = "BeeJay28 & James"
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
SWEP.Primary.ClipSize = 150
SWEP.Primary.DefaultClip = 150
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Weight = 7
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true
SWEP.ViewModel = "models/weapons/v_pist_fiveseven.mdl"
SWEP.WorldModel = "models/weapons/w_pist_fiveseven.mdl"

--- Initialize the variables.

-- This sets the soundeffects. Ripped directly from Overwatch™️
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

-- Kaboom size. In general. 1000 is about the
-- size of the lighthouse in that minecraft map...
-- with the lighthouse (editor's note, it's minecraft_b5) -- thanks editor
local explosionRadius = 850

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
        -- Create mech entity, including model and explosive code
        local bombEnt = self:BuildBomb(ply)
        if not bombEnt then return end
    end
    ply:EmitSound(primVoiceline, 350, 100, 1)
    local angle = Angle(-10, -5, 0)
    ply:ViewPunch(angle)
end

function SWEP:BuildBomb(ply)
    -- How to build a bomb, a step-by-mine guide

    -- Step 2: Spawn the bomb
    local bombEnt = ents.Create("ent_ttt_ttt2_milk_gun")

    -- Step 3: Is the bomb a valid member of society
    if not IsValid(bombEnt) then return false end

    -- Step 4: Profit (actually no, this is under GPL license)
    
    -- Yaw and Roll of player, Pitch = 0
    local eyeAngles = ply:EyeAngles()
    bombEnt:SetAngles(Angle(0, eyeAngles[2], eyeAngles[3]))

    bombEnt:SetPos(ply:EyePos() + (ply:GetAimVector() * 16)) -- 16/2 Burgers away from your face -- 16 because 2^4
    bombEnt:SetOwner(ply)
    bombEnt:Spawn()
    -- This probably needs to be here
    bombEnt:Activate()
    local phys = bombEnt:GetPhysicsObject()

    -- Check if our little bomb is physic-able
    if (not IsValid(phys)) then
        bombEnt:Remove()
        return false
    end

    -- Physicus activaticus (I'm bad at spell names, I'd rather keep building bombs)
    phys:Wake()
    phys:SetMass(mass)
    phys:SetVelocity(ply:GetAimVector() * shootVelocity)

    local function explode()

        -- Find ANYTHING (Actually only entities) inside the sphere of the explosion radius
        local entityTable = ents.FindInSphere(bombEnt:GetPos(), explosionRadius)
        for _, sphereEnt in pairs(entityTable) do
            if sphereEnt:IsValid() and sphereEnt:IsPlayer() then

                -- Trace for head, shoulders, knees and toes... without the shoulders and toes
                local traceResultHead = util.TraceLine(
                    {
                        -- This is 100% the spine [See print(bombEnt:GetBoneName(1))]
                        start = bombEnt:GetBonePosition(1),
                        -- This should return the head position [See print(sphereEnt:GetBoneName(6))]
                        endpos = sphereEnt:GetBonePosition(6), -- THIS IS BROKEN... ISH. IF USING GETPOSITION IT JUST DOESNT WANT TO TRACE. FIX BEFORE RELEASE!!!111ELF
                        filter = {},
                        mask = MASK_PLAYERSOLID,
                        collision = COLLISION_GROUP_NONE,
                        ignoreworld = false,
                        table = nil
                    }
                )

                -- nobody's already tracer
                if not traceResultHead then return end
                print(traceResultHead.Entity)

                if traceResultHead.Entity == sphereEnt then
                    local forceVector = self:GetForceVector(sphereEnt, bombEnt)

                    sphereEnt:SetVelocity(forceVector)
                    -- Set Damage
                    local dmgInfo = DamageInfo()
                    local explosionDmg = GetConVar("ttt_dvabomb_damage"):GetInt()
                    dmgInfo:SetAttacker(ply)
                    dmgInfo:SetInflictor(self)
                    dmgInfo:SetDamage(explosionDmg)
                    dmgInfo:SetDamageType(DMG_BLAST)
                    sphereEnt:TakeDamageInfo(dmgInfo)

                    -- sphereEnt:TakeDamage(explosionDmg, ply, self)
                    -- TODO: Try this code for boundingBox -- Update: It doesnt work... -James
                    -- TODO: Change bounding box to reflect custom model size
                end
            end
        end
        bombEnt:Remove()
    end
    -- 3.5 seconds is exactly the delay needed to sync up with the boom sound
    timer.Simple(3.5, explode)
end

function SWEP:SecondaryAttack()
    -- More James inhibition code
    self:SetNextSecondaryFire(CurTime() + 2)

    if GetConVar("ttt_dvabomb_secondary_sound"):GetBool() then
        self:GetOwner():EmitSound(secondVoiceline, 75, 100, 0.4)
    end
end

function SWEP:GetForceVector(hitPly, bombEnt)
    -- On explosion, yeet whoever dares to get too close
    local localVecFromBombToRadius = (hitPly:GetPos() - bombEnt:GetPos()):GetNormalized() * explosionRadius
    print(localVecFromBombToRadius)
    local forceVec = (bombEnt:GetPos() + localVecFromBombToRadius) - hitPly:GetPos()
    print(forceVec)
    local posVec = self:GetPositiveVector(forceVec)
    print(posVec)
    -- for jumpy fun
    posVec.z = 400
    forceVec = (posVec * forceVec)/200
    print(forceVec)
    return forceVec
end

-- Get math.abs version of vector
function SWEP:GetPositiveVector(vector)
    local posVec = Vector()
    posVec.x = math.abs(vector.x)
    posVec.y = math.abs(vector.y)
    posVec.z = math.abs(vector.z)
    return posVec
end