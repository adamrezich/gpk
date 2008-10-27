if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if (CLIENT) then
	SWEP.DrawAmmo			= true
	SWEP.DrawCrosshair		= false
	SWEP.ViewModelFOV		= 82
	SWEP.ViewModelFlip		= true
	SWEP.CSMuzzleFlashes	= true
end

SWEP.Base						= "weapon_base"

SWEP.Spawnable					= false
SWEP.AdminSpawnable				= false

SWEP.AutoSwitchTo				= true
SWEP.AutoSwitchFrom				= true

SWEP.Primary.Sound				= Sound("Weapon_AK47.Single")
SWEP.Primary.Recoil				= 1.5
SWEP.Primary.Damage				= 40
SWEP.Primary.NumShots			= 1
SWEP.Primary.Cone				= 0.02
SWEP.Primary.Delay				= 0.15

SWEP.Primary.ClipSize			= -1
SWEP.Primary.DefaultClip		= -1
SWEP.Primary.Automatic			= false
SWEP.Primary.Ammo				= "none"

SWEP.Secondary.ClipSize			= -1
SWEP.Secondary.DefaultClip		= -1
SWEP.Secondary.Automatic		= false
SWEP.Secondary.Ammo				= "none"

SWEP.ShowIndividualRounds		= false
SWEP.Holstered					= false

SWEP.Mode						= WEAPON_GENERIC

SWEP.ReloadTapDone				= CurTime()
SWEP.OneReloadTap				= false
SWEP.AddedHoldingPenalty		= false

SWEP.IsFlashlight				= false
SWEP.Lowered					= false
SWEP.Shotgun					= false
SWEP.CockNext					= false // no jokes about this one
SWEP.CockTimer					= CurTime()	// or this one either

local IRONSIGHT_TIME = 0.25
local SAFETY_TIME = 0.25
SWEP.NextSecondaryAttack = 0

local ActIndex = {}
ActIndex[ "pistol" ] 		= ACT_HL2MP_IDLE_PISTOL
ActIndex[ "smg" ] 			= ACT_HL2MP_IDLE_SMG1
ActIndex[ "grenade" ] 		= ACT_HL2MP_IDLE_GRENADE
ActIndex[ "ar2" ] 			= ACT_HL2MP_IDLE_AR2
ActIndex[ "shotgun" ] 		= ACT_HL2MP_IDLE_SHOTGUN
ActIndex[ "rpg" ]	 		= ACT_HL2MP_IDLE_RPG
ActIndex[ "physgun" ] 		= ACT_HL2MP_IDLE_PHYSGUN
ActIndex[ "crossbow" ] 		= ACT_HL2MP_IDLE_CROSSBOW
ActIndex[ "melee" ] 		= ACT_HL2MP_IDLE_MELEE
ActIndex[ "slam" ] 			= ACT_HL2MP_IDLE_SLAM
ActIndex[ "normal" ]		= ACT_HL2MP_IDLE

function SWEP:SetWeaponHoldType(t)

	local index = ActIndex[ t ]
	
	if (index == nil) then
		Msg("SWEP:SetWeaponHoldType - ActIndex[ \""..t.."\" ] isn't set!\n")
		return
	end

	self.ActivityTranslate = {}
	self.ActivityTranslate [ ACT_HL2MP_IDLE ] 					= index
	self.ActivityTranslate [ ACT_HL2MP_WALK ] 					= index+1
	self.ActivityTranslate [ ACT_HL2MP_RUN ] 					= index+2
	self.ActivityTranslate [ ACT_HL2MP_IDLE_CROUCH ] 			= index+3
	self.ActivityTranslate [ ACT_HL2MP_WALK_CROUCH ] 			= index+4
	self.ActivityTranslate [ ACT_HL2MP_GESTURE_RANGE_ATTACK ] 	= index+5
	self.ActivityTranslate [ ACT_HL2MP_GESTURE_RELOAD ] 		= index+6
	self.ActivityTranslate [ ACT_HL2MP_JUMP ] 					= index+7
	self.ActivityTranslate [ ACT_RANGE_ATTACK1 ] 				= index+8
	
	//self:SetupWeaponHoldTypeForAI(t)

