--	///////////////////////////////////////////////////////////////////////////////////////////
--
--	BattlePetCageMatch 
--	Author: SLOKnightfall

--	BattlePetCageMatch: Scans bags and puts icons on the Pet Journal for any pet that is currently caged
--

--	License: You are hereby authorized to freely modify and/or distribute all files of this add-on, in whole or in part,
--		providing that this header stays intact, and that you do not claim ownership of this Add-on.
--
--		Additionally, the original owner wishes to be notified by email if you make any improvements to this add-on.
--		Any positive alterations will be added to a future release, and any contributing authors will be
--		identified in the section above.
--
--
--
--	///////////////////////////////////////////////////////////////////////////////////////////

BPCM = LibStub("AceAddon-3.0"):NewAddon("BattlePetCageMatch", "AceEvent-3.0", "AceConsole-3.0", "AceHook-3.0")


local bagResults = {};
local globalPetList = {}
local playerInv_DB
local Profile
local playerNme 
local realmName

local TSM_LOADED =  IsAddOnLoaded("TradeSkillMaster") and IsAddOnLoaded("TradeSkillMaster_AuctionDB")


---Initilizes of data sources from TSM for the options dropdown
--Return:  sources - table of data sources available
local function TSM_Source()
	local sources
	if TSM_LOADED then 
		sources = TSMAPI:GetPriceSources()
	else
		sources = {}
	end

	return sources
end

--ACE3 Options Constuctor
local options = {
    name = "BattlePetCageMatch",
    handler = BattlePetCageMatch,
    type = 'group',
	args = {
		Options_Header = {
			order = 0,
			name = "Options",
			
			type = "header",
			--set = function(info,val) Profile.Other_Server = val end,
			--get = function(info) return Profile.Other_Server end,
			width = "full",
		},

		Tradeable = {
			order = 1,
			name = "Show Non-tradeable icon",
			desc = "Toggles a marker for pets tha can not be caged",
			type = "toggle",
			set = function(info,val) Profile.No_Trade = val end,
			get = function(info) return Profile.No_Trade end,
			width = "full",
		},


		GlobalList = {
			order = 2,
			name = "Flags cages on other Server",
			desc = "Shows/Hides the List icon on the Pet Journal when cages on other servers are in the DB.",
			type = "toggle",
			set = function(info,val) Profile.Other_Server = val end,
			get = function(info) return Profile.Other_Server end,
			width = "full"
		},
		Inv_Tooltips = {
			order = 2.1,
			name = "Add Inventory count to cage tooltip",
			desc = nil,
			type = "toggle",
			set = function(info,val) Profile.Inv_Tooltips = val end,
			get = function(info) return Profile.Inv_Tooltips end,
			width = "full"
		},
		TSM_Header = {
			order = 3,
			name = "TSM Data Options",
			desc = "Shows/Hides the Coin icon on the Pet Journal",
			type = "header",
			--set = function(info,val) Profile.Other_Server = val end,
			--get = function(info) return Profile.Other_Server end,
			width = "full",
		},
		TSM_Header_Text = {
			order = 3.1,
			name = "Requires TSM",
			type = "description",
			--set = function(info,val) Profile.Other_Server = val end,
			--get = function(info) return Profile.Other_Server end,
			width = "full",
			image = "Interface/ICONS/INV_Misc_Coin_17",
		},
		TSM_Value = {
			order = 4,
			name = "Show TSM  Data(Requires TSM)",
			desc = "Shows/Hides the Coin icon on the Pet Journal",
			type = "toggle",
			set = function(info,val) Profile.TSM_Value = val end,
			get = function(info) return Profile.TSM_Value end,
			width = "double",
		},
		TSM_Market = {
			order = 5,
			name = "TSM Source to Use",
			desc = "TSM Source to get price data.",
			type = "select",
			set = function(info,val) Profile.TSM_Market = val end,
			get = function(info) return Profile.TSM_Market end,
			width = "normal",
			values = function() return TSM_Source() end
		},
		TSM_Filter = {
			order = 6,
			name = "Filter based on price",
			desc = "Only puts Coin icon when the value is greater than the filter.",
			type = "toggle",
			set = function(info,val) Profile.TSM_Filter = val end,
			get = function(info) return Profile.TSM_Filter end,
			width = "normal"
		},

		TSM_Filter_Value = {
			order = 7,
			name = "Gold",
			desc = "Gold limit for the filter.",
			type = "input",
			set = function(info,val) Profile.TSM_Filter_Value = val end,
			get = function(info) return Profile.TSM_Filter_Value end,
			width = "normal"
		},

		TSM_Rank = {
			order = 8,
			name = "Value Based Icons",
			desc = "Toggles the minimap button.",
			type = "select",
			type = "toggle",
			set = function(info,val) Profile.TSM_Rank = val end,
			get = function(info) return Profile.TSM_Rank end,
			width = "full"
		},
		TSM_Rank_Medium = {
			order = 9,
			name = "Value Based Icons",
			desc = "Toggles the minimap button.",
			type = "select",
			type = "range",
			set = function(info,val) Profile.TSM_Rank_Medium = val end,
			get = function(info) return Profile.TSM_Rank_Medium end,
			width = "normal",
			min = 1,
			max = 10,
			step = 1,
			isPercent = true,
		},
		TSM_Rank_High = {
			order = 10,
			name = "Value Based Icons",
			desc = "Toggles the minimap button.",
			type = "select",
			type = "range",
			set = function(info,val) Profile.TSM_Rank_High = val end,
			get = function(info) return Profile.TSM_Rank_High end,
			width = "normal",
			min = 1,
			max = 10,
			step = 1,
			isPercent = true,
			icon = "Interface/ICONS/INV_Misc_Coin_17",
		},

	},
}

