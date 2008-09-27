include("shd_config.lua")

GM.Name 		= "GPK"
GM.Author 		= "Adam \"takua108/Unniloct\" Rezich"
GM.Email 		= "adam@rezich.com"
GM.Website 		= "adam.rezich.com"
GM.TeamBased 	= TEAMBASED

function GM:Initialize()
	self.BaseClass.Initialize(self)
	if (SERVER) then game.ConsoleCommand("mp_falldamage 1\n") end
end