end
function SWEP:TranslateActivity(act)

	if (self.Owner:IsNPC()) then
		if (self.ActivityTranslateAI[ act ]) then
			return self.ActivityTranslateAI[ act ]
		end
		return -1
	end

	if (self.ActivityTranslate[ act ] != nil) then
		return self.ActivityTranslate[ act ]
	end
	
	return -1

end
function SWEP:ShouldDropOnDie()
	return false
end
function SWEP:GetCapabilities()

	return CAP_WEAPON_RANGE_ATTACK1 | CAP_INNATE_RANGE_ATTACK1

end

function SWEP:ResetLower()
	timer.Adjust("LowerTimer_"..self.PrintName, self.LowerTime, 1, function(self)
		if (self and self != NULL and self != {NULL} and self:IsValid() and self != nil and self.Owner and self.Owner:IsPlayer() and self.Owner:GetActiveWeapon() == self.Weapon) then
			self.Weapon.Lowered = true
			self.Weapon:SendWeaponAnim(ACT_VM_IDLE_TO_LOWERED)
			timer.Simple(0.05, function(self)
				self.Weapon:SendWeaponAnim(ACT_VM_IDLE_LOWERED)
			end, self)
			self:SetWeaponHoldType("normal")
			self:ResetLower()
		end
	end, self)
end
function SWEP:StartLower()
	timer.Start("LowerTimer_"..self.PrintName)
end

function SWEP:Initialize()
	if SERVER then
		self:SetWeaponHoldType(self.HoldType)
		self:ResetLower()
	end
	
	self:SetNetworkedBool("Ironsights", false)
	self:SetNetworkedBool("Safety", false)
	self:SetNetworkedBool("LastViewChange", false) // true = safety | false = ironsights
	self:SetNetworkedEntity("held",nil)
	self:SetNetworkedBool("canprimary",true)
	self:SetNetworkedBool("cansecondary",true)
	self:SetNetworkedBool("canreload",true)
	
	-- Precache our sounds.
	if self.Primary.Sound then
		util.PrecacheSound(self.Primary.Sound)
	end
	
	if self.Secondary.Sound then
		util.PrecacheSound(self.Secondary.Sound)
	end
	
	if self.Sounds then
		for _, v in pairs(self.Sounds) do
			util.PrecacheSound(v)
		end
	end
end
function SWEP:Think()
	self.Weapon:SetPlaybackRate(1.0)
	local ply = self.Owner
	if ply:GetMoveType() == MOVETYPE_LADDER then
		self:DoHolster()
	elseif ply:GetMoveType() != MOVETYPE_LADDER then
		self:DoDeploy()
	end
	if (SERVER) then
		/*if ply:GetMoveType() == MOVETYPE_LADDER then
			self:DoHolster()
		elseif ply:GetMoveType() != MOVETYPE_LADDER then
			self:DoDeploy()
		end*/
		//if (ply:KeyDown(IN_SPEED)) then
		//if (!ply:OnGround()) then
		if (false) then
			self.Weapon:SetNetworkedBool("Safety",true)
			self.Weapon:SetNetworkedBool("Ironsights",false)
			self.Weapon:SetNetworkedBool("LastViewChange",true)
		else
			self.Weapon:SetNetworkedBool("Safety",false)
		end
		
		if (ply:KeyReleased(IN_SPEED)) then
			timer.Simple(0.30 , function () self.Weapon:SetNetworkedBool("LastViewChange", false) end)
		end
	end
end
function SWEP:DoHolster()
	if !self.Weapon.Holstered then
		self.Weapon:SendWeaponAnim(ACT_VM_HOLSTER)
		self.Weapon.Holstered = true
		if (SERVER) then
			timer.Simple(self.Weapon.SafetyTime, function(self)
				if (self.Owner:GetActiveWeapon() == self.Weapon) then
					self.Owner:DrawViewModel(false)
				end
			end, self)
		end
	end
