local BPCM = select(2, ...)
local Cage = BPCM:NewModule("BPCM", "AceEvent-3.0", "AceHook-3.0")
BPCM.Cage = Cage
BPCM.Learn_Click = false
local Profile = {}

local addonName, addon = ...
addon = LibStub("AceAddon-3.0"):GetAddon(addonName)

local L = LibStub("AceLocale-3.0"):GetLocale("BattlePetCageMatch")

local petsToCage = {}
local removeIndex = {}
local learn_queue = {}
local skipPetList = {}
local learnindex = nil
local skil_list = {}
local cageListButton
local LISTWINDOW


local function GetPriceSource()
	return  (Profile.TSM_Use_Custom and Profile.TSM_Custom) or BPCM.PriceSources[Profile.TSM_Market] or "DBMarket"
end


local function TSMPricelookup(pBattlePetID)
	if (not BPCM.TSM_LOADED) or (not Profile.Cage_Max_Price) then 
		--addon:Debug(("Not already caged: %s"):format(tostring(value)), 2)
		return true 
	end

	local source = GetPriceSource()
	if Profile.Cage_Max_Price_Value == ""  or not Profile.Cage_Max_Price_Value then Profile.Cage_Max_Price_Value = 0 end
	return (BPCM.TSM:GetCustomPriceValue(source, "p:"..pBattlePetID) or 0) >= (Profile.Cage_Max_Price_Value *100*100)
end


local function TSMCustomPricelookup(pBattlePetID)
	if (not BPCM.TSM_LOADED) or (not Profile.Cage_Custom_TSM_Price) then return true end
	if Profile.Cage_Custom_TSM_Price_Value == "" or not Profile.Cage_Custom_TSM_Price_Value then print("No TSM Price Source Entered") return true end
	local source = GetPriceSource()
	local custom_value = (BPCM.TSM:GetCustomPriceValue(Profile.Cage_Custom_TSM_Price_Value, "p:"..pBattlePetID) or 0)
	return (BPCM.TSM:GetCustomPriceValue(source, "p:"..pBattlePetID) or 0) >= custom_value
end


local function TSMAuctionLookup(pGuid, pBattlePetID)
	if (not BPCM.TSM_LOADED) or (not Profile.Skip_Auction) then return true end

	if Profile.Skip_Auction and Profile.Skip_Auction_Matching then
		local link = C_PetJournal.GetBattlePetLink(pGuid)
		local TSM_String = TSM_API.ToItemString(link)
		return BPCM.TSM:GetAuctionQuantity(TSM_String) == 0 
	else 
		local link = C_PetJournal.GetBattlePetLink(pGuid)
		return BPCM.TSM:GetAuctionQuantity("p:".. pBattlePetID) == 0 
	end
end


function Cage:Cage_Message(msg)
	--if Profile.Cage_Output then 
		DEFAULT_CHAT_FRAME:AddMessage("\124cffc79c6eCageing:\124r \124cff69ccf0" .. msg .."\124r")
	--end
end

local function CheckFavorite()


end

local function CheckSkipCaged(pBattlePetID)
	local value = (Profile.Skip_Caged and not BPCM.bagResults[pBattlePetID]) or (not Profile.Skip_Caged and true)
	addon:Debug(("Not already caged: %s"):format(tostring(value)), 2)
	return value
end

local function CheckBlackList(pName)
	local value = (Profile.Handle_PetBlackList and not BPCM.BlackListDB:FindIndex(pName)) or (not Profile.Handle_PetBlackList and true)
	addon:Debug(("Not on BlackList: %s"):format(tostring(value)), 2)
	return value
end


