--function CageMe()


-- TSMAPI.Inventory:GetAuctionQuantity(

--end

local BPCM = select(2, ...)
local Cage = BPCM:NewModule("BPCM", "AceEvent-3.0", "AceHook-3.0")
--local Profile = BPCM.db.global
local L = LibStub("AceLocale-3.0"):GetLocale("BattlePetCageMatch")

local petsToCage = {};

--local petCagedPattern = string.gsub(L.BATTLE_PET_NEW_PET, "%%s", ".*Hbattlepet:(%%d+).*");


local function TSMPricelookup(pBattlePetID)
	local Profile = BPCM.db.global


	if (not IsAddOnLoaded("TradeSkillMaster")) or (not Profile.Cage_Max_Price) then return true end

	return TSMAPI:GetCustomPriceValue(Profile.TSM_Market , "p:"..pBattlePetID..":1:2") >= (Profile.Cage_Max_Price_Value *100*100)

end

local function TSMAuctionLookup(pBattlePetID)
	local Profile = BPCM.db.global

	if (not IsAddOnLoaded("TradeSkillMaster")) or (not Profile.Skip_Auction) then return true end
	return TSMAPI.Inventory:GetAuctionQuantity("p:"..pBattlePetID..":1:2")==0 

end

function Cage.Cage_Message(msg)
	DEFAULT_CHAT_FRAME:AddMessage("\124cffc79c6eAutoCageing:\124r \124cff69ccf0" .. msg .."\124r");
end

function CageMe(petToCageID)
	local Profile = BPCM.db.global
	C_PetJournal.ClearSearchFilter(); -- Clear filter so we have a full pet list.
	C_PetJournal.SetPetSortParameter(LE_SORT_BY_LEVEL); -- Sort by level, ensuring higher level pets are encountered first.

	local total, owned = C_PetJournal.GetNumPets();
	local petCache = {};
	petsToCage = {};

	if petToCageID ~= nil then
		petToCageID = tonumber(petToCageID);
	end

	for index = 1, owned do -- Loop every pet owned (unowned will be over the offset).
		local pGuid, pBattlePetID, _, pNickname, pLevel, pIsFav, _, pName, _, _, _, _, _, _, _, pIsTradeable = C_PetJournal.GetPetInfoByIndex(index);
		local numCollected = C_PetJournal.GetNumCollectedInfo(pBattlePetID)


		--if petToCageID == nil or petToCageID == pBattlePetID then
				if ((pIsFav and (Profile.Favorite_Only == "include" or Profile.Favorite_Only == "only")) or (not pIsFav and (Profile.Favorite_Only == "include" or Profile.Favorite_Only == "ignore")))
				and pIsTradeable 
				--and (tonumber(pLevel) <= tonumber(Profile.Cage_Max_Level))
				and numCollected >= Profile.Cage_Max_Quantity
				and ((Profile.Skip_Caged and not BPCM.bagResults[pBattlePetID]) or (not Profile.Skip_Caged and true))
				and not petCache[pBattlePetID] 
				and TSMPricelookup(pBattlePetID) 
				and TSMAuctionLookup(pBattlePetID) then
					if (tonumber(pLevel) <= tonumber(Profile.Cage_Max_Level)) then  --Breaks if included in previous if statement
						Cage.Cage_Message(pName .. " :: " .. L.CAGED_MESSAGE);
						table.insert(petsToCage, pGuid);
						petCache[pBattlePetID] = true
					end
				end
			
		--end
	end
	print(#petsToCage)
end




--btn:SetAttribute("target-item", "1 1"); -- ("bag slot")
local learn_queue = {}
function learnme()
print(#learn_queue)
	if #learn_queue > 0 then
	--print(learn_queue[1])
	local t =learn_queue[1][1]
	local c = learn_queue[1][2]
	print(t)
	print(c)
	--BBBUUU:SetAttribute("target-item", t.." "..c); -- ("bag slot")

	macroBtn:Click()
		--UseContainerItem(t, c)
		table.remove(learn_queue,1)
	else

	for t=0,4 do 
		local slots = GetContainerNumSlots(t);
		--print(slots)
		if (slots > 0) then
			for c=1,slots do
				local _,_,_,_,_,_,itemLink,_,_,itemID = GetContainerItemInfo(t,c)
		--print(itemID)
				if (itemID == 82800) then
				local _, _, _, _, speciesID,_ , _, _, _, _, _, _, _, _, cageName = string.find(itemLink, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
				--local recipeName = select(4, strsplit("|", link))
				--printable = gsub(itemLink, "\124", "\124\124");
				print(t.."/"..c)

				local bag = {t,c}
				tinsert(learn_queue, bag)
	
				end
			end
		end	
		
	end

	end

end

--[[

local macro = "/run for t=0,4 do local slots = GetContainerNumSlots(t);if (slots > 0) then for c=1,slots do local _,_,_,_,_,_,itemLink,_,_,itemID = GetContainerItemInfo(t,c);	print(itemID);if (itemID == 82800) then UseItemByName(itemLink); end	end	end	end"

local button = CreateFrame("Button", "only_for_testing", UIParent, "SecureActionButtonTemplate")
        button:SetPoint("CENTER", mainframe, "CENTER", 0, 0)
        button:SetWidth(200)
        button:SetHeight(50)
        
        button:SetText("My Test")
        button:SetNormalFontObject("GameFontNormalSmall")

	button:SetNormalTexture("Interface/ICONS/INV_Pet_PetTrap01")
        
        button:SetNormalTexture("Interface/Buttons/UI-Panel-Button-Up")
        button:SetHighlightTexture("Interface/Buttons/UI-Panel-Button-Highlight")
       -- button:SetPushedTexture("Interface/Buttons/UI-Panel-Button-Down")
--button:SetAttribute("target-item", "0 1"); -- ("bag slot")
   --  button:SetScript("OnClick", function() learnme(); end)
     button:SetAttribute("type1", "macro") -- left click causes macro
button:SetAttribute("macrotext1", macro) -- text for macro on left click
]]--

function Cage:OnEnable()

 --cage_button = CreateFrame("Button", "only_for_testing", PetJournal, "SecureActionButtonTemplate")
	-- Add a caging button
local	cageButton = CreateFrame("Button", "AutoCage_CageButton", PetJournal, "MagicButtonTemplate");
	cageButton:SetNormalTexture("Interface/ICONS/INV_Pet_PetTrap01")
	cageButton:SetPoint("RIGHT", PetJournalFindBattle, "LEFT", 0, 0);
	--cageButton:SetPoint("LEFT", PetJournalSummonButton, "RIGHT", 0, 0);
--	cageButton:SetWidth(150);
	cageButton:SetWidth(20)
	cageButton:SetHeight(20)
	--cageButton:SetText("Cage Pets");
	cageButton:SetScript("OnClick", function() CageMe() end);
	cageButton:SetScript("OnEnter",
		function(self)
			GameTooltip:SetOwner (self, "ANCHOR_RIGHT");
			GameTooltip:SetText("Cage Pets", 1, 1, 1);
			--GameTooltip:AddLine(AutoCage_GetLocalizedString(L_AUTOCAGE_DUPLICATE_PETS_BUTTON_TOOLTIP), nil, nil, nil, true);
			GameTooltip:Show();
		end
	);
	cageButton:SetScript("OnLeave",
		function()
			GameTooltip:Hide();
		end
	);
end

--rematch heal button
--PetJournalFindBattle