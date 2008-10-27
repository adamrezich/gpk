if (SERVER) then AddCSLuaFile("shared.lua") end

SWEP.Base						= "weapon_gpk_base"

SWEP.ViewModel					= "models/weapons/v_stunstick.mdl"
SWEP.WorldModel					= "models/weapons/w_stunstick.mdl"

SWEP.PrintName					= "Stunstick"
SWEP.Slot						= 0
SWEP.SlotPos					= 2

SWEP.AutoSwitchTo				= true
SWEP.AutoSwitchFrom				= true

SWEP.ViewModelFOV				= 60
SWEP.ViewModelFlip				= false
SWEP.IronSightsPos 				= Vector(0, 0, 0)
SWEP.IronSightsAng				= Vector(0, 0, 0)

SWEP.SafetyPos					= Vector(1.6253, -12.7378, -1.4437)
SWEP.SafetyAng					= Vector(81.6156, -1.3747, 11.5092)
SWEP.SafetyTime					= 0.01

SWEP.NoWorldModel				= false
SWEP.Weight						= 5
SWEP.HoldType					= "normal"
SWEP.RealHoldType				= "melee"
SWEP.LowerTime					= 0.5
SWEP.GunSmoke					= true
SWEP.ShowIndividualRounds		= false

SWEP.Primary.Sound				= Sound("weapons/pistol/pistol_fire2.wav")
SWEP.Primary.ReloadSound		= Sound("weapons/pistol/pistol_reload1.wav")
SWEP.Primary.Recoil				= 75
SWEP.Primary.Damage				= 35
SWEP.Primary.NumShots			= 1
SWEP.Primary.Cone				= 0
SWEP.Primary.NoCone				= true
SWEP.Primary.Delay				= 0.35
SWEP.Primary.ClipSize			= -1
SWEP.Primary.DefaultClip		= -1
SWEP.Primary.Automatic			= true
SWEP.Primary.Ammo				= "none"

SWEP.Secondary.Damage			= 25
SWEP.Secondary.Delay			= 0.5
SWEP.Secondary.ClipSize			= -1
SWEP.Secondary.DefaultClip		= -1
SWEP.Secondary.Automatic		= true
SWEP.Secondary.Ammo				= "none"

SWEP.KillString1				= "killed"
SWEP.KillString2				= "with his 9mm Pistol"

function SWEP:Precache()
	util.PrecacheSound("physics/flesh/flesh_impact_bullet3.wav")
	util.PrecacheSound("physics/flesh/flesh_impact_bullet4.wav")
	util.PrecacheSound("physics/flesh/flesh_impact_bullet5.wav")
	util.PrecacheSound("weapons/iceaxe/iceaxe_swing1.wav")
end

function SWEP:PrimaryAttack()
self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
if (!self:CanPrimaryAttack()) then return end
local trace = self.Owner:GetEyeTrace()
self:SetWeaponHoldType(self.RealHoldType)
self.Owner:SetAnimation(PLAYER_ATTACK1)
self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
if (CLIENT) then
	timer.Simple(0.1, function(self)
		if (self.Owner and self.Owner:IsPlayer()) then
			self.Owner:ViewPunch(Angle(math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) *self.Primary.Recoil, math.Rand(-0.1,0.1) *self.Primary.Recoil))
		end
	end, self)
end
timer.Simple(self.LowerTime, function(self)
		if (self and self != NULL and self != {NULL} and self:IsValid() and self != nil) then
			self:SetWeaponHoldType("normal")
		end
	end, self)
local power = math.floor(self.Owner:GetVelocity():Length()) / 600
if trace.HitPos:Distance(self.Owner:GetShootPos()) <= 90 then
	bullet = {}
	bullet.Num    = 1
	bullet.Src    = self.Owner:GetShootPos()
	bullet.Dir    = self.Owner:GetAimVector()
	bullet.Spread = Vector(0, 0, 0)
	bullet.Tracer = 0
	bullet.Force  = 5 + (power * 50)
	bullet.Damage = 2 + (math.pow(3, 1+power))
self.Owner:FireBullets(bullet)
self.Weapon:EmitSound("physics/flesh/flesh_impact_bullet" .. math.random(3, 5) .. ".wav")
else
	self.Weapon:EmitSound("weapons/iceaxe/iceaxe_swing1.wav")
	self.Weapon:SendWeaponAnim(ACT_VM_MISSCENTER)
end
end
