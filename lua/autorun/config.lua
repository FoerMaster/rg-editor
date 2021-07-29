rgedit = rgedit or {config = {},ents={},ui={},vars = {["show_bounds"] = true, ["show_class"] = true, }}

function rgedit.CanAccess(ply,access)
    return rgedit.config.groups[ply:GetUserGroup()] and rgedit.config.groups[ply:GetUserGroup()][access] or false
end


rgedit.config.groups = {
    ["superadmin"] = {
        ["OPENMENU"] = true, -- Can open menu?
        ["SAVEENTS"] = true, -- Can save ents?
    },
    ["admin"] = {
        ["OPENMENU"] = true,
        ["SAVEENTS"] = false,
    },
    ["user"] = {
        ["OPENMENU"] = false,
        ["SAVEENTS"] = false,
    },
}