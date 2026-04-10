local M = {}

local ghostSpawnsQueued = {}

M.veh_to_ghost_map = {}
M.id_is_ghost = {}
M.ghost_state = {}
M.pause_overrides = {}

local actual_ghost_states = {}
local function set_vehicle_ghost(veh_id, ghost_state, mesh_fade)
  if M.pause_overrides[veh_id] then
    -- we still want M.ghost_state to keep its original value
    ghost_state = 2
  else
    M.ghost_state[veh_id] = ghost_state
  end

  if actual_ghost_states[veh_id] == ghost_state then return end
  actual_ghost_states[veh_id] = ghost_state

  local veh = getObjectByID(veh_id)

  if ghost_state == 0 then -- no ghost
    veh:setActive(1)
    veh:queueLuaCommand("kiss_vehicle.set_collision(true)")
  elseif ghost_state == 1 then -- no collisions
    veh:setActive(1)
    veh:queueLuaCommand("kiss_vehicle.set_collision(false)")
  elseif ghost_state == 2 then -- in stasis (more logic for this state is in onUpdate)
    veh:setActive(1)
    veh:queueLuaCommand("kiss_vehicle.set_collision(false)")
  elseif ghost_state == 3 then -- tucked somewhere in a parallel universe
    veh:setActive(0)
  end

  if type(mesh_fade) ~= "number" then
    mesh_fade = mesh_fade and 0.5 or 1
  end
  veh:setMeshAlpha(mesh_fade, "")
end

local function onUpdate()
  for id, v in pairs(M.pause_overrides) do
    -- 0.75 appears to be a safe value
    -- values too small cause breakage
    local veh = getObjectByID(id)
    if veh and v then
      veh:applyClusterVelocityScaleAdd(0, 0.75, 0, 0, 0)
    end
  end
end

local function set_pause_override(id, bool)
  if not bool then
    M.pause_overrides[id] = nil
  else
    M.pause_overrides[id] = true
  end
  set_vehicle_ghost(id, M.ghost_state[id], bool)
end

local velocity = vec3()
local function set_pause_override_for_owned(bool)
  for id in pairs(vehiclemanager.ownership) do
    local vehicle = getObjectByID(id)
    velocity:set(vehicle:getVelocityXYZ())
    if velocity:length() < 1 then
      set_pause_override(id, bool)
    end
  end
end

local pause_counter = 0
local pause_requests = {}

local function attempt_pause(id)
  if pause_requests[id] then
    return
  end
  pause_requests[id] = true
  pause_counter = pause_counter + 1
  if pause_counter > 0 then
    set_pause_override_for_owned(true)
  end
end

local function attempt_unpause(id)
  if not pause_requests[id] then
    return
  end
  pause_requests[id] = nil
  pause_counter = math.max(0, pause_counter - 1)

  if pause_counter == 0 then
    set_pause_override_for_owned(false)
  end
end

local function onVehicleSpawned(vehId)
  if not network.connection.connected then return end
  ghostSpawnsQueued[#ghostSpawnsQueued+1] = vehId
end

local function onVehicleDestroyed(vehId)
  M.pause_overrides[vehId] = nil
end

local function onExtensionLoaded()
end

M.onUpdate = onUpdate
M.onExtensionLoaded = onExtensionLoaded
M.onVehicleSpawned = onVehicleSpawned
M.onVehicleDestroyed = onVehicleDestroyed

M.set_vehicle_ghost = set_vehicle_ghost
M.set_pause_override = set_pause_override

M.attempt_pause = attempt_pause
M.attempt_unpause = attempt_unpause

return M