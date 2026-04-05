local M = {}
local im = ui_imgui

local red_color = im.ImVec4(0.9, 0, 0, 1)
local mouse_cursor_pos = im.ImVec2(0, 0)
local config_items = {}

local confirm_popup_active = false
local confirm_player_name = im.ArrayChar(32, "")
local confirm_timer = 5

local function render_checkbox(ui_name, setting_id)
  local checkbox_name = "###"..setting_id
  if ui_name then
    checkbox_name = ui_name..checkbox_name
  end
  if im.Checkbox(checkbox_name, config_items[setting_id]) then
    kissconfig.set_setting(setting_id, config_items[setting_id][0])
  end
end

local function render_sliderF(ui_name, setting_id,  min, max)
  local slider_name = "###"..setting_id
  if ui_name then
    slider_name = ui_name..slider_name
  end
  if im.SliderFloat(slider_name, config_items[setting_id],  min, max) then
    kissconfig.set_setting(setting_id, config_items[setting_id][0])
  end
end

local function render_sliderI(ui_name, setting_id, min, max)
  local slider_name = "###"..setting_id
  if ui_name then
    slider_name = ui_name..slider_name
  end
  if im.SliderInt(slider_name, config_items[setting_id],  min, max) then
    kissconfig.set_setting(setting_id, config_items[setting_id][0])
  end
end

local function draw(dt)
  im.Text("User Interface")
  im.Separator()
  render_sliderF("Window Opacity", "ui.window_opacity", 0, 1)

  im.NewLine()
  im.Text("Player Visbility")
  im.Separator()
  render_checkbox("Show Players In Vehicles", "players.show_drivers")
  render_checkbox("Show Name Tags", "players.show_nametags")

  im.NewLine()
  im.Text("Performance")
  im.Separator()
  render_checkbox(nil, "perf.enable_view_distance")
  local slider_active = config_items["perf.enable_view_distance"][0]
  if not slider_active then
    im.BeginDisabled()
  end
  im.SameLine()
  render_sliderI("View Distance", "perf.view_distance", 50, 500)
  im.PushTextWrapPos(0)
  im.Text("Warning: This feature is experimental. It can introduce a small, usually unnoticeable lag spike when approaching vehicles. It'll also block the ability to switch to vehicles outside of the view distance.")
  im.PopTextWrapPos()
  if not slider_active then
    im.EndDisabled()
  end

  im.PushStyleColor2(im.Col_Text, red_color)
  im.NewLine()
  im.Text("Danger Zone")
  im.Separator()
  if im.Checkbox("Allow public servers to run commands", config_items["security.public_scripting"]) then
    if config_items["security.public_scripting"][0] then
      im.OpenPopup1("SecurityConfirmationPopup")
      mouse_cursor_pos = im.GetMousePos()
      confirm_popup_active = true
    end
  end
  if im.Checkbox("Allow mods from public servers", config_items["security.public_mods"]) then
    if config_items["security.public_mods"][0] then
      im.OpenPopup1("SecurityConfirmationPopup")
      mouse_cursor_pos = im.GetMousePos()
      confirm_popup_active = true
    end
  end
  im.PopStyleColor()

  im.SetNextWindowPos(mouse_cursor_pos, im.Cond_Always, im.ImVec2(0, 0))
  if im.BeginPopup("SecurityConfirmationPopup") then
    im.Text("Servers can infect your computer.")
    im.Text("Servers can steal your data.")
    im.Text("ONLY USE PUBLIC SERVERS YOU TRUST.")
    im.NewLine()

    if confirm_timer > 0 then
      confirm_timer = confirm_timer - dt
    end
    local cant_use = confirm_timer > 0
    if cant_use then
      im.BeginDisabled()
      im.Text("("..math.ceil(confirm_timer)..") Enter your player name to continue:")
    else
      im.Text("Enter your player name to continue:")
    end
    if im.InputText("##name", confirm_player_name) then
      if ffi.string(confirm_player_name) == ffi.string(kissui.player_name) then
        kissconfig.set_setting("security.public_scripting", config_items["security.public_scripting"][0])
        kissconfig.set_setting("security.public_mods", config_items["security.public_mods"][0])
        ffi.copy(confirm_player_name, "")
        confirm_timer = 5
        confirm_popup_active = false
        im.CloseCurrentPopup()
      end
    end
    if cant_use then
      im.EndDisabled()
    end

    im.EndPopup()
  elseif confirm_popup_active then -- user closed it
    config_items["security.public_scripting"][0] = kissconfig.get_setting("security.public_scripting")
    config_items["security.public_mods"][0] = kissconfig.get_setting("security.public_mods")
    ffi.copy(confirm_player_name, "")
    confirm_timer = 5
    confirm_popup_active = false
  end
end

local function onKissMPSettingsChanged(config)
  config_items["ui.window_opacity"] = im.FloatPtr(config["ui.window_opacity"])

  config_items["players.show_nametags"] = im.BoolPtr(config["players.show_nametags"])
  config_items["players.show_drivers"] = im.BoolPtr(config["players.show_drivers"])

  config_items["perf.enable_view_distance"] = im.BoolPtr(config["perf.enable_view_distance"])
  config_items["perf.view_distance"] = im.IntPtr(config["perf.view_distance"])

  if not confirm_popup_active then
    config_items["security.public_scripting"] = im.BoolPtr(config["security.public_scripting"])
    config_items["security.public_mods"] = im.BoolPtr(config["security.public_mods"])
  end
end

M.draw = draw
M.onKissMPSettingsChanged = onKissMPSettingsChanged

return M
