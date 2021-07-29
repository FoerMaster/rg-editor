util.AddNetworkString("rgeditor.hook")
file.CreateDir("rgeditor")

net.Receive( "rgeditor.hook", function( len, pl )
	hook.Call("rgeditor.Get",nil,pl,net.ReadString(),net.ReadTable())
end )



function rgedit.SaveEnts()
    file.Write("rgeditor/"..game.GetMap().."_map.dat",util.TableToJSON(rgedit.ents))
end

function rgedit.LoadEnts()
    if !file.Exists( "rgeditor/"..game.GetMap().."_map.dat", "DATA" ) then return end
    local data = file.Read("rgeditor/"..game.GetMap().."_map.dat","DATA")
    if data then -- хз зачем, просто хочу
        data = util.JSONToTable(data) or {}
    else
        data = {}
    end
    rgedit.ents = data
end

hook.Add("rgeditor.Get","OpenMenu",function(ply,_type,data)
    local pl = ply
    if !pl or !IsValid(pl) or !pl:IsPlayer() or _type != "OPENMENU" then return end

    if !rgedit.CanAccess(pl,"OPENMENU") then pl:ChatPrint("Need access") return end
 
    net.Start("rgeditor.hook")
    net.WriteTable(rgedit.ents)
    net.Send(pl)

end)

function rgedit.CleanEnts()
    for k,v in pairs(ents.GetAll()) do
        if v.SpawnedBy and v.SpawnedBy == "RGEDITOR" then
            v:Remove()
        end
    end
end

function rgedit.SpawnEnts()
    for k,v in pairs(rgedit.ents) do
        local ent = ents.Create( v.class )
        ent:SetPos( v.pos )
        ent:SetAngles( v.ang )
        ent:Spawn()
        ent.SpawnedBy = "RGEDITOR"
    end
end

hook.Add("rgeditor.Get","SaveEnts",function(ply,_type,data)
    local pl = ply
    if !pl or !IsValid(pl) or !pl:IsPlayer() or _type !=  "SAVEENTS" then return end

    if !rgedit.CanAccess(pl,"SAVEENTS") then pl:ChatPrint("Need access") return end

    rgedit.ents = data -- shit

    rgedit.SaveEnts()

    rgedit.CleanEnts()

    rgedit.SpawnEnts()


end)

hook.Add("PostCleanupMap","LoadEnts",function()
    rgedit.CleanEnts()
    rgedit.SpawnEnts()
end)

hook.Add("InitPostEntity", "InitializeEnts", function()
    rgedit.CleanEnts()
    rgedit.LoadEnts()
    rgedit.SpawnEnts()
end)
timer.Simple(5, function()
    rgedit.CleanEnts()
    rgedit.LoadEnts()
    rgedit.SpawnEnts()
end)