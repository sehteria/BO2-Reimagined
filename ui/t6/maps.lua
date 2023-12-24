require( "T6.Lobby" )
require( "T6.Menus.PopupMenus" )
require( "T6.ListBox" )

local GameModes = {
	"ZMUI_CLASSIC_GAMEMODE_CAPS",
	"ZMUI_STANDARD_CAPS",
	"ZMUI_GRIEF_CAPS",
	"ZMUI_SNR_CAPS",
	"ZMUI_RACE_CAPS",
	"ZMUI_CONTAINMENT_CAPS",
	"ZMUI_MEAT_CAPS",
	-- "ZMUI_CLEANSED_CAPS", -- TODO: uncomment when game mode is added
}
local Maps = {
	"ZMUI_CLASSIC_CAPS",
	"ZMUI_CLASSIC_ZM_HIGHRISE_CAPS",
	"ZMUI_CLASSIC_ZM_PRISON_CAPS",
	"ZMUI_CLASSIC_ZM_BURIED_CAPS",
	"ZMUI_CLASSIC_ZM_TOMB_CAPS",
}
local Locations = {
	"ZMUI_TRANSIT_STARTLOC_CAPS",
	"ZMUI_DINER_CAPS",
	"ZMUI_FARM_CAPS",
	"ZMUI_POWER_CAPS",
	"ZMUI_TOWN_CAPS",
	"ZMUI_TUNNEL_CAPS",
	"ZMUI_CORNFIELD_CAPS",
	"ZMUI_NUKED_STARTLOC_CAPS",
	-- "ZMUI_GREEN_ROOFTOP_CAPS", -- TODO: add localized string, uncomment when location is added
    -- "ZMUI_BLUE_ROOFTOP_CAPS", -- TODO: add localized string, uncomment when location is added
    -- "ZMUI_BLUE_HIGHRISE_CAPS", -- TODO: add localized string, uncomment when location is added
	"ZMUI_CELLBLOCK_CAPS",
    "ZMUI_DOCKS_CAPS",
	"ZMUI_STREET_LOC_CAPS",
    "ZMUI_MAZE_CAPS",
	-- "ZMUI_BUNKERS_CAPS", -- TODO: add localized string, uncomment when location is added
    -- "ZMUI_EXCAVATION_SITE_CAPS", -- TODO: add localized string, uncomment when location is added
    -- "ZMUI_CHURCH_CAPS", -- TODO: add localized string, uncomment when location is added
    -- "ZMUI_CRAZY_PLACE_CAPS", -- TODO: add localized string, uncomment when location is added
}

local function gameModeListFocusChangedEventHandler( self, event )
	local focusedIndex = self.listBox:getFocussedIndex()
end

local function gameModeListSelectionClickedEventHandler( self, event )
	local focusedIndex = self.listBox:getFocussedIndex()

	local gameMode = GameModes[focusedIndex]

	if gameMode == "ZMUI_CLASSIC_GAMEMODE_CAPS" then
		Engine.SetDvar("ui_zm_gamemodegroup", "zclassic")
		Engine.SetDvar("ui_gametype", "zclassic")
	elseif gameMode == "ZMUI_STANDARD_CAPS" then
		Engine.SetDvar("ui_zm_gamemodegroup", "zsurvival")
		Engine.SetDvar("ui_gametype", "zstandard")
	elseif gameMode == "ZMUI_GRIEF_CAPS" then
		Engine.SetDvar("ui_zm_gamemodegroup", "zencounter")
		Engine.SetDvar("ui_gametype", "zgrief")
		Engine.SetDvar("ui_gametype_obj", "zgrief")
	elseif gameMode == "ZMUI_SNR_CAPS" then
		Engine.SetDvar("ui_zm_gamemodegroup", "zencounter")
		Engine.SetDvar("ui_gametype", "zgrief")
		Engine.SetDvar("ui_gametype_obj", "zsnr")
	elseif gameMode == "ZMUI_RACE_CAPS" then
		Engine.SetDvar("ui_zm_gamemodegroup", "zencounter")
		Engine.SetDvar("ui_gametype", "zgrief")
		Engine.SetDvar("ui_gametype_obj", "zrace")
	elseif gameMode == "ZMUI_CONTAINMENT_CAPS" then
		Engine.SetDvar("ui_zm_gamemodegroup", "zencounter")
		Engine.SetDvar("ui_gametype", "zgrief")
		Engine.SetDvar("ui_gametype_obj", "zcontainment")
	elseif gameMode == "ZMUI_MEAT_CAPS" then
		Engine.SetDvar("ui_zm_gamemodegroup", "zencounter")
		Engine.SetDvar("ui_gametype", "zgrief")
		Engine.SetDvar("ui_gametype_obj", "zmeat")
	elseif gameMode == "ZMUI_CLEANSED_CAPS" then
		-- TODO: set dvars when game mode is added
	end

	if gameMode == "ZMUI_CLASSIC_GAMEMODE_CAPS" then
		self:openMenu("SelectMapListZM", self.controller)
	else
		self:openMenu("SelectLocationListZM", self.controller)
	end

	self:close()
