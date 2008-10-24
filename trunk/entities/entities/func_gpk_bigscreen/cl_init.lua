include('shared.lua')
/*
  __=__________  _        __________________ ____  __.      _  __________=__    
()_____[____])@//        /  _____/\______   \    |/ _|       \\@([____]_____()  
       [____]-|/\_      /   \  ___ |     ___/      <        _/\|-[____]         
        ( ))\     \     \    \_\  \|    |   |    |  \      /     /(( )          
        '----'|____\     \______  /|____|   |____|__ \    /____|'----'          
              \____/            \/                  \/    \____/                          
*/
local TEXT = {}
TEXT[ 0] = "''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''"
TEXT[ 1] = "'''__=__________''_'''''''__________________'____''__.''''''_''__________=__''''"
TEXT[ 2] = "'()_____[____])@//'''''''/  _____/\\______   \\    |/ _|'''''''\\\\@([____]_____()''"
TEXT[ 3] = "''''''''[____]-|/\\_'''''/   \\''___'|     ___/      <''''''''_/\\|-[____]'''''''''"
TEXT[ 4] = "'''''''''( ))\\     \\''''\\    \\_\\  \\|    |...|    |  \\''''''/     /(( )''''''''''"
TEXT[ 5] = "''''''''''----'|____\\''''\\______  /|____|'''|____|__ \\''''/____|'----'''''''''''"
TEXT[ 6] = "'''''''''''''''\\____/'''''''''''\\/''''''''''''''''''\\/''''\\____/''''''''''''''''"
TEXT[ 7] = "''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''"
TEXT[ 8] = "''''+----------------------------------------------------------------------+''''"
TEXT[ 9] = "''''| : WALLJUMPING :::::::::::::::::::::::::::::::::::::::::::::::::::::: |''''"
TEXT[10] = "''''|   Run into a wall and tap JUMP. Once midair, tap JUMP again while    |''''"
TEXT[11] = "''''| holding the direction opposite the wall.                             |''''"
TEXT[12] = "''''|                                                                      |''''"
TEXT[13] = "''''| : CLIMBING ::::::::::::::::::::::::::::::::::::::::::::::::::::::::: |''''"
TEXT[14] = "''''|   Press and hold USE when near a suitable ledge (like the boxes in   |''''"
TEXT[15] = "''''| in to the right of this sign). If the object is too high (such as    |''''"
TEXT[16] = "''''| the first box in said next room), you may need to JUMP and then hold |''''"
TEXT[17] = "''''| USE in midair. If you're having problems, try tapping JUMP faster,   |''''"
TEXT[18] = "''''| and not holding onto it for as long.                                 |''''"
TEXT[19] = "''''|                                                                      |''''"
TEXT[20] = "''''| : ROLLING :::::::::::::::::::::::::::::::::::::::::::::::::::::::::: |''''"
TEXT[21] = "''''|   To roll to break your fall (or at least reduce the damage), hold   |''''"
TEXT[22] = "''''| DUCK while looking down. Note that this will only work at the        |''''"
TEXT[23] = "''''| moment if your fall is big enough to cause damage.                   |''''"
TEXT[24] = "''''|                                                                      |''''"
TEXT[25] = "''''| : WALLSLIDING :::::::::::::::::::::::::::::::::::::::::::::::::::::: |''''"
TEXT[26] = "''''|   To slide down a wall, reducing your downward velocity, simply look |''''"
TEXT[27] = "''''| at the wall and press FORWARD. You will begin to gradually slow      |''''"
TEXT[28] = "''''| down, and will hopefully take less falling damage because of it.     |''''"
TEXT[29] = "''''|                                                                      |''''"
TEXT[30] = "''''| : WALLRUNNING :::::::::::::::::::::::::::::::::::::::::::::::::::::: |''''"
TEXT[31] = "''''|   Coming soon!                                                       |''''"
TEXT[32] = "''''|                                                                      |''''"
TEXT[33] = "''''| : PROTIPS :::::::::::::::::::::::::::::::::::::::::::::::::::::::::: |''''"
TEXT[34] = "''''|   * Press USE while walking over a weapon to pick it up.             |''''"
TEXT[35] = "''''|   * Only crowbars, pistols, SMGs, and shotguns are supported.        |''''"
TEXT[36] = "''''|   * Bind a key to 'DropWeapon' to drop the currently-held weapon.    |''''"
TEXT[37] = "''''|      * Soon, more weapons = more weight = slower movement speed.     |''''"
TEXT[38] = "''''+------+--------------------------------------------------------+------+''''"
TEXT[39] = "''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''"

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
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(x, y, 640, 480)
		for k, txt in pairs(TEXT) do
			draw.SimpleText(txt, "Fixedsys12", x+320, y+240-(6*#TEXT)+(12*k), Color(255, 255, 255, 255), 1, 1)
		end
	cam.End3D2D()
end