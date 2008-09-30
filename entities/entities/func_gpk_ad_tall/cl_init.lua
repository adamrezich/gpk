include('shared.lua')
TEXT = {}
TEXT[0]="Your advertisement here,"
TEXT[1]="just $1.00/month!"
TEXT[2]="Hurry, prices subject to"
TEXT[3]="change based on demand!"

function ENT:Initialize()
	local h = 384
	local l = 128
	local w = 8
	local _min = Vector(0-(w/2),0-(l/2),0-(h/2))
	local _max = Vector(w/2,l/2,h/2) 
	self.Entity:SetCollisionBounds(Vector(38400,38400,38400), Vector(-38400,-38400,38400))
end
function ENT:Draw()
	cam.Start3D2D(self.Entity:GetPos() + self.Entity:GetForward() * 7, /*self.Entity:GetAngles()*/ Angle(180, 90, 270), 0.8)
		local x = -80
		local y = -240
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(x, y, 160, 480)
		/*surface.SetTexture(surface.GetTextureID("gpk/ad_tall_0")) 
		surface.SetDrawColor(255,255,255,255)
		cam.IgnoreZ(false)
		surface.DrawTexturedRect(x,y,512,512)*/
		for k, txt in pairs(TEXT) do
			draw.SimpleText(txt, "Tahoma14", x+80, y+240-(6*#TEXT)+(12*k), Color(255, 255, 255, 255), 1, 1)
		end
	cam.End3D2D()
end