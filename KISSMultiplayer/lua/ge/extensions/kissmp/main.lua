local M = {}

local http = require("socket.http")
http.TIMEOUT = 0.5

local first_update = false

M.bridge_connected = false

local extension_load_list = {
  -- network first
  "kissmp_network",
  "kissmp_vehiclemanager",
  "kissmp_richpresence",
  "kissmp_voicechat",

  -- other important client stuff
  "kissmp_mods",
  "kissmp_config",
  "kissmp_players",
  "kissmp_transform",

  -- ui goes last
  "kissmp_ui",
}

local function check_bridge_connect()
  local b, _, _  = http.request("http://127.0.0.1:3693/check")
  if b and b == "ok" then
    M.bridge_launched = true
  else
    M.bridge_launched = false
  end

  return M.bridge_launched
end

local function onUpdate()
  if first_update then return end
  first_update = true

  loadJsonMaterialsFile("art/shapes/kissmp_playermodels/main.materials.json")
  for i=1, #extension_load_list do
    extensions.load(extension_load_list[i])
  end

  check_bridge_connect()
  extensions.hook("onKissMPLoaded")
end

local function onExtensionUnloaded()
  -- extension dependency system *should* handle this, but it might change across game updates
  for i=1, #extension_load_list do
    extensions.unload(extension_load_list[i])
  end
end

M.check_bridge_connect = check_bridge_connect

M.onUpdate = onUpdate
M.onExtensionUnloaded = onExtensionUnloaded
M.onExtensionLoaded = function()
  setExtensionUnloadMode(M, "manual")
end

return M
