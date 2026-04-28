local M = {}
local imgui = ui_imgui

local function draw()
  imgui.Text("Server address:")
  imgui.InputText("##addr", kissmp_ui.addr)
  imgui.SameLine()
  if imgui.Button("Connect") then
    local addr = ffi.string(kissmp_ui.addr)
    local player_name = ffi.string(kissmp_ui.player_name)
    kissmp_config.set_setting("ui.name", player_name)
    kissmp_config.set_setting("ui.addr", addr)
    kissmp_network.connect(addr, player_name, false)
  end
end

M.draw = draw

return M
