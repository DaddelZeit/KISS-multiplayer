local M = {}

local string_buffer = require("string.buffer")

local mainController = nil
local gearbox = nil

local last_received_data = {}

local function get_gearbox_data()
  local state = mainController.getState()
  local data = {
    vehicle_id = objectId,
    lock_coef = gearbox and gearbox.lockCoef or 0,
  }

  if not state.grb_idx then
    state.grb_idx = 0
  end

  if not state.grb_mde then
    state.grb_mde = ""
  end

  tableMerge(data, state)

  return data
end

local function apply(buffer_data)
  local data = string_buffer.decode(buffer_data)

  if last_received_data.grb_mde ~= data.grb_mde or last_received_data.grb_idx ~= data.grb_idx then
    mainController.setState(data)
  end

  if gearbox and gearbox.setLock then
    gearbox:setLock(data.lock_coef == 0)
  end

  last_received_data = data
end

local function onExtensionLoaded()
  mainController = controller.mainController
  gearbox = powertrain.getDevice("gearbox")

  -- Search for a gearbox if one wasn't found
  if not gearbox then
    local devices = powertrain.getDevices()
    for _, device in pairs(devices) do
      if device.deviceCategories.gearbox then
        gearbox = device
        break
      end
    end
  end
end

M.apply = apply
M.get_gearbox_data = get_gearbox_data
M.onExtensionLoaded = onExtensionLoaded

return M
