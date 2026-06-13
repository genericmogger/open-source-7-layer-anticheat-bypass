local url = "https://raw.githubusercontent.com/genericmogger/open-source-7-layer-anticheat-bypass/refs/heads/main/source.lua"

local fullBypassScript = [[
loadstring(game:HttpGet("]] .. url .. [["))()
]]

if queue_on_teleport then
    queue_on_teleport(fullBypassScript)
end

loadstring(game:HttpGet(url))()
