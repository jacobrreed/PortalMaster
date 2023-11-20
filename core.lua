local addon_name, addon_shared = ...;

local _G = getfenv(0);

local LibStub = LibStub;
local Addon = LibStub("AceAddon-3.0"):NewAddon(addon_name, "AceEvent-3.0");
_G[addon_name] = Addon;

_G["BINDING_HEADER_PORTALMASTER"] = "PortalMaster";
_G["BINDING_NAME_TOGGLE_PORTALMASTER"] = "Toggle PortalMaster";

StaticPopupDialogs["PORTALMASTER_NO_KEYBIND"] = {
	text = "PortalMaster does not currently have a keybinding. Do you want to open the key binding menu to set it?|n|nOption you are looking for is found under AddOns category.",
	button1 = YES,
	button2 = NO,
	button3 = "Don't Ask Again",
	OnAccept = function(self)
		KeyBindingFrame_LoadUI();
		KeyBindingFrame.mode = 1;
		ShowUIPanel(KeyBindingFrame);
	end,
	OnCancel = function(self)
	end,
	OnAlt = function()
		PortalMasterKeybindAlert = true;
	end,
	hideOnEscape = 1,
	timeout = 0,
}

local PM_MATCH_TELEPORT = 0x1;
local PM_MATCH_PORTAL 	= 0x2;

local MagePortSpells = {
	Common = {
		{	-- Dalaran
			teleport 	= 53140,
			portal 		= 53142,
			alias		= {"nr", "wrath", "old"},
			priority	= 2,
		},
		{	-- Ancient Dalaran
			teleport 	= 120145,
			portal 		= 120146,
			alias		= {"crater", "alterac"},
			priority	= 1,
		},
		{	-- Class Hall
			teleport 	= 193759,
			portal 		= nil, -- No portal to class hall
			alias		= {"class"},
		},
		{ -- Oribos
			teleport	= 344587,
			portal		= 344597,
			alias		= {"ob"}
		},
		{ -- Valdraken
			teleport 	= 395277,
			portal 		= 395289,
			alias 		= {	"vd"}
		}

	},
	Alliance	= {
		{	-- Stormwind
			teleport 	= 3561,
			portal 		= 10059,
			alias		= {"sw"},
		},
		{	-- Ironforge
			teleport 	= 3562,
			portal 		= 11416,
			alias		= {"if"},
		},
		{	-- Darnassus
			teleport 	= 3565,
			portal 		= 11419,
		},
		{	-- Exodar
			teleport 	= 32271,
			portal 		= 32266,
		},
		{	-- Theramore
			teleport 	= 49359,
			portal 		= 49360,
			alias		= {"dustwallow"},
		},	
		{	-- Shattrath
			teleport 	= 33690,
			portal 		= 33691,
			alias		= {"outland"},
		},				
		{	-- Tol Barad
			teleport 	= 88342,
			portal 		= 88345,
			alias		= {"tb"},
		},
		
		{	-- Vale of Eternal Blossoms
			teleport 	= 132621,
			portal 		= 132620,
			alias		= {"shrine"},
		},
		{	-- Stormshield
			teleport 	= 176248,
			portal 		= 176246,
			alias		= {"ss", "ashran"},
		},
		
		{	-- Dalaran - Broken Isles
			teleport 	= 224869,
			portal 		= 224871,
			alias		= {"bi"},
			priority	= 3,
		},		
		{	-- Boralus
			teleport 	= 281403,
			portal 		= 281400,
			alias		= {"kt"},
		},
	},
	
	Horde 		= {
		{	-- Orgrimmar
			teleport	= 3567,
			portal		= 11417,
			alias		= {"og"},
		},
		{	-- Thunder Bluff
			teleport	= 3566,
			portal		= 11420,
			alias		= {"tb"},
		}, 
		{	-- Undercity
			teleport	= 3563,
			portal		= 11418,
			alias		= {"uc"},
		}, 
		{	-- Silvermoon City
			teleport	= 32272,
			portal		= 32267,
			alias		= {"smc"},
		},
		{	-- Stonard
			teleport	= 49358,
			portal		= 49361,
			alias		= {"swamp"},
		},
		
		{	-- Shattrath
			teleport	= 35715,
			portal		= 35717,
			alias		= {"outland"},
		},
		{	-- Tol Barad
			teleport	= 88344,
			portal		= 88346,
		},	
		{	-- Vale of Eternal Blossoms
			teleport	= 132627,
			portal		= 132626,
			alias		= {"shrine"},
		},
		{	-- Warspear
			teleport	= 176242,
			portal		= 176244,
			alias		= {"ws", "ashran"},
		},
		{	-- Dalaran - Broken Isles
			teleport 	= 224869,
			portal 		= 224871,
			alias		= {"bi"},
			priority	= 3,
		},
		{	-- Dazar'alor
			teleport 	= 281404,
			portal 		= 281402,
			alias		= {"da"},
		},
	},
};