--Saved Variables Defaults
local defaults = {
	global ={
		No_Trade = true,
		TSM_Value = true,
		Other_Server = true,
		TSM_Filter = false,
		TSM_Filter_Value = 0,
		TSM_Market = 1,
		TSM_Rank = true,
		TSM_Rank_Medium = 2,
		TSM_Rank_High = 5,
		Inv_Tooltips = true,
	}
}



---Builds a list of saved data keyed by pet species id
function BuildDBLookupList()
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


---Scans the players bags and logs any caged battle pets
local function BPScanBags()
	wipe(playerInv_DB)
	wipe(bagResults)
	bagResults = {}
	for t=0,4 do
		local slots = GetContainerNumSlots(t);
		if (slots > 0) then
			for c=1,slots do
				local _,_,_,_,_,_,itemLink,_,_,itemID = GetContainerItemInfo(t,c)
		
				if (itemID == 82800) then
				local _, _, _, _, speciesID,_ , _, _, _, _, _, _, _, _, cageName = string.find(itemLink, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
				--local recipeName = select(4, strsplit("|", link))
				--printable = gsub(itemLink, "\124", "\124\124");

				speciesID = tonumber(speciesID)
				bagResults[speciesID]= bagResults[speciesID] or {}
				bagResults[speciesID]["count"] = (bagResults[speciesID]["count"] or 0) + 1
				bagResults[speciesID]["data"] = bagResults[speciesID]["data"] or {}
				tinsert(bagResults[speciesID]["data"],itemLink )
	
				playerInv_DB[speciesID] = bagResults[speciesID]
				end
			end
		end	
		
	end
	BuildDBLookupList()
end

---Searches database for pet data
--Pram: PetID(num) - ID of the pet to look up
--Pram: Ignore(bool) - ignore data for current player
--Return:  string - String containing findings
function SearchList(PetID, ignore)
	local string = nil
	if globalPetList[PetID] then
		for player, data in pairs(globalPetList[PetID])do

			if (playerNme.." - "..realmName == player) and ignore then 
			else
				string = string or ""
				string = string..player..": "..data.count.." - L: "
				for _, itemLink in ipairs(data.data)do
					local _, _, _, _, _,level  = string.find(itemLink, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
					string= string..level..", \n"
				end
			end
		end
	end
	return string
end


---Builds tooltip data
--Pram: frame - Name of frame to attach tooltip to 
function BuildToolTip(frame)
	GameTooltip:SetOwner(frame, "ANCHOR_LEFT");

	if frame.display then
		frame.tooltip = SearchList(frame.speciesID,true) or nil
	end

	if frame.petlink then
		frame.tooltip = pricelookup(frame.petlink) or nil
	end

	if frame.cage then

		frame.tooltip = "Inventory: "..bagResults[frame.speciesID].count.. "- L:"

		for _, itemLink in ipairs(bagResults[frame.speciesID].data)do
			local _, _, _, _, _,level  = string.find(itemLink, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
			frame.tooltip = frame.tooltip ..level..", "
		end
	end

	if frame.tooltip then 
		GameTooltip:SetText(frame.tooltip, nil, nil, nil, nil, true)
	end
end



---Initilizes the buttons and creates the appropriate on click behaviour
--Pram: frame - frame that the checkbox should be added to
--Pram: index - index used to refrence the checkbox that is created created
--Return:  checkbox - the created checkbox frame
local function init_button(frame, index)

	local checkbox = CreateFrame("Button", "CageMatch"..index, frame, "UICheckButtonTemplate")
	checkbox:SetPoint("BOTTOMRIGHT")
	checkbox.SpeciesID = 0
	checkbox:SetScript("OnClick", function() end)
	checkbox:SetScript("OnEnter", function (...) BuildToolTip(checkbox); end)
	checkbox:SetScript("OnLeave", function() GameTooltip:Hide(); end)

	checkbox:SetButtonState("NORMAL", true) 
	checkbox:SetWidth(20)
	checkbox:SetHeight(20)
	return checkbox
end


---Initilizes the buttons and creates the appropriate on click behaviour
--Pram: frame - frame that the checkbox should be added to
--Pram: index - index used to refrence the checkbox that is created created
--Return:  checkbox - the created checkbox frame
function pricelookup(itemID)
	local tooltip
	local rank = 1
	local source = Profile.TSM_Market or "DBMarket"
	local priceMarket = TSMAPI:GetCustomPriceValue(source, itemID)

	if Profile.TSM_Filter and (priceMarket <= (Profile.TSM_Filter_Value *100*100)) then 
		return false
	elseif Profile.TSM_Filter and (priceMarket >= (Profile.TSM_Filter_Value *100*100) *Profile.TSM_Rank_High) then
		rank = 3
	elseif Profile.TSM_Filter and (priceMarket >= (Profile.TSM_Filter_Value *100*100) *Profile.TSM_Rank_Medium) then
		rank = 2
	end
	
	if priceMarket then
		tooltip = ("%dg %ds %dc"):format(priceMarket / 100 / 100, (priceMarket / 100) % 100, priceMarket % 100)
	else
		tooltip = "No Market Data"
	end

	return tooltip, rank
end

---Updates the icons on Pet Journal to tag caged pets
 function UpdatePetList_Icons()
	local scrollFrame = PetJournalEnhancedListScrollFrame or PetJournalListScrollFrame
	local offset = HybridScrollFrame_GetOffset(scrollFrame)
	local buttons = scrollFrame.buttons
	local numPets = C_PetJournal.GetNumPets()
	local showPets = true
	if  ( numPets < 1 ) then return end  --If there are no Pets then nothing needs to be done.

	local numDisplayedPets = C_PetJournal.GetNumPets()
	for i=1, #buttons do
		local button = buttons[i]
		local displayIndex = i + offset
		if ( displayIndex <= numDisplayedPets and showPets ) then
			local index = displayIndex
			local petID,speciesID,_,_,level,_,_,petName,_,_,_,_,_,_,_,tradeable =  C_PetJournal.GetPetInfoByIndex(index)

			if  button.BP_Cage then
			else
				button.BP_Cage = init_button(button, i.."C")
				button.BP_Value = init_button(button, i.."V")
				button.BP_Value:SetNormalTexture("Interface/ICONS/INV_Misc_Coin_19")
				button.BP_Global= init_button(button, i.."G")
				button.BP_Global:SetNormalTexture("Interface/ICONS/INV_Misc_Note_04")
				button.BP_Value:ClearAllPoints();
				button.BP_Cage:ClearAllPoints();
				button.BP_Value:SetPoint("TOPRIGHT", button.BP_Global, "TOPLEFT");
				button.BP_Cage:SetPoint("TOPRIGHT", button.BP_Value, "TOPLEFT");
			end

			if tradeable then 
			--Set Cage icon info
				button.BP_Cage:Hide()
				if bagResults[speciesID] then 
					button.BP_Cage:SetNormalTexture("Interface/ICONS/INV_Pet_PetTrap01")
					button.BP_Cage.cage = true;
					button.BP_Cage.speciesID = speciesID
					button.BP_Cage:Show()
				end
				
				--Set Value icon ifno
				if TSM_LOADED and Profile.TSM_Value then
					button.BP_Value.petlink = "p:"..speciesID..":1:2"
					local pass, rank = pricelookup(button.BP_Value.petlink)

					if Profile.TSM_Filter and not pass then
						button.BP_Value:Hide()
					else
						if Profile.TSM_Rank and rank == 2 then
						button.BP_Value:SetNormalTexture("Interface/ICONS/INV_Misc_Coin_18")
						elseif Profile.TSM_Rank and  rank == 3 then
						button.BP_Value:SetNormalTexture("Interface/ICONS/INV_Misc_Coin_17")
						else
						button.BP_Value:SetNormalTexture("Interface/ICONS/INV_Misc_Coin_19")
						end
						button.BP_Value:Show()
					end
				else
					button.BP_Value:Hide()
				end

				--Set Global icon info
				if SearchList(speciesID,true) then
					button.BP_Global:Show()
					button.BP_Global.speciesID = speciesID
					button.BP_Global.display = true
				else
					button.BP_Global:Hide()
				end

			else
				button.BP_Cage:SetNormalTexture("Interface/Buttons/UI-GROUPLOOT-PASS-DOWN")
				button.BP_Cage:Show()
				button.BP_Cage.cage = false
				button.BP_Cage.tooltip = nil
				button.BP_Value.tooltip = nil
				button.BP_Value:Hide()
				button.BP_Value.petlink = nil
				button.BP_Global.speciesID = nil
				button.BP_Global:Hide()
			end
			--button.BPCM:Show()

		else
			button.BP_Cage:Hide()
			button.BP_Value:Hide()
			button.BP_Global:Hide()
		end
	end
end


local function BattlePetTooltip_Show(self, speciesID)
	local ownedText = self.Owned:GetText() or "" -- C_PetJournal.GetOwnedBattlePetString(species)
	local source = (Profile.Inv_Tooltips  and SearchList(speciesID) ) or ""
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
	BPScanBags()
	UpdatePetList_Icons()
end

---Ace based addon initilization
function BPCM:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("BattlePetCageMatch_Options", defaults, true)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("BattlePetCageMatch", options)
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("BattlePetCageMatch", "BattlePetCageMatch")

	BattlePetCageMatch_Data = BattlePetCageMatch_Data or {}
	playerNme = UnitName("player")
	realmName = GetRealmName()
	BattlePetCageMatch_Data[realmName] = BattlePetCageMatch_Data[realmName]  or {}
	BattlePetCageMatch_Data[realmName][playerNme] =  BattlePetCageMatch_Data[realmName][playerNme] or {}
	playerInv_DB = BattlePetCageMatch_Data[realmName][playerNme] 

	Profile = self.db.global 
end


function BPCM:OnEnable()
	BPCM:RegisterEvent("AUCTION_HOUSE_CLOSED", UpdateData)
	BPCM:RegisterEvent("BANKFRAME_CLOSED", UpdateData)
	BPCM:RegisterEvent("GUILDBANKFRAME_CLOSED", UpdateData)
	BPCM:RegisterEvent("DELETE_ITEM_CONFIRM", UpdateData)
	BPCM:RegisterEvent("MERCHANT_CLOSED", UpdateData)
	BPCM:RegisterEvent("COMPANION_LEARNED", UpdateData)
	BPCM:RegisterEvent("COMPANION_UNLEARNED", UpdateData)
	BPCM:RegisterEvent("MAIL_CLOSED", UpdateData)

	--Hooking PetJournal functions
	LoadAddOn("Blizzard_Collections")
	hooksecurefunc("PetJournal_UpdatePetList", UpdateData)
	hooksecurefunc(PetJournalListScrollFrame,"update", UpdatePetList_Icons)	
	hooksecurefunc("BattlePetToolTip_Show", function(species, level, quality, health, power, speed, customName)
		BattlePetTooltip_Show(BattlePetTooltip, species)
	end)
end