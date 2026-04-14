local M = {}

M.font_index = {}
M.language = ""

local string_format = require("kissmp/string_format")

local translation_dir_template = "/art/kissmp/translations/%s/"
local translation_dir_default = "/art/kissmp/translations/en-US/"
local font_index_template = "/art/kissmp/font_indexes/%s.json"
local font_index_default = "/art/kissmp/font_indexes/en-US.json"
local translations = {}

local translation_cache = {}

local function translate(id, context)
  return translations[id] and
  (context and string_format(translations[id], context) or translations[id])
  or id
end

local function onSettingsChanged()
  local userlang = settings.getValue("userLanguage")
  if M.language == userlang then return end

  translations = {}

  log("D", "kissmp.translate.load", string.format("Setting language: %s", userlang))

  local translation_dir = string.format(translation_dir_template, userlang)
  for _, translation_file in ipairs(FS:findFiles(translation_dir_default, "*", 0)) do
    local filename = translation_file:match("([^/]+)$")
    local new_translation_file = translation_dir..filename

    if FS:fileExists(new_translation_file) then
      log("D", "kissmp.translate.load", "Loading file: "..new_translation_file)
      translations = tableMerge(translations, jsonReadFile(new_translation_file) or {})
    else
      log("D", "kissmp.translate.load", string.format("Translation not found for %s, using en-US fallback.", filename))
      translations = tableMerge(translations, jsonReadFile(translation_file) or {})
    end
  end

  local new_font_index = string.format(font_index_template, userlang)
  if FS:fileExists(new_font_index) then
    log("D", "kissmp.translate.load", "Loading font index: "..new_font_index)
    M.font_index = jsonReadFile(new_font_index) or {}
  else
    log("D", "kissmp.translate.load", string.format("Font index not found for %s, using en-US fallback.", userlang))
    M.font_index = jsonReadFile(font_index_default) or {}
  end

  -- update all translations
  for _, v in pairs(translation_cache) do
    if v[1] then
      for i=1, #v[1] do
        v[1]:update()
      end
    else
      v:update()
    end
  end

  M.language = userlang
end

local TranslationInstance = {}
function TranslationInstance:set(id, context)
  self.id = id
  self.context = context
  self.txt = translate(self.id, self.context)
end

function TranslationInstance:update(context)
  self.context = context and tableMerge(self.context or {}, context) or self.context
  self.txt = translate(self.id, self.context)
end

function TranslationInstance:disable()
  self.txt = self.id
end

local function createOrGetTranslationInstance(...)
  local o = {}
  setmetatable(o, TranslationInstance)
  TranslationInstance.__index = TranslationInstance
  o:set(...)
  return o
end

local function onExtensionLoaded()
  setExtensionUnloadMode(M, "manual")
  onSettingsChanged()
  setmetatable(M, {
    __call = function(self, id, context, force)
      if not force and translation_cache[id] then
        return translation_cache[id]
      else
        if translation_cache[id] then
          if not translation_cache[id][1] then
            translation_cache[id] = {translation_cache[id]}
          end
          translation_cache[id][#translation_cache[id]+1] = createOrGetTranslationInstance(id, context)
          return translation_cache[id][#translation_cache[id]]
        else
          translation_cache[id] = createOrGetTranslationInstance(id, context)
          return translation_cache[id]
        end
      end
    end
  })
end

local function set_debug_active(bool)
  local loop_func_name = bool and "disable" or "update"
  for _, v in pairs(translation_cache) do
    if v[1] then
      for i=1, #v[1] do
        v[1][loop_func_name](v[1])
      end
    else
      v[loop_func_name](v)
    end
  end
end

M.onExtensionLoaded = onExtensionLoaded
M.onSettingsChanged = onSettingsChanged
M.set_debug_active = set_debug_active

return M
