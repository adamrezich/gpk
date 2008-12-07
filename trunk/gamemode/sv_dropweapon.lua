function DropCurrentWeapon(ply)
	if (ply:GetActiveWeapon():GetClass() != "weapon_gpk_fists") then
		ply:DropWeapon(ply:GetActiveWeapon())
	end
end
concommand.Add("DropWeapon", DropCurrentWeapon)
 
function AutoBindOnSpawn(ply)
	ply.AllowWeaponPickupFix = 1
	//ply:ConCommand("bind g DropWeapon\n")
end
 
hook.Add("PlayerInitialSpawn", "AutobindDropWeapon", AutoBindOnSpawn)
