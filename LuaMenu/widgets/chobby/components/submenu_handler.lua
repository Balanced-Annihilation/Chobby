function GetSubmenuHandler(buttonWindow, panelWindow, submenuPanelWindow, submenus, titleUpdateFunction)
	
	local externalFunctions = {}
	local submenuPanelNames = {}
	
	local buttonsHolder
	
	local fontSizeScale = 3
	local buttonHeight = 70
	
	-- Matches interface root and submenu handler
	local buttonSpacing = 4
	local BUTTON_SIDE_SPACING = 1
	
	local buttonOffset = 50
	local title
	
	-------------------------------------------------------------------
	-- Local Functions
	-------------------------------------------------------------------
	local function BackToMainMenu(panelHandler) 
		panelHandler.Hide() 
		if not buttonsHolder.visible then
			buttonsHolder:Show()
		end
		
		titleUpdateFunction()
		title = nil
		
		if panelWindow.children[1] and panelHandler.GetManagedControlByName(panelWindow.children[1].name) then
			panelWindow:ClearChildren()
			if panelWindow.visible then
				panelWindow:Hide()
			end
		end
	end
	
	local function SetTitle(newTitle)
		if newTitle == title then
			return
		end
		title = newTitle
		titleUpdateFunction(title)
	end
	
	local function SetButtonPositionAndSize(index)
		submenus[index].button:SetPos(
			BUTTON_SIDE_SPACING, 
			(index - 1) * (buttonHeight + buttonSpacing) + buttonOffset - buttonSpacing, 
			nil, 
			buttonHeight
		)
		submenus[index].button._relativeBounds.right = BUTTON_SIDE_SPACING
		submenus[index].button:UpdateClientArea()
	end
	
	-------------------------------------------------------------------
	-- External Functions
	-------------------------------------------------------------------
	function externalFunctions.GetTabList(name)
		return submenuPanelNames[name]
	end
	
	function externalFunctions.GetSubheadingName()
		return title
	end
	
	function externalFunctions.GetCurrentSubmenu()
		for i = 1, #submenus do
			local panelHandler = submenus[i].panelHandler
			if panelHandler.IsVisible() then
				return i
			end
		end
		return false
	end
	
	function externalFunctions.OpenSubmenu(index, tabName)
		if buttonsHolder.visible then
			buttonsHolder:Hide()
		end
		WG.Analytics.SendOnetimeEvent(submenus[index].analyticsName)
		
		submenus[index].panelHandler.Show()
		
		if submenus[index].entryCheck then
			submenus[index].entryCheck()
		end
		if tabName then
			submenus[index].panelHandler.OpenTabByName(tabName)
		end
	end
	
	function externalFunctions.SetBackAtMainMenu(submenuName)
		if submenuName then
			local index = externalFunctions.GetCurrentSubmenu()
			if index and (submenuName ~= submenus[index].name) then
				return
			end
		end
		
		local clearMainWindow = false
		for i = 1, #submenus do
			local panelHandler = submenus[i].panelHandler
			if panelHandler then
				clearMainWindow = panelHandler.CloseSubmenu() or clearMainWindow
			end
		end
		
		if not buttonsHolder.visible then
			buttonsHolder:Show()
		end
		if titleUpdateFunction then
			titleUpdateFunction()
		end
		
		if clearMainWindow then
			panelWindow:ClearChildren()
			if panelWindow.visible then
				panelWindow:Hide()
			end
		end
	end
	
	function externalFunctions.ReplaceSubmenu(index, newTabs, newCleanupFunction)
		externalFunctions.SetBackAtMainMenu()
		submenus[index].panelHandler.Destroy()
		submenus[index].analyticsName = "lobby:" .. submenus[index].name
		
		local newPanelHandler = GetTabPanelHandler(submenus[index].name, buttonWindow, panelWindow, submenuPanelWindow, newTabs, true, BackToMainMenu, newCleanupFunction, fontSizeScale, nil, nil, nil, SetTitle, "lobby:" .. submenus[index].name)
		newPanelHandler.Rescale(fontSizeScale, buttonHeight, nil, buttonOffset, buttonSpacing)
		newPanelHandler.Hide()
		submenus[index].panelHandler = newPanelHandler
	end
	
	function externalFunctions.Rescale(newFontSize, newButtonHeight, newButtonOffset, newButtonSpacing)
		fontSizeScale = newFontSize or fontSizeScale
		buttonHeight = newButtonHeight or buttonHeight
		buttonSpacing = newButtonSpacing or buttonSpacing
		if newButtonOffset then
			buttonOffset = newButtonOffset
		end
		for i = 1, #submenus do
			submenus[i].panelHandler.Rescale(newFontSize, newButtonHeight, nil, newButtonOffset, buttonSpacing)
			ButtonUtilities.SetFontSizeScale(submenus[i].button, fontSizeScale)
			SetButtonPositionAndSize(i)
		end
	end
	
	-------------------------------------------------------------------
	-- Initialization
	-------------------------------------------------------------------
	buttonsHolder = Control:New {
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		name = "buttonsHolder",
		parent = buttonWindow,
		padding = {0, 0, 0, 0},
		children = {}
	}
	
	for i = 1, #submenus do
		
		submenus[i].analyticsName = "lobby:" .. submenus[i].name
		local panelHandler = GetTabPanelHandler(submenus[i].name, buttonWindow, panelWindow, submenuPanelWindow, submenus[i].tabs, true, BackToMainMenu, submenus[i].cleanupFunction, fontSizeScale, submenus[i].submenuControl, nil, nil, SetTitle, submenus[i].analyticsName)
		panelHandler.Hide()
		
		submenuPanelNames[submenus[i].name] = panelHandler
		submenus[i].panelHandler = panelHandler
		
		submenus[i].button = Button:New {
			x = BUTTON_SIDE_SPACING,
			y = (i - 1) * (buttonHeight + buttonSpacing) + buttonOffset - buttonSpacing,
			right = BUTTON_SIDE_SPACING,
			height = buttonHeight,
			caption = i18n(submenus[i].name),
			font = { size = 20},
			parent = buttonsHolder,
			OnClick = {
				function(self) 
					externalFunctions.OpenSubmenu(i)
				end
			},
		}
	end
	
	return externalFunctions
end
