include('shared.lua')
local TEXT = {}
TEXT[0]="                               Windows                             "
TEXT[1]=""
TEXT[2]="A fatal exception 0E has occurred at 0028:C00068F8 in VxD VMM(01) +"
TEXT[3]="000059F8. The current application will be terminated.              "
TEXT[4]=""
TEXT[5]="* Press any key to terminate the application.                      "
TEXT[6]="* Press CTRL+ALT+DEL to restart your computer. You will            "
TEXT[7]="  lose any unsaved information in all applications.                "
TEXT[8]=""
TEXT[9]="                     Press any key to continute                    "

function ENT:Initialize()
	local h = 384
	local l = 512
	local w = 8
	local _min = Vector(0-(w/2),0-(l/2),0-(h/2))
	local _max = Vector(w/2,l/2,h/2) 
	self.Entity:SetRenderBounds(_min,_max)
end
function ENT:Draw()
	cam.Start3D2D(self.Entity:GetPos() + self.Entity:GetForward() * 7, /*self.Entity:GetAngles()*/ Angle(180, 90, 270), 0.8)
		local x = -320
		local y = -240
		surface.SetDrawColor(2, 2, 172, 255)
		surface.DrawRect(x, y, 640, 480)
		for k, txt in pairs(TEXT) do
			draw.SimpleText(txt, "Fixedsys12", x+320, y+240-(6*#TEXT)+(12*k), Color(255, 255, 255, 255), 1, 1)
		end
	cam.End3D2D()
end