end
function SWEP:DoDeploy()
	if self.Weapon.Holstered then
		self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
		self.Weapon.Holstered = false
		if (SERVER) then self.Owner:DrawViewModel(true) end
	end
end
function SWEP:Holster()
	if (SERVER) then self.Owner:DrawWorldModel(true) end
	return true
end
function SWEP:Deploy()
	if (self.NoWorldModel and SERVER) then
		self.Owner:DrawWorldModel(false)
	else
		self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
		self.Weapon.Lowered = false
		self:SetWeaponHoldType(self.RealHoldType)
		if (SERVER) then self:StartLower() end
		timer.Simple(0.05, function(self)
			self.Weapon:SendWeaponAnim(ACT_VM_IDLE)
		end, self)
	end
	return true
end 
function SWEP:Reload()
	if (/*self:GetNetworkedEntity("held"):IsValid() or */!self:GetNetworkedBool("canreload")) then
		return false
	end
	
	-- Basic checks.
	if self.Weapon:Clip1() >= self.Primary.ClipSize || self.Owner:GetMoveType() == MOVETYPE_LADDER || self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0 then
		return false
	end
	
	-- We really should not reload while in ironsights.
	self:SetIronsights(false)
	
	// We can't reload while running at a million miles an hour
	if (self.Weapon:GetNetworkedBool("Safety")) then return false end
	
	self:SetWeaponHoldType(self.RealHoldType)
	if (SERVER) then self:StartLower() end
	
	if (self.Weapon.reloadtimer and CurTime() < self.Weapon.reloadtimer) then return false end
	
	self.Weapon:EmitSound(self.Primary.ReloadSound)
	
		if (self.Shotgun) then -- Reload individually
			
			if CurTime() >= self.ReloadTapDone  then
				if self.OneReloadTap then
					if !self.AddedHoldingPenalty then
						self.AddedHoldingPenalty = true
						self.Weapon.reloadtimer = self.Weapon.reloadtimer + 0.4
					end
				else
					self.OneReloadTap = true
				end
			end
			
			if !self.Weapon.reloadtimer || CurTime() > self.Weapon.reloadtimer then	
			
				self.Weapon:SendWeaponAnim( ACT_VM_RELOAD )
				//self.Owner:SetAnimation(PLAYER_RELOAD)
				self.Owner:SetAnimation(PLAYER_RELOAD_SHOTGUN)
				self.Owner:RemoveAmmo( 1, self.Primary.Ammo, false )
				self.Weapon:SetClip1(  self.Weapon:Clip1() + 1 )
				
				if self.Weapon:Clip1() >= self.Primary.ClipSize || self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0 then
					timer.Simple( 0.4, function()
						if (self.Owner and self.Owner:IsPlayer() and self.Weapon and self.Weapon:IsValid()) then
							self.Weapon:SendWeaponAnim( ACT_SHOTGUN_RELOAD_FINISH )
						end
					end)
					timer.Simple( 1.4, function()
						if (self.Owner and self.Owner:IsPlayer() and self.Weapon and self.Weapon:IsValid()) then
							self.Weapon:SendWeaponAnim( ACT_VM_IDLE )
						end
					end )
				end
				
				self.Weapon.reloadtimer 	= CurTime() + 0.4
				self.ReloadTapDone			= CurTime() + 0.3
				self.OneReloadTap			= false
				self.AddedHoldingPenalty	= false
				
			end
		else	
			//self:TakePrimaryAmmo( self.Weapon:Clip1() )
			self.Owner:RemoveAmmo(self.Weapon:Clip1(), self.Weapon:GetPrimaryAmmoType())
			self.Weapon:DefaultReload( ACT_VM_RELOAD )
			self.Weapon.reloadtimer = CurTime() + 2
		end
	return false