end

local function gameModeListBackEventHandler( self, event )
	CoD.Menu.ButtonPromptBack( self, event )
end

local function gameModeListCreateButtonMutables( controller, mutables )
	local text = LUI.UIText.new()
	text:setLeftRight( true, false, 0, 0 )
	text:setTopBottom( true, true, 0, 0 )
	text:setRGB( 1, 1, 1 )
	text:setAlpha( 1 )
	mutables:addElement( text )
	mutables.text = text
end

local function gameModeListGetButtonData( controller, index, mutables, self )
	local gameMode = GameModes[index]
	mutables.text:setText( Engine.Localize(gameMode) )
end

function LUI.createMenu.SelectGameModeListZM( controller )
	local self = CoD.Menu.New( "SelectGameModeListZM" )
	self.controller = controller

	if UIExpression.DvarBool(nil, "ui_game_lobby_open") == 1 then
		self:setPreviousMenu( "PrivateOnlineGameLobby" )
	else
		self:setPreviousMenu( "MainLobby" )
	end

	self:registerEventHandler( "open_menu", CoD.Lobby.OpenMenu )
	self:addSelectButton()
	self:addBackButton()

	self:addTitle( Engine.Localize("MPUI_GAMEMODE_CAPS") )

	local listBox = CoD.ListBox.new( nil, controller, 15, CoD.CoD9Button.Height, 250, gameModeListCreateButtonMutables, gameModeListGetButtonData, 0, 0 )
	listBox:setLeftRight( true, false, 0, 250 )
	listBox:setTopBottom( true, false, 75, 75 + 530 )
	listBox:addScrollBar( 530 + (8 * 12), 2 )
	listBox:setTotalItems( #GameModes )
	self:addElement( listBox )
	self.listBox = listBox

	self:registerEventHandler( "button_prompt_back", gameModeListBackEventHandler )
	self:registerEventHandler( "listbox_focus_changed", gameModeListFocusChangedEventHandler )
	self:registerEventHandler( "listbox_clicked", gameModeListSelectionClickedEventHandler )

	return self
end

local function mapListFocusChangedEventHandler( self, event )
	local focusedIndex = self.listBox:getFocussedIndex()
end

local function mapListSelectionClickedEventHandler( self, event )
	local focusedIndex = self.listBox:getFocussedIndex()

	local map = Maps[focusedIndex]

	if map == "ZMUI_CLASSIC_CAPS" then
		Engine.SetDvar("ui_mapname", "zm_transit")
		Engine.SetDvar("ui_zm_mapstartlocation", "transit")
	elseif map == "ZMUI_CLASSIC_ZM_HIGHRISE_CAPS" then
		Engine.SetDvar("ui_mapname", "zm_highrise")
		Engine.SetDvar("ui_zm_mapstartlocation", "rooftop")
	elseif map == "ZMUI_CLASSIC_ZM_PRISON_CAPS" then
		Engine.SetDvar("ui_mapname", "zm_prison")
		Engine.SetDvar("ui_zm_mapstartlocation", "prison")
	elseif map == "ZMUI_CLASSIC_ZM_BURIED_CAPS" then
		Engine.SetDvar("ui_mapname", "zm_buried")
		Engine.SetDvar("ui_zm_mapstartlocation", "processing")
	elseif map == "ZMUI_CLASSIC_ZM_TOMB_CAPS" then
		Engine.SetDvar("ui_mapname", "zm_tomb")
		Engine.SetDvar("ui_zm_mapstartlocation", "tomb")
	end

	if UIExpression.DvarBool(nil, "ui_game_lobby_open") == 0 then
		local gameType = UIExpression.DvarString(nil, "ui_gametype")
		local mapName = UIExpression.DvarString(nil, "ui_mapname")
		CoD.SwitchToPrivateLobby(self.controller) -- this changes "ui_gametype" and "ui_mapname"
		Engine.SetDvar("ui_gametype", gameType)
		Engine.SetDvar("ui_mapname", mapName)
	end

	self:openMenu("PrivateOnlineGameLobby", self.controller)

	self:close()
end

local function mapListCreateButtonMutables( controller, mutables )
	local text = LUI.UIText.new()
	text:setLeftRight( true, false, 0, 0 )
	text:setTopBottom( true, true, 0, 0 )
	text:setRGB( 1, 1, 1 )
	text:setAlpha( 1 )
	mutables:addElement( text )
	mutables.text = text
end

local function mapListGetButtonData( controller, index, mutables, self )
	local map = Maps[index]
	mutables.text:setText( Engine.Localize(map) )
end

function LUI.createMenu.SelectMapListZM( controller )
	local self = CoD.Menu.New( "SelectMapListZM" )
	self.controller = controller

	self:setPreviousMenu( "SelectGameModeListZM" )
	self:registerEventHandler( "open_menu", CoD.Lobby.OpenMenu )
	self:addSelectButton()
	self:addBackButton()

	self:addTitle( Engine.Localize("MPUI_MAPS_CAPS") )

	local listBox = CoD.ListBox.new( nil, controller, 15, CoD.CoD9Button.Height, 250, mapListCreateButtonMutables, mapListGetButtonData, 0, 0 )
	listBox:setLeftRight( true, false, 0, 250 )
	listBox:setTopBottom( true, false, 75, 75 + 530 )
	listBox:addScrollBar( 530 + (8 * 12), 2 )
	listBox:setTotalItems( #Maps )
	self:addElement( listBox )
	self.listBox = listBox

	self:registerEventHandler( "listbox_focus_changed", mapListFocusChangedEventHandler )
	self:registerEventHandler( "listbox_clicked", mapListSelectionClickedEventHandler )

	return self
end

local function locationListFocusChangedEventHandler( self, event )
	local focusedIndex = self.listBox:getFocussedIndex()
end

local function locationListSelectionClickedEventHandler( self, event )
	local focusedIndex = self.listBox:getFocussedIndex()

	local location = Locations[focusedIndex]

	if location == "ZMUI_TRANSIT_STARTLOC_CAPS" then
		Engine.SetDvar("ui_mapname", "zm_transit")
		Engine.SetDvar("ui_zm_mapstartlocation", "transit")
	elseif location == "ZMUI_DINER_CAPS" then
		Engine.SetDvar("ui_mapname", "zm_transit")
		Engine.SetDvar("ui_zm_mapstartlocation", "diner")
	elseif location == "ZMUI_FARM_CAPS" then
		Engine.SetDvar("ui_mapname", "zm_transit")
		Engine.SetDvar("ui_zm_mapstartlocation", "farm")
	elseif location == "ZMUI_POWER_CAPS" then
		Engine.SetDvar("ui_mapname", "zm_transit")
		Engine.SetDvar("ui_zm_mapstartlocation", "power")
	elseif location == "ZMUI_TOWN_CAPS" then
		Engine.SetDvar("ui_mapname", "zm_transit")
		Engine.SetDvar("ui_zm_mapstartlocation", "town")
	elseif location == "ZMUI_TUNNEL_CAPS" then
		Engine.SetDvar("ui_mapname", "zm_transit")
		Engine.SetDvar("ui_zm_mapstartlocation", "tunnel")
	elseif location == "ZMUI_CORNFIELD_CAPS" then
		Engine.SetDvar("ui_mapname", "zm_transit")
		Engine.SetDvar("ui_zm_mapstartlocation", "cornfield")
	elseif location == "ZMUI_NUKED_STARTLOC_CAPS" then
		Engine.SetDvar("ui_mapname", "zm_nuked")
		Engine.SetDvar("ui_zm_mapstartlocation", "nuked")
	elseif location == "ZMUI_GREEN_ROOFTOP_CAPS" then
		-- TODO: set dvars when location is added
	elseif location == "ZMUI_BLUE_ROOFTOP_CAPS" then
		-- TODO: set dvars when location is added
	elseif location == "ZMUI_BLUE_HIGHRISE_CAPS" then
		-- TODO: set dvars when location is added
	elseif location == "ZMUI_CELLBLOCK_CAPS" then
		Engine.SetDvar("ui_mapname", "zm_prison")
		Engine.SetDvar("ui_zm_mapstartlocation", "cellblock")
		Engine.SetDvar("ui_zm_mapstartlocation_fake", "")
	elseif location == "ZMUI_DOCKS_CAPS" then
		Engine.SetDvar("ui_mapname", "zm_prison")
		Engine.SetDvar("ui_zm_mapstartlocation", "cellblock")
		Engine.SetDvar("ui_zm_mapstartlocation_fake", "docks")
	elseif location == "ZMUI_STREET_LOC_CAPS" then
		Engine.SetDvar("ui_mapname", "zm_buried")
		Engine.SetDvar("ui_zm_mapstartlocation", "street")
		Engine.SetDvar("ui_zm_mapstartlocation_fake", "")
	elseif location == "ZMUI_MAZE_CAPS" then
		Engine.SetDvar("ui_mapname", "zm_buried")
		Engine.SetDvar("ui_zm_mapstartlocation", "street")
		Engine.SetDvar("ui_zm_mapstartlocation_fake", "maze")
	elseif location == "ZMUI_BUNKERS_CAPS" then
		-- TODO: set dvars when location is added
	elseif location == "ZMUI_EXCAVATION_SITE_CAPS" then
		-- TODO: set dvars when location is added
	elseif location == "ZMUI_CHURCH_CAPS" then
		-- TODO: set dvars when location is added
	elseif location == "ZMUI_CRAZY_PLACE_CAPS" then
		-- TODO: set dvars when location is added
	end

	if UIExpression.DvarBool(nil, "ui_game_lobby_open") == 0 then
		local gameType = UIExpression.DvarString(nil, "ui_gametype")
		local mapName = UIExpression.DvarString(nil, "ui_mapname")
		CoD.SwitchToPrivateLobby(self.controller) -- this changes "ui_gametype" and "ui_mapname"
		Engine.SetDvar("ui_gametype", gameType)
		Engine.SetDvar("ui_mapname", mapName)
	end

	self:openMenu("PrivateOnlineGameLobby", self.controller)

	self:close()
end

local function locationListCreateButtonMutables( controller, mutables )
	local text = LUI.UIText.new()
	text:setLeftRight( true, false, 0, 0 )
	text:setTopBottom( true, true, 0, 0 )
	text:setRGB( 1, 1, 1 )
	text:setAlpha( 1 )
	mutables:addElement( text )
	mutables.text = text
end

local function locationListGetButtonData( controller, index, mutables, self )
	local location = Locations[index]
	mutables.text:setText( Engine.Localize(location) )
end

function LUI.createMenu.SelectLocationListZM( controller )
	local self = CoD.Menu.New( "SelectLocationListZM" )
	self.controller = controller

	self:setPreviousMenu( "SelectGameModeListZM" )
	self:registerEventHandler( "open_menu", CoD.Lobby.OpenMenu )
	self:addSelectButton()
	self:addBackButton()

	self:addTitle( Engine.Localize("MPUI_MAPS_CAPS") )

	local listBox = CoD.ListBox.new( nil, controller, 15, CoD.CoD9Button.Height, 250, locationListCreateButtonMutables, locationListGetButtonData, 0, 0 )
	listBox:setLeftRight( true, false, 0, 250 )
	listBox:setTopBottom( true, false, 75, 75 + 530 )
	listBox:addScrollBar( 530 + (8 * 12), 2 )
	listBox:setTotalItems( #Locations )
	self:addElement( listBox )
	self.listBox = listBox

	self:registerEventHandler( "listbox_focus_changed", locationListFocusChangedEventHandler )
	self:registerEventHandler( "listbox_clicked", locationListSelectionClickedEventHandler )

	return self
end