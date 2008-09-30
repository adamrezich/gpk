 include('shared.lua')
function ENT:Initialize()
//	self.Entity:SetAngles(Angle(0,0,90))
end
function ENT:Draw()
	cam.Start3D2D(self.Entity:GetPos() + self.Entity:GetForward() * 7, /*self.Entity:GetAngles()*/ Angle(180, 90, 270), 1.6)
		local x = -40
		local y = -120
		/*surface.SetDrawColor(0, 0, 255, 255)
		surface.DrawRect(x, y, 80, 240)*/
		surface.SetTexture(surface.GetTextureID("gpk/ad_tall_0")) 
		surface.SetDrawColor(255,255,255,255)
		//cam.IgnoreZ(true)
		cam.IgnoreZ(false)
		surface.DrawTexturedRect(x,y,256,256)
		draw.SimpleText("160x480", "Fixedsys12", x+40, y+120, Color(255, 255, 255, 255), 1, 1)
	cam.End3D2D()
end