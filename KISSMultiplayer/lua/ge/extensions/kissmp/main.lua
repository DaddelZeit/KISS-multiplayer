local M = {}

local http = require("socket.http")
http.TIMEOUT = 0.5

local first_update = false

M.bridge_connected = false
M.incorrect_install = true
M.install_path = ""

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

  -- verify mod install
  local filepath = FS:findOverrides("/lua/ge/extensions/kissmp/main.lua")
  if filepath and filepath[1] then
    filepath = filepath[1]:gsub("\\", "/"):match("/mods.+")
    M.install_path = filepath

    local modname = string.lower(filepath)
    modname = modname:gsub('dir:/', '')
    modname = modname:gsub('/mods/', '')
    modname = modname:gsub('repo/', '')
    modname = modname:gsub('unpacked/', '')
    modname = modname:gsub('/', '')
    modname = modname:gsub('.zip$', '')
    M.install_name = modname

    M.incorrect_install = false
  else
    M.incorrect_install = true
  end

  -- load extensions
  loadJsonMaterialsFile("/art/kissmp/playermodels/main.materials.json")
  for i=1, #extension_load_list do
    extensions.load(extension_load_list[i])
  end

  -- check if bridge works
  check_bridge_connect()

  -- run global init hook
  extensions.hook("onKissMPLoaded")
end

local function onExtensionUnloaded()
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
