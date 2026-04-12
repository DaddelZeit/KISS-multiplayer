local M = {}
local http = require("socket.http")

local function update()
  if (not kissmp_network.connection.server_info) or (not kissmp_network.connection.connected) then
    local _, _, _  = http.request("http://127.0.0.1:3693/rich_presence/none")
    Steam.clearRichPresence()
    return
  end

  local _, _, _  = http.request("http://127.0.0.1:3693/rich_presence/"..kissmp_network.connection.server_info.name)
  Steam.setRichPresence("b", "KissMP - "..kissmp_network.connection.server_info.name)
end

M.update = update
M.onExtensionLoaded = function()
  setExtensionUnloadMode(M, "manual")
end

return M
