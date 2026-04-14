local M = {}
local im = ui_imgui

local red_color = im.ImVec4(0.9, 0, 0, 1)
local mouse_cursor_pos = im.ImVec2(0, 0)
local config_items = {}

local confirm_popup_active = false
local confirm_player_name = im.ArrayChar(32, "")
local confirm_timer = 5

local translate_near = kissmp_ui_translate("ui.main.settings.distance_near")
local translate_balanced = kissmp_ui_translate("ui.main.settings.distance_balanced")
local translate_far = kissmp_ui_translate("ui.main.settings.distance_far")
local translate_very_far = kissmp_ui_translate("ui.main.settings.distance_very_far")
local translate_custom = kissmp_ui_translate("ui.main.settings.distance_custom")

local translate_distance_ext = kissmp_ui_translate("ui.main.settings.distance_ext", {unit = "m"}, true)

local translate_separator_ui = kissmp_ui_translate("ui.main.settings.separator_ui")
local translate_ui_scale = kissmp_ui_translate("ui.main.settings.ui.scale")
local translate_ui_window_opacity = kissmp_ui_translate("ui.main.settings.ui.window_opacity")

local translate_separator_player = kissmp_ui_translate("ui.main.settings.separator_player")
local translate_players_show_drivers = kissmp_ui_translate("ui.main.settings.players.show_drivers")
local translate_players_show_nametags = kissmp_ui_translate("ui.main.settings.players.show_nametags")
local translate_players_nametags_colorful = kissmp_ui_translate("ui.main.settings.players.nametags.colorful")
local translate_players_nametags_fade = kissmp_ui_translate("ui.main.settings.players.nametags.fade")
local translate_players_nametags_use_z = kissmp_ui_translate("ui.main.settings.players.nametags.use_z")

local translate_separator_performance = kissmp_ui_translate("ui.main.settings.separator_performance")
local translate_perf_view_distance = kissmp_ui_translate("ui.main.settings.perf.view_distance")
local translate_perf_view_distance_warning = kissmp_ui_translate("ui.main.settings.view_distance_warning")

local translate_separator_danger = kissmp_ui_translate("ui.main.settings.separator_danger")
local translate_security_public_scripting = kissmp_ui_translate("ui.main.settings.security.public_scripting")
local translate_security_public_mods = kissmp_ui_translate("ui.main.settings.security.public_mods")
local translate_security_confirmation_popup = kissmp_ui_translate("ui.main.settings.security_confirmation_popup")
local translate_security_confirmation_instruction_timer = kissmp_ui_translate("ui.main.settings.security_confirmation_instruction_timer")
local translate_security_confirmation_instruction = kissmp_ui_translate("ui.main.settings.security_confirmation_instruction")

local fade_distance_name
local fade_distances = {
  {translate_near, 50},
  {translate_balanced, 100},
  {translate_far, 250},
  {translate_very_far, 400}
}

local view_distance_name
local view_distances = {
  {translate_near, 150},
  {translate_balanced, 300},
  {translate_far, 450},
  {translate_very_far, 600}
}

local function render_checkbox(ui_name, setting_id)
  local checkbox_name = "###"..setting_id
  if ui_name then
    checkbox_name = ui_name..checkbox_name
  end
  if im.Checkbox(checkbox_name, config_items[setting_id]) then
    kissmp_config.set_setting(setting_id, config_items[setting_id][0])
  end
end

local function render_sliderF(ui_name, setting_id,  min, max, format)
  format = format or "%.1f"
  local slider_name = "###"..setting_id
  if ui_name then
    slider_name = ui_name..slider_name
  end
  if im.SliderFloat(slider_name, config_items[setting_id], min, max, format) then
    kissmp_config.set_setting(setting_id, config_items[setting_id][0])
  end
end

local function render_sliderI(ui_name, setting_id, min, max, format)
  local slider_name = "###"..setting_id
  if ui_name then
    slider_name = ui_name..slider_name
  end
  if im.SliderInt(slider_name, config_items[setting_id], min, max, format) then
    kissmp_config.set_setting(setting_id, config_items[setting_id][0])
  end
end

