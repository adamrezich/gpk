GM.Name 		= "GPK"
GM.Author 		= "Adam \"takua108/Unniloct\" Rezich"
GM.Email 		= "adam@rezich.com"
GM.Website 		= "adam.rezich.com"
GM.TeamBased 	= false

ROLLING = false;
ROLLFACTOR = 0.50;
ROLLSTART = CurTime();
ROLLTIMER = CurTime();

OVERRIDEPICKUP = false;

function GM:Initialize()
	self.BaseClass.Initialize( self )
end

function GM:CalcView(ply, origin, angles, fov)
	if (!ROLLING) then
		return self.BaseClass:CalcView(ply, origin, angles, fov)
	else
		if (CurTime() > ROLLTIMER) then ROLLING = false end
		angles = angles - Angle(360 + (ROLLTIMER - CurTime()) * 600, 0 , 0)
		ply.Entity:SetAngles(angles)
		local view = {}
		view.angles = angles;
		view.fov = fov;
		view.origin = origin;
		return view;
	end
end