end
function SWEP:CanPrimaryAttack()
	if (self.Weapon.Lowered) then
		self.Weapon:SendWeaponAnim(ACT_VM_LOWERED_TO_IDLE)
		timer.Simple(0.15, function(self)
			if (self and self != NULL and self != {NULL} and self:IsValid() and self != nil and self.Owner and self.Owner:IsPlayer() and self.Owner:GetActiveWeapon() == self.Weapon) then
				self.Weapon.Lowered = false
				self.Weapon:SendWeaponAnim(ACT_VM_IDLE)
				self:PrimaryAttack()
			end
		end, self)
		return false
	end
	
	if (self.Weapon.Holstered) then return false end
	if self.Primary.DefaultClip == -1 && self.Primary.ClipSize == -1 then return true end -- Of course we can fire, we don't need ammo.
	//if (self.Weapon:GetNetworkedBool("Safety")) then return false end
	
	if self.Weapon:Clip1() <= 0 then
		self.Weapon:EmitSound("Weapon_Pistol.Empty")
		self.Weapon:SetNextPrimaryFire(CurTime() + 0.2)
		return false
	end
	
	if self.Weapon:GetOwner():GetMoveType() == MOVETYPE_LADDER then
		return false
	end

	return true
end
function SWEP:PrimaryAttack()
	/*if (self:GetNetworkedEntity("held"):IsValid() or !self:GetNetworkedBool("canprimary")) then
		return false
	end*/
	if (self.Weapon.Shotgun and self.Weapon:Clip1() > 0) then
		if (self.Weapon.CockNext) then
			self.Weapon.CockNext = false
			self.Weapon:SendWeaponAnim(ACT_SHOTGUN_PUMP)
			self.Weapon:EmitSound(Sound("Weapon_Shotgun.Special1"))
			self.Weapon.CockTimer = CurTime() + 0.45
			return true
		elseif (self.Weapon.CockTimer <= CurTime()) then
			self.Weapon.CockNext = true
		else
			return true
		end
	end
	self:SetWeaponHoldType(self.RealHoldType)
	if (SERVER) then self:StartLower() end
	self.Weapon:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	
	if (!self:CanPrimaryAttack()) then return end
	self.Weapon.Lowered = false
	self.Weapon:EmitSound(self.Primary.Sound)
	self:ShootBullets(self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone)

	self:TakePrimaryAmmo(1)

	self.Owner:ViewPunch(Angle(math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) *self.Primary.Recoil, 0))
	if (SinglePlayer() and SERVER) || CLIENT then
		self.Weapon:SetNetworkedFloat("LastShootTime", CurTime())
	end
end
function SWEP:CanSecondaryAttack()
	if (self.Weapon.Lowered) then
		self.Weapon:SendWeaponAnim(ACT_VM_LOWERED_TO_IDLE)
		timer.Simple(0.05, function(self)
			self.Weapon.Lowered = false
			self.Weapon:SendWeaponAnim(ACT_VM_IDLE)
		end, self)
		return false
	end
	
	if (self.Weapon.Holstered) then return false end
	if self.Primary.DefaultClip == -1 && self.Primary.ClipSize == -1 then return true end -- Of course we can fire, we don't need ammo.
	//if (self.Weapon:GetNetworkedBool("Safety")) then return false end
	
	if self.Weapon:Clip1() <= 0 then
		self.Weapon:EmitSound("Weapon_Pistol.Empty")
		self.Weapon:SetNextPrimaryFire(CurTime() + 0.2)
		return false
	end
	
	if (self.Weapon.Shotgun and self.Weapon.CockNext) then
		//self.Weapon:
	end
	
	if self.Weapon:GetOwner():GetMoveType() == MOVETYPE_LADDER then
		return false
	end

	return true