local function help_marker(text, desc)
  im.TextDisabled(text)
  if im.IsItemHovered(im.HoveredFlags_AllowWhenDisabled) and im.BeginTooltip() then
    im.PushTextWrapPos(im.GetFontSize() * 35.0);
    im.TextUnformatted(desc);
    im.PopTextWrapPos();
    im.EndTooltip();
  end
end

local function draw(dt)
  im.Text(translate_separator_ui.txt)
  im.Separator()
  render_sliderF(translate_ui_scale.txt, "ui.scale", 0.9, 2)
  render_sliderF(translate_ui_window_opacity.txt, "ui.window_opacity", 0.3, 1)

  im.NewLine()
  im.Text(translate_separator_player.txt)
  im.Separator()
  render_checkbox(translate_players_show_drivers.txt, "players.show_drivers")
  im.NewLine()
  render_checkbox(translate_players_show_nametags.txt, "players.show_nametags")
  render_checkbox(translate_players_nametags_colorful.txt, "players.nametags.colorful")
  render_checkbox(nil, "players.nametags.fade")
  local slider_active = config_items["players.nametags.fade"][0]
  if not slider_active then
    im.BeginDisabled()
  end
  im.SameLine()
  local cursorX = im.GetCursorPosX()
  local distance = config_items["players.nametags.fade"][0]
  im.SetNextItemWidth(im.CalcTextSize(fade_distance_name.txt).x+im.GetTextLineHeight()+im.GetStyle().FramePadding.x*4)
  if im.BeginCombo(translate_players_nametags_fade.txt, fade_distance_name.txt) then
    for _, v in ipairs(fade_distances) do
      translate_distance_ext:update({preset_name = v[1].txt, distance = v[2]})
      if im.Selectable1(translate_distance_ext.txt, fade_distance_name == v[1]) then
        distance = v[2]
        kissmp_config.set_setting("players.nametags.fade_start_distance", distance)
        fade_distance_name = v[1]
      end
    end
    if im.Selectable1(translate_custom.txt, fade_distance_name == translate_custom) then
      fade_distance_name = translate_custom
    end
    im.EndCombo()
  end
  if fade_distance_name == translate_custom then
    im.SetCursorPosX(cursorX)
    render_sliderI("##players.nametags.fade_start_distance", "players.nametags.fade_start_distance", 25, 500, "%dm")
  end
  if not slider_active then
    im.EndDisabled()
  end
  render_checkbox(translate_players_nametags_use_z.txt, "players.nametags.use_z")


  im.NewLine()
  im.Text(translate_separator_performance.txt)
  im.Separator()
  render_checkbox(nil, "perf.enable_view_distance")
  local slider_active = config_items["perf.enable_view_distance"][0]
  if not slider_active then
    im.BeginDisabled()
  end
  im.SameLine()
  local cursorX = im.GetCursorPosX()
  local distance = config_items["perf.view_distance"][0]
  im.SetNextItemWidth(im.CalcTextSize(view_distance_name.txt).x+im.GetTextLineHeight()+im.GetStyle().FramePadding.x*4)
  if im.BeginCombo(translate_perf_view_distance.txt, view_distance_name.txt) then
    for _, v in ipairs(view_distances) do
      translate_distance_ext:update({preset_name = v[1].txt, distance = v[2]})
      if im.Selectable1(translate_distance_ext.txt, view_distance_name == v[1]) then
        distance = v[2]
        kissmp_config.set_setting("perf.view_distance", distance)
        view_distance_name = v[1]
      end
    end
    if im.Selectable1(translate_custom.txt, view_distance_name == translate_custom) then
      view_distance_name = translate_custom
    end
    im.EndCombo()
  end
  im.SameLine()

  if not slider_active then
    im.EndDisabled()
  end
  help_marker("[?]", translate_perf_view_distance_warning.txt)
  if not slider_active then
    im.BeginDisabled()
  end

  if view_distance_name == translate_custom then
    im.SetCursorPosX(cursorX)
    render_sliderI("##perf.view_distance", "perf.view_distance", 50, 1000, "%dm")
  end
  im.SetCursorPosX(cursorX)
  im.PushTextWrapPos(0)
  im.PopTextWrapPos()
  if not slider_active then
    im.EndDisabled()
  end

  im.PushStyleColor2(im.Col_Text, red_color)
  im.NewLine()
  im.Text(translate_separator_danger.txt)
  im.Separator()
  if im.Checkbox(translate_security_public_scripting.txt, config_items["security.public_scripting"]) then
    if config_items["security.public_scripting"][0] then
      im.OpenPopup1("SecurityConfirmationPopup")
      mouse_cursor_pos = im.GetMousePos()
      confirm_popup_active = true
    else
      kissmp_config.set_setting("security.public_scripting", false)
    end
  end
  if im.Checkbox(translate_security_public_mods.txt, config_items["security.public_mods"]) then
    if config_items["security.public_mods"][0] then
      im.OpenPopup1("SecurityConfirmationPopup")
      mouse_cursor_pos = im.GetMousePos()
      confirm_popup_active = true
    else
      kissmp_config.set_setting("security.public_mods", false)
    end
  end
  im.PopStyleColor()

  im.SetNextWindowPos(mouse_cursor_pos, im.Cond_Always, im.ImVec2(0, 0))
  if im.BeginPopup("SecurityConfirmationPopup") then
    im.Text(translate_security_confirmation_popup.txt)
    im.NewLine()

    if confirm_timer > 0 then
      confirm_timer = confirm_timer - dt
    end
    local cant_use = confirm_timer > 0
    if cant_use then
      im.BeginDisabled()
      translate_security_confirmation_instruction_timer:update({time = math.ceil(confirm_timer)})
      im.Text(translate_security_confirmation_instruction_timer.txt)
    else
      im.Text(translate_security_confirmation_instruction.txt)
    end
    if im.InputText("##name", confirm_player_name) then
      if ffi.string(confirm_player_name) == ffi.string(kissmp_ui.player_name) then
        kissmp_config.set_setting("security.public_scripting", config_items["security.public_scripting"][0])
        kissmp_config.set_setting("security.public_mods", config_items["security.public_mods"][0])
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
    config_items["security.public_scripting"][0] = kissmp_config.get_setting("security.public_scripting")
    config_items["security.public_mods"][0] = kissmp_config.get_setting("security.public_mods")
    ffi.copy(confirm_player_name, "")
    confirm_timer = 5
    confirm_popup_active = false
  end
