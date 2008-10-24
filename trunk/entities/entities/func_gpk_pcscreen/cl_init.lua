include('shared.lua')
function ENT:Initialize()
	local h = 32
	local l = 24 // TODO: FIX!!
	local w = 8
	local _min = Vector(0-(w/2),0-(l/2),0-(h/2))
	local _max = Vector(w/2,l/2,h/2) 
	self.Entity:SetRenderBounds(_min,_max)
	self.Entity:SetCollisionBounds(_min,_max)
end
function ENT:Draw()
	cam.Start3D2D(self.Entity:GetPos() - self.Entity:GetForward() * 0.5, /*self.Entity:GetAngles()*/ Angle(180, 270, 270), 0.1)
		local x = -160
		local y = -120
		surface.SetDrawColor(0, 0, 255, 255)
		surface.DrawRect(x, y, 320, 240)
		draw.SimpleText(self.Text, "Fixedsys12", x+160, y+120, Color(255, 255, 255, 255), 1, 1)
	cam.End3D2D()
end