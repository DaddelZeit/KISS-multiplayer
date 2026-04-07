local SyncController = {}
SyncController.__index = SyncController

function SyncController.new()
  local self = setmetatable({}, SyncController)
  self.contr = nil
  self.unmapped_data = {}
  return self
end

function SyncController:set_controller(value)
  self.contr = value
  return self.contr.serialize and self.contr.serialize() ~= nil
end

function SyncController:get()
  local data = self.contr and self.contr.serialize()
  if data then
    return {
      data.escConfigKey,
    }
  end
end

function SyncController:set(data)
  self.unmapped_data.escConfigKey = data[1]
  if self.contr then
    self.contr.deserialize(self.unmapped_data)
  end
end

return SyncController