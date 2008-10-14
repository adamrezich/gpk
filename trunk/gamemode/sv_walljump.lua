function WallJump(ply, key)	
	if !ply:KeyDown(IN_JUMP) then return end
	if (CurTime() < ply:GetNWInt("WalljumpTimer")) then return end
	ReboundPower = 300
	ReboundPowerUp = 180
	local tr = 	util.TraceLine(util.GetPlayerTrace(ply, Vector(0, 0, -1)))
	if !tr.Hit then return end
	local HitDistance = tr.HitPos:Distance(tr.StartPos)
	if (HitDistance > 8) then
		local vForward = ply:GetForward():GetNormalized()
		local vRight = ply:GetRight():GetNormalized()
		local vVelocity = Vector(0,0,0)
		local pVelocity = ply:GetVelocity()
		//if (pVelocity.z < 0) then return end
		if ply:KeyDown(IN_MOVERIGHT) then
			local tracedata = {}
			tracedata.start = ply:GetPos()
			tracedata.endpos = ply:GetPos()+(vRight*-24)
			tracedata.filter = ply
			local tr = util.TraceLine(tracedata)
			if (tr.Fraction < 1.0) then
				vVelocity = pVelocity + (vRight * ReboundPower)
				vVelocity.z = pVelocity.z + ReboundPowerUp
				ply:SetLocalVelocity(vVelocity)
				WallJumpSound(ply)
				ply:SetNWInt("WalljumpTimer", CurTime() + WALLJUMPTIME + ply:GetNWInt("WalljumpCombo") * WALLJUMPDECAY)
			end
		end
		if ply:KeyDown(IN_MOVELEFT) then
			local tracedata = {}
			tracedata.start = ply:GetPos()
			tracedata.endpos = ply:GetPos()+(vRight*24)
			tracedata.filter = ply
			local tr = util.TraceLine(tracedata)
			if (tr.Fraction < 1.0) then
				vVelocity = pVelocity + (vRight * -ReboundPower)
				vVelocity.z = pVelocity.z + ReboundPowerUp
				ply:SetLocalVelocity(vVelocity)
				WallJumpSound(ply)
				ply:SetNWInt("WalljumpTimer", CurTime() + WALLJUMPTIME + ply:GetNWInt("WalljumpCombo") * WALLJUMPDECAY)
			end
		end
		if ply:KeyDown(IN_BACK) then
			local tracedata = {}
			tracedata.start = ply:GetPos()
			tracedata.endpos = ply:GetPos()+(vForward*24)
			tracedata.filter = ply
			local tr = util.TraceLine(tracedata)
			if (tr.Fraction < 1.0) then
				vVelocity = pVelocity + (vForward * -ReboundPower)
				vVelocity.z = pVelocity.z + ReboundPowerUp
				ply:SetLocalVelocity(vVelocity)
				WallJumpSound(ply)
				ply:SetNWInt("WalljumpTimer", CurTime() + WALLJUMPTIME + ply:GetNWInt("WalljumpCombo") * WALLJUMPDECAY)
			end
		end
		if ply:KeyDown(IN_FORWARD) then
			local tracedata = {}
			tracedata.start = ply:GetPos()
			tracedata.endpos = ply:GetPos()+(vForward*-24)
			tracedata.filter = ply
			local tr = util.TraceLine(tracedata)
			if (tr.Fraction < 1.0) then
				vVelocity = pVelocity + (vForward * ReboundPower)
				vVelocity.z = pVelocity.z + ReboundPowerUp
				ply:SetLocalVelocity(vVelocity)
				WallJumpSound(ply)
				ply:SetNWInt("WalljumpTimer", CurTime() + WALLJUMPTIME + ply:GetNWInt("WalljumpCombo") * WALLJUMPDECAY)
			end
		end
	end
end
hook.Add("KeyPress", "WallJump", WallJump)
function WallSlide(ply, key)
	for k, ply in pairs(player.GetAll()) do
		local tr = 	util.TraceLine(util.GetPlayerTrace(ply, Vector(0, 0, -1)))
		local HitDistance = tr.HitPos:Distance(tr.StartPos)
		if (HitDistance > 8) then
			local _lookangle = ply:GetUp() - ply:GetAimVector();
			local vForward = ply:GetForward():GetNormalized()
			local vRight = ply:GetRight():GetNormalized()
			//local vVelocity = Vector(0,0,0)
			local vVelocity = ply:GetVelocity()
			if (ply:KeyDown(IN_FORWARD) and vVelocity.z < 0 /*and _lookangle.z < 1.5*/) then
				local tracedata = {}
				tracedata.start = ply:GetPos()
				tracedata.endpos = ply:GetPos()+(vForward*24)
				tracedata.filter = ply
				local tr = util.TraceLine(tracedata)
				if (tr.Fraction < 1.0) then
					if (!ply:GetNWBool("Climbing")) then
						SlideSound[ply:UniqueID()]:PlayEx(1,100)
						ply:SetNWBool("Wallsliding", true)
					end
					vVelocity.z = vVelocity.z * WALLSLIDEFACTOR
					ply:SetLocalVelocity(vVelocity)
				else
					SlideSound[ply:UniqueID()]:Stop()
					ply:SetNWBool("Wallsliding", false)
				end
			else
				SlideSound[ply:UniqueID()]:Stop()
				ply:SetNWBool("Wallsliding", false)
			end
		else
			SlideSound[ply:UniqueID()]:Stop()
			ply:SetNWBool("Wallsliding", false)
		end
	end
end
hook.Add("Think", "WallSlide", WallSlide)

function WallJumpSound(ply)
	ply:EmitSound("/physics/concrete/rock_impact_hard" .. math.random(1, 6) .. ".wav", math.Rand(90, 110), math.Rand(60, 80))
	WallJumpCombo(ply)
end
function WallJumpCombo(ply)
	ply:SetNWInt("WalljumpCombo", ply:GetNWInt("WalljumpCombo") + 1)
	//if (ply:GetNWInt("WalljumpCombo") > 1) then ply:PrintMessage(HUD_PRINTCENTER, "WALLJUMP x" .. ply:GetNWInt("WalljumpCombo")) end
end