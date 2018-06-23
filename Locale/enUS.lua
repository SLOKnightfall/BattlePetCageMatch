local AddOnFolderName, private = ...

-- See http://wow.curseforge.com/addons/ion-status-bars/localization/
local L = _G.LibStub("AceLocale-3.0"):NewLocale("BattlePetCageMatch", "enUS", true)

if not L then return end
--@localization(locale="enUS", format="lua_additive_table", handle-unlocalized="comment")@
 local commandColor = "FFFFC654";


L.OPTIONS_HEADER = "Options"
L.OPTIONS_TRADEABLE = "Show Non-tradeable icon"
L.OPTIONS_TRADEABLE_TOOLTIP = "Toggles a marker for pets tha can not be caged"
L.OPTIONS_GLOBAL_LIST = "Show cage inventory on other Server"
L.OPTIONS_GLOBAL_LIST_TOOLTIP = "Shows/Hides the List icon on the Pet Journal when cages on other servers are in the DB."
L.OPTIONS_INV_TOOLTIPS = "Add Inventory count to cage tooltip"
L.OPTIONS_CAGE_HEADER = "Auto Cage Pet Options"
L.OPTIONS_CAGE_OUTPUT = "Print Cage Scan output text"
L.OPTIONS_CAGE_ONCE = "Cage only 1 of any pet"
L.OPTIONS_SKIP_CAGED = "Skip pets that have already been caged"
L.OPTIONS_INCOMPLETE_LIST = "How to Handle Interupted Auto Cage Lists"
L.OPTIONS_INCOMPLETE_LIST_1 = "Create New List"
L.OPTIONS_INCOMPLETE_LIST_2 = "Continue Old List"
L.OPTIONS_INCOMPLETE_LIST_3 = "Prompt"
L.OPTIONS_FAVORITE_LIST = "How to handle Favorite pets"
L.OPTIONS_CAGE_MAX_LEVEL = "Max Level to cage"
L.OPTIONS_CAGE_MAX_LEVEL_TOOLTIP = "Skips any level over this value"
L.OPTIONS_CAGE_MAX_QUANTITY = "Only caged when over Quantity"
L.OPTIONS_CAGE_MAX_QUANTITY_TOOLTIP = "Skips pet if learned quantatiy is below this value"
L.OPTIONS_SKIP_AUCTION = "Skip pets that current character has active auctions for. (Requires TSM)"
L.OPTIONS_CAGE_MAX_PRICE = "Only Cage over a specific price (Requires TSM)"
L.OPTIONS_CAGE_MAX_PRICE_VALUE = "Gold"
L.OPTIONS_CAGE_MAX_PRICE_VALUE_TOOLTIP = "Gold limit for the filter."
L.OPTIONS_HANDLE_PETWHITELIST = "How to handle Custom Pet List"
L.OPTIONS_HANDLE_PETWHITELIST_TOOLTIP = "This list will always be added and ignores any set rules."

L.OPTIONS_PETWHITELIST = "Custom Pet List"

L.OPTIONS_WHITELLIST_TOOLTIP = "Add any Pet that you don't included when caging pets, |c"..commandColor.."one Pet per line|r. Proper capitalization is not required, but all other characters in the  name must be accurate. You may may also use |c"..commandColor.."*|r as a wildcard.This list will always be added and ignores any set rules."
L.OPTIONS_HANDLE_PETBLACKLIST = "Skip Blacklisted pets"
L.OPTIONS_PETBLACKLIST = "Pet Blacklist"
L.OPTIONS_BLACKLIST_TOOLTIP = "Add any Pet that you don't included when caging pets, |c"..commandColor.."one Pet per line|r. Proper capitalization is not required, but all other characters in the  name must be accurate. You may may also use |c"..commandColor.."*|r as a wildcard. "

L.OPTIONS_TSM_HEADER = "TSM Data Options"
L.OPTIONS_TSM_VALUE = "Show TSM Data(Requires TSM)"
L.OPTIONS_TSM_VALUE_TOOLTIP = "Shows/Hides the Coin icon on the Pet Journal"
L.OPTIONS_TSM_DATASOURCE = "TSM Source to Use"
L.OPTIONS_TSM_FILTER = "Filter based on price"
L.OPTIONS_TSM_FILTER_TOOLTIP = "Only puts Coin icon when the value is greater than the filter."
L.OPTIONS_TSM_RANK = "Change coin icon when over % of filter value"
L.OPTIONS_TSM_RANK_MEDIUM = "Silver"
L.OPTIONS_TSM_RANK_HIGH = "Gold"

L.CAGED_MESSAGE = "Matched pet; caging it for you!"
L.CAGED_MESSAGE_WHITELIST = "Pet caged due to Whitelist."
L.CAGED_MESSAGE_BLACKLIST = "Pet ignored due to Blacklist."

L.CONTINUE_CAGEING_DIALOG_TEXT = "Continue Cageing Old List?"
L.CONTINUE_CAGEING_DIALOG_YES = "Yes"
L.CONTINUE_CAGEING_DIALOG_NO = "No"

L.AUTO_CAGE_TOOLTIP_1 = "Cage Pets"
L.AUTO_CAGE_TOOLTIP_2 = "Click:  Cage Pets based on rules"
L.AUTO_CAGE_TOOLTIP_3 = "Shift Click: Options"

L.FULL_INVENTORY = "Inventory is full, stopping."

L.KEYBIND_LEARN = "Learn Caged Pets"

L.BUILD_LEARN_LIST = "Building Learn List" 
L.LEARN_COMPLETE = "All Possible Pets Have Been Learned."
L.CAGE_COMPLETE  = "All Pets Caged"

L.BPCM_MOUSEOVER_CAGE = "Cage pet mouse is currently over"