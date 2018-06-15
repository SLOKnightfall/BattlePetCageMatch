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

BPCM = LibStub("AceAddon-3.0"):NewAddon("BattlePetCageMatch")

local InvCageList = 0

local results = {};
local bagResults = {};
local matches = 0;


---Scans the players bags and logs any caged battle pets
local function BPScanBags()
	results = {};
	local bagMatches = 0;
	for t=0,4 do
		
		bagResults[t] = {};
		local slots = GetContainerNumSlots(t);
		if (slots > 0) then
			for c=1,slots do
				local _,_,_,_,_,_,itemLink,_,_,itemID = GetContainerItemInfo(t,c)
		
				if (itemID == 82800) then
				local _, _, _, _, _, _, _, _, _, _, _, _, _, _, cageName = string.find(itemLink, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
				results[cageName] = true
				bagMatches = bagMatches + 1
				end
			end
		end	
		
	end
	--print("Cages in Inventory: "..bagMatches)
end

---Initilizes the buttons and creates the appropriate on click behaviour
--Pram: frame - frame that the checkbox should be added to
--Pram: index - index used to refrence the checkbox that is created created
--Return:  checkbox - the created checkbox frame
local function init_button(frame, index)
	local checkbox = CreateFrame("CheckButton", "CageMatch"..index, frame, "ChatConfigCheckButtonTemplate")
	checkbox:SetPoint("BOTTOMRIGHT")
	checkbox.SpellID = 0
	checkbox:Disable()
	return checkbox
end

---Updates the icons on Pet Journal to tag caged pets
 function UpdatePetList_Checkboxes()
	BPScanBags()
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
			local petId,_,_,_,_,_,_,petName,_,_,_,_,_,_,_,tradeable =  C_PetJournal.GetPetInfoByIndex(index)

			if  button.BPCM then

			else
				button.BPCM = init_button(button, i)
			end

			if tradeable then 
				button.BPCM:SetChecked(false)
				button.BPCM:Hide()
				if results[petName] then 
					--print(petName.." in Cage") 
					--button.BPCM:SetCheckedTexture("Interface/Buttons/UI-CheckBox-Check")
					--G:\World of Warcraft\BlizzardInterfaceArt\Interface\ICONS\
					button.BPCM:SetCheckedTexture("Interface/ICONS/INV_Pet_PetTrap01")
					button.BPCM:SetDisabledCheckedTexture("Interface/ICONS/INV_Pet_PetTrap01")
					button.BPCM:SetChecked(true)
					button.BPCM:Show()
				end
			else
				button.BPCM:SetCheckedTexture("Interface/Buttons/UI-GROUPLOOT-PASS-DOWN")
				button.BPCM:SetDisabledCheckedTexture("Interface/Buttons/UI-GROUPLOOT-PASS-DOWN")
				button.BPCM:SetChecked(true)
				button.BPCM:Show()
			end
			--button.BPCM:Show()

		else
			button.BPCM:Hide()
		end
	end
end


function BPCM:OnEnable()
	--Hooking PetJournal functions
	LoadAddOn("Blizzard_Collections")
	hooksecurefunc("PetJournal_UpdatePetList", UpdatePetList_Checkboxes)
	hooksecurefunc(PetJournalListScrollFrame,"update", UpdatePetList_Checkboxes)
end