end

local function onKissMPSettingsChanged(config)
  config_items["ui.scale"] = im.FloatPtr(config["ui.scale"])
  config_items["ui.window_opacity"] = im.FloatPtr(config["ui.window_opacity"])

  config_items["players.show_nametags"] = im.BoolPtr(config["players.show_nametags"])
  config_items["players.show_drivers"] = im.BoolPtr(config["players.show_drivers"])

  config_items["players.nametags.fade"] = im.BoolPtr(config["players.nametags.fade"])
  config_items["players.nametags.fade_start_distance"] = im.IntPtr(config["players.nametags.fade_start_distance"])

  -- this will stop the entire widget changing away from custom whenever a distance matches a preset
  -- but ONLY between game sessions, restarting the game will make it use an actual preset if applicable
  if fade_distance_name ~= translate_custom then
    local distance = config["players.nametags.fade_start_distance"]
    for _, v in ipairs(fade_distances) do
      if distance == v[2] then
        fade_distance_name = v[1]
        goto break_loop
      end
    end
    fade_distance_name = translate_custom
    ::break_loop::
  end

  config_items["players.nametags.colorful"] = im.BoolPtr(config["players.nametags.colorful"])
  config_items["players.nametags.use_z"] = im.BoolPtr(config["players.nametags.use_z"])

  config_items["perf.enable_view_distance"] = im.BoolPtr(config["perf.enable_view_distance"])
  config_items["perf.view_distance"] = im.IntPtr(config["perf.view_distance"])

  if view_distance_name ~= translate_custom then
    local distance = config["perf.view_distance"]
    for _, v in ipairs(view_distances) do
      if distance == v[2] then
        view_distance_name = v[1]
        goto break_loop
      end
    end
    view_distance_name = translate_custom
    ::break_loop::
  end

  if not confirm_popup_active then
    config_items["security.public_scripting"] = im.BoolPtr(config["security.public_scripting"])
    config_items["security.public_mods"] = im.BoolPtr(config["security.public_mods"])
  end
end

M.draw = draw
M.onKissMPSettingsChanged = onKissMPSettingsChanged

return M
