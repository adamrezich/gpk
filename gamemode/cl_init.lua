include(		"shared.lua")
include(		"shd_ragspec.lua")
include(		"shd_viewpunch.lua")

surface.CreateFont("Fixedsys", 12, 400, false, false, "Fixedsys12")

ROLLING = false
ROLLSTART = CurTime()
ROLLTIMER = CurTime()

function GM:CalcView(ply, origin, angles, fov)
	if (!ROLLING) then
		return self.BaseClass:CalcView(ply, origin, angles, fov)
	else
		if (CurTime() > ROLLTIMER) then ROLLING = false end
		angles = angles - Angle(360 + (ROLLTIMER - CurTime()) * 600, 0 , 0)
		ply.Entity:SetAngles(angles)
		local view = {}
		view.angles = angles
		view.fov = fov
		view.origin = origin
		return view
	end
end
// TODO: COMBINE!
local function CalcView(pl, origin, angles, fov)
	local ragdoll = pl:GetRagdollEntity()
	if (!ragdoll or ragdoll == NULL or !ragdoll:IsValid()) then return end
	local eyes = ragdoll:GetAttachment(ragdoll:LookupAttachment("eyes"))
	local view = {
		origin = eyes.Pos,
		angles = eyes.Ang,
		fov = 90, 
	}
	return view
end
hook.Add("CalcView", "DeathView", CalcView)