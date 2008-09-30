AddCSLuaFile(	"cl_init.lua")
AddCSLuaFile(	"shared.lua")
AddCSLuaFile(	"shd_config.lua")
AddCSLuaFile(	"shd_ragspec.lua")
AddCSLuaFile(	"shd_viewpunch.lua")

include(		"shared.lua")
include(		"sv_walljump.lua")
include(		"sv_svn.lua")
include(		"sv_dropweapon.lua")
include(		"shd_ragspec.lua")
include(		"shd_viewpunch.lua")

PLAYER_RELOAD_SHOTGUN = 9001
PLAYER_ROLL_LEFT = 9002
PLAYER_ROLL_RIGHT = 9003

SlideSound = {}

local AnimTranslateTable = {} 
AnimTranslateTable[ PLAYER_RELOAD ] 	= ACT_HL2MP_GESTURE_RELOAD 
AnimTranslateTable[ PLAYER_JUMP ] 		= ACT_HL2MP_JUMP 
AnimTranslateTable[ PLAYER_ATTACK1 ] 	= ACT_HL2MP_GESTURE_RANGE_ATTACK
AnimTranslateTable[ PLAYER_ROLL_LEFT ] 	= ACT_ROLL_LEFT
AnimTranslateTable[ PLAYER_ROLL_RIGHT ] 	= ACT_ROLL_RIGHT
AnimTranslateTable[PLAYER_RELOAD_SHOTGUN] 	= ACT_SHOTGUN_RELOAD_START

function GM:SetPlayerAnimation(pl, anim)
	local act = ACT_HL2MP_IDLE
	local Speed = pl:GetVelocity():Length()
	local OnGround = pl:OnGround()
	// If it's in the translate table then just straight translate it
	if (AnimTranslateTable[ anim ] != nil) then
		act = AnimTranslateTable[ anim ]
	else
		// Crawling on the ground
		if (OnGround && pl:Crouching()) then
			act = ACT_HL2MP_IDLE_CROUCH
			if (Speed > 0) then
				act = ACT_HL2MP_WALK_CROUCH
			end
		elseif (Speed > 210) then
			act = ACT_HL2MP_RUN
			// Player is running on ground
		elseif (Speed > 0) then
			act = ACT_HL2MP_WALK
		end
	end
	// Attacking/Reloading is handled by the RestartGesture function
	if (act == ACT_HL2MP_GESTURE_RANGE_ATTACK ||
		act == ACT_HL2MP_GESTURE_RELOAD) then
		pl:RestartGesture(pl:Weapon_TranslateActivity(act))
		// If this was an attack send the anim to the weapon model
		if (act == ACT_HL2MP_GESTURE_RANGE_ATTACK) then
			pl:Weapon_SetActivity(pl:Weapon_TranslateActivity(ACT_RANGE_ATTACK1), 0);
		end
	return
	end
	// Always play the jump anim if we're in the air
	if (!OnGround) then
		act = ACT_HL2MP_JUMP
	end
	// Ask the weapon to translate the animation and get the sequence
	// (ACT_HL2MP_JUMP becomes ACT_HL2MP_JUMP_AR2 for example)
	local seq = pl:SelectWeightedSequence(pl:Weapon_TranslateActivity(act))
	// If we're in a vehicle just sit down
	// We should let the vehicle decide this when we have scripted vehicles
	if (pl:InVehicle()) then
		// TODO! Different ACTS for different vehicles!
		if (pl:GetVehicle():GetTable().HandleAnimation) then
			seq = pl:GetVehicle():GetTable().HandleAnimation(pl)
		else
			local class = pl:GetVehicle():GetClass()
			if (class == "prop_vehicle_jeep") then
				seq = pl:LookupSequence("drive_jeep")
			elseif (class == "prop_vehicle_airboat") then
				seq = pl:LookupSequence("drive_airboat")
			else
				seq = pl:LookupSequence("drive_pd")
			end
		end
	end
	// If the weapon didn't return a translated sequence just set
	//	the activity directly.
	if (seq == -1) then
		// Hack.. If we don't have a weapon and we're jumping we
		// use the SLAM animation (prevents the reference anim from showing)
		if (act == ACT_HL2MP_JUMP) then
			act = ACT_HL2MP_JUMP_SLAM
		end
		seq = pl:SelectWeightedSequence(act)
	end
	// Don't keep switching sequences if we're already playing the one we want.
	if (pl:GetSequence() == seq) then return end
	// Set and reset the sequence
	pl:SetPlaybackRate(1.0)
	pl:ResetSequence(seq)
	pl:SetCycle(0)
