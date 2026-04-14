local M = {}
local imgui = ui_imgui

local window_title = kissmp_ui_translate("ui.main.name", {version = kissmp_network.VERSION_STR})
local translate_player_name = kissmp_ui_translate("ui.main.player_name")
local translate_disconnect =  kissmp_ui_translate("ui.main.disconnect")

local translate_server_list = kissmp_ui_translate("ui.main.server_list.name")
local translate_direct_connect = kissmp_ui_translate("ui.main.direct_connect.name")
local translate_create_server = kissmp_ui_translate("ui.main.create_server.name")
local translate_favourites = kissmp_ui_translate("ui.main.favourites.name")
local translate_settings = kissmp_ui_translate("ui.main.settings.name")

local function draw(dt)
  kissmp_ui.tabs.favorites.draw_add_favorite_window(gui)
  if kissmp_ui.show_download then return end

  if not kissmp_ui.gui.isWindowVisible("KissMP") then return end
  imgui.SetNextWindowBgAlpha(kissmp_ui.window_opacity)
  imgui.PushStyleVar2(imgui.StyleVar_WindowMinSize, imgui.ImVec2(300, 300))
  imgui.SetNextWindowViewport(imgui.GetMainViewport().ID)
  if imgui.Begin(window_title.txt) then
    imgui.Text(translate_player_name.txt)
    imgui.InputText("##name", kissmp_ui.player_name)
    if kissmp_network.connection.connected then
      if imgui.Button(translate_disconnect.txt) then
        kissmp_network.disconnect()
      end
    end

    imgui.Dummy(imgui.ImVec2(0, 5))

    if imgui.BeginTabBar("server_tabs##") then
      if imgui.BeginTabItem(translate_server_list.txt) then
        kissmp_ui.tabs.server_list.draw(dt)
        imgui.EndTabItem()
      end
      if imgui.BeginTabItem(translate_direct_connect.txt) then
        kissmp_ui.tabs.direct_connect.draw()
        imgui.EndTabItem()
      end
      if imgui.BeginTabItem(translate_create_server.txt) then
        kissmp_ui.tabs.create_server.draw()
        imgui.EndTabItem()
      end
      if imgui.BeginTabItem(translate_favourites.txt) then
        kissmp_ui.tabs.favorites.draw()
        imgui.EndTabItem()
      end
      if imgui.BeginTabItem(translate_settings.txt) then
        kissmp_ui.tabs.settings.draw(dt)
        imgui.EndTabItem()
      end
      imgui.EndTabBar()
    end
  end
  imgui.End()
  imgui.PopStyleVar()
end

local function init(m)
  m.tabs.server_list.refresh(m)
  m.tabs.favorites.load(m)
  m.tabs.favorites.update(m)
  m.tabs.server_list.update_filtered(m)
end

M.draw = draw
M.init = init

return M