local AvailablePorts = {}

local FACTION_NAME = UnitFactionGroup("player"); 

local MESSAGE_PATTERN = "|cffe8608fPortalMaster|r %s";
function Addon:AddMessage(pattern, ...)
	DEFAULT_CHAT_FRAME:AddMessage(MESSAGE_PATTERN:format(string.format(pattern, ...)));
end

function Addon:OnInitialize()
	SLASH_PORTALMASTER1	= "/pm";
	SLASH_PORTALMASTER2	= "/portalmaster";
	SLASH_PORTALMASTER3	= "/port";
	SlashCmdList["PORTALMASTER"] = function(message)
		Addon:SlashHandler(message);
	end
end

function Addon:SlashHandler(message)
	Addon:OpenFrame(strtrim(message));
end

local _, PLAYER_CLASS = UnitClass("player");

function Addon:IsBindingSet()
	return GetBindingKey("TOGGLE_PORTALMASTER") ~= nil;
end

function Addon:OnEnable()
	if(PLAYER_CLASS == "MAGE") then
		Addon:RegisterEvent("PLAYER_REGEN_DISABLED");
		
		if(not Addon:IsBindingSet() and not PortalMasterKeybindAlert) then
			StaticPopup_Show("PORTALMASTER_NO_KEYBIND");
		end
		
		Addon.NoResult = true;

		-- Create available porttals by merging common & faction
		AvailablePorts = MagePortSpells[FACTION_NAME]
		for i = 1, #MagePortSpells["Common"] do
			AvailablePorts[#AvailablePorts+1] = MagePortSpells["Common"][i]
		end
	end
end

function Addon:PLAYER_REGEN_DISABLED()
	Addon:CloseFrame();
end

function Addon:ToggleFrame()
	if(InCombatLockdown()) then return end
	if(PLAYER_CLASS ~= "MAGE") then Addon:AddMessage("Not a mage"); return end
	
	if(not PortalMasterFrame:IsShown()) then
		Addon:OpenFrame();
	else
		Addon:CloseFrame();
	end
end

function Addon:OpenFrame(prefill)
	if(PLAYER_CLASS ~= "MAGE") then return end
	
	if(PortalMasterFrame:IsShown()) then return end
	
	Addon.MatchMode = PM_MATCH_TELEPORT;
	PortalMasterFrameSearch.Instructions:SetText("Search Teleport");
	
	Addon:ResetSearch(prefill);
	PortalMasterFrame:Show();
	
	PortalMasterFrameSearch:Show();
	PortalMasterFrameSearch:SetFocus();
	
	PortalMasterFrameSpellConfirm:Hide();
end

function Addon:CloseFrame()
	if(InCombatLockdown()) then return end;
	
	Addon:RemoveTemporaryBinding();
	PortalMasterFrame:Hide();
end

function Addon:ResetSearch(prefill)
	PortalMasterFrameSearch:SetText(prefill or "");
	PortalMasterFrameSearch:HighlightText(0, strlen(prefill or ""));
	
	if(prefill) then
		Addon:UpdateSearch();
	end
end

function PortalMaster_OnEditFocusLost()
	-- Addon:CloseFrame();
end

function Addon:CreateTemporaryBinding()
	if(Addon.TemporaryBindExists) then return end
	-- print("CREATING TEMP BIND!");
	
	SetOverrideBindingClick(PortalMasterFrame, true, "ENTER", "PortalMasterFrameSpellButton", "LeftButton");
	Addon.TemporaryBindExists = true;
end

function Addon:RemoveTemporaryBinding()
	if(not Addon.TemporaryBindExists) then return end
	
	PortalMasterFrameSpellButton:SetAttribute("type", nil);
	PortalMasterFrameSpellButton:SetAttribute("spell", nil);
	
	ClearOverrideBindings(PortalMasterFrame);
	Addon.TemporaryBindExists = false;
end

function PortalMaster_OnEnterPressed(self)
	if(not PortalMasterFrame:IsShown()) then return end
	if(Addon.NoResult) then return end
	
	local searchText = strtrim(strlower(self:GetText()));
	if(strlen(searchText) == 0) then
		Addon:CloseFrame();
		return;
	end
	
	Addon:CreateTemporaryBinding();
	
	PortalMasterFrameSearch:Hide();
	PortalMasterFrame.searchInfo:Hide();
	PortalMasterFrameSpellConfirm:Show();
end

function Addon:UpdateSearch()
	PortalMaster_OnTextChanged(PortalMasterFrameSearch);
end

function PortalMaster_OnTabPressed(self)
	if(Addon.MatchMode == PM_MATCH_TELEPORT) then
		Addon.MatchMode = PM_MATCH_PORTAL;
	else
		Addon.MatchMode = PM_MATCH_TELEPORT;
		
		local searchText = strtrim(PortalMasterFrameSearch:GetText());
		local first, rest = strsplit(" ", searchText, 2);
		
		if(strlower(first) == "p" or strlower(first) == "portal") then
			PortalMasterFrameSearch:SetText(rest or "")
		end
	end
	
	autoset_portal = false;
	
	Addon:UpdateSearch();
end

local autoset_portal = false;

function PortalMaster_OnTextChanged(self)
	SearchBoxTemplate_OnTextChanged(self)
	
	local searchText = strtrim(strlower(self:GetText()));
	
	local first, rest = strsplit(" ", searchText, 2);
	
	if(first == "p" or first == "portal") then
		Addon.MatchMode = PM_MATCH_PORTAL;
		searchText = rest or "";
		autoset_portal = true;
	elseif(Addon.MatchMode == PM_MATCH_PORTAL and autoset_portal) then
		Addon.MatchMode = PM_MATCH_TELEPORT;
		autoset_portal = false;
	end
	
	PortalMasterFrame.searchInfo:Show();
	
	if(Addon.MatchMode == PM_MATCH_TELEPORT) then
		PortalMasterFrame.searchInfo:SetText("Press TAB to Match Portals");
		PortalMasterFrameSearch.Instructions:SetText("Search Teleport");
	elseif(Addon.MatchMode == PM_MATCH_PORTAL) then
		PortalMasterFrame.searchInfo:SetText("Press TAB to Match Teleports");
		PortalMasterFrameSearch.Instructions:SetText("Search Portal");
	end
	
	Addon.NoResult = true;
	
	if(strlen(searchText) > 0) then
		local spellMatches = Addon:SearchSpells(searchText, Addon.MatchMode);
		
		if(spellMatches and spellMatches[1]) then
			local match = spellMatches[1];
			
			local spellName, _, icon = GetSpellInfo(match.spellID);
			
			PortalMasterFrameSpellName:SetText(spellName);
			
			PortalMasterFrameSpellButton.icon:SetTexture(icon);
			PortalMasterFrameSpellButton.iconBorder:SetVertexColor(0.1, 0.1, 0.1);
			
			PortalMasterFrameSpellButton:SetAttribute("type", "spell");
			PortalMasterFrameSpellButton:SetAttribute("spell", spellName);
			
			PortalMasterFrameSpellButton:Show();
			
			Addon.NoResult = false;
			return;
		else
			PortalMasterFrameSpellName:SetText("No Result");
			PortalMasterFrameSpellButton:Hide();
		end
	else
		PortalMasterFrameSpellName:SetText("Enter Spell Name");
		PortalMasterFrameSpellButton:Hide();
	end
end

function Addon:SearchSpells(searchText, matchMode)
	if(not searchText) then return false end
	
	local matches = {};
	
	local tokens = { strsplit(" ", searchText) };
	-- for index, data in ipairs(MagePortSpells[FACTION_NAME]) do
	for index, data in ipairs(AvailablePorts) do
		local spellID = data.teleport;
		if(matchMode == PM_MATCH_PORTAL and data.portal) then
			spellID = data.portal;
		end
		
		if(IsSpellKnown(spellID)) then
			local spellName, _, icon = GetSpellInfo(spellID);
			if(spellName) then
				local searchSpellName = gsub(spellName, "Teleport: ", "");
				searchSpellName = gsub(searchSpellName, "Portal: ", "");
				
				if(data.alias) then
					searchSpellName = searchSpellName .. " " .. table.concat(data.alias, " ");
				end
				
				local spellFound = true;
				for _, token in ipairs(tokens) do
					spellFound = spellFound and strmatch(strlower(searchSpellName), token);
				end
				
				if(spellFound) then
					tinsert(matches, { data = data, spellID = spellID, });
				end
			end
		end
	end
	
	if(#matches > 1) then
		table.sort(matches, function(a, b)
			if(a == nil and b == nil) then return false end
			if(a == nil) then return true end
			if(b == nil) then return false end
			
			return (a.data.priority or 0) > (b.data.priority or 0) or (a.data.alias and 1 or 0) > (b.data.alias and 1 or 0);
		end);
	end
	
	return matches;
end

function PortalMaster_OnEscapePressed(self)
	self:ClearFocus();
	Addon:CloseFrame();
end

function PortalMaster_CloseFrame()
	Addon:CloseFrame();
end

function Addon:OnDisable()
		
end
