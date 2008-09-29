if ( SERVER ) then AddCSLuaFile( "shared.lua" ) end

SWEP.Base						= "weapon_gpk_base"

SWEP.ViewModel					= "models/weapons/v_shotgun.mdl"
SWEP.WorldModel					= "models/weapons/w_shotgun.mdl"

SWEP.PrintName					= "Shotgun"
SWEP.Slot						= 3
SWEP.SlotPos					= 0

SWEP.ViewModelFOV				= 80
SWEP.ViewModelFlip				= false
SWEP.IronSightsPos 				= Vector( 4.3, -2, 2.7 )
SWEP.IronSightsAng				= Vector( 0, 0, 0 )

SWEP.SafetyPos					= Vector(1.6253, -12.7378, -1.4437)
SWEP.SafetyAng					= Vector(81.6156, -1.3747, 11.5092)
SWEP.SafetyTime					= 0.3

SWEP.NoWorldModel				= false
SWEP.Weight						= 5
SWEP.HoldType					= "shotgun"
SWEP.RealHoldType				= "shotgun"
SWEP.LowerTime					= 4
SWEP.GunSmoke					= true
SWEP.ShowIndividualRounds		= true
SWEP.Shotgun					= true

SWEP.Primary.Sound				= Sound("weapons/shotgun/shotgun_fire6.wav")
SWEP.Primary.ReloadSound		= Sound("weapons/shotgun/shotgun_reload1.wav")
SWEP.Primary.Recoil				= 90
SWEP.Primary.Damage				= 15
SWEP.Primary.NumShots			= 7
SWEP.Primary.Cone				= 0.08
SWEP.Primary.NoCone				= false
SWEP.Primary.Delay				= 0.07
SWEP.Primary.ClipSize			= 6
SWEP.Primary.DefaultClip		= 6
SWEP.Primary.Automatic			= false
SWEP.Primary.Ammo				= "buckshot"

SWEP.Secondary.ClipSize			= -1
SWEP.Secondary.DefaultClip		= -1
SWEP.Secondary.Automatic		= false
SWEP.Secondary.Ammo				= "none"

SWEP.KillString1				= "killed"
SWEP.KillString2				= "with his 9mm Pistol"