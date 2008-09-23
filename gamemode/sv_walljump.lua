
function WallJump( ply, key )	
	if !ply:KeyDown( IN_JUMP ) then return end
	
	--variables
	ReboundPower = 400 --it was 275 in the original.
	JumpHeight = 5 --how far off the ground you have to be for it to work.
	
	
	-- Are we in the air?
	local tr = 	util.TraceLine( util.GetPlayerTrace(ply, Vector( 0, 0, -1 )) )
	if !tr.Hit then return end
	
	local HitDistance = tr.HitPos:Distance(tr.StartPos)
	if(  HitDistance > JumpHeight ) then
		local vForward = ply:GetForward():GetNormalized()
		local vRight = ply:GetRight():GetNormalized()
		local vVelocity = Vector( 0,0,0 )

		-- Left Jump
		if ply:KeyDown( IN_MOVERIGHT ) then
			-- Trace left
			local tracedata = {}
			tracedata.start = ply:GetPos()
			tracedata.endpos = ply:GetPos()+(vRight*-24)
			tracedata.filter = ply
			local tr = util.TraceLine(tracedata) 

			-- Are we near a wall?
			if( tr.Fraction < 1.0 ) then
				vVelocity = vVelocity + (vRight * ReboundPower);
				vVelocity.z = vVelocity.z + ReboundPower;
				ply:SetLocalVelocity( vVelocity );
			end
		end
                   
		-- Right Jump
		if ply:KeyDown( IN_MOVELEFT ) then
			-- Trace left
			local tracedata = {}
			tracedata.start = ply:GetPos()
			tracedata.endpos = ply:GetPos()+(vRight*24)
			tracedata.filter = ply
			local tr = util.TraceLine(tracedata) 


			-- Are we near a wall?
			if( tr.Fraction < 1.0 ) then
				vVelocity = vVelocity + (vRight * -ReboundPower);
				vVelocity.z = vVelocity.z + ReboundPower;
				ply:SetLocalVelocity( vVelocity );
			end
		end
		
		--Forward jump
		if ply:KeyDown( IN_BACK ) then
			-- Trace forward
			local tracedata = {}
			tracedata.start = ply:GetPos()
			tracedata.endpos = ply:GetPos()+(vForward*24)
			tracedata.filter = ply
			local tr = util.TraceLine(tracedata) 


			-- Are we near a wall?
			if( tr.Fraction < 1.0 ) then
				vVelocity = vVelocity + (vForward * -ReboundPower);
				vVelocity.z = vVelocity.z + ReboundPower;
				ply:SetLocalVelocity( vVelocity );
			end
		end
		
		--Backwards jump
		if ply:KeyDown( IN_FORWARD ) then
			-- Trace backward
			local tracedata = {}
			tracedata.start = ply:GetPos()
			tracedata.endpos = ply:GetPos()+(vForward*-24)
			tracedata.filter = ply
			local tr = util.TraceLine(tracedata) 


			-- Are we near a wall?
			if( tr.Fraction < 1.0 ) then
				vVelocity = vVelocity + (vForward * ReboundPower);
				vVelocity.z = vVelocity.z + ReboundPower;
				ply:SetLocalVelocity( vVelocity );
			end
		end
	end
end
hook.Add("KeyPress", "WallJump", WallJump); 