--Cycles through pet journal and creates a table of pets that match caging rules
function Cage:GeneratePetList()
	C_PetJournal.ClearSearchFilter() -- Clear filter so we have a full pet list.
	PetJournal.FilterDropdown:Reset()
	--PetJournalFilterDropDown_ResetFilters()
	addon:Debug("Clearing Search Filter", 1)
	--PetJournalFilterDropDown_SetCollectedFilter(true)
	--PetJournalFilterDropDown_SetNotCollectedFilter(false)
	PetJournalFilterDropdown_SetAllPetSources(true)
	PetJournalFilterDropdown_SetAllPetTypes(true)

	C_PetJournal.SetPetSortParameter(LE_SORT_BY_LEVEL) -- Sort by level, ensuring higher level pets are encountered first.
	addon:Debug("Sorting By Level", 1)
	
	local total, owned = C_PetJournal.GetNumPets()

	Cage:Cage_Message(format(L.BUILDING_CAGE_LIST, total))
	addon:Debug("Starting to generate cage list", 1)

	addon:Debug(("Owned Pets: %s"):format(owned), 1)
	local petCache = {}
	petsToCage = {}
	skipPetList = {}
	local petCageCount = {}

	if total == 0 then Cage:Cage_Message("No pets found due to filters") return end

	for index = 1, owned do -- Loop every pet owned (unowned will be over the offset).
		local pGuid, pBattlePetID, _, pNickname, pLevel, pIsFav, _, pName, _, _, _, _, _, _, _, pIsTradeable = C_PetJournal.GetPetInfoByIndex(index)
		if pGuid then
			local _, _, _, _, rarity = C_PetJournal.GetPetStats(pGuid)
			local isSlotted = C_PetJournal.PetIsSlotted(pGuid)
			local isHurt = C_PetJournal.PetIsHurt(pGuid)
			local canBeTraded = C_PetJournal.PetIsTradable(pGuid)

			if pBattlePetID and pIsTradeable and canBeTraded then 
				addon:Debug(("Checking status: %s"):format(pName), 1)

				if isSlotted then 
					Cage:Cage_Message(pName .. " :: " .. L.SLOTTED_PET_MESSAGE)
					addon:Debug(pName .. " :: " .. L.SLOTTED_PET_MESSAGE, 2)

				elseif isHurt then
					Cage:Cage_Message(pName .. " :: " .. L.HURT_PET_MESSAGE)
					addon:Debug(pName .. " :: " .. L.HURT_PET_MESSAGE, 2)

				elseif (Profile.Handle_PetBlackList and  BPCM.BlackListDB:FindIndex(pName)) then
					Cage:Cage_Message(pName .. " :: " .. L.CAGED_MESSAGE_BLACKLIST)
					addon:Debug(pName .. " :: " .. L.CAGED_MESSAGE_BLACKLIST, 2)

				else
					local numCollected = C_PetJournal.GetNumCollectedInfo(tonumber(pBattlePetID))
					petCache[pName] = ((pIsTradeable and pGuid and canBeTraded) and pGuid) or nil
					petCageCount[pBattlePetID] = petCageCount[pBattlePetID] or 1

					if ((pIsFav and (Profile.Favorite_Only == "include" or Profile.Favorite_Only == "only")) or (not pIsFav and (Profile.Favorite_Only == "include" or Profile.Favorite_Only == "ignore")))
					--and (tonumber(pLevel) <= tonumber(Profile.Cage_Max_Level))
					and numCollected >= Profile.Cage_Max_Quantity
					--and not isSlotted
					and CheckSkipCaged(pBattlePetID)
					and CheckBlackList(pName)
					--and ((Profile.Handle_PetWhiteList == "only" and BPCM.WhiteListDB:FindIndex(pName)) or ((Profile.Handle_PetWhiteList == "include"  or Profile.Handle_PetWhiteList == "disable" ) and true))
					and ((Profile.Handle_PetWhiteList == "only" and false) or ((Profile.Handle_PetWhiteList == "include"  or Profile.Handle_PetWhiteList == "disable" ) and true))
					--and ((Profile.Cage_Once and not petCache[pBattlePetID] ) or (not Profile.Cage_Once  and true))
					and TSMPricelookup(pBattlePetID) 
					and TSMCustomPricelookup(pBattlePetID)
					and TSMAuctionLookup(pGuid,pBattlePetID) 
					and (rarity and Profile.Cage_Quality[rarity]) then

						--Checks to make sure that min max are valid.  tried to do when setting sliders but had issues due to 
						--if Profile.Cage_Min_Level > Profile.Cage_Max_Level then
							--Profile.Cage_Max_Level = Profile.Cage_Min_Level							
						--elseif Profile.Cage_Min_Level > Profile.Cage_Max_Level then 
						--	Profile.Cage_Min_Level = Profile.Cage_Max_Level
						--end

						if (tonumber(pLevel) >= tonumber(Profile.Cage_Min_Level)) 
							and (tonumber(pLevel) <= tonumber(Profile.Cage_Max_Level)) 
							and (petCageCount[pBattlePetID] <= Profile.Cage_Ammount) then  --Breaks if included in previous if statement
							addon:Debug(("%s added to queue"):format(pName), 1)

							--Cage:Cage_Message(pName .. " :: " .. L.CAGED_MESSAGE)
							table.insert(petsToCage, pGuid)
							petCache[pBattlePetID] = true
							petCageCount[pBattlePetID] = petCageCount[pBattlePetID] + 1
						end
					end
				end
			end
		end
	end

	if (Profile.Handle_PetWhiteList == "include" or Profile.Handle_PetWhiteList == "only") then 
		for pName, pGuid in pairs(petCache) do
			if type(pName)== "string" and BPCM.WhiteListDB:FindIndex(pName) then
				Cage:Cage_Message(pName .. " :: " .. L.CAGED_MESSAGE_WHITELIST)
				table.insert(petsToCage, pGuid)
			end
		end
	end

	Cage:Cage_Message(#petsToCage .. " Pets to Cage")
	addon:Debug(#petsToCage .. " Pets to Cage",1)

	if #petsToCage > 0  then 
		BPCM.eventFrame.petIndex = 1
		if Profile.Cage_Window then 
			BPCM:GenerateListView()
		else
			Cage:StartCageing(BPCM.eventFrame.petIndex)
		end
	else
		Cage:Cage_Message(L.NO_PETS_TO_CAGE)
	end
end


---Initializes the caging process
function Cage:StartCageing(index)
	if not Cage:inventorySpaceCheck() then
		BPCM.eventFrame.pendingUpdate = false
		Cage:Cage_Message(L.FULL_INVENTORY)
		addon:Debug(L.FULL_INVENTORY ,1)

		return false
	end

	if Profile.Cage_Window then 
		cageListButton:SetText(L.STOP_CAGING_DIALOG_TEXT)
		cageListButton:SetCallback("OnClick", function() 	
			if BPCM.eventFrame.pendingUpdate == true then
				BPCM.eventFrame.pendingUpdate = false
				StaticPopup_Show("BPCM_STOP_CAGING")
				return
			end 
		end)
	end

	if skipPetList[petsToCage[index]] then
		removeIndex[index] = true
		BPCM.eventFrame.petIndex = index + 1
		Cage:StartCageing(BPCM.eventFrame.petIndex)

	else
		--The Cagepet function is delayed slightly so the game does not get overloaded
		C_Timer.NewTimer(.25, function()C_PetJournal.CagePetByID(petsToCage[index]) end)
			BPCM.eventFrame.petIndex = index + 1
			BPCM.eventFrame.pendingUpdate = true
			return true
		end
end


--Verifies that there is free bag space
function Cage:inventorySpaceCheck()
	local free=0
	for bag = 0,NUM_BAG_SLOTS do
		local bagFree, bagFam = C_Container.GetContainerNumFreeSlots(bag)
		if bagFam == 0 then
			free = free + bagFree
		end
	end
	
	if free == 0 then 
		return false
	else
		return true
	end
end


--The auto caging has to be haneled by an event.  Trying to use an loop overwhelms the game and only a few pets are caged.
--The frame watches for any time a pet is caged and then tries to cage a new pet after a short delay, which then triggers 
-- the next pet on the list being caged untill no pets are in the list.  

-- Event handling frame.
local eventFrame = CreateFrame("Button", "BPCM_LearnButton", UIParent, "SecureActionButtonTemplate")
--local eventFrame = CreateFrame("FRAME")
BPCM.eventFrame  = eventFrame
eventFrame.pendingUpdate = false
eventFrame.petIndex = nil
eventFrame:RegisterEvent("PET_JOURNAL_PET_DELETED")
eventFrame:RegisterEvent("UI_ERROR_MESSAGE")
eventFrame:RegisterEvent("BAG_UPDATE")
eventFrame:RegisterEvent("NEW_PET_ADDED")
eventFrame:SetScript("OnEvent", function(self, event, ...)
	if InCombatLockdown() then return end
	if event == "PET_JOURNAL_PET_DELETED" then
		local index = eventFrame.petIndex or 2
		if self.pendingUpdate then
	
			if index > #petsToCage then
				self.pendingUpdate = false
				eventFrame.petIndex = nil
				petsToCage = {}
				removeIndex = {}
				Cage:Cage_Message(L.CAGE_COMPLETE)
			else
				Cage:StartCageing(index)
			end
		end
	elseif (event == "BAG_UPDATE") then
		BPCM.Create_Learn_Queue()

	elseif (event == "UI_ERROR_MESSAGE" and select(2,...) == SPELL_FAILED_CANT_ADD_BATTLE_PET )or event == "NEW_PET_ADDED" then
		if BPCM.Learn_Click then
			if not learnindex then
				BPCM.Create_Learn_Queue()
			else
				learnindex = learnindex + 1
				Cage:Update_Learn_Queue_Macro()
			end
		end
		BPCM.Learn_Click = false
	end
end);
eventFrame:SetAttribute("type1", "macro") -- left click causes macro		
--eventFrame:SetAttribute("macrotext1","/run BPCM.Create_Learn_Queue();\n/run BPCM.Learn_Click = true;") -- text for macro on left click
eventFrame:SetAttribute("macrotext1","/use pet cage;\n/run BPCM.Learn_Click = true;") -- text for macro on left click
eventFrame:RegisterForClicks("LeftButtonDown")

--Virtual Button to attach the Learn Keybinding to
--local learnbutton = CreateFrame("Button", "BPCM_LearnButton", UIParent, "SecureActionButtonTemplate")
--learnbutton:SetAttribute("type1", "macro") -- left click causes macro		
--learnbutton:SetAttribute("macrotext1","/run BPCM.Create_Learn_Queue()") -- text for macro on left click
function Cage:CreateButton(parent)
	local cageButton = CreateFrame("Button", "BPCM_CageButton_"..parent, PetJournal)
	cageButton:SetNormalTexture("Interface/ICONS/INV_Pet_PetTrap01")
	cageButton:SetPoint("RIGHT", PetJournalFindBattle, "LEFT", 0, 0)
	cageButton:SetWidth(20)
	cageButton:SetHeight(20)
	cageButton:SetShown(Profile.Show_Cage_Button)
	cageButton:SetScript("OnClick", function(self, button, down) 
		local Shift = IsShiftKeyDown()
		if Shift then
			LibStub("AceConfigDialog-3.0"):Open("BattlePetCageMatch")
		else
			Cage:Controll()
		end
	end)
	cageButton:SetScript("OnEnter",
		function(self)
			GameTooltip:SetOwner (self, "ANCHOR_RIGHT")
			GameTooltip:SetText(L.AUTO_CAGE_TOOLTIP_1, 1, 1, 1)
			GameTooltip:AddLine(L.AUTO_CAGE_TOOLTIP_2, nil, nil, nil, true)
			GameTooltip:AddLine(L.AUTO_CAGE_TOOLTIP_3, nil, nil, nil, true)
			GameTooltip:Show()
		end
	)
	cageButton:SetScript("OnLeave",
		function()
			GameTooltip:Hide()
		end
	)
	return cageButton
end


function Cage:OnEnable()
	Profile = BPCM.Profile
	-- Add caging buttons to Pet Journal & Rematch
	BPCM.cageButton = Cage:CreateButton("PetJournal")
	
	if C_AddOns.IsAddOnLoaded("Rematch") then
		--BPCM.RematchCageButton = Cage:CreateButton("Rematch")
		--BPCM.RematchCageButton:SetParent(RematchToolbar)
		--BPCM.RematchCageButton:ClearAllPoints()
		--BPCM.RematchCageButton:SetPoint("LEFT", RematchToolbar.PetCount, "RIGHT", 5, 0)
		--BPCM.RematchCageButton:SetWidth(32)
		--BPCM.RematchCageButton:SetHeight(32)
		--BPCM.RematchCageButton:SetShown(true) --Profile.Show_Cage_Button and not RematchSettings.Minimized)
	end
end

--Dialog Box for user decided handeling of an existing cage list
StaticPopupDialogs["BPCM_CONTINUE_CAGING"] = {
	text = L.CONTINUE_CAGING_DIALOG_TEXT,
	button1 = L.CONTINUE_CAGING_DIALOG_YES,
	button2 = L.CONTINUE_CAGING_DIALOG_NO,
	OnAccept = function ()
		for index , pet in ipairs(petsToCage) do 
			if removeIndex[pet] then
				tremove(petsToCage, index)
			end
		end
		Cage:StartCageing(BPCM.eventFrame.petIndex)
		BPCM:GenerateListView()
	end,
	OnCancel = function (_,reason)
		Cage:GeneratePetList()
	end,
	enterClicksFirstButton= true,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}

--Dialog Box for user decided handeling of an existing cage list
StaticPopupDialogs["BPCM_STOP_CAGING"] = {
	text = L.STOP_CAGING_DIALOG_TEXT,
	button2 = L.CONTINUE_CAGING_DIALOG_YES,
	button1 = L.CONTINUE_CAGING_DIALOG_NO,
	OnCancel = function () 
		if LISTWINDOW then LISTWINDOW:Hide() end
	end,
	OnAccept = function (_,reason)
		Cage:StartCageing(BPCM.eventFrame.petIndex)
	end,
	OnShow = function(self) 
	    self:SetFrameLevel(20)
		self:SetFrameStrata("FULLSCREEN_DIALOG")
	end,
	enterClicksFirstButton = true,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}

--Dialog Box for user decided handeling of an existing cage list
StaticPopupDialogs["BPCM_START_CAGING"] = {
	text = L.START_CAGING_DIALOG_TEXT,
	button1 = L.CONTINUE_CAGING_DIALOG_YES,
	button2 = L.CONTINUE_CAGING_DIALOG_NO,
	OnAccept = function ()
		Cage:ResetListCheck()
	end,
	OnCancel = function (_,reason)	end,
	enterClicksFirstButton= true,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}


function Cage:Controll()
	--Allows stoping of an auto cage process
	if BPCM.eventFrame.pendingUpdate == true then
		BPCM.eventFrame.pendingUpdate = false
		StaticPopup_Show("BPCM_STOP_CAGING")
		return
	end

	if Profile.Cage_Confirm and not Profile.Cage_Window  then
		StaticPopup_Show("BPCM_START_CAGING")
	else
		Cage:ResetListCheck()
	end
end


--Determines how an existing cage list should be handled
function Cage:ResetListCheck()
	if #petsToCage > 0  and Profile.Incomplete_List == "prompt" then
		StaticPopup_Show("BPCM_CONTINUE_CAGING")
	elseif #petsToCage > 0  and Profile.Incomplete_List == "old" then
		Cage:StartCageing(BPCM.eventFrame.petIndex)
	else
		Cage:GeneratePetList()
	end
end


--Updates Button Macro to use cage based on bag & slot from cage list
function Cage:Update_Learn_Queue_Macro()
	if InCombatLockdown() then return end
	if learnindex <= #learn_queue then
		local macro = "/use "..learn_queue[learnindex][1].." "..learn_queue[learnindex][2]..";\n/run BPCM.Learn_Click = true;"
		BPCM_LearnButton:SetAttribute("macrotext1", macro)
	else 
		BPCM_LearnButton:SetAttribute("macrotext1","/use pet cage;\n/run BPCM.Learn_Click = true;") -- text for macro on left click
		--BPCM_LearnButton:SetAttribute("macrotext1","/run BPCM.Create_Learn_Queue();\n/run BPCM.Learn_Click = true;")
		learnindex = nil
		learn_queue = {}
	end
end


--Scans bags and creats a list the bag & slot positison for any found cages
function BPCM.Create_Learn_Queue()
	wipe(learn_queue)
	for t = 0 , 4 do 
		local slots = C_Container.GetContainerNumSlots(t)
		if (slots > 0) then
			for c = 1,slots do
				local itemData = C_Container.GetContainerItemInfo(t,c)
				
				if (itemData and itemData.itemID == 82800) then
					local itemLink = itemData.hyperlink
					local _, _, _, _, speciesId,_ , _, _, _, _, _, _, _, _, cageName = string.find(itemLink, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
					local speciesID = tonumber(speciesId)
					local numCollected, limit = C_PetJournal.GetNumCollectedInfo(speciesId)
					--only queue if can be learned
					if numCollected < limit then 
						tinsert(learn_queue, {t,c})
					else
						--print("Skipping ".. cageName..", max already learned")
					end
				end
			end
		end		
	end

	learnindex = 1
	Cage:Update_Learn_Queue_Macro()
end


--local pGuid, pBattlePetID, _, pNickname, pLevel, pIsFav, _, pName, _, _, _, _, _, _, _, pIsTradeable = C_PetJournal.GetPetInfoByIndex(index)
local AceGUI = LibStub("AceGUI-3.0")
function BPCM:GenerateListView()
	if LISTWINDOW then LISTWINDOW:Hide() end

	-- Create a container frame
	local f = AceGUI:Create("Window")
	f:SetCallback("OnClose",function(widget) AceGUI:Release(widget) end)
	f:SetTitle("Cageing List")
	f:SetStatusText("Status Bar")
	f:SetLayout("Flow")
	--f:SetAutoAdjustHeight(true)
	f:EnableResize(false)
	_G["BPCM_Cage_ListWindow"] = f.frame
	LISTWINDOW = f
	tinsert(UISpecialFrames, "BPCM_Cage_ListWindow")

	local scrollcontainer = AceGUI:Create("SimpleGroup")
	scrollcontainer:SetFullWidth(true)
	--scrollcontainer:SetFullHeight(true) -- probably?
	scrollcontainer:SetHeight(f.frame:GetHeight()-75)
	scrollcontainer:SetLayout("Fill") -- important!
	f:AddChild(scrollcontainer)

	local scroll = AceGUI:Create("ScrollFrame")
	scroll:SetLayout("Flow") -- probably?
	scroll:SetFullWidth(true)
	scroll:SetFullHeight(true) -- probably?
	scrollcontainer:AddChild(scroll)	

	local btn = AceGUI:Create("Button")
	btn:SetWidth(170)
	btn:SetHeight(25)
	btn:SetText(L.START_CAGING_DIALOG_TEXT)
	btn:SetCallback("OnClick", function() Cage:StartCageing(BPCM.eventFrame.petIndex) end)
	f:AddChild(btn)
	btn:ClearAllPoints()
	btn:SetPoint("BOTTOMRIGHT")
	cageListButton = btn


	local heading = AceGUI:Create("Label")
	heading:SetText(BPCM:SetCageRulesText())
	heading:SetFullWidth(true)
	scroll:AddChild(heading)

	local source = GetPriceSource()


	for i=BPCM.eventFrame.petIndex, #petsToCage do
		local petID = petsToCage[i]

		if type(petID) == "string" then 
			local speciesID, customName, level, xp, maxXp, displayID, isFavorite, name, icon, petType, creatureID, sourceText, description, isWild, canBattle, tradable, unique, obtainable = C_PetJournal.GetPetInfoByPetID(petID)
			if not skipPetList[petID] then 

				local CheckBox = AceGUI:Create("CheckBox")
				local priceText = ""
				local cageText = ""
				if BPCM.TSM_LOADED and speciesID and (Profile.Cage_Max_Price or Profile.Cage_Custom_TSM_Price) then 
					priceText =  L.LIST_DISPLAY_TEXT_PRICE:format(BPCM.TSM:MoneyToString(BPCM.TSM:GetCustomPriceValue(source, "p:"..speciesID) or 0 ))
					cageText = ((Profile.Cage_Custom_TSM_Price and Profile.Cage_Show_Custom_TSM_Price) and L.CAGE_RULES_PRICE_TO_CAGE:format(BPCM.TSM:MoneyToString(BPCM.TSM:GetCustomPriceValue(Profile.Cage_Custom_TSM_Price_Value, "p:"..speciesID) or 0 ))) or ""
				end

				CheckBox:SetLabel(L.LIST_DISPLAY_TEXT:format(C_PetJournal.GetBattlePetLink(petID), level, priceText, cageText ))
				CheckBox:SetValue(true)
				CheckBox:SetImage(icon)
				CheckBox:SetFullWidth(true)
				CheckBox:SetCallback("OnValueChanged", function(self, info, value) skipPetList[petID] = not value end)
				scroll:AddChild(CheckBox)
			end
		end
	end
end