end
function SWEP:SecondaryAttack()
	if (self:GetNetworkedEntity("held"):IsValid() or !self:GetNetworkedBool("cansecondary")) then
		return false
	end	
	
	if (self.NextSecondaryAttack > CurTime()) then return end
	
	if self.Mode == WEAPON_MELEE then -- We are a melee swep, fire appropriatly
		-- Sexy melee handling comeing up here!
		if !self.SecondaryTable then return false end -- Just in case
		
		for _, v in pairs(self.SecondaryTable) do
			if !v.time || v.time == 0 then
				self:DoMelee(v.damage, v.punch, v.anim, v.sound) 
			else
				timer.Simple(v.time, 	
					function(self, v)
						if self && self.Owner && self.Owner:IsValid() && self:IsValid() && v then
							self:DoMelee(v.damage, v.punch, v.anim, v.sound) 
						end
					end
				, self, v)
			end
		end
		
		-- Do this seperatly from the ironsights.
		self.Weapon:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
		self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	else -- We are a standard weapon, do some ironsights
		if (!self.IronSightsPos) then return end

		
		bIronsights = !self.Weapon:GetNetworkedBool("Ironsights", false)

		self:SetIronsights(bIronsights)
		
		self.NextSecondaryAttack = CurTime() + 0.3
	end
end
function SWEP:DoMelee(damage, punch, anim, sound) 
	if damage then -- if we need to deal some damage
		if SERVER then
			if self.Owner:GetFatigue() >= damage then
				self.Owner:Fatigue(-damage*2)
				self.Owner:TraceHullAttack(self.Owner:GetShootPos(), self.Owner:GetAimVector() * 120, Vector(-16,-16,-16), Vector(36,36,36), damage, DMG_CLUB, true)
				local trace = util.GetPlayerTrace(self.Owner)
				local tr = util.TraceLine(trace)
				if (trace.start - tr.HitPos):Length() < 120 then
					if !tr.HitWorld and tr.Entity:IsValid() then
						tr.Entity:GetPhysicsObject():ApplyForceOffset(self.Owner:GetAimVector() * 10000, tr.HitPos)
					end
				end
			else
				self.Weapon:SetNextPrimaryFire(CurTime() + 2)
				self.Weapon:EmitSound(Sound("common/warning.wav"))
				self.Weapon:SendWeaponAnim(ACT_VM_IDLE)
				return false
			end
		end
	end
	
	if punch then
		self.Owner:ViewPunch(punch)
	end
	
	if anim then
		if (anim!=ACT_VM_IDLE) then
			self.Weapon:SendWeaponAnim(anim)
		end
	end
	
	if sound then
		self.Weapon:EmitSound(Sound(sound))
	end
end
function SWEP:ShootBullets(dmg, recoil, numbul, cone)

	numbul 	= numbul 	or 1
	cone 	= cone 		or 0.01

	// Code to modify aim cones when crouched or running

	if !self.Primary.NoCone then
		if self.Owner:Crouching() then
			if cone > 0.02 then
				cone = cone - 0.03
			else
				cone = 0.1
			end
		end

		if self.Weapon:GetNetworkedBool("Ironsights") then
			if cone > 0.01 then
				cone = cone - 0.02
			else
				cone = 0
			end
		end

	    if self.Owner:GetVelocity():Length() >= 140 then
	    	cone = cone + 0.05
	    end

	    if self.Owner:GetVelocity():Length() > 5 then
	    	cone = cone + 0.03
	    end
	end
	
	local aimspread = Vector(cone, cone, 0)

	local bullet = {}
	bullet.Num 		= numbul
	bullet.Src 		= self.Owner:GetShootPos()			// Source
	bullet.Dir 		= self.Owner:GetAimVector()			// Dir of bullet
	bullet.Spread 	= aimspread							// Aim Cone
	bullet.Tracer	= 1									// Show a tracer on every x bullets
	bullet.TracerName = "Tracer"
	bullet.Force	= 20/numbul									// Amount of force to give to phys objects
	bullet.Damage	= dmg
	
	self.Owner:FireBullets(bullet)
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK) 		// View model animation
	self.Owner:MuzzleFlash()								// Crappy muzzle light
	self.Owner:SetAnimation(PLAYER_ATTACK1)				// 3rd Person Animation
	
	// CUSTOM RECOIL !
	/*if ((SinglePlayer() && SERVER) || (!SinglePlayer() && CLIENT)) then
		local eyeang = self.Owner:EyeAngles()
		eyeang.pitch = eyeang.pitch - recoil
		self.Owner:SetEyeAngles(eyeang)
	end*/

