local M = {}
local im = ui_imgui

local red_color = im.ImVec4(1,0.25,0.25,1)
local config_items = {}

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

local function draw()
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

  im.NewLine()
  im.TextColored(red_color, "Danger Zone")
  im.Separator()
  render_checkbox("Allow public servers to run commands", "security.public_scripting")
  im.PushTextWrapPos(0)
  im.TextColored(red_color, "Warning: ONLY USE PUBLIC SERVERS YOU TRUST WITH THIS ACTIVE. Arbitrary commands can infect your computer and/or steal data.")
  im.PopTextWrapPos()
end

local function onKissMPSettingsChanged(config)
  config_items["ui.window_opacity"] = im.IntPtr(config["ui.window_opacity"])

  config_items["players.show_nametags"] = im.BoolPtr(config["players.show_nametags"])
  config_items["players.show_drivers"] = im.BoolPtr(config["players.show_drivers"])

  config_items["perf.enable_view_distance"] = im.BoolPtr(config["perf.enable_view_distance"])
  config_items["perf.view_distance"] = im.IntPtr(config["perf.view_distance"])

  config_items["security.public_scripting"] = im.BoolPtr(config["security.public_scripting"] or false)
end

M.draw = draw
M.onKissMPSettingsChanged = onKissMPSettingsChanged

return M
