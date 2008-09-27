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

/*function GM:OnNPCKilled(victim, killer, weapon)
end*/
function GM:PlayerInitialSpawn(ply)
	ply:PrintMessage(HUD_PRINTTALK, "Welcome to the GPK Test Server!\nGPK is a parkour gamemode for Garry's Mod, still under extreme development.\nDirect any questions you have to Unniloct, or takua108 on Facepunch.\nEnjoy! (r"..REVISION..")")
	ply:SetNWInt(	"Speed",			0)
	ply:SetNWInt(	"MinSpeed",			100)
	ply:SetNWInt(	"MaxSpeed",			400)
	ply:SetNWInt(	"CurMaxSpeed",		400)
	ply:SetNWInt(	"Acceleration",		1.5)
	ply:SetNWInt(	"SlideDecrease",	0.2)
	ply:SetNWBool(	"Climbing",			false)
	/*
	ply:SetNWBool(	"Rolling",			false)
	ply:SetNWInt(	"RollFactor",		0.5)
	ply:SetNWInt(	"RollTimer",		CurTime())
	ply:SetNWInt(	"RollStart",		CurTime())
	*/
	ply:SetNWBool(	"OverridePickup",	false)
end
function GM:PlayerLoadout(ply)
	ply:SetNWBool("OverridePickup", true)
	ply:Give("weapon_gpk_fists")
	ply:Give("weapon_gpk_pistol")
	ply:SetNWBool("OverridePickup", false)
	ply:SetArmor(100)
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
			timer.Simple(ply:GetActiveWeapon().Weapon.SafetyTime, function(ply)
				ply:DrawViewModel(false)
			end, ply);
			timer.Simple(0.6, function(ply)
				if (ply:Alive()) then // he very well could have died from falling damage
					ply:GetActiveWeapon().Weapon:SendWeaponAnim(ACT_VM_DRAW);
					ply:DrawViewModel(true)
					ply:GetActiveWeapon().Weapon.Holstered = false;
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
		if (wep:GetClass() == "weapon_pistol") then
			if (ply:HasWeapon("weapon_gpk_pistol")) then
				ply:GiveAmmo(18, "pistol")
				wep.Entity:Remove();
			else
				local _override = ply:GetNWBool("OverridePickup");
				ply:SetNWBool("OverridePickup", true);
				ply:Give("weapon_gpk_pistol");
				ply:SetNWBool("OverridePickup", _override);
				wep.Entity:Remove();
			end
		elseif (wep:GetClass() == "weapon_gpk_pistol") then
			return true
		elseif (wep:GetClass() == "weapon_physgun") then
			return true
		end
	end
	return ply:GetNWBool("OverridePickup");
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