end
function SWEP:GetViewModelPosition(pos, ang)
	if (!self.IronSightsPos) then return pos, ang end
	
	if (self.SafetyPos and (self.Weapon:GetNetworkedBool("Safety") or self.Weapon:GetNetworkedBool("LastViewChange"))) then
		local bSafety = self.Weapon:GetNetworkedBool("Safety")
		if (bSafety != self.bLastIron) then
			self.bLastIron = bSafety
			self.fSafetyTime = CurTime()
			if (bSafety) then
				self.SwayScale 	= 1.0
				self.BobScale 	= 1.0
			else
				self.SwayScale 	= 1.0
				self.BobScale 	= 1.0
			end
		end
		local fSafetyTime = self.fSafetyTime or 0
		if (!bSafety && fSafetyTime < CurTime() - SAFETY_TIME) then
		return pos, ang
		end
		local Mul = 1.0
		if (fSafetyTime > CurTime() - SAFETY_TIME) then
			Mul = math.Clamp((CurTime() - fSafetyTime) / SAFETY_TIME, 0, 1)
			if (!bSafety) then Mul = 1 - Mul end
		end
		local Offset	= self.SafetyPos
		if (self.SafetyAng) then
			ang = ang * 1
			ang:RotateAroundAxis(ang:Right(), 		self.SafetyAng.x * Mul)
			ang:RotateAroundAxis(ang:Up(), 		self.SafetyAng.y * Mul)
			ang:RotateAroundAxis(ang:Forward(), 	self.SafetyAng.z * Mul)
		end
		local Right 	= ang:Right()
		local Up 		= ang:Up()
		local Forward 	= ang:Forward()
		pos = pos + Offset.x * Right * Mul
		pos = pos + Offset.y * Forward * Mul
		pos = pos + Offset.z * Up * Mul
		return pos, ang
	elseif (!self.Weapon:GetNetworkedBool("LastViewChange")) then
		local bIron = self.Weapon:GetNetworkedBool("Ironsights")
		if (bIron != self.bLastIron) then
			self.bLastIron = bIron
			self.fIronTime = CurTime()
			if (bIron) then
				self.SwayScale 	= 0.3
				self.BobScale 	= 0.1
			else
				self.SwayScale 	= 1.0
				self.BobScale 	= 1.0
			end
		end
		local fIronTime = self.fIronTime or 0
		if (!bIron && fIronTime < CurTime() - IRONSIGHT_TIME) then
		return pos, ang
		end
		local Mul = 1.0
		if (fIronTime > CurTime() - IRONSIGHT_TIME) then
			Mul = math.Clamp((CurTime() - fIronTime) / IRONSIGHT_TIME, 0, 1)
			if (!bIron) then Mul = 1 - Mul end
		end
		local Offset	= self.IronSightsPos
		if (self.IronSightsAng) then
			ang = ang * 1
			ang:RotateAroundAxis(ang:Right(), 		self.IronSightsAng.x * Mul)
			ang:RotateAroundAxis(ang:Up(), 		self.IronSightsAng.y * Mul)
			ang:RotateAroundAxis(ang:Forward(), 	self.IronSightsAng.z * Mul)
		end
		local Right 	= ang:Right()
		local Up 		= ang:Up()
		local Forward 	= ang:Forward()
		pos = pos + Offset.x * Right * Mul
		pos = pos + Offset.y * Forward * Mul
		pos = pos + Offset.z * Up * Mul
		return pos, ang
	end
end
function SWEP:SetIronsights(b)
	if ((self.Mode == WEAPON_SCOPED and self.Owner:GetVelocity()==Vector(0,0,0)) or self.Mode != WEAPON_SCOPED) then
		self.Weapon:SetNetworkedBool("Ironsights", b)
	end
end
function SWEP:OnRestore()
	self.NextSecondaryAttack = 0
	self:SetIronsights(false)
end
