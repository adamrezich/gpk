ENT.Type = "anim"
ENT.Base = "base_anim";
ENT.Text = "D:    why won't these work    T_T"
function ENT:Think()
	self.Entity:DrawShadow(false)
end
function ENT:Use()
end