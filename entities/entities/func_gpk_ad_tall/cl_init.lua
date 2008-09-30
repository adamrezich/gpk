 include('shared.lua')
function ENT:Initialize()
//	self.Entity:SetAngles(Angle(0,0,90))
end
function ENT:Draw()
	cam.Start3D2D(self.Entity:GetPos() + self.Entity:GetForward() * 7, /*self.Entity:GetAngles()*/ Angle(180, 90, 270), 1.6)
		local x = -40
		local y = -120
		surface.SetDrawColor(0, 0, 255, 255)
		surface.DrawRect(x, y, 80, 240)
		draw.SimpleText("80x240", "Fixedsys12", x+40, y+120, Color(255, 255, 255, 255), 1, 1)
	cam.End3D2D()
end