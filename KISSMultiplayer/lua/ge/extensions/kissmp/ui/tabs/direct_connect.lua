local M = {}
local imgui = ui_imgui

local translate_connect = kissmp_ui_translate("ui.main.connect")
local translate_address = kissmp_ui_translate("ui.main.direct_connect.address")

local function draw()
  imgui.Text(translate_address.txt)
  imgui.InputText("##addr", kissmp_ui.addr)
  imgui.SameLine()
  if imgui.Button(translate_connect.txt) then
    local addr = ffi.string(kissmp_ui.addr)
    local player_name = ffi.string(kissmp_ui.player_name)
    kissmp_config.set_setting("ui.name", player_name)
    kissmp_config.set_setting("ui.addr", addr)
    kissmp_network.connect(addr, player_name, false)
  end
end

M.draw = draw

return M
