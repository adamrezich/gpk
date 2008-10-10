include(		"shared.lua")
include(		"shd_ragspec.lua")
include(		"shd_viewpunch.lua")

surface.CreateFont("Fixedsys", 12, 400, false, false, "Fixedsys12")
surface.CreateFont("Tahoma", 14, 400, false, false, "Tahoma14")

ROLLING = false
ROLLSTART = CurTime()
ROLLTIMER = CurTime()

local WalkTimer = 0
local VelSmooth = 0
local LastStrafeRoll = 0

function GM:CalcView(ply, origin, angle, fov)
	if ply:GetNetworkedInt("thirdperson") == 1 then
	return self.BaseClass:CalcView(ply, origin, angle, fov)
	end
	if (!ROLLING) then
		local ragdoll = ply:GetRagdollEntity()
		local eyes = nil
		local pos = origin
		if (!ragdoll or ragdoll == NULL or !ragdoll:IsValid() /*or ply:Alive()*/) then
			local vel = ply:GetVelocity()
			local ang = ply:EyeAngles()
			
			VelSmooth = math.Clamp( VelSmooth * 0.9 + vel:Length() * 0.1, 0, 700 )
			
			WalkTimer = WalkTimer + VelSmooth * FrameTime() * 0.05
			// Roll on strafe (smoothed)
			LastStrafeRoll = (LastStrafeRoll * 3) + (ang:Right():DotProduct( vel ) * 0.0001 * VelSmooth * 0.3)
			LastStrafeRoll = LastStrafeRoll * 0.25
			angle.roll = angle.roll + LastStrafeRoll
			
			// Roll on steps
			if ( ply:GetGroundEntity() != NULL ) then
				angle.roll = angle.roll + math.sin( WalkTimer ) * VelSmooth * 0.000002 * VelSmooth
				angle.pitch = angle.pitch + math.cos( WalkTimer * 0.5 ) * VelSmooth * 0.000002 * VelSmooth
				angle.yaw = angle.yaw + math.cos( WalkTimer ) * VelSmooth * 0.000002 * VelSmooth
			end
			//return self.BaseClass:CalcView(ply, origin, angle, fov)
		else
			local eyes = ragdoll:GetAttachment(ragdoll:LookupAttachment("eyes"))
			angle = eyes.Ang
			pos = eyes.Pos
		end
		
		local view = {
			origin = pos,
			angles = angle,
			fov = 90, 
		}
		return view
	else
		if (CurTime() > ROLLTIMER) then ROLLING = false end
		angle = angle - Angle(360 + (ROLLTIMER - CurTime()) * 600, 0 , 0)
		ply.Entity:SetAngles(angle)
		local view = {}
		view.angles = angle
		view.fov = fov
		view.origin = origin
		return view
	end
end