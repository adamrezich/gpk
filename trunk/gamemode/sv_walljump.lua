function WallJump(ply, key)	
	if !ply:KeyDown(IN_JUMP) then return end
	ReboundPower = 300 //it was 275 in the original.
	local tr = 	util.TraceLine(util.GetPlayerTrace(ply, Vector(0, 0, -1)))
	if !tr.Hit then return end
	local HitDistance = tr.HitPos:Distance(tr.StartPos)
	if (HitDistance > 8) then
		local vForward = ply:GetForward():GetNormalized()
		local vRight = ply:GetRight():GetNormalized()
		local vVelocity = Vector(0,0,0)
		local pVelocity = ply:GetVelocity():Length()
		if ply:KeyDown(IN_MOVERIGHT) then
			local tracedata = {}
			tracedata.start = ply:GetPos()
			tracedata.endpos = ply:GetPos()+(vRight*-24)
			tracedata.filter = ply
			local tr = util.TraceLine(tracedata)
			if (tr.Fraction < 1.0) then
				vVelocity = vVelocity + (vRight * ReboundPower)
				vVelocity.z = vVelocity.z + ReboundPower
				ply:SetLocalVelocity(vVelocity)
			end
		end
		if ply:KeyDown(IN_MOVELEFT) then
			local tracedata = {}
			tracedata.start = ply:GetPos()
			tracedata.endpos = ply:GetPos()+(vRight*24)
			tracedata.filter = ply
			local tr = util.TraceLine(tracedata)
			if (tr.Fraction < 1.0) then
				vVelocity = vVelocity + (vRight * -ReboundPower)
				vVelocity.z = vVelocity.z + ReboundPower
				ply:SetLocalVelocity(vVelocity)
			end
		end
		if ply:KeyDown(IN_BACK) then
			local tracedata = {}
			tracedata.start = ply:GetPos()
			tracedata.endpos = ply:GetPos()+(vForward*24)
			tracedata.filter = ply
			local tr = util.TraceLine(tracedata)
			if (tr.Fraction < 1.0) then
				vVelocity = vVelocity + (vForward * -ReboundPower)
				vVelocity.z = vVelocity.z + ReboundPower
				ply:SetLocalVelocity(vVelocity)
			end
		end
		if ply:KeyDown(IN_FORWARD) then
			local tracedata = {}
			tracedata.start = ply:GetPos()
			tracedata.endpos = ply:GetPos()+(vForward*-24)
			tracedata.filter = ply
			local tr = util.TraceLine(tracedata)
			if (tr.Fraction < 1.0) then
				vVelocity = vVelocity + (vForward * ReboundPower)
				vVelocity.z = vVelocity.z + ReboundPower
				ply:SetLocalVelocity(vVelocity)
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
					vVelocity.z = vVelocity.z * WALLSLIDEFACTOR
					ply:SetLocalVelocity(vVelocity)
				end
			end
		end
	end
end
hook.Add("Think", "WallSlide", WallSlide)