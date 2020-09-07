local AddOnFolderName, private = ...

-- See http://wow.curseforge.com/addons/ion-status-bars/localization/
local L = _G.LibStub("AceLocale-3.0"):NewLocale("BattlePetCageMatch", "enUS", true)

if not L then return end
--@localization(locale="enUS", format="lua_additive_table", handle-unlocalized="comment")@
 local commandColor = "FFFFC654";


L.OPTIONS_HEADER = "Options"
L.OPTIONS_SHOW_BUTTON = "Show Cage Button on Pet Journal"
L.OPTIONS_SHOW_BUTTON_TOOLTIP = ""
L.OPTIONS_TRADEABLE = "Show Non-tradeable icon"
L.OPTIONS_TRADEABLE_TOOLTIP = "Toggles a marker for pets tha can not be caged"
L.OPTIONS_GLOBAL_LIST = "Show cage inventory on other Server"
L.OPTIONS_GLOBAL_LIST_TOOLTIP = "Shows/Hides the List icon on the Pet Journal when cages on other servers are in the DB."
L.OPTIONS_INV_TOOLTIPS = "Add Inventory count to cage tooltip"
L.OPTIONS_ICON_TOOLTIPS = "Adds tooltips to the Pet Icon in the Pet Journal."
L.OPTIONS_ICON_TOOLTIPS_1 = "Show current character cage inventory"
L.OPTIONS_ICON_TOOLTIPS_2 = "Show TSM price"
L.OPTIONS_ICON_TOOLTIPS_3 = "Show other character's cage inventory"
L.OPTIONS_CAGE_HEADER = "Auto Cage Pet Options"

L.OPTIONS_CAGE_CUSTOM_TOOLTIP = "This value will be compaired against the selected TSM source."
L.OPTIONS_CAGE_CONFIRM = "Requires confirmation before caging"
L.OPTIONS_CAGE_WINDOW = "Show Cage List Window"
L.OPTIONS_CAGE_ONCE = "Cage only 1 of any pet"
L.OPTIONS_CAGE_AMMOUNT = "How many pets to cage"
L.OPTIONS_SKIP_CAGED = "Skip pets that have already been caged"
L.OPTIONS_INCOMPLETE_LIST = "How to Handle Interupted Auto Cage Lists"
L.OPTIONS_INCOMPLETE_LIST_1 = "Create New List"
L.OPTIONS_INCOMPLETE_LIST_2 = "Continue Old List"
L.OPTIONS_INCOMPLETE_LIST_3 = "Prompt"
L.OPTIONS_FAVORITE_LIST = "How to handle Favorite pets"
L.OPTIONS_CAGE_MAX_LEVEL = "Max Level to cage"
L.OPTIONS_CAGE_MAX_LEVEL_TOOLTIP = "Skips any level over this value"
L.OPTIONS_CAGE_MIN_LEVEL = "Min Level to cage"
L.OPTIONS_CAGE_MIN_LEVEL_TOOLTIP = "Skips any level below this value"
L.OPTIONS_CAGE_MAX_QUANTITY = "Only caged when Quantity is at or above"
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
L.OPTIONS_TSM_USE_CUSTOM = "Use Custom TSM Source"


L.OPTIONS_TSM_CUSTOM_CAGE = "Custom TSM Source - Price that a pet must exceed to be caged. Don't use the same source as in the TSM Data section."
L.OPTIONS_TSM_CUSTOM_TOOLTIP = "Enter Custom Pice Source. See TSM Documentation for instructions"

L.OPTIONS_TSM_CUSTOM = "Custom TSM Source - Determines the listed price of a pet."
L.OPTIONS_TSM_CUSTOM_TOOLTIP = "Enter Custom Pice Source. See TSM Documentation for instructions"
L.OPTIONS_TSM_FILTER = "Filter based on price"
L.OPTIONS_TSM_FILTER_TOOLTIP = "Only puts Coin icon when the value is greater than the filter."
L.OPTIONS_TSM_RANK = "Change coin icon when over % of filter value"
L.OPTIONS_TSM_RANK_MEDIUM = "Silver"
L.OPTIONS_TSM_RANK_HIGH = "Gold"

L.CAGED_MESSAGE = "Matched pet; caging it for you!"
L.CAGED_MESSAGE_WHITELIST = "Pet caged due to Whitelist."
L.CAGED_MESSAGE_BLACKLIST = "Pet ignored due to Blacklist."

L.SLOTTED_PET_MESSAGE = "Pet is in Pet Battle Slot and skipped"

L.CONTINUE_CAGING_DIALOG_TEXT = "Continue Caging Old List?"
L.CONTINUE_CAGING_DIALOG_YES = "Yes"
L.CONTINUE_CAGING_DIALOG_NO = "No"

L.BUILDING_CAGE_LIST = "Building Cage List"

L.AUTO_CAGE_TOOLTIP_1 = "Cage Pets"
L.AUTO_CAGE_TOOLTIP_2 = "Click:  Cage Pets based on rules"
L.AUTO_CAGE_TOOLTIP_3 = "Shift Click: Options"

L.FULL_INVENTORY = "Inventory is full, stopping."

L.KEYBIND_LEARN = "Learn Caged Pets"

L.BUILD_LEARN_LIST = "Building Learn List" 
L.LEARN_COMPLETE = "All Possible Pets Have Been Learned."
L.CAGE_COMPLETE  = "All Pets Caged"

L.BPCM_MOUSEOVER_CAGE = "Cage pet mouse is currently over"

L.TSM_CUSTOM_ERROR ="Not a valid custom price: %s"


L.STOP_CAGING_DIALOG_TEXT = "Stop Caging?"
L.START_CAGING_DIALOG_TEXT = "Start Caging?"

L.LIST_DISPLAY_TEXT = "%s - Level: %d %s %s"
L.LIST_DISPLAY_TEXT_PRICE = "- Value: %s"
L.CAGE_RULES_PRICE_TO_CAGE = "- Value to Cage: %s"

L.CAGE_RULES_INFO = "-Caging up to %d pet(s) between levels %d - %d, %s that I have at least %d or more of. %s %s"
L.SKIPPING_RULE = "Skipping pets in inventory"
L.CAGE_RULES = "Caging Rules"
L.CAGE_RULES_CUSTOM_TSM = "when %s is greater than %s"
L.CAGE_RULES_CUSTOM_PRICE = "valued over %s gold"
L.CAGE_RULES_SKIP = "\n-Skipping: %s %s %s"
L.CAGE_RULES_SKIP_CAGED = "Already caged pets"
L.CAGE_RULES_SKIP_AUCTION = "Pets on the AH"
L.CAGE_RULES_SKIP_BLACKLIST = "Blacklisted Pets"

L.NO_PETS_TO_CAGE = "No pets match crieteria"
L.OPTIONS_CAGE_QUALITY = "Quality of pet to cage"
L.CAGE_RULES_QUALITY = "\n-Caging Quality: %s%s%s%s"

L.OPTIONS_SHOW_TSM_CUSTOM = "Show value on cage list."
