if ( SERVER ) then AddCSLuaFile( "shared.lua" ) end

SWEP.Base						= "weapon_gpk_base"

SWEP.ViewModel					= "models/weapons/v_smg1.mdl"
SWEP.WorldModel					= "models/weapons/w_smg1.mdl"

SWEP.PrintName					= "Submachine Gun"
SWEP.Slot						= 2
SWEP.SlotPos					= 0

SWEP.ViewModelFOV				= 80
SWEP.ViewModelFlip				= false
SWEP.IronSightsPos 				= Vector( 4.3, -2, 2.7 )
SWEP.IronSightsAng				= Vector( 0, 0, 0 )

SWEP.SafetyPos					= Vector(1.6253, -12.7378, -1.4437)
SWEP.SafetyAng					= Vector(81.6156, -1.3747, 11.5092)
SWEP.SafetyTime					= 0.01

SWEP.NoWorldModel				= false
SWEP.Weight						= 5
SWEP.HoldType					= "smg"
SWEP.RealHoldType				= "smg"
SWEP.LowerTime					= 4
SWEP.GunSmoke					= true
SWEP.ShowIndividualRounds		= true

SWEP.Primary.Sound				= Sound("weapons/smg1/smg1_fire1.wav")
SWEP.Primary.ReloadSound		= Sound("weapons/smg1/smg1_reload.wav")
SWEP.Primary.Recoil				= 12
SWEP.Primary.Damage				= 7
SWEP.Primary.NumShots			= 1
SWEP.Primary.Cone				= 0
SWEP.Primary.NoCone				= true
SWEP.Primary.Delay				= 0.07
SWEP.Primary.ClipSize			= 45
SWEP.Primary.DefaultClip		= 45
SWEP.Primary.Automatic			= true
SWEP.Primary.Ammo				= "smg1"

SWEP.Secondary.ClipSize			= -1
SWEP.Secondary.DefaultClip		= -1
SWEP.Secondary.Automatic		= false
SWEP.Secondary.Ammo				= "none"

SWEP.KillString1				= "killed"
SWEP.KillString2				= "with his 9mm Pistol"