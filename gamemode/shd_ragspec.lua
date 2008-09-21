// Credits to Jinto
if( CLIENT ) then
	local function CalcView( pl, origin, angles, fov )
		local ragdoll = pl:GetRagdollEntity();
		if (!ragdoll or ragdoll == NULL or !ragdoll:IsValid()) then return end
		local eyes = ragdoll:GetAttachment(ragdoll:LookupAttachment("eyes"));
		local view = {
			origin = eyes.Pos,
			angles = eyes.Ang,
			fov = 90, 
		};
		return view;
	end
	hook.Add("CalcView", "DeathView", CalcView);
end 
