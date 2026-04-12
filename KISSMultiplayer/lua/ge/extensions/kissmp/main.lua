local M = {}

local first_update = false

M.bridge_connected = false

local extension_load_list = {
  -- network first
  "vehiclemanager",
  "network",
  "kissrichpresence",
  "kissvoicechat",

  -- other important client stuff
  "kissmods",
  "kissconfig",
  "kissplayers",
  "kisstransform",

  -- ui goes last
  "kissui",
}

local function onUpdate()
  if first_update then return end
  first_update = true

  loadJsonMaterialsFile("art/shapes/kissmp_playermodels/main.materials.json")
  for i=1, #extension_load_list do
    extensions.load(extension_load_list[i])
  end
end

local function onExtensionUnloaded()
  -- extension dependency system *should* handle this, but it might change across game updates
  for i=1, #extension_load_list do
    extensions.unload(extension_load_list[i])
  end
end

M.onExtensionUnloaded = onExtensionUnloaded
M.onUpdate = onUpdate

return M
