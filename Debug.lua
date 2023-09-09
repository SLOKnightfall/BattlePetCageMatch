local addonName, addon = ...
addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
--local Debug = {}
--addon.Debug = Debug
local TextDump = LibStub("LibTextDump-1.0")

--function addon:Debug(text, level)
	--if not self.Options or not self.Options.DebugMode then return end
	--if (level or 1) <= DBM.Options.DebugLevel then
		--local frame = _G[tostring(DBM.Options.ChatFrame)]
		--frame = frame and frame:IsShown() and frame or DEFAULT_CHAT_FRAME
		--frame:AddMessage("|cffff7d0aDBM Debug:|r "..text, 1, 1, 1)
		--fireEvent("DBM_Debug", text, level)
	--end
--end



--function SetDebug(value)
--debugPriority = value
--end
debugPriority = 0
-- ----------------------------------------------------------------------------
-- Debugger.
-- ----------------------------------------------------------------------------
local DebugPour, GetDebugger
do
	--local TextDump = LibStub("LibTextDump-1.0")

	local DEBUGGER_WIDTH = 750
	local DEBUGGER_HEIGHT = 800

	local debugger

	---------
	local function Debug(...)
	---------
		if not debugger then
			debugger = TextDump:New(("%s Output"):format(addonName), DEBUGGER_WIDTH, DEBUGGER_HEIGHT)
		end

		local t = type(...)
		if t == "string" then
			local message = string.format(...)
			debugger:AddLine(message, "%X")
		elseif t == "number" then
			local message = string.format tostring((...))
			debugger:AddLine(message, "%X")
		elseif t == "boolean" then
			local message = string.format tostring((...))
			debugger:AddLine(message, "%X")
		elseif t == "table" then
			--debugger:AddLine(message, "%X")
			--pour(textOrAddon, ...)
		else
			--error("Invalid argument 2 to :Pour, must be either a string or a table.")
		end

		return message
	end

	---------
	function DebugPour(...)
	---------
		DEFAULT_CHAT_FRAME:AddMessage(string.format(...));
		Debug(...)

	end

	---------
	function GetDebugger()
	---------
		if debugPriority <=0 then return end
		if not debugger then
			debugger = TextDump:New(("%s Output"):format(addonName), DEBUGGER_WIDTH, DEBUGGER_HEIGHT)
		end
		if debugger:Lines() == 0 then
			debugger:AddLine("Nothing to report.")
			debugger:Display()
			debugger:Clear()
			return
		end
		debugger:Display()
		--debugger:Clear()

		return debugger
	end

	---------
	function ClearDebugger()
	---------
		if not debugger then
			debugger = TextDump:New(("%s Output"):format(addonName), DEBUGGER_WIDTH, DEBUGGER_HEIGHT)
		end

		debugger:Clear()
	end

	--------
	function Export(...)
	---------
		if not debugger then
			debugger = TextDump:New(("%s Export"):format(addonName), DEBUGGER_WIDTH, DEBUGGER_HEIGHT)
		end

		debugger:Clear()
			local message = string.format(...)
			debugger:AddLine(message)

		 debugger:Display()
		 return debugger

	end



	function addon:Debug(message, prioirity)
		if not prioirity or prioirity > debugPriority then return end
		GetDebugger()
		Debug(message)
	end
end