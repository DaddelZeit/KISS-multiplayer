local M = {}

local current_level = ""
M.is_loading = false
local function load_level(filename)
  if FS:fileExists(filename) then
    freeroam_freeroam.startFreeroam(filename)
    M.is_loading = true
  else
    log("E", "kissmp_levelmanager.load_level", "Level does not exist!")
    kissmp_network.disconnect()
  end
end

local function join_current_level()
  load_level(current_level)
end

local function onKissMPConnected(delay_level_load, server_info)
  current_level = server_info.map
  if not delay_level_load then
    join_current_level()
  end
end

local function onKissMPDisconnected()
  if getMissionFilename() ~= "" or M.is_loading then
    returnToMainMenu()
  end
end

local function onClientEndMission()
  if getMissionFilename():lower() ~= current_level:lower() and not M.is_loading then
    kissmp_network.disconnect()
  end
end

local function onClientPostStartMission()
  M.is_loading = false
end

local function onExtensionLoaded()
  setExtensionUnloadMode(M, "manual")
end

M.load_level = load_level

M.onKissMPFinishedDownloads = join_current_level
M.onKissMPConnected = onKissMPConnected
M.onKissMPDisconnected = onKissMPDisconnected

M.onClientEndMission = onClientEndMission
M.onClientPostStartMission = onClientPostStartMission
M.onExtensionLoaded = onExtensionLoaded

return M
