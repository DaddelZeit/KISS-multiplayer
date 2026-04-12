local M = {}

local string_buffer = require("string.buffer")

local prev_controller_data = {}

local function is_diff(t1, t2)
  if t1 == t2 then return false end

  if type(t1) ~= "table" or type(t2) ~= "table" then
    return t1 ~= t2
  end

  local t1_key_count = 0
  for k, v in pairs(t1) do
    if t2[k] == nil then return true end

    if is_diff(v, t2[k]) then
      return true
    end
    t1_key_count = t1_key_count + 1
  end

  local t2_key_count = 0
  for _ in pairs(t2) do
    t2_key_count = t2_key_count + 1
  end

  return t1_key_count ~= t2_key_count
end

local active_controllers = {}
local function send()
  local diff_count = 0
  local diffs = {}

  for i = 1, #active_controllers do
    local new_data = active_controllers[i]:get()

    if is_diff(prev_controller_data[i], new_data) then
      diffs[i] = new_data
      diff_count = diff_count + 1
      prev_controller_data[i] = new_data
    end
  end

  if diff_count > 0 then
    obj:queueGameEngineLua(string.format(
      "network.send_data(%q, true)",
      jsonEncode({
        ControllersUndefinedUpdate = {objectId, {diff = serialize(diffs)}}
      })))
  end
end

local full_controller_data = {}
local function apply_diff(buffer_data)
  local diff = string_buffer.decode(buffer_data)
  local data = deserialize(diff)
  for k,v in pairs(data) do
    tableMergeRecursive(full_controller_data[k], v)
    active_controllers[k]:set(full_controller_data[k])
  end
end

local function onExtensionLoaded()
  for _, contr in pairs(controller.getAllControllers()) do
    if FS:fileExists(string.format("/lua/vehicle/extensions/kiss_mp/controller_sync_extensions/%s.lua", contr.typeName)) then
      -- sync extensions are in this instance format to allow multiple controllers of the same type to be synced
      local sync_ext = require("/kiss_mp/controller_sync_extensions/"..contr.typeName).new()

      if sync_ext:set_controller(contr) then
        active_controllers[#active_controllers + 1] = sync_ext
        full_controller_data[#active_controllers] = sync_ext:get()
      end
    end
  end
end

M.send = send
M.apply_diff = apply_diff

M.onExtensionLoaded = onExtensionLoaded

return M
