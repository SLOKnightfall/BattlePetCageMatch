local AddOnFolderName, private = ...

-- See http://wow.curseforge.com/addons/ion-status-bars/localization/
local L = _G.LibStub("AceLocale-3.0"):NewLocale("BattlePetCageMatch", "enUS", true)

if not L then return end
--@localization(locale="enUS", format="lua_additive_table", handle-unlocalized="comment")@


L.CAGED_MESSAGE = "Matched pet; caging it for you!"