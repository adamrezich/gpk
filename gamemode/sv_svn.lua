local SVNTREE={}

local function DirTree(p)
	local t={}
	local o=file.FindDir(p.."*")
	local k,v
	for k,v in pairs(o) do
		if (table.Count(file.FindDir(p..v.."/*"))!=0) then
			t[v]=DirTree(p..v.."/")
		else
			if (file.Exists(p..v.."/.svn/entries")) then
				table.insert(SVNTREE,p..v.."/.svn/entries")
				t[v]="SUCCESS"
			else
				t[v]="FAILURE"
			end
		end
	end
	return t
end

function GetSVNBuild(g)
	local base="../gamemodes/"..g.."/"
	local highest=0
	DirTree(base)
	local k,v
	for k,v in pairs(SVNTREE) do
		for x,y in pairs(string.Explode("\n",file.Read(v))) do
			if (tonumber(y)!=nil and tonumber(y)>highest) then highest=tonumber(y) end
		end
	end
	return highest
end

REVISION = GetSVNBuild("gpk")

// Send the version to every single client
/*local function SendVersionToClient(ply)
	umsg.Start("RecvSVNRevision", ply)
		umsg.Short(ZDayConfig["version"])
	umsg.End()
end
hook.Add("PlayerInitialSpawn", "SendVersionToClient", function(ply) SendVersionToClient(ply); end)*/