end

/*function GM:OnNPCKilled(victim, killer, weapon)
end*/
function GM:PlayerInitialSpawn(ply)
	ply:SetNWInt(	"Speed",			0)
	ply:SetNWInt(	"MinSpeed",			100)
	ply:SetNWInt(	"MaxSpeed",			400)
	ply:SetNWInt(	"CurMaxSpeed",		400)
	ply:SetNWInt(	"Acceleration",		1.5)
	ply:SetNWInt(	"SlideDecrease",	0.2)
	ply:SetNWBool(	"Climbing",			false)
	ply:SetNWBool(	"Rolling",			false)
	/*
	ply:SetNWInt(	"RollFactor",		0.5)
	ply:SetNWInt(	"RollTimer",		CurTime())
	ply:SetNWInt(	"RollStart",		CurTime())
	*/
	ply:SetNWBool(	"OverridePickup",	false)
	
	SlideSound[ply:UniqueID()] = CreateSound(ply,"physics/body/body_medium_scrape_smooth_loop1.wav")
end
function GM:PlayerLoadout(ply)
	ply:SetNWBool("OverridePickup", true)
	ply:Give("weapon_gpk_fists")
	//ply:Give("weapon_gpk_pistol")
	ply:SetNWBool("OverridePickup", false)
	ply:SetArmor(0)
	ply:DrawWorldModel(false)
	return true
end
local function ReduceFallDamage( ent, inflictor, attacker, amount, dmginfo )
	if (!ent:IsPlayer()) then return false end
	local ply = ent;
	
	if (dmginfo:IsFallDamage()) then
		local _lookangle = ply:GetUp() - ply:GetAimVector();
		local _lookingdown = false;
		if (_lookangle.z > 1.7) then _lookingdown = true end
		if (_lookingdown == true and ply:KeyDown(IN_DUCK)) then
			dmginfo:SetDamage(amount * ROLLFACTOR)
			ply:SendLua("ROLLING = true;ROLLSTART = CurTime();ROLLTIMER = CurTime() + 0.6;");
			ply:GetActiveWeapon().Weapon:SendWeaponAnim(ACT_VM_HOLSTER);
			ply:GetActiveWeapon().Weapon.Holstered = true;
			ply:SetNWBool("Rolling", true)
			timer.Simple(ply:GetActiveWeapon().Weapon.SafetyTime, function(ply)
				ply:DrawViewModel(false)
			end, ply);
			timer.Simple(0.6, function(ply)
				if (ply:Alive()) then // he very well could have died from falling damage
					ply:GetActiveWeapon().Weapon:SendWeaponAnim(ACT_VM_DRAW);
					ply:DrawViewModel(true)
					ply:GetActiveWeapon().Weapon.Holstered = false;
					ply:SetNWBool("Rolling", false)
				end
			end, ply);
		else
			dmginfo:SetDamage(amount * FALLFACTOR)
			local recoil = dmginfo:GetDamage()
			local _dir = math.Rand(-1,1)
			ply:ViewPunch(Angle(recoil, _dir * recoil * 0.8, _dir * recoil * 0.9))
		end
	end
end
hook.Add( "EntityTakeDamage", "ReduceFallDamage", ReduceFallDamage )
local function IncreaseSlashingDamage( ent, inflictor, attacker, amount, dmginfo )
	if (!ent:IsPlayer()) then return false end
	local ply = ent;
	
	/*if (dmginfo) then
	end*/
end
hook.Add( "EntityTakeDamage", "IncreaseSlashingDamage", IncreaseSlashingDamage)
local function PlayerPainSounds( ent, inflictor, attacker, amount, dmginfo)
	if (ent:IsPlayer()) then
		local num = math.ceil(dmginfo:GetDamage()/10)
		num = num + math.random(-1, 1)
		if (num > 10) then num = 10 end
		if (num < 1) then num = 1 end
		ent:EmitSound("/vo/npc/male01/pain0" .. num .. ".wav", 50 + (dmginfo:GetDamage() / 2), 100)
	end
end
//hook.Add("EntityTakeDamage", "PlayerPainSounds", PlayerPainSounds)
function PosNeg()
	if (math.random(2)==1) then return -1 else return 1 end
end
local function SlowPlayerAnimation(ply, anim)
	ply:SetPlaybackRate(1.55)
