local ADDON_NAME = "pfQuest_db_VMaNGOS"
local ADDON_LABEL = "|cff33ffccpf|cffffffffQuest|cff33ffcc_db_VMaNGOS|r"

local function message(text)
  if DEFAULT_CHAT_FRAME then
    DEFAULT_CHAT_FRAME:AddMessage(ADDON_LABEL .. ": " .. text)
  end
end

local function replace_table(target, source)
  if not target or not source then
    return
  end

  for key in pairs(target) do
    target[key] = nil
  end

  for key, value in pairs(source) do
    target[key] = value
  end
end

local source_info = pfQuest_db_VMaNGOS_source
local addon_db = pfQuest_db_VMaNGOS_data

if not source_info or not source_info.generated then
  return
end

if not pfDB or not pfDatabase or not pfDatabase.Reload then
  message("pfQuest database API is unavailable; database update was not applied.")
  return
end

if IsAddOnLoaded and IsAddOnLoaded("pfQuest-turtle") then
  message("pfQuest-turtle is loaded; VMaNGOS database update was not applied.")
  return
end

if not addon_db or source_info.schema ~= 1 then
  message("Unsupported or missing generated database; update was not applied.")
  return
end

local locale = GetLocale and GetLocale() or "enUS"
local data_sets = { "items", "units", "objects", "quests", "quests-itemreq", "refloot" }

for _, name in pairs(data_sets) do
  local source_db = addon_db[name]
  local target_db = pfDB[name]

  if source_db and target_db and source_db["data"] then
    if not target_db["data"] then
      target_db["data"] = {}
    end
    replace_table(target_db["data"], source_db["data"])
  end

  if source_db and target_db then
    local source_locale = source_db[locale] or source_db["enUS"]
    if source_locale then
      local target_locale = target_db["loc"] or target_db[locale] or target_db["enUS"]
      if not target_locale then
        target_locale = {}
      end

      replace_table(target_locale, source_locale)
      target_db["loc"] = target_locale

      if source_db[locale] then
        target_db[locale] = target_locale
      else
        target_db["enUS"] = target_locale
      end
    end
  end
end

if addon_db["meta"] and pfDB["meta"] then
  replace_table(pfDB["meta"], addon_db["meta"])
end

pfDatabase:Reload()

if pfDatabase.BuildNameIndex then
  pfDatabase:BuildNameIndex()
end

if pfDatabase.BuildStaticRejectSet then
  pfDatabase:BuildStaticRejectSet()
end

pfQuest_db_VMaNGOS_loaded = true
pfQuest_db_VMaNGOS_data = nil
pfQuest_vMangosDB_data = nil

if collectgarbage then
  collectgarbage("collect")
end
