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
		/*self.mx,self.my = MousePos(self)
		if self.mx>0 and self.my>0 then
			draw.SimpleText("lol", "Fixedsys12", self.mx, selfmy, Color(255, 255, 255, 255), 1, 1)
			DrawText( math.Round(self.mx).." "..math.Round(self.my), self.mx, self.my )
		end*/
	cam.End3D2D()
end
local function DrawText( txt, x, y, col )
	if !txt then return end
	col = col or {r=255,g=255,b=255,a=255}
	surface.SetTextPos( x+2, y+2 )
	surface.SetTextColor( 0, 0, 0, 255 )
	surface.DrawText( txt )
	surface.SetTextPos( x, y )
	surface.SetTextColor( col.r, col.g, col.b, col.a )
	surface.DrawText( txt )
end
function RayQuadIntersect(vOrigin, vDirection, vPlane, vX, vY)
	local vp = vDirection:Cross(vY)

	local d = vX:DotProduct(vp)
	if (d <= 0.0) then return end

	local vt = vOrigin - vPlane
	local u = vt:DotProduct(vp)
	if (u < 0.0 or u > d) then return end

	local v = vDirection:DotProduct(vt:Cross(vX))
	if (v < 0.0 or v > d) then return end

	return Vector(u / d, v / d, 0)
end
function MousePos(self)
	local mx, my
	local pl = LocalPlayer()
	local tr = util.TraceLine({start=pl:EyePos(),endpos=pl:EyePos()+pl:GetAimVector()*200,mask=MASK_SOLID_BRUSHONLY})
	print(tr.Entity:GetClass())
	if !tr.Hit then return 0, 0 end
	local pos = tr.HitPos+tr.HitNormal*2
	local sp = self:GetPos()+Vector( -2, 64, 32 )
	if pos.x != sp.x+.09375 then return 0, 0 end
	mx, my = math.Clamp( sp.y-pos.y,0,32 )*10,math.Clamp( sp.z-pos.z,0,24 )*10
	if mx == 0 || my == 0 || mx == 320 || my == 240 then return 0, 0 end
	return mx, my
end