end
hook.Add("SetPlayerAnimation", "SlowPlayerAnimation", SlowPlayerAnimation)
function GM:KeyPress(ply, key)
	if (key == IN_USE) then
		ClimbCheck(ply)
	end
end
function ClimbCheck(ply)
	local tr = {}
	tr.a = false
	tr.b = false
	tr.c = false
	local basepos = ply:GetShootPos() - Vector(0, 0, 64)
	local pos = basepos
	local ang = ply:GetAimVector()
	ang.z=0
	pos = basepos + Vector(0, 0, 108)
	local trace = util.QuickTrace(pos, ang * 32, ply)
	tr.a = trace.HitWorld
	pos = basepos + Vector(0, 0, 32)
	local trace = util.QuickTrace(pos, ang * 32, ply)
	tr.b = trace.HitWorld
	pos = basepos - Vector(0, 0, 0)
	local trace = util.QuickTrace(pos, ang * 32, ply)
	tr.c = trace.HitWorld
	
	if (!tr.a and (tr.b or tr.c) and ply:KeyDown(IN_USE)) then
		ply:SetNWBool("Climbing", true)
	else
		ply:SetNWBool("Climbing", false)
	end
	//ply:PrintMessage(HUD_PRINTTALK, tostring(tr.a) .. "|" .. tostring(tr.b) .. "|" .. tostring(tr.c))
end
function Climb()
	for k, ply in pairs(player.GetAll()) do
		if (ply:GetNWBool("Climbing")) then
			local velo = ply:GetAimVector()
			velo.x = velo.x * 2
			velo.y = velo.y * 2
			velo.z = 2
			ply:SetVelocity(velo)
			//print(tostring(velo))
			ply:SetPos(ply:GetPos() + Vector(0, 0, 4))
			ClimbCheck(ply)
		end
	end 
end
hook.Add("Think", "Climb", Climb)
function GM:PlayerCanPickupWeapon(ply, wep)
	if (!ply:GetNWBool("OverridePickup")) then
		local r = false
		local o = false
		if (!ply:KeyDown(IN_USE)) then return false end
		if (wep:GetClass() == "weapon_pistol") then
			if (ply:HasWeapon("weapon_gpk_pistol")) then
				ply:GiveAmmo(18, "pistol")
				wep.Entity:Remove();
				//PickupViewPunch(ply)
			else
				local _override = ply:GetNWBool("OverridePickup");
				ply:SetNWBool("OverridePickup", true);
				ply:Give("weapon_gpk_pistol");
				ply:SelectWeapon("weapon_gpk_pistol")
				ply:SetNWBool("OverridePickup", _override);
				wep.Entity:Remove();
				//PickupViewPunch(ply)
			end
		elseif (wep:GetClass() == "weapon_smg1") then
			if (ply:HasWeapon("weapon_gpk_smg")) then
				ply:GiveAmmo(45, "smg1")
				wep.Entity:Remove();
				//PickupViewPunch(ply)
			else
				local _override = ply:GetNWBool("OverridePickup");
				ply:SetNWBool("OverridePickup", true);
				ply:Give("weapon_gpk_smg");
				ply:SelectWeapon("weapon_gpk_smg")
				ply:SetNWBool("OverridePickup", _override);
				wep.Entity:Remove();
				//PickupViewPunch(ply)
			end
		elseif (wep:GetClass() == "weapon_shotgun") then
			if (ply:HasWeapon("weapon_gpk_shotgun")) then
				ply:GiveAmmo(6, "buckshot")
				wep.Entity:Remove();
				//PickupViewPunch(ply)
			else
				local _override = ply:GetNWBool("OverridePickup");
				ply:SetNWBool("OverridePickup", true);
				ply:Give("weapon_gpk_shotgun");
				ply:SelectWeapon("weapon_gpk_shotgun")
				ply:SetNWBool("OverridePickup", _override);
				wep.Entity:Remove();
				//PickupViewPunch(ply)
			end
		elseif (wep:GetClass() == "weapon_crowbar") then
			if (ply:HasWeapon("weapon_gpk_crowbar")) then
				return false
			else
				local _override = ply:GetNWBool("OverridePickup");
				ply:SetNWBool("OverridePickup", true);
				ply:Give("weapon_gpk_crowbar");
				ply:SelectWeapon("weapon_gpk_crowbar")
				ply:SetNWBool("OverridePickup", _override);
				wep.Entity:Remove();
				//PickupViewPunch(ply)
			end
		elseif (wep:GetClass() == "weapon_gpk_pistol") then
			PickupViewPunch(ply)
			timer.Simple(0.05, function(ply)
				ply:SelectWeapon("weapon_gpk_pistol")
			end, ply)
			return true
		elseif (wep:GetClass() == "weapon_gpk_smg") then
			PickupViewPunch(ply)
			timer.Simple(0.05, function(ply)
				ply:SelectWeapon("weapon_gpk_smg")
			end, ply)
			return true
		elseif (wep:GetClass() == "weapon_gpk_shotgun") then
			PickupViewPunch(ply)
			timer.Simple(0.05, function(ply)
				ply:SelectWeapon("weapon_gpk_shotgun")
			end, ply)
			return true
		elseif (wep:GetClass() == "weapon_gpk_crowbar") then
			PickupViewPunch(ply)
			timer.Simple(0.05, function(ply)
				ply:SelectWeapon("weapon_gpk_crowbar")
			end, ply)
			return true
		/*elseif (wep:GetClass() == "weapon_slam") then
			PickupViewPunch(ply)
			return true
		elseif (wep:GetClass() == "weapon_stunstick") then
			PickupViewPunch(ply)
			return true
		elseif (wep:GetClass() == "weapon_physgun") then
			PickupViewPunch(ply)
			return true*/
		end
	end
	PickupViewPunch(ply)
	return ply:GetNWBool("OverridePickup");
end
function PickupViewPunch(ply)
	ply:ViewPunch(Angle(10, -10, 10))
end
function GM:SetupMove(ply, move)
	if (ply:OnGround()) then
		if (ply:KeyDown(IN_FORWARD) and (ply:KeyDown(IN_MOVELEFT) or ply:KeyDown(IN_MOVERIGHT))) then
			ply:SetNWInt("CurMaxSpeed", ply:GetNWInt("MaxSpeed") * 0.90)
		elseif (!ply:KeyDown(IN_FORWARD) and !ply:Crouching() and (ply:KeyDown(IN_MOVELEFT) or ply:KeyDown(IN_MOVERIGHT))) then
			ply:SetNWInt("CurMaxSpeed", ply:GetNWInt("MaxSpeed") * 0.25)
		else
			ply:SetNWInt("CurMaxSpeed", ply:GetNWInt("MaxSpeed"))
		end
		if (ply:KeyDown(IN_BACK)) then
			ply:SetNWInt("CurMaxSpeed", ply:GetNWInt("MaxSpeed") * 0.5)
		end
		if (ply:KeyDown(IN_FORWARD) or ply:KeyDown(IN_MOVELEFT) or ply:KeyDown(IN_MOVERIGHT) or ply:KeyDown(IN_BACK)) then
			if (ply:GetNWInt("Speed") < ply:GetNWInt("CurMaxSpeed") * 0.25) then
				ply:SetNWInt("Speed", ply:GetNWInt("CurMaxSpeed") + ply:GetNWInt("Acceleration") * 4)
			else
				ply:SetNWInt("Speed", ply:GetNWInt("Speed") + ply:GetNWInt("Acceleration"))
			end
		end
		if (ply:KeyDown(IN_DUCK)) then
			ply:SetNWInt("Speed", ply:GetNWInt("Speed") - ply:GetNWInt("SlideDecrease"))
		end
		if (!ply:KeyDown(IN_FORWARD) and !ply:KeyDown(IN_MOVELEFT) and !ply:KeyDown(IN_MOVERIGHT) and !ply:KeyDown(IN_BACK)) then
			ply:SetNWInt("Speed", ply:GetNWInt("Speed") / 2);
		end
		if (ply:GetNWInt("Speed") < ply:GetNWInt("MinSpeed")) then ply:SetNWInt("Speed", ply:GetNWInt("MinSpeed")) end
		if (ply:GetNWInt("Speed") > ply:GetNWInt("CurMaxSpeed")) then ply:SetNWInt("Speed", ply:GetNWInt("CurMaxSpeed")) end
		GAMEMODE:SetPlayerSpeed(ply, ply:GetNWInt("Speed"), ply:GetNWInt("Speed"))
	end
	//ply:PrintMessage(HUD_PRINTTALK, ply:GetVelocity():Length().." ("..ply:GetNWInt("Speed").."/"..ply:GetNWInt("CurMaxSpeed")..")")
end
function GM:FinishMove(ply, move)
end
function util.QuickTrace( origin, dir, filter )

local trace = {}

trace.start = origin
trace.endpos = origin + dir
trace.filter = filter

return util.TraceLine( trace )

end 