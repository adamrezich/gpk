local Player = FindMetaTable("Player")
 
local PUNCH_DAMPING = 9
local PUNCH_SPRING_CONSTANT = 65
function Player:DecayPunchAngle()
  if CLIENT then
    self.punchAngle = self:GetNetworkedVector("punchAngle")
    self.punchAngleVelocity = self:GetNetworkedVector("punchAngleVelocity")
  end
  if not self.punchAngle or not self.punchAngleVelocity then
    return
  end
  if self.punchAngle:Length() > 0.001 or self.punchAngleVelocity:Length() > 0.001 then
    self.punchAngle = self.punchAngle + (self.punchAngleVelocity * FrameTime())
    self.punchAngleVelocity = self.punchAngleVelocity * math.max(1 - (PUNCH_DAMPING * FrameTime()), 0)
    self.punchAngleVelocity = self.punchAngleVelocity - (self.punchAngle * math.Clamp(PUNCH_SPRING_CONSTANT * FrameTime(), 0, 2))
    self.punchAngle.x = math.Clamp(self.punchAngle.x, -89, 89)
    self.punchAngle.y = math.Clamp(self.punchAngle.y, -179, 179)
    self.punchAngle.z = math.Clamp(self.punchAngle.z, -89, 89)
  else
    self:ViewPunchReset()
  end
  self:SetNetworkedVector("punchAngle", self.punchAngle)
  self:SetNetworkedVector("punchAngleVelocity", self.punchAngleVelocity)
end
 
Player.OldGetAimVector = Player.GetAimVector
function Player:GetAimVector()
  local a = self:EyeAngles()
  local p = self:GetViewPunch()
  a.yaw = a.yaw + p.x
  a.pitch = a.pitch + p.y
  a.roll = a.roll + p.z
  return a:Forward()
end
 
function Player:GetViewPunch()
  return self.punchAngle or Vector(0, 0, 0)
end
 
Player.OldViewPunch = Player.ViewPunch
function Player:ViewPunch(angle)
  if not self:InVehicle() then
    self.punchAngleVelocity.x = self.punchAngleVelocity.x + angle.yaw * 20
    self.punchAngleVelocity.y = self.punchAngleVelocity.y + angle.pitch * 20
    self.punchAngleVelocity.z = self.punchAngleVelocity.z + angle.roll * 20
  end
  return self:OldViewPunch(angle)
end
 
function Player:ViewPunchReset()
  self.punchAngle = Vector(0, 0, 0)
  self.punchAngleVelocity = Vector(0, 0, 0)
end
 
function GM:PlayerSpawn(player)
  player:ViewPunchReset()
  return self.BaseClass:PlayerSpawn(player)
end
 
function GM:UpdateAnimation(player)
  player:DecayPunchAngle()
  return self.BaseClass:UpdateAnimation(player)
end
