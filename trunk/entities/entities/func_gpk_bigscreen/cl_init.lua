include('shared.lua')
function ENT:Initialize()
	local h = 384
	local l = 512
	local w = 8
	local _min = Vector(0-(w/2),0-(l/2),0-(h/2))
	local _max = Vector(w/2,l/2,h/2) 
	self.Entity:SetRenderBounds(_min,_max)
end
function ENT:Draw()
	cam.Start3D2D(self.Entity:GetPos() + self.Entity:GetForward() * 7, /*self.Entity:GetAngles()*/ Angle(180, 90, 270), 1.6)
		local x = -160
		local y = -120
		surface.SetDrawColor(0, 0, 255, 255)
		surface.DrawRect(x, y, 320, 240)
		draw.SimpleText("- Welcome to the GPK Lobby -", "Fixedsys12", x+160, y+120, Color(255, 255, 255, 255), 1, 1)
	cam.End3D2D()
end