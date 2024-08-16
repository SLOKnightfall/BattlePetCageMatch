--	///////////////////////////////////////////////////////////////////////////////////////////
--
--	BattlePetCageMatch
--	Author: SLOKnightfall
--	BattlePetCageMatch: Scans bags and puts icons on the Pet Journal for any pet that is currently caged
--
--	///////////////////////////////////////////////////////////////////////////////////////////

local BPCM = select(2, ...)
BPCM.TSM = {}
local addonName, addon = ...
_G["BPCM"] = BPCM
BPCM = LibStub("AceAddon-3.0"):NewAddon(addon,"BattlePetCageMatch", "AceEvent-3.0", "AceConsole-3.0", "AceHook-3.0")
BPCM.Frame = LibStub("AceGUI-3.0")
BPCM.DataBroker = LibStub( "LibDataBroker-1.1" )
BPCM.bagResults = {}

local globalPetList = {}
local playerInv_DB
local Profile
local playerNme
local realmName

local L = LibStub("AceLocale-3.0"):GetLocale("BattlePetCageMatch")

--Registers for LDB addons
LibStub("LibDataBroker-1.1"):NewDataObject(addonName, {
	type = "data source",
	text = addonName,
	--tooltip = L.AUTO_CAGE_TOOLTIP_1,
	icon = "Interface/ICONS/INV_Pet_PetTrap01",
	OnClick = function(self, button, down) 
		--if (button == "RightButton") then
		BPCM.Cage:ResetListCheck()
		--end
	end,
	OnTooltipShow = function(tooltip)
		if not tooltip or not tooltip.AddLine then return end
			tooltip:AddLine(L.AUTO_CAGE_TOOLTIP_1)
		end,
	})

local optionHandler = {}

-- ----------------------------------------------------------------------------
-- Config Handlers.
-- ----------------------------------------------------------------------------
function optionHandler:Setter(info, value)
	local option = info[#info]
	Profile[option] = value
end


function optionHandler:Getter(info)
	return Profile[info[#info]]
end

function optionHandler:TSMDisable(info)
	return not BPCM.TSM_LOADED
end

function optionHandler:ValidatePrice(info, value)
	local option = info[#info]
	local cleanValue = tonumber((string.match(value,"(%d*)")))
	--return tonumber(value) or 0
	if not cleanValue then
		return "Price Error"
	else 
		return true
	end
end

function optionHandler:ValidateTSMSource(info, value)
	local option = info[#info]
	local isValid, err = BPCM.TSM:ValidateCustomPrice(value)
	if not isValid then
		if option == "TSM_Custom" then
			Profile[option] = Profile[option] or "DBMarket"
		else 
			Profile[option] = Profile[option] or "DBMinBuyout"
		end
		return L.TSM_CUSTOM_ERROR:format(err)
	else
	--optionHandler:Setter(info, value)
		return true
	end	

end


function optionHandler:ValidateLevels(info, value)
	value = tonumber(value)
	local option = info[#info]
	if not tonumber(value) then 
		return "Error: Must Be Number"
	elseif value > 25  or  value < 1 then 
		return "Error: Must Be Number from 1 to 25"
	end

	if option == "Cage_Min_Level" and value > Profile.Cage_Max_Level then
		--info.handler:Setter(info, Profile.Cage_Max_Level)
		return "Error: Min Level above Max Level"
	elseif option == "Cage_Max_Level" and value < Profile.Cage_Min_Level then
		--Profile.Cage_Min_Level = Profile.Cage_Max_Level
		--info.handler:Setter(info, Profile.Cage_Min_Level)
	 	return "Error: Max Level below Min Level"
	else
		return true
	end
end


function optionHandler:SetCageRulesText()
	local source = (Profile.TSM_Use_Custom and Profile.TSM_Custom) or BPCM.PriceSources[Profile.TSM_Market] or "DBMarket"
	local price = (	Profile.Cage_Max_Price and L.CAGE_RULES_CUSTOM_PRICE:format(Profile.Cage_Max_Price_Value or "")) or (Profile.Cage_Custom_TSM_Price and L.CAGE_RULES_CUSTOM_TSM:format(source, Profile.Cage_Custom_TSM_Price_Value or "")) or ""
	local skip = L.CAGE_RULES_SKIP:format((Profile.Skip_Caged and L.CAGE_RULES_SKIP_CAGED..",") or "", (Profile.Skip_Auction and L.CAGE_RULES_SKIP_AUCTION.."," ) or "", ((Profile.Handle_PetBlackList and L.CAGE_RULES_SKIP_BLACKLIST)  or ""))
	local quality = L.CAGE_RULES_QUALITY:format((Profile.Cage_Quality[1] and _G["BATTLE_PET_BREED_QUALITY1"]..", ") or "",(Profile.Cage_Quality[2] and _G["BATTLE_PET_BREED_QUALITY2"]..", " ) or "", (Profile.Cage_Quality[3] and _G["BATTLE_PET_BREED_QUALITY3"]..", ") or "", (Profile.Cage_Quality[4] and _G["BATTLE_PET_BREED_QUALITY4"]) or "")
	return L.CAGE_RULES_INFO:format(Profile.Cage_Ammount, Profile.Cage_Min_Level ,Profile.Cage_Max_Level, price, Profile.Cage_Max_Quantity, ((Profile.Skip_Auction or Profile.Skip_Caged) and skip) or "", quality)
end

BPCM.SetCageRulesText = optionHandler.SetCageRulesText


--ACE3 Options Constuctor
local options = {
	name = "BattlePetCageMatch",
	handler = optionHandler,
	type = 'group',
	childGroups = "tab",
	inline = true,
	get = "Getter",
	set = "Setter",
	args = {
		settings={
			name = "Options",
			type = "group",
			--inline = true,
			order = 0,
			args={
				Options_Header = {
					order = 0,
					name = L.OPTIONS_HEADER,
					type = "header",
					width = "full",
				},
				Show_Cage_Button = {
					order = .9,
					name = L.OPTIONS_SHOW_BUTTON ,
					desc = L.OPTIONS_SHOW_BUTTON_TOOLTIP,
					type = "toggle",
					set = function(info,val) 
						Profile.Show_Cage_Button = val
						if C_AddOns.IsAddOnLoaded("Rematch") then BPCM.RematchCageButton:SetShown(Profile.Show_Cage_Button and not RematchSettings.Minimized) end
						BPCM.cageButton:SetShown(Profile.Show_Cage_Button) end,
					get = function(info) return Profile.Show_Cage_Button end,
					width = "full",
				},
				Tradeable = {
					order = 1,
					name = L.OPTIONS_TRADEABLE ,
					desc = L.OPTIONS_TRADEABLE_TOOLTIP,
					type = "toggle",
					width = "full",
				},

				GlobalList = {
					order = 2,
					name = L.OPTIONS_GLOBAL_LIST,
					desc = L.OPTIONS_GLOBAL_LIST_TOOLTIP,
					type = "toggle",
					width = "full"
				},
				Inv_Tooltips = {
					order = 3,
					name = L.OPTIONS_INV_TOOLTIPS,
					desc = nil,
					type = "toggle",
					width = "full"
				},
				Icon_Tooltips = {
					order = 3.1,
					name = L.OPTIONS_ICON_TOOLTIPS,
					desc = nil,
					type = "multiselect",
					set = function(info, key, value) Profile.Icon_Tooltips[key] = value end,
					get = function(info,key) return Profile.Icon_Tooltips[key] end,
					width = "full",
					values = {["cage"]= L.OPTIONS_ICON_TOOLTIPS_1, ["value"] = L.OPTIONS_ICON_TOOLTIPS_2, ["db"] = L.OPTIONS_ICON_TOOLTIPS_3},
				},
				Cage_Header = {
					order = 4,
					name = L.OPTIONS_CAGE_HEADER,
					type = "header",
					width = "full",
				},
				Cage_Confirm = {
					order = 4.9,
					name = L.OPTIONS_CAGE_CONFIRM,
					desc = nil,
					type = "toggle",
					width = "full"
				},
				Cage_Window = {
					order = 5,
					name = L.OPTIONS_CAGE_WINDOW,
					desc = nil,
					type = "toggle",
					width = "full"
				},
				Incomplete_List = {
					order = 5.3,
					name = L.OPTIONS_INCOMPLETE_LIST,
					desc = nil,
					type = "select",
					width = "double",
					values = {["new"] = L.OPTIONS_INCOMPLETE_LIST_1, ["old"] =L.OPTIONS_INCOMPLETE_LIST_2, ["prompt"] = L.OPTIONS_INCOMPLETE_LIST_3}
				},
				Linebreak_4 = {
					order = 5.4,
					name = "",
					desc = nil,
					type = "description",
					width = "normal",

				},
				Favorite_Only = {
					order = 6,
					name = L.OPTIONS_FAVORITE_LIST,
					desc = nil,
					type = "select",
					width = "normal",
					values = {["include"] = "Include in scan", ["ignore"] ="Ignore in scan", ["only"] = "Only scan favorites"}
				},
				Linebreak_1 = {
					order = 6.1,
					name = "",
					desc = nil,
					type = "description",
					width = "double",

				},
				Cage_Ammount = {
					order = 6.11,
					name = L.OPTIONS_CAGE_AMMOUNT,
					type = "select",
					type = "range",
					width = "double",
					min = 1,
					max = 3,
					step = 1,
				},
				Cage_Min_Level = {
					order = 6.2,
					name = L.OPTIONS_CAGE_MIN_LEVEL,
					desc = OPTIONS_CAGE_MIN_LEVEL_TOOLTIP,
					type = "input",
					width = "double",
					set = function(info,val) Profile.Cage_Min_Level = tonumber(val) end,
					get = function(info) return tostring(Profile.Cage_Min_Level) end,
					validate = "ValidateLevels",
				},
				Cage_Max_Level = {
					order = 7,
					name = L.OPTIONS_CAGE_MAX_LEVEL,
					desc = OPTIONS_CAGE_MAX_LEVEL_TOOLTIP,
					type = "input",
					width = "double",
					set = function(info,val) Profile.Cage_Max_Level = tonumber(val) end,
					get = function(info) return tostring(Profile.Cage_Max_Level) end,
					validate = "ValidateLevels",
				},
				Cage_Max_Quantity = {
					order = 8,
					name = L.OPTIONS_CAGE_MAX_QUANTITY,
					desc = L.OPTIONS_CAGE_MAX_QUANTITY_TOOLTIP,
					type = "range",
					width = "double",
					min = 1,
					max = 3,
					step = 1,
				},
				Cage_Quality = {
					order = 8.1,
					name = L.OPTIONS_CAGE_QUALITY,
					desc = nil,
					type = "multiselect",
					get = function(info, key) return Profile.Cage_Quality[key] end,
					set = function(info, key, value) Profile.Cage_Quality[key] = value end,
					width = "double",
					values = {[1] =  _G["BATTLE_PET_BREED_QUALITY1"], [2] =_G["BATTLE_PET_BREED_QUALITY2"], [3] = _G["BATTLE_PET_BREED_QUALITY3"], [4] = _G["BATTLE_PET_BREED_QUALITY4"]}
				},
				Skip_Caged = {
					order = 8.2,
					name = L.OPTIONS_SKIP_CAGED ,
					desc = nil,
					type = "toggle",
					width = "full"
				},
				Skip_Auction = {
					order = 9,
					name = L.OPTIONS_SKIP_AUCTION ,
					desc = nil,
					type = "toggle",
					disabled = "TSMDisable",
					width = "full"
				},
				Skip_Auction_Matching = {
					order = 9.5,
					name = L.OPTIONS_SKIP_AUCTION_MATCHING ,
					desc = nil,
					type = "toggle",
					disabled = function() return not Profile.Skip_Auction end,
					width = "full"
				},
				Cage_Max_Price = {
					order = 10,
					name = L.OPTIONS_CAGE_MAX_PRICE,
					desc = nil,
					type = "toggle",
					set = function(info,val) Profile.Cage_Max_Price = val; if (val and Profile.Cage_Custom_TSM_Price) then Profile.Cage_Custom_TSM_Price = false end; end,
					get = function(info) return Profile.Cage_Max_Price end,
					width = "double",
					disabled = "TSMDisable",
				},
				Cage_Max_Price_Value = {
					order = 11,
					name = L.OPTIONS_CAGE_MAX_PRICE_VALUE,
					desc = L.OPTIONS_CAGE_MAX_PRICE_VALUE_TOOLTIP ,
					type = "input",
					set = function(info,val) Profile.Cage_Max_Price_Value = BPCM:CleanValues(val) end,
					get = function(info) return tostring(Profile.Cage_Max_Price_Value) end,
					validate = "ValidatePrice",
					width = "normal",
					disabled = "TSMDisable",
				},
				Cage_Custom_TSM_Price = {
					order = 11.1,
					name = L.OPTIONS_TSM_USE_CUSTOM.." (Requires TSM)",
					desc = L.OPTIONS_CAGE_CUSTOM_TOOLTIP,
					type = "toggle",
					set = function(info,val) Profile.Cage_Custom_TSM_Price = val; if (val and Profile.Cage_Max_Price) then Profile.Cage_Max_Price = false end;  end,
					get = function(info) return Profile.Cage_Custom_TSM_Price end,
					width = "double",
					disabled = "TSMDisable",
				},
				Cage_Show_Custom_TSM_Price = {
					order = 11.2,
					name = L.OPTIONS_SHOW_TSM_CUSTOM,
					desc = L.OPTIONS_SHOW_TSM_CUSTOM,
					type = "toggle",
					--width = "double",
					disabled = "TSMDisable",
				},
				Cage_Custom_TSM_Price_Value = {
					order = 11.3,
					name = L.OPTIONS_TSM_CUSTOM_CAGE,
					desc = L.OPTIONS_TSM_CUSTOM_CAGE,
					descStyle  = "inline",
					type = "input",
					--set = function(info,val) Profile.Cage_Custom_TSM_Price_Value = val end,
					--get = function(info) return Profile.Cage_Custom_TSM_Price_Value end,
					width = "full",
					disabled = "TSMDisable",
					validate = "ValidateTSMSource",
				},

				Caging_Rules = {
					order = 11.5,
					name = L.CAGE_RULES,
					desc = nil,
					type = "input",
					width = "full",
					get = "SetCageRulesText",
					disabled = true,
					multiline  = true,
				},
				Handle_PetWhiteList = {
					order = 12,
					name = L.OPTIONS_HANDLE_PETWHITELIST,
					desc = nil,
					type = "select",
					width = "normal",
					values = {["include"] = "Include after normal scan", ["only"] = "Only cage list", ["disable"] = "Do not use list"}
				},
				Linebreak_2 = {
					order = 12.1,
					name = "",
					desc = nil,
					type = "description",
					width = "double",

				},
				PetWhiteList = {
					type = "input",
					multiline = true,
					width = "double",
					name = L.OPTIONS_PETWHITELIST,
					desc = L.OPTIONS_WHITELLIST_TOOLTIP,
					order = 13,
					width = "full",
					get = function(info)
						return BPCM.WhiteListDB:ToString();
					end,
					set = function(info, value)
						local itemList = { strsplit("\n", value:trim()) };
						BPCM.WhiteListDB:Populate(itemList);
					end,
						},
				Handle_PetBlackList = {
					order = 13.1,
					name = L.OPTIONS_HANDLE_PETBLACKLIST,
					desc = L.OPTIONS_HANDLE_PETWHITELIST_TOOLTIP,
					type = "select",
					set = function(info,val) if val == 1 then Profile.Handle_PetBlackList = true; else Profile.Handle_PetBlackList = false end; end,
					get = function(info) if Profile.Handle_PetBlackList  then return 1; else return 2; end; end,
					width = "normal",
					values = {[1] = "On", [2] = "Off"}
				},
				Linebreak_3 = {
					order = 13.2,
					name = "",
					desc = nil,
					type = "description",
					width = "double",

				},
				PetBlackList = {
					type = "input",
					multiline = true,
					width = "double",
					name = L.OPTIONS_PETBLACKLIST,
					desc = L.OPTIONS_BLACKLIST_TOOLTIP,
					order = 14,
					width = "full",
					get = function(info)
						return BPCM.BlackListDB:ToString();
					end,
					set = function(info, value)
						local itemList = { strsplit("\n", value:trim()) };
						BPCM.BlackListDB:Populate(itemList);
					end,
						},

				TSM_Header = {
					order = 15,
					name = L.OPTIONS_TSM_HEADER,
					type = "header",
					width = "full",
				},
				TSM_Header_Text = {
					order = 16,
					name = "Requires TSM",
					type = "description",
					width = "full",
					--image = "Interface/ICONS/INV_Misc_Coin_17",
				},
				TSM_Value = {
					order = 17,
					name = L.OPTIONS_TSM_VALUE,
					desc = L.OPTIONS_TSM_VALUE_TOOLTIP,
					type = "toggle",
					width = "double",
					disabled = "TSMDisable",
				},
				TSM_Market = {
					order = 18,
					name = L.OPTIONS_TSM_DATASOURCE,
					--desc = "TSM Source to get price data.",
					type = "select",
					width = "normal",
					values = function() return BPCM:TSM_Source() end,
					disabled = "TSMDisable",
				},
				TSM_Use_Custom = {
					order = 18.1,
					name = L.OPTIONS_TSM_USE_CUSTOM,
					--desc = L.OPTIONS_TSM_FILTER_TOOLTIP,
					type = "toggle",
					width = "double",
					disabled = "TSMDisable",
				},
				TSM_Custom = {
					order = 18.2,
					name = L.OPTIONS_TSM_CUSTOM,
					desc = L.OPTIONS_TSM_CUSTOM_TOOLTIP,
					type = "input",
					--set = function(info,val) Profile.TSM_Custom = BPCM:TSM_CustomSource(val) end,
					--get = function(info) return Profile.TSM_Custom end,
					width = "full",
					disabled = "TSMDisable",
					validate = "ValidateTSMSource",
				},
				TSM_Filter = {
					order = 19,
					name = L.OPTIONS_TSM_FILTER,
					desc = L.OPTIONS_TSM_FILTER_TOOLTIP,
					type = "toggle",
					width = "normal",
					disabled = "TSMDisable",
				},

				TSM_Filter_Value = {
					order = 20,
					name = L.OPTIONS_CAGE_MAX_PRICE_VALUE,
					desc = L.OPTIONS_CAGE_MAX_PRICE_VALUE_TOOLTIP,
					type = "input",
					set = function(info,val) Profile.TSM_Filter_Value = BPCM:CleanValues(val) end,
					get = function(info) return tostring(Profile.TSM_Filter_Value) end,
					width = "normal",
					disabled = "TSMDisable",
				},
				TSM_Rank = {
					order = 21,
					name = L.OPTIONS_TSM_RANK,
					type = "toggle",
					width = "full",
					disabled = "TSMDisable",
				},
				TSM_Rank_Medium = {
					order = 22,
					name = L.OPTIONS_TSM_RANK_MEDIUM,
					type = "range",
					width = "normal",
					min = 1,
					max = 10,
					step = 1,
					isPercent = true,
					disabled = "TSMDisable",
				},
				TSM_Rank_High = {
					order = 23,
					name = L.OPTIONS_TSM_RANK_HIGH,
					type = "range",
					width = "normal",
					min = 1,
					max = 10,
					step = 1,
					isPercent = true,
					icon = "Interface/ICONS/INV_Misc_Coin_17",
					disabled = "TSMDisable",
				},
			},
		},

	},
}

--ACE Profile Saved Variables Defaults
local defaults = {
	profile ={
		Show_Cage_Button = true,
		No_Trade = true,
		TSM_Value = true,
		Other_Server = true,
		TSM_Filter = false,
		TSM_Filter_Value = 0,
		TSM_Market = "DBMarket",
		TSM_Use_Custom = false,
		TSM_Custom = "DBMarket",
		Cage_Custom_TSM_Price_Value = "DBMinBuyout",
		TSM_Rank = true,
		TSM_Rank_Medium = 2,
		TSM_Rank_High = 5,
		Inv_Tooltips = true,
		Icon_Tooltips = {["db"] = false,
				["value"] = false,
				["cage"] = false,},
		Cage_Window = true,
		Cage_Once = true,
		Cage_Ammount = 1, 
		Skip_Caged = true,
		Incomplete_List = "old",
		Skip_Auction = true,
		Favorite_Only = "include",
		Cage_Max_Level = 25,
		Cage_Min_Level = 1, 
		Cage_Max_Price = false,
		Cage_Max_Price_Value = 100,
		Cage_Max_Quantity = 1,
		Cage_Custom_TSM_Price = false,
		Handle_PetWhiteList = "include",
		Pet_Whitelist = {},
		Handle_PetBlackList = true,
		Pet_Blacklist = {},
		Cage_Confirm = false,
		Cage_Quality = {true, true, true, true},
		Cage_Show_Custom_TSM_Price = false,
		Skip_Auction_Matching = false,
	}
}


---Builds a list of saved data keyed by pet species id
function BPCM:BuildDBLookupList()
	globalPetList = globalPetList or {}
	for realm, realm_data in pairs(BattlePetCageMatch_Data) do
		for player, player_data in pairs(realm_data) do
			for pet, count in pairs(player_data) do
				globalPetList[pet] = globalPetList[pet] or {}
				globalPetList[pet][player.." - "..realm] = count
			end
		end
	end
end


--Removes any text from the option value fields to only leave numbers
function BPCM:CleanValues(value)
	value = (string.match(value,"(%d*)"))
	return tonumber(value) or 0
end


---Scans the players bags and logs any caged battle pets
function BPCM:BPScanBags()
	wipe(playerInv_DB)
	wipe(BPCM.bagResults)
	BPCM.bagResults = {}
	for t = 0  , 4 do
		local slots = C_Container.GetContainerNumSlots(t);
		if (slots > 0) then
			for c = 1, slots do
				local itemData = C_Container.GetContainerItemInfo(t,c)
				
				if (itemData and itemData.itemID == 82800) then
					local itemLink = itemData.hyperlink
					local _, _, _, _, speciesID,_ , _, _, _, _, _, _, _, _, cageName = string.find(itemLink, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
					--local recipeName = select(4, strsplit("|", link))
					--printable = gsub(itemLink, "\124", "\124\124");

					speciesID = tonumber(speciesID)
					BPCM.bagResults [speciesID]= BPCM.bagResults [speciesID] or {}
					BPCM.bagResults [speciesID]["count"] = (BPCM.bagResults [speciesID]["count"] or 0) + 1
					BPCM.bagResults [speciesID]["data"] = BPCM.bagResults [speciesID]["data"] or {}
					tinsert(BPCM.bagResults [speciesID]["data"],itemLink )

					playerInv_DB[speciesID] = BPCM.bagResults [speciesID]
				end
			end
		end
	end

	BPCM:BuildDBLookupList()
end


---Searches database for pet data
--Pram: PetID(num) - ID of the pet to look up
--Pram: Ignore(bool) - ignore data for current player
--Return:  string - String containing findings
function BPCM:SearchList(PetID, ignore)
	local string = nil
	if globalPetList[PetID] then
		for player, data in pairs(globalPetList[PetID])do

			if (playerNme.." - "..realmName == player) and ignore then
			else
				string = string or ""
				string = string..player..": "..data.count.."\n"-- - L: "
				--for _, itemLink in ipairs(data.data)do
					--local _, _, _, _, _,level  = string.find(itemLink, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
					--string= string..level..", \n"
				--end
			end
		end
	end
	return string
end


---Builds tooltip data
--Pram: frame - Name of frame to attach tooltip to
function BPCM:BuildToolTip(frame)
	local tooltip = nil

	local speciesID = (frame:GetParent()):GetParent().speciesID
	GameTooltip:SetOwner(frame, "ANCHOR_LEFT");

	if frame.display then
		tooltip = BPCM:SearchList(speciesID, true)
	end

	if BPCM.TSM_LOADED and (frame.petlink) then
		tooltip = BPCM:pricelookup(frame.petlink) or "N/A"  
	end

	if frame.cage then
		tooltip= "Inventory: "..(BPCM.bagResults[tonumber(speciesID)].count)
	end

	if frame.AH_Count then
		tooltip = "Player Auctions: "..frame.AH_Count
	end

	GameTooltip:SetText((tooltip or ""), nil, nil, nil, nil, true)
	GameTooltip:Show()	
end


---Builds tooltip data
--Pram: frame - Name of frame to attach tooltip to
function BPCM:BuildIconToolTip(frame)
	GameTooltip:SetOwner(frame, "ANCHOR_RIGHT");
	local tooltip_DB = nil
	local tooltip_Value = nil
	local tooltip_Cage = nil
	local tooltip = nil
	local tooltip_Auction
	
	local petlink = frame:GetParent().petlink 
	if Profile.Icon_Tooltips["db"]then
		tooltip_DB= BPCM:SearchList(frame:GetParent().speciesID,true) 
	end

	if BPCM.TSM_LOADED and Profile.Icon_Tooltips["value"] and (petlink) then
		tooltip_Value = BPCM:pricelookup(petlink) 
	end

	if BPCM.TSM_LOADED and Profile.Icon_Tooltips["value"] and (petlink) then
		tooltip_Value = BPCM:pricelookup(petlink) 
	end
	if Profile.Icon_Tooltips["cage"]  and frame:GetParent().speciesID then

		local inv = BPCM.bagResults[tonumber(frame:GetParent().speciesID)] or 0
		if inv == 0 then 
		else
			tooltip_Cage= "Inventory: "..(BPCM.bagResults[tonumber(frame:GetParent().speciesID)].count)
		end
	end

	if (tooltip_Cage or tooltip_Value or tooltip_DB) then
		GameTooltip:SetText((tooltip_Value or tooltip_Cage or tooltip_DB), nil, nil, nil, nil, true)
		GameTooltip:AddLine(((tooltip_Value and tooltip_Cage) or tooltip_DB), nil, nil, nil, nil, true)
		GameTooltip:AddLine((tooltip_Value and tooltip_DB), nil, nil, nil, nil, true)
	end

	GameTooltip:Show()
end


---Initilizes the buttons and creates the appropriate on click behaviour
--Pram: frame - frame that the checkbox should be added to
--Pram: index - index used to refrence the checkbox that is created created
--Return:  checkbox - the created checkbox frame
function BPCM:init_button(frame, index)
	local buttton = CreateFrame("Button", "CageMatch"..index, frame, "UICheckButtonTemplate")
	buttton:SetPoint("BOTTOMRIGHT")
	buttton.SpeciesID = 0
	buttton:SetScript("OnClick", function() end)
	buttton:SetScript("OnEnter", function (...) BPCM:BuildToolTip(buttton); end)
	buttton:SetScript("OnLeave", function() GameTooltip:Hide(); end)

	buttton:SetButtonState("NORMAL", true)
	buttton:SetWidth(20)
	buttton:SetHeight(20)
	return buttton
end


---Initilizes the buttons and creates the appropriate on click behaviour
--Pram: frame - frame that the checkbox should be added to
--Pram: index - index used to refrence the checkbox that is created created
--Return:  checkbox - the created checkbox frame
function BPCM:pricelookup(itemID)
	local tooltip
	local rank = 1
	local source = (Profile.TSM_Use_Custom and Profile.TSM_Custom) or BPCM.PriceSources[Profile.TSM_Market] or "DBMarket"
	local priceMarket = BPCM.TSM:GetCustomPriceValue(source, itemID) or 0 

	if Profile.TSM_Filter and (priceMarket <= (Profile.TSM_Filter_Value *100*100)) then
		return false
	elseif Profile.TSM_Filter and (priceMarket >= (Profile.TSM_Filter_Value *100*100) *Profile.TSM_Rank_High) then
		rank = 3
	elseif Profile.TSM_Filter and (priceMarket >= (Profile.TSM_Filter_Value *100*100) *Profile.TSM_Rank_Medium) then
		rank = 2
	end

	if priceMarket then
		tooltip = BPCM.TSM:MoneyToString(priceMarket)--("%dg %ds %dc"):format(priceMarket / 100 / 100, (priceMarket / 100) % 100, priceMarket % 100)
	else
		tooltip = "No Market Data"
	end

	return tooltip, rank
end

function BPCM:TSMAuctionLookup(pBattlePetID)
	if (not BPCM.TSM_LOADED) or (not Profile.Skip_Auction) then return 0 end
	local link = C_PetJournal.GetBattlePetLink(pBattlePetID)
	local TSM_String = TSM_API.ToItemString(link)
	return BPCM.TSM:GetAuctionQuantity(TSM_String)
end

local l
---Initilizes of data sources from TSM for the options dropdown
--Return:  sources - table of data sources available
function BPCM:TSM_Source()
	local sources
	if BPCM.TSM_LOADED  then
		sources = BPCM.TSM:GetPriceSources()
	else
		sources = {}
	end

	return sources
end


---Uses TSM's API to validate a custom price string to use instead of a stanard market source
function BPCM:TSM_CustomSource(price)
	local isValid, err = BPCM.TSM:ValidateCustomPrice(price)
	if not isValid then
		print(string.format(L.TSM_CUSTOM_ERROR, BPCM.TSM:GetInlineColor("link") .. price .. "|r", err))
	else
		return price
	end
end


function BPCM:PositionIcons(button)
	local Anchor = "BOTTOMRIGHT"
	local offset = 0

	if BPCM.PJE_LOADED and BPCM.REMATCH_LOADED and RematchPetPanel:IsVisible() then
		Anchor = "TOPRIGHT"
		offset = -5
	else 	
		Anchor = "BOTTOMRIGHT"
		offset = 0
	end

	if button.BP_Global.display then
		button.BP_Global:ClearAllPoints()
		button.BP_Global:SetPoint(Anchor,offset,offset)

		if button.BP_Value.display then 	
			button.BP_Value:ClearAllPoints()
			button.BP_Cage:ClearAllPoints()
			button.BP_Value:SetPoint("TOPRIGHT", button.BP_Global, "TOPLEFT")
			button.BP_Cage:SetPoint("TOPRIGHT", button.BP_Value, "TOPLEFT")
		else
			button.BP_Cage:ClearAllPoints();
			button.BP_Cage:SetPoint("TOPRIGHT", button.BP_Global, "TOPLEFT")
		end

	else
		if button.BP_Value.display then 
			button.BP_Value:ClearAllPoints()
			button.BP_Value:SetPoint(Anchor,offset,offset)
			button.BP_Cage:ClearAllPoints();
			button.BP_Cage:SetPoint("TOPRIGHT", button.BP_Value, "TOPLEFT")
		else
			button.BP_Cage:ClearAllPoints()
			button.BP_Cage:SetPoint(Anchor,offset,offset)
		end

	end

	if button.BP_Auction.display then
		button.BP_Auction:ClearAllPoints()
		if button.BP_Cage:IsShown() then 
			button.BP_Auction:SetPoint("TOPRIGHT", button.BP_Cage, "TOPLEFT")
		elseif button.BP_Value:IsShown() then
			button.BP_Auction:SetPoint("TOPRIGHT", button.BP_Value, "TOPLEFT")
		elseif button.BP_Global:IsShown() then
			button.BP_Auction:SetPoint("TOPRIGHT", button.BP_Global, "TOPLEFT")
		else
			button.BP_Auction:SetPoint(Anchor,offset,offset)
		end
	end
end


local function SetCageIcon(button, speciesID)
	button.BP_Cage:Hide()
	--button.petlink = "p:"..speciesID..":1:3"
	button.speciesID = speciesID

	if BPCM.bagResults [speciesID] then
		button.BP_Cage.icon:SetTexture("Interface/ICONS/INV_Pet_PetTrap01")
		button.BP_Cage.cage = true;
		button.BP_Cage.speciesID = speciesID
		button.BP_Cage:Show()
	else
		button.BP_Cage:Hide()
	end
end


local function SetTSMValue(button, speciesID)
	z= (button:GetParent()):GetParent()
	if BPCM.TSM_LOADED and Profile.TSM_Value then
		--button.BP_Value.petlink = "p:"..speciesID..":1:3"
		button.BP_Value.petlink = (button:GetParent()):GetParent().BP_InfoFrame.petlink
		local pass, rank = BPCM:pricelookup(button.BP_Value.petlink)

		if Profile.TSM_Filter and not pass then
			button.BP_Value:Hide()
			button.BP_Value.display = false

		else
			if Profile.TSM_Rank and rank == 2 then
				button.BP_Value.icon:SetTexture("Interface/ICONS/INV_Misc_Coin_18")
				elseif Profile.TSM_Rank and  rank == 3 then
				button.BP_Value.icon:SetTexture("Interface/ICONS/INV_Misc_Coin_17")
			else
				button.BP_Value.icon:SetTexture("Interface/ICONS/INV_Misc_Coin_19")
			end

			button.BP_Value.display = true
			button.BP_Value:Show()
		end

	else
		button.BP_Value:Hide()
		button.BP_Value.display = false
	end
end

function BPCM:GetItemString(item)
	if not item then return "" end
	local result = strmatch(item, "^\124cff[0-9a-z]+\124[Hh](.+)\124h%[.+%]\124h\124r$")
	result = strjoin(":", strmatch(result, "^battle(p)et:(%d+:%d+:%d+)"))

	if result then
		local num = 1
		while num > 0 do
			result, num = gsub(result, ":0?$", "")
		end

		return strmatch(result, "^(p:%d+:%d+:%d+)$") or strmatch(result, "^(p:%d+:i%d+)$") or strmatch(result, "^(p:%d+)")
	end
	
end


local UpdateButton
---Updates the icons on Pet Journal to tag caged pets
 function BPCM:UpdatePetList_Icons()
 	if not PetJournal:IsVisible() or (Rematch and RematchFrame:IsVisible()) then return end

	--[[local scrollFrame = (Rematch and RematchPetPanel:IsVisible() and RematchPetPanel)
			or (PetJournalEnhanced and PetJournalEnhancedListScrollFrame:IsVisible() and PetJournalEnhancedListScrollFrame)
			or (PetJournalListScrollFrame)
			]]--
	local scrollFrame = PetJournal.ScrollBox

	local roster = Rematch and Rematch.Roster
	local offset = scrollFrame:GetDerivedScrollOffset()
	local buttons = scrollFrame:GetScrollTarget()
	local numPets = C_PetJournal.GetNumPets()
	local showPets = true
	
	if  ( numPets < 1 ) then return end  --If there are no Pets then nothing needs to be done.

	--local numDisplayedPets = (Rematch and RematchPetPanel:IsVisible() and  #roster.petList)
		--or (PetJournalEnhanced and PetJournalEnhancedListScrollFrame:IsVisible() and BPCM.Sorting and BPCM.Sorting:GetNumPets())
		--or C_PetJournal.GetNumPets()

	local numDisplayedPets = (PetJournalEnhanced and PetJournalEnhancedListScrollFrame:IsVisible() and BPCM.Sorting and BPCM.Sorting:GetNumPets())
		or C_PetJournal.GetNumPets()

		for index, button in PetJournal.ScrollBox:EnumerateFrames() do
		local displayIndex = index --+ offset
		--local button_name = button:GetName()
		local pet_icon_frame = button.dragButton --(Rematch and _G[button_name].Pet) or button.dragButton
		if ( displayIndex <= numDisplayedPets ) then
--[[
			local index = (Rematch and RematchPetPanel:IsVisible() and displayIndex)
			or (PetJournalEnhanced and PetJournalEnhancedListScrollFrame:IsVisible() and BPCM.Sorting and BPCM.Sorting:GetPetByIndex(displayIndex)["index"])
			or displayIndex

			local speciesID, level, petName, tradeable
			local petID = (Rematch and RematchPetPanel:IsVisible() and roster.petList[index]) or nil
			local idType = (Rematch and RematchPetPanel:IsVisible() and Rematch:GetIDType(petID)) or nil

			--Get data from proper indexes based on addon loaded and visable
			if Rematch and RematchPetPanel:IsVisible() and idType=="pet" then -- this is an owned pet
				speciesID, _, level, _, _, _, _, petName, _, petType, _, _, _, _, _, tradeable = C_PetJournal.GetPetInfoByPetID(petID)

			elseif Rematch and RematchPetPanel:IsVisible() and idType=="species" then -- speciesID for unowned pets
				speciesID = petID
				petName, _, _, _, _, _, _, _, tradeable = C_PetJournal.GetPetInfoBySpeciesID(petID)
			else
				petID,speciesID,_,_,level,_,_,petName,_,_,_,_,_,_,_,tradeable =  C_PetJournal.GetPetInfoByIndex(index)
			end
]]--

			local speciesID, level, petName, tradeable
			petID,speciesID,_,_,level,_,_,petName,_,_,_,_,_,_,_,tradeable =  C_PetJournal.GetPetInfoByIndex(button.index)

			if  button.BP_InfoFrame then
			else
				pet_icon_frame:SetScript("OnEnter", function (...) BPCM:BuildIconToolTip(pet_icon_frame); end)
				pet_icon_frame:SetScript("OnLeave", function() GameTooltip:Hide(); end)
				local frame = CreateFrame("Frame", "CageMatch"..index, button, "BPCM_ICON_TEMPLATE")
				frame:ClearAllPoints()
				frame:SetPoint("BOTTOMRIGHT", 0,0);
				frame.no_trade:ClearAllPoints()
				frame.no_trade:SetPoint("BOTTOMRIGHT", 0,0);
				button.BP_InfoFrame  = frame
			end

			local link = C_PetJournal.GetBattlePetLink(petID)
			button.BP_InfoFrame.speciesID = speciesID
			button.BP_InfoFrame.petlink = BPCM:GetItemString(link) -- "p:"..speciesID..":1:3"
			button.BP_InfoFrame.petID = petID


			if tradeable then
			--Set Cage icon info
				SetCageIcon(button.BP_InfoFrame.icons, speciesID)
				button.BP_InfoFrame.icons:Show()		
				button.BP_InfoFrame.no_trade:Hide()


				--Set Value icon info
				SetTSMValue(button.BP_InfoFrame.icons, speciesID)

				--Set Global icon info
				if BPCM:SearchList(speciesID,true) then
					button.BP_InfoFrame.icons.BP_Global:Show()
					button.BP_InfoFrame.icons.BP_Global.speciesID = speciesID
					button.BP_InfoFrame.icons.BP_Global.display = true
				else
					button.BP_InfoFrame.icons.BP_Global:Hide()
					button.BP_InfoFrame.icons.BP_Global.display = false
				end

				--Set Auction House info
					button.BP_InfoFrame.icons.BP_Auction:Show()
					local AH_Count = BPCM:TSMAuctionLookup(petID)
				if AH_Count > 0 then 
					button.BP_InfoFrame.icons.BP_Auction:Show()
					button.BP_InfoFrame.icons.BP_Auction.display = true
					button.BP_InfoFrame.icons.BP_Auction.AH_Count = AH_Count
					--print(speciesID)
				else
					button.BP_InfoFrame.icons.BP_Auction:Hide()
					button.BP_InfoFrame.icons.BP_Auction.display = false
					button.BP_InfoFrame.icons.BP_Auction.AH_Count = nil
				end

			else
				if Profile.No_Trade then
					button.BP_InfoFrame.no_trade:Show()
				else
					button.BP_InfoFrame.no_trade:Hide()

				end

				
				button.BP_InfoFrame.icons:Hide()
			end
			BPCM:PositionIcons(button.BP_InfoFrame.icons)
			--button.BPCM:Show()




		else
			button.BP_InfoFrame.icons.BP_Cage:Hide()
			button.BP_InfoFrame.icons.BP_Value:Hide()
			button.BP_InfoFrame.icons.BP_Global:Hide()
			button.BP_InfoFrame.icons.BP_Auction:Hide()

			button.BP_InfoFrame.icons.BP_Value.display = false
			button.BP_InfoFrame.icons.BP_Global.display = false
			button.BP_InfoFrame.icons.BP_Auction.display = false

			button.BP_InfoFrame:Hide()
		end

	
	end
end


function BPCM:UpdateButtons()
	if BPCM.REMATCH_LOADED  and RematchToolbar:IsVisible() then
		BPCM.cageButton:SetParent("RematchToolbar")
		BPCM.cageButton:SetPointSetPoint("LEFT", RematchToolbar.PetCount, "RIGHT", 25, 0)
		BPCM.cageButton:SetWidth(20)
		BPCM.cageButton:SetHeight(20)
	else
		BPCM.cageButton:SetParent("PetJournal")
		BPCM.cageButton:SetPoint("RIGHT", PetJournalFindBattle, "LEFT", 0, 0)

		BPCM.cageButton:SetWidth(20)
		BPCM.cageButton:SetHeight(20)
	end
end


function BPCM:BattlePetTooltip_Show(self, speciesID)
	local ownedText = self.Owned:GetText() or "" -- C_PetJournal.GetOwnedBattlePetString(species)
	local source = (Profile.Inv_Tooltips  and BPCM:SearchList(speciesID) ) or ""
	if source then
		local origHeight = self.Owned:GetHeight()
		self.Owned:SetWordWrap(true)
		self.Owned:SetText(ownedText .."|n" .. source)
		self:SetHeight(self:GetHeight() + self.Owned:GetHeight() - origHeight + 2)

		if self == FloatingBattlePetTooltip then
			self.Delimiter:SetPoint("TOPLEFT", self.Owned, "BOTTOMLEFT", -6, -2)
		end
	else
		self.Owned:SetWordWrap(false)

		if self == FloatingBattlePetTooltip then
			self.Delimiter:SetPoint("TOPLEFT", self.SpeedTexture, "BOTTOMLEFT", -6, -5)
		end
	end
end


local function UpdateData()
	BPCM:BPScanBags()
	BPCM:UpdatePetList_Icons()
end


---Updates Profile after changes
function BPCM:RefreshConfig()
	BPCM.Profile = self.db.profile
	Profile = BPCM.Profile
end

local Patrons = {
	name = "Patrons |TInterface/Addons/BattlePetCageMatch/Images/Patreon:12:12|t",
	handler = optionHandler,
	get = "Getter",
	set = "Setter",
	type = 'group',
	childGroups = "tab",
	inline = false,
	args = {
			Patronss_Label = {
				order = 1,
				name = function() return addonName .. ' is distributed for free and supported trough donations. A massive thank you to all the supporters on Patreon and Paypal who keep development alive. You can become a patron too at |cFFF96854patreon.com/SLOKnightfall|r.\n\n\n', 'https://www.patreon.com/SLOKnightfall' end,
				type = "description",
				width = "full",

			},
			Patronss_Header = {
				order = 2,
				name = "Patrons",
				type = "header",
				width = "full",
			},
			
		},
}
	
local function addPatrons()
	for i, namex in ipairs(addon.Patrons) do
		Patrons.args["name"..i] = {
				order = i + 2,
				name = namex,
				type = "description",
				width = ".3",
			}
	end
end


---Ace based addon initilization
function BPCM:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("BattlePetCageMatch_Options", defaults, true)
	options.args.profiles  = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	LibStub("AceConfigRegistry-3.0"):ValidateOptionsTable(options, "BattlePetCageMatch")
	LibStub("AceConfig-3.0"):RegisterOptionsTable("BattlePetCageMatch", options)

	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("BattlePetCageMatch", "BattlePetCageMatch")
	self.db.RegisterCallback(BPCM, "OnProfileChanged", "RefreshConfig")
	self.db.RegisterCallback(BPCM, "OnProfileCopied", "RefreshConfig")
	self.db.RegisterCallback(BPCM, "OnProfileReset", "RefreshConfig")

	BattlePetCageMatch_Data = BattlePetCageMatch_Data or {}
	playerNme = UnitName("player")
	realmName = GetRealmName()
	BattlePetCageMatch_Data[realmName] = BattlePetCageMatch_Data[realmName]  or {}
	BattlePetCageMatch_Data[realmName][playerNme] =  BattlePetCageMatch_Data[realmName][playerNme] or {}
	playerInv_DB = BattlePetCageMatch_Data[realmName][playerNme]

	BPCM.Profile = self.db.profile
	Profile = BPCM.Profile
	if Profile.TSM_Custom == "" then Profile.TSM_Custom = "DBMarket" end
	if Profile.Cage_Custom_TSM_Price_Value == "" then Profile.Cage_Custom_TSM_Price_Value = "DBMinBuyout" end 

	BPCM.BlackListDB = BPCM.PetBlacklist:new()
	BPCM.WhiteListDB = BPCM.PetWhitelist:new()

	LibStub("AceConfig-3.0"):RegisterOptionsTable("BPCM_Patrons", Patrons)
	self.patrons = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("BPCM_Patrons", "Patrons |TInterface/Addons/BattlePetCageMatch/Images/Patreon:12:12|t","BattlePetCageMatch")

end

function BPCM:OnEnable()
	BPCM:RegisterEvent("AUCTION_HOUSE_CLOSED", UpdateData)
	BPCM:RegisterEvent("BANKFRAME_CLOSED", UpdateData)
	BPCM:RegisterEvent("GUILDBANKFRAME_CLOSED", UpdateData)
	BPCM:RegisterEvent("DELETE_ITEM_CONFIRM", UpdateData)
	BPCM:RegisterEvent("MERCHANT_CLOSED", UpdateData)
	BPCM:RegisterEvent("NEW_PET_ADDED", UpdateData)
	BPCM:RegisterEvent("PET_JOURNAL_PET_DELETED", UpdateData)
	BPCM:RegisterEvent("MAIL_CLOSED", UpdateData)

	--Hooking PetJournal functions
	C_AddOns.LoadAddOn("Blizzard_Collections")
	hooksecurefunc("PetJournal_UpdatePetList", UpdateData)
	hooksecurefunc(PetJournal.ScrollBox,"Update", function(...)BPCM:UpdatePetList_Icons(); end)
	hooksecurefunc("BattlePetToolTip_Show", function(species, level, quality, health, power, speed, customName)
		BPCM:BattlePetTooltip_Show(BattlePetTooltip, species)
	end)
----PetJournal.ScrollBox.ScrollTarget
	--PetJournalEnhanced hooks
	if C_AddOns.IsAddOnLoaded("PetJournalEnhanced") then
		hooksecurefunc(PetJournalEnhancedListScrollFrame,"update", function(...)BPCM:UpdatePetList_Icons(); end)
		 local PJE = LibStub("AceAddon-3.0"):GetAddon("PetJournalEnhanced")
		 BPCM.Sorting = PJE:GetModule(("Sorting"))
	end

	--Rematch hooks
	if C_AddOns.IsAddOnLoaded("Rematch") then
		--hooksecurefunc(Rematch,"FillCommonPetListButton", function(...)BPCM:UpdateRematch(...); end)
		--hooksecurefunc(RematchFrame,"ToggleSize", function(...) BPCM.RematchCageButton:SetShown(Profile.Show_Cage_Button and not RematchSettings.Minimized)end)
	end

	BPCM.TSM_LOADED =  C_AddOns.IsAddOnLoaded("TradeSkillMaster") --and IsAddOnLoaded("TradeSkillMaster_AuctionDB")
	BPCM.PJE_LOADED =  C_AddOns.IsAddOnLoaded("PetJournalEnhanced")
	BPCM.REMATCH_LOADED =  C_AddOns.IsAddOnLoaded("Rematch")
	addPatrons()
end

-- Binding Variables
BINDING_HEADER_BATTLEPETCAGEMATCH = "Battle Pet Cage Match"
BINDING_NAME_BPCM_AUTOCAGE = L.AUTO_CAGE_TOOLTIP_1
BINDING_NAME_BPCM_MOUSEOVER_CAGE = L.BPCM_MOUSEOVER_CAGE
_G["BINDING_NAME_CLICK BPCM_LearnButton:LeftButton"] = L.KEYBIND_LEARN


local recount_index = 1
function BPCM:UpdateRematch(button, petID)
--if not PetJournal:IsVisible() or RematchPetPanel:IsVisible() then return end
	local scrollFrame = (Rematch and RematchPetPanel:IsVisible() and RematchPetPanel)
						or (PetJournalEnhanced and PetJournalEnhancedListScrollFrame:IsVisible() and PetJournalEnhancedListScrollFrame)
						or (PetJournalListScrollFrame)

	local roster = Rematch and Rematch.Roster
	local button_name = button:GetName()

	local offset = HybridScrollFrame_GetOffset(scrollFrame)
	local buttons = scrollFrame.buttons
	local numPets = C_PetJournal.GetNumPets()
	local showPets = true
	
	local pet_icon_frame =  button.Pet
	local speciesID, level, petName, tradeable
	local idType = (Rematch and RematchPetPanel:IsVisible() and Rematch:GetIDType(petID)) or nil

	--Get data from proper indexes based on addon loaded and visable
	if Rematch and RematchPetPanel:IsVisible() and idType == "pet" then -- this is an owned pet
		speciesID, _, level, _, _, _, _, petName, _, petType, _, _, _, _, _, tradeable = C_PetJournal.GetPetInfoByPetID(petID)

	elseif Rematch and RematchPetPanel:IsVisible() and idType=="species" then -- speciesID for unowned pets
		speciesID = petID
		petName, _, _, _, _, _, _, _, tradeable = C_PetJournal.GetPetInfoBySpeciesID(petID)
	--else
		--petID,speciesID,_,_,level,_,_,petName,_,_,_,_,_,_,_,tradeable =  C_PetJournal.GetPetInfoByIndex(index)
	end

	if  button.BP_InfoFrame then
	else
		local frame = CreateFrame("Frame", "CageMatch_RC"..recount_index, button, "BPCM_ICON_TEMPLATE")
		local offset = (button.Breed:IsShown() and (0-button.Breed:GetStringWidth())-8) or 0
		frame:ClearAllPoints()
		frame:SetPoint("BOTTOMRIGHT", offset,0);
		frame.no_trade:ClearAllPoints()
		frame.no_trade:SetPoint("BOTTOMRIGHT", 0,0);
		button.BP_InfoFrame  = frame
	end

	local link = C_PetJournal.GetBattlePetLink(petID)
	button.BP_InfoFrame.speciesID = speciesID
	button.BP_InfoFrame.petlink = BPCM:GetItemString(link) -- "p:"..speciesID..":1:3"
	button.BP_InfoFrame.petID = petID


	if tradeable then
	--Set Cage icon info
		SetCageIcon(button.BP_InfoFrame.icons, speciesID)
		button.BP_InfoFrame.icons:Show()		
		button.BP_InfoFrame.no_trade:Hide()

		--Set Value icon info
		SetTSMValue(button.BP_InfoFrame.icons, speciesID)

		--Set Global icon info
		if BPCM:SearchList(speciesID,true) then
			button.BP_InfoFrame.icons.BP_Global:Show()
			button.BP_InfoFrame.icons.BP_Global.speciesID = speciesID
			button.BP_InfoFrame.icons.BP_Global.display = true
		else
			button.BP_InfoFrame.icons.BP_Global:Hide()
			button.BP_InfoFrame.icons.BP_Global.display = false
		end

	else
		if Profile.No_Trade then

			button.BP_InfoFrame.no_trade:Show()
		else
			--button.BP_InfoFrame.icons.BP_Cage:Hide()
			button.BP_InfoFrame.no_trade:Hide()
		end

		button.BP_InfoFrame.icons:Hide()
	end

	BPCM:PositionIcons(button.BP_InfoFrame.icons)
	--button.BPCM:Show()
end


--Support for TSM4
function BPCM.TSM:GetCustomPriceValue(source, itemID)
	return TSM_API.GetCustomPriceValue(source, itemID)
end

function BPCM.TSM:MoneyToString(priceMarket)
	return TSM_API.FormatMoneyString(priceMarket)
end


function BPCM.TSM:GetAuctionQuantity(pBattlePetID)
	return TSM_API.GetAuctionQuantity(pBattlePetID)
end


function BPCM.TSM:ValidateCustomPrice(price)
	return TSM_API.IsCustomPriceValid(price)
end


BPCM.PriceSources = {}
function BPCM.TSM:GetPriceSources()
	local table = {}
	wipe(BPCM.PriceSources)
	TSM_API.GetPriceSourceKeys(BPCM.PriceSources)
	return BPCM.PriceSources
end
