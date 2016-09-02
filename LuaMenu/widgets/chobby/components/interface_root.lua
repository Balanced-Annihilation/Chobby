function GetInterfaceRoot(optionsParent, mainWindowParent, fontFunction)

	local externalFunctions = {}

	local globalKeyListener = false

	local titleWidthRel = 28
	local panelWidthRel = 40

	local userStatusPanelWidth = 250

	local battleStatusWidth = 480
	local panelButtonsWidth = 500
	local panelButtonsHeight = 42
	local statusWindowGapSmall = 44

	local chatTabHolderHeight = 50

	local battleStatusTopPadding = 20
	local battleStatusBottomPadding = 20
	local battleStatusLeftPadding = 30

	local smallStatusLeftPadding = 5
	local battleStatusTopPaddingSmall = 5

	local chatTabHolderRight = 0

	local titleHeight = 125
	local titleHeightSmall = 90
	local titleWidth = 360

	local mainButtonsWidth = 180
	local mainButtonsWidthSmall = 140

	local userStatusWidth = 225

	local imageFudge = 0

	local padding = 0

	local statusButtonWidth = 420
	local statusButtonWidthSmall = 310
	
	local topBarHeight = 50

	-- Switch to single panel mode when below the minimum screen width
	local minScreenWidth = 1280

	local gameRunning = false
	local showTopBar = false
	local doublePanelMode = true
	local autodetectDoublePanel = true

	local IMAGE_TOP_BACKGROUND = LUA_DIRNAME .. "images/top-background.png"

	local INVISIBLE_COLOR = {0, 0, 0, 0}
	local VISIBLE_COLOR = {1, 1, 1, 1}

	-------------------------------------------------------------------
	-- Window structure
	-------------------------------------------------------------------
	local ingameInterfaceHolder = Control:New {
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		name = "ingameInterfaceHolder",
		parent = screen0,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		children = {},
		preserveChildrenOrder = true
	}
	ingameInterfaceHolder:Hide()
	
	local lobbyInterfaceHolder = Control:New {
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		name = "lobbyInterfaceHolder",
		parent = screen0,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		children = {},
		preserveChildrenOrder = true
	}
	
	-- Direct children of lobbyInterfaceHolder are called holder_<name>
	-- and are each within their own subsection
	
	-----------------------------------
	-- Ingame top bar holder
	-----------------------------------
	local holder_topBar = Control:New {
		x = 0,
		y = 0,
		right = 0,
		height = topBarHeight,
		name = "holder_topBar",
		parent = lobbyInterfaceHolder,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		children = {}
	}
	holder_topBar:Hide()
	
	-----------------------------------
	-- Heading holder
	-----------------------------------
	local holder_heading = Control:New {
		x = 0,
		y = 0,
		width = titleWidth,
		height = titleHeight,
		name = "holder_heading",
		parent = lobbyInterfaceHolder,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		children = {}
	}
	local heading_image = Image:New {
		y = 0,
		x = 0,
		right = 0,
		bottom = 0,
		keepAspect = false,
		file = Configuration:GetHeadingImage(doublePanelMode),
		OnClick = { function()
			Spring.Echo("OpenURL: uncomment me in interface_root.lua")
			-- Uncomment me to try it!
			--Spring.OpenURL("https://gitter.im/Spring-Chobby/Chobby")
			--Spring.OpenURL("/home/gajop")
		end},
		parent = holder_heading,
	}

	-----------------------------------
	-- Top middle and top right status
	-----------------------------------
	local holder_status = Control:New {
		x = titleWidth,
		y = 0,
		right = 0,
		height = titleHeight,
		name = "holder_status",
		caption = "", -- Status Window
		parent = lobbyInterfaceHolder,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
	}

	local status_userWindow = Control:New {
		y = 0,
		right = 0,
		bottom = panelButtonsHeight,
		width = userStatusWidth,
		height = "100%",
		padding = {0, 0, 0, 0},
		parent = holder_status,
		children = {
			WG.UserStatusPanel.GetControl(),
		}
	}

	local status_battleHolder = Control:New {
		x = battleStatusLeftPadding,
		y = battleStatusTopPadding,
		right = userStatusWidth,
		bottom = battleStatusBottomPadding,
		name = "status_battleHolder",
		caption = "", -- Battle and MM Status Window
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		parent = holder_status,
	}

	local status_panelButtons = Control:New {
		bottom = 0,
		right = 0,
		width = panelButtonsWidth,
		height = panelButtonsHeight,
		name = "status_panelButtons",
		parent = holder_status,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		children = {}
	}
	local panelButtons_buttons = Control:New {
		x = "0%",
		y = "0%",
		width = "100%",
		height = "100%",
		name = "panelButtons_buttons",
		caption = "", -- Panel Buttons
		parent = status_panelButtons,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		children = {}
	}
	
	-----------------------------------
	-- Main Window
	-----------------------------------
	local holder_mainWindow = Control:New {
		x = 0,
		y = titleHeight,
		width = (100 - panelWidthRel) .. "%",
		bottom = 0,
		name = "holder_mainWindow",
		caption = "", -- Main Window
		parent = lobbyInterfaceHolder,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		children = {}
	}
	local mainWindow_buttonsHolder = Control:New {
		x = padding,
		y = padding,
		width = mainButtonsWidth,
		bottom = padding,
		name = "mainWindow_buttonsHolder",
		parent = holder_mainWindow,
		padding = {0, 0, 0, 0},
		children = {},
	}
	local buttonsHolder_buttons = Control:New {
		x = 0,
		y = 0,
		width = "100%",
		height = "100%",
		name = "buttonsHolder_buttons",
		caption = "", -- Main Buttons
		parent = mainWindow_buttonsHolder,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		children = {}
	}
	
	local buttonsHolder_image = Image:New {
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		file = IMAGE_TOP_BACKGROUND,
		parent = mainWindow_buttonsHolder,
		keepAspect = false,
		color = {0.218, 0.23, 0.49, 0.1},
	}

	local mainWindow_mainContent = Control:New {
		x = mainButtonsWidth,
		y = padding,
		right = padding,
		bottom = padding,
		name = "mainWindow_mainContent",
		caption = "", -- Content Place
		parent = holder_mainWindow,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		children = {}
	}
	local mainContent_window = Window:New {
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		name = "mainContent_window",
		caption = "", -- Content Place
		parent = mainWindow_mainContent,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		children = {}
	}
	mainContent_window:Hide()
	
	-- Exit button
	local function ExitSpring()
		Spring.Echo("Quitting...")
		Spring.Quit()
	end
	
	local buttons_exit = Button:New {
		x = 0,
		bottom = 0,
		width = "100%",
		height = 70,
		caption = i18n("exit"),
		font = Configuration:GetFont(3),
		parent = buttonsHolder_buttons,
		OnClick = {
			function(self)
				ConfirmationPopup(ExitSpring, "Are you sure you want to quit?", nil, 315, 200)
			end
		},
	}
	
	-----------------------------------
	-- Top image
	-----------------------------------
	local holder_topImage = Image:New {
		x = 0,
		y = 0,
		right = 0,
		height = titleHeight,
		file = IMAGE_TOP_BACKGROUND,
		parent = lobbyInterfaceHolder,
		keepAspect = false,
		color = {0.218, 0.23, 0.49, 0.25},
	}
	
	-----------------------------------
	-- Right panel holder
	-----------------------------------
	
	local holder_rightPanel = Control:New {
		x = (100 - panelWidthRel) .. "%",
		y = titleHeight,
		right = 0,
		bottom = 0,
		name = "holder_rightPanel",
		caption = "", -- Panel Window
		parent = lobbyInterfaceHolder,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		children = {}
	}
	local rightPanel_window = Window:New {
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		name = "rightPanel_window",
		caption = "", -- Panel Window
		parent = holder_rightPanel,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		children = {}
	}
	rightPanel_window:Hide()

	-----------------------------------
	-- Background holder is put here to be at the back
	-----------------------------------
	local backgroundHolder = Background()
	
	-------------------------------------------------------------------
	-- In-Window Handlers
	-------------------------------------------------------------------
	local chatWindows = ChatWindows()
	local mainWindowHandler

	local function CleanMultiplayerState(notFromBackButton)
		if notFromBackButton then
			mainWindowHandler.SetBackAtMainMenu("multiplayer")
		end
		WG.BattleRoomWindow.LeaveBattle(true)
	end

	local rightPanelTabs = {
		{name = "chat", control = chatWindows.window},
		{name = "settings", control = WG.SettingsWindow.GetControl()},
		{name = "downloads", control = WG.DownloadWindow.GetControl()},
		{name = "friends", control = WG.FriendWindow.GetControl()},
	}

	local queueListWindow = QueueListWindow()
	local battleListWindow = BattleListWindow()

	local submenus = {
		{
			name = "singleplayer",
			tabs = Configuration:GetGameConfig(false, "singleplayerMenu.lua", Configuration.shortnameMap[Configuration.singleplayer_mode]) or {}
		},
		{
			name = "multiplayer",
			entryCheck = WG.MultiplayerEntryPopup,
			tabs = {
				{name = "matchmaking", control = queueListWindow.window},
				{name = "serverList", control = battleListWindow.window},
			},
			cleanupFunction = CleanMultiplayerState
		},
	}

	local battleStatusTabControls = {
		myBattle = WG.BattleStatusPanel.GetControl
	}

	local battleStatusPanelHandler = GetTabPanelHandler("myBattlePanel", status_battleHolder, mainContent_window, {}, nil, nil, nil, nil, statusButtonWidth, battleStatusTabControls)
	local rightPanelHandler = GetTabPanelHandler("panelTabs", panelButtons_buttons, rightPanel_window, rightPanelTabs)
	mainWindowHandler = GetSubmenuHandler(buttonsHolder_buttons, mainContent_window, submenus)

	-------------------------------------------------------------------
	-- Resizing functions
	-------------------------------------------------------------------

	local function RescaleMainWindow(newFontSize, newButtonHeight)
		mainWindowHandler.Rescale(newFontSize, newButtonHeight)
		buttons_exit:SetPos(nil, nil, nil, newButtonHeight)

		ButtonUtilities.SetFontSizeScale(buttons_exit, newFontSize)
	end

	local function UpdateChildLayout()
		if doublePanelMode then
			chatWindows:ReattachTabHolder()

			rightPanelHandler.UpdateLayout(rightPanel_window, false)
			if not mainContent_window:IsEmpty() then
				local control, index = rightPanelHandler.GetManagedControlByName(mainContent_window.children[1].name)
				if control then
					mainContent_window:ClearChildren()
					mainContent_window:SetVisibility(false)
					rightPanelHandler.OpenTab(index)
				elseif rightPanel_window.visible then
					rightPanel_window:Hide()
				end
			elseif rightPanel_window.visible then
				rightPanel_window:Hide()
			end

		else
			chatWindows:SetTabHolderParent(holder_status, smallStatusLeftPadding, titleHeightSmall - chatTabHolderHeight + imageFudge, chatTabHolderRight)

			rightPanelHandler.UpdateLayout(mainContent_window, true)
			if mainContent_window:IsEmpty() and not rightPanel_window:IsEmpty() then
				local panelChild = rightPanel_window.children[1]
				local control, index = rightPanelHandler.GetManagedControlByName(panelChild.name)
				rightPanelHandler.OpenTab(index)
			else
				rightPanel_window:ClearChildren()
			end
		end
	end

	local function UpdateDoublePanel(newDoublePanel)
		if newDoublePanel == doublePanelMode then
			return
		end
		doublePanelMode = newDoublePanel
		
		local topOffset = (showTopBar and topBarHeight) or 0
		
		if doublePanelMode then
			battleStatusPanelHandler.Rescale(3, nil, statusButtonWidth)
			RescaleMainWindow(3, 70)

			-- Make main buttons wider
			mainWindow_mainContent:SetPos(mainButtonsWidth)
			mainWindow_mainContent._relativeBounds.right = 0
			mainWindow_mainContent:UpdateClientArea()

			--mainContent_window.color = VISIBLE_COLOR

			mainWindow_buttonsHolder:SetPos(nil, nil, mainButtonsWidth)

			-- Move Panel Buttons
			buttonsHolder_buttons:RemoveChild(panelButtons_buttons)
			status_panelButtons:AddChild(panelButtons_buttons)

			panelButtons_buttons:SetPosRelative("0%","0%", "100%","100%")
			--buttonsHolder_buttons:SetPosRelative("0%","0%", nil,"100%")

			-- Make Main Window take up more space
			status_panelButtons:Show()
			holder_rightPanel:Show()
			holder_rightPanel:SetPos(nil, titleHeight + topOffset)
			holder_rightPanel._relativeBounds.bottom = 0
			holder_rightPanel:UpdateClientArea()

			holder_mainWindow:SetPos(nil, titleHeight + topOffset)
			holder_mainWindow._relativeBounds.right = panelWidthRel .. "%"
			holder_mainWindow._relativeBounds.bottom = 0
			holder_mainWindow:UpdateClientArea()

			-- Align game title and status.
			holder_heading:SetPos(0, topOffset, titleWidth, titleHeight)
			holder_status:SetPos(titleWidth, topOffset, titleHeight, titleHeight)
			holder_status._relativeBounds.right = 0
			holder_status:UpdateClientArea()

			status_userWindow._relativeBounds.bottom = panelButtonsHeight
			status_userWindow:UpdateClientArea()

			status_battleHolder:SetPos(battleStatusLeftPadding, battleStatusTopPadding)
			status_battleHolder._relativeBounds.bottom = battleStatusBottomPadding
			status_battleHolder:UpdateClientArea()

			holder_topImage:SetPos(nil, topOffset, nil, titleHeight + imageFudge)
		else
			rightPanelHandler.Rescale(2, 55)
			battleStatusPanelHandler.Rescale(3, nil, statusButtonWidthSmall)
			RescaleMainWindow(2, 55)

			-- Make main buttons thinner
			mainWindow_mainContent:SetPos(mainButtonsWidthSmall)
			mainWindow_mainContent._relativeBounds.right = 0
			mainWindow_mainContent:UpdateClientArea()

			--mainContent_window.color = INVISIBLE_COLOR

			mainWindow_buttonsHolder:SetPos(nil, nil, mainButtonsWidthSmall)

			-- Move Panel Buttons
			status_panelButtons:RemoveChild(panelButtons_buttons)
			buttonsHolder_buttons:AddChild(panelButtons_buttons)

			panelButtons_buttons:SetPosRelative("0%","45%", "100%","50%")
			--buttonsHolder_buttons:SetPosRelative("0%","0%", nil,"50%")

			-- Make Main Window take up more space
			status_panelButtons:Hide()
			status_panelButtons:ClearChildren()
			if holder_rightPanel.visible then
				holder_rightPanel:Hide()
			end
			holder_mainWindow:SetPos(nil, titleHeightSmall + topOffset)
			holder_mainWindow._relativeBounds.right = 0
			holder_mainWindow._relativeBounds.bottom = 0
			holder_mainWindow:UpdateClientArea()

			-- Align game title and status.
			holder_heading:SetPos(0, topOffset, mainButtonsWidthSmall + padding, titleHeightSmall)
			holder_status:SetPos(mainButtonsWidthSmall, topOffset, titleHeightSmall, titleHeightSmall)
			holder_status._relativeBounds.right = 0
			holder_status:UpdateClientArea()

			status_userWindow._relativeBounds.bottom = 0
			status_userWindow:UpdateClientArea()

			status_battleHolder:SetPos(smallStatusLeftPadding, battleStatusTopPaddingSmall)
			status_battleHolder._relativeBounds.bottom = statusWindowGapSmall
			status_battleHolder:UpdateClientArea()

			holder_topImage:SetPos(nil, topOffset, nil, titleHeightSmall + imageFudge)
		end

		heading_image.file = Configuration:GetHeadingImage(doublePanelMode)
		heading_image:Invalidate()

		UpdateChildLayout()
	end

	local function UpdatePadding(screenWidth, screenHeight)
		local leftPad, rightPad, bottomPad, middlePad
		if screenWidth < 1366 or (not doublePanelMode) then
			leftButtonPad = 0
			leftPad = 0
			rightPad = 0
			bottomPad = 0
			middlePad = 0
		elseif screenWidth < 1650 then
			leftButtonPad = 20
			leftPad = 5
			rightPad = 15
			bottomPad = 20
			middlePad = 10
		else
			leftButtonPad = 30
			leftPad = 10
			rightPad = 40
			bottomPad = 40
			middlePad = 20
		end
		
		mainContent_window:SetPos(leftPad)
		mainContent_window._relativeBounds.right = middlePad
		mainContent_window._relativeBounds.bottom = bottomPad
		mainContent_window:UpdateClientArea()

		rightPanel_window:SetPos(middlePad)
		rightPanel_window._relativeBounds.right = rightPad
		rightPanel_window._relativeBounds.bottom = bottomPad
		rightPanel_window:UpdateClientArea()

		status_panelButtons._relativeBounds.right = rightPad
		rightPanel_window:UpdateClientArea()

		buttons_exit._relativeBounds.bottom = bottomPad
		buttons_exit:UpdateClientArea()

		if doublePanelMode then
			status_battleHolder._relativeBounds.right = panelButtonsWidth + rightPad
			status_battleHolder:UpdateClientArea()
		else
			status_battleHolder._relativeBounds.right = userStatusWidth
			status_battleHolder:UpdateClientArea()
		end

		mainWindow_buttonsHolder:SetPos(leftButtonPad)
		local contentOffset = leftButtonPad
		if doublePanelMode then
			contentOffset = contentOffset + mainButtonsWidth
		else
			contentOffset = contentOffset + mainButtonsWidthSmall
		end
		mainWindow_mainContent:SetPos(contentOffset)
		mainWindow_mainContent._relativeBounds.right = 0
		mainWindow_mainContent:UpdateClientArea()
	end
	
	-------------------------------------------------------------------
	-- Visibility and size handlers
	-------------------------------------------------------------------

	local function SetMainInterfaceVisible(newVisible)
		if lobbyInterfaceHolder.visible == newVisible then
			return
		end
		backgroundHolder:SetEnabled(newVisible)
		if newVisible then
			lobbyInterfaceHolder:Show()
			ingameInterfaceHolder:Hide()
		else
			lobbyInterfaceHolder:Hide()
			ingameInterfaceHolder:Show()
		end
	end
		
	local function SetTopBarVisible(newVisible)
		if newVisible == showTopBar then
			return
		end
		holder_topBar:SetVisibility(newVisible)
		showTopBar = newVisible
		
		local topOffset = (showTopBar and topBarHeight) or 0
		local titleOffset = (doublePanelMode and titleHeight) or titleHeightSmall
		
		holder_rightPanel:SetPos(nil, titleOffset + topOffset)
		holder_rightPanel._relativeBounds.bottom = 0
		holder_rightPanel:UpdateClientArea()
			
		holder_mainWindow:SetPos(nil, titleOffset + topOffset)
		holder_mainWindow._relativeBounds.bottom = 0
		holder_mainWindow:UpdateClientArea()
		
		holder_topImage:SetPos(nil, topOffset)
		holder_heading:SetPos(nil, topOffset)
		holder_status:SetPos(nil, topOffset)
		
		if showTopBar then
			backgroundHolder:SetAlpha(0.85)
		else
			backgroundHolder:SetAlpha(1)
		end
		
		local screenWidth, screenHeight = Spring.GetViewGeometry()
		screen0:Resize(screenWidth, screenHeight)
	end
	
	-------------------------------------------------------------------
	-- Top bar initialisation
	-------------------------------------------------------------------
	
	local switchToMenuButton = Button:New {
		y = 5,
		right = 5,
		width = 100,
		height = 41,
		name = "switchToMenuButton",
		caption = "Menu",
		font = WG.Chobby.Configuration:GetFont(3),
		parent = ingameInterfaceHolder,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		
		OnClick = {
			function ()
				SetMainInterfaceVisible(true)
			end
		}
	}
	local switchToGameButton = Button:New {
		y = 5,
		right = 5,
		width = 100,
		height = 41,
		name = "switchToGameButton",
		caption = "Game",
		font = WG.Chobby.Configuration:GetFont(3),
		parent = holder_topBar,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		
		OnClick = {
			function ()
				SetMainInterfaceVisible(false)
			end
		}
	}
	local leaveGameButton = Button:New {
		y = 5,
		right = 110,
		width = 100,
		height = 41,
		height = topBarHeight - 10,
		name = "leaveGameButton",
		caption = "Leave",
		font = WG.Chobby.Configuration:GetFont(3),
		parent = holder_topBar,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		
		OnClick = {
			function ()
				Spring.Reload("")
			end
		}
	}
	
	local topBarImage = Image:New {
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		file = IMAGE_TOP_BACKGROUND,
		parent = holder_topBar,
		keepAspect = false,
		color = {0.218, 0.23, 0.49, 0.9},
	}
	
	-------------------------------------------------------------------
	-- External Functions
	-------------------------------------------------------------------
	function externalFunctions.ViewResize(screenWidth, screenHeight)
		if autodetectDoublePanel then
			local newDoublePanel = minScreenWidth <= screenWidth
			UpdateDoublePanel(newDoublePanel)
		end
		UpdatePadding(screenWidth, screenHeight)
	end

	function externalFunctions.SetPanelDisplayMode(newAutodetectDoublePanel, newDoublePanel)
		autodetectDoublePanel = newAutodetectDoublePanel
		local screenWidth, screenHeight = Spring.GetViewGeometry()
		if autodetectDoublePanel then
			UpdateDoublePanel(screenWidth > minScreenWidth)
		else
			UpdateDoublePanel(newDoublePanel)
		end
		UpdatePadding(screenWidth, screenHeight)
		-- Make all children request realign.
		screen0:Resize(screenWidth, screenHeight)
	end
	
	function externalFunctions.SetIngame(newIngame)
		gameRunning = not newIngame
		SetMainInterfaceVisible(not newIngame)
		SetTopBarVisible(newIngame)
	end
	
	function externalFunctions.GetChatWindow()
		return chatWindows
	end

	function externalFunctions.GetContentPlace()
		return mainContent_window
	end

	function externalFunctions.GetStatusWindow()
		return holder_status
	end

	function externalFunctions.GetMainWindowHandler()
		return mainWindowHandler
	end

	function externalFunctions.GetRightPanelHandler()
		return rightPanelHandler
	end

	function externalFunctions.GetBattleStatusWindowHandler()
		return battleStatusPanelHandler
	end

	function externalFunctions.GetDoublePanelMode()
		return doublePanelMode
	end

	function externalFunctions.CleanMultiplayerState()
		CleanMultiplayerState(true)
	end

	function externalFunctions.KeyPressed(key, mods, isRepeat, label, unicode)
		if globalKeyListener then
			return globalKeyListener(key, mods, isRepeat, label, unicode)
		end
		if chatWindows.visible and key == Spring.GetKeyCode("tab") and mods.ctrl then
			if mods.shift then
				chatWindows:CycleTab(-1)
			else
				chatWindows:CycleTab(1)
			end
			return true
		end
		return false
	end

	function externalFunctions.SetGlobalKeyListener(newListenerFunc)
		-- This is intentially set up such that there is only one global key
		-- listener at a time. This is indended for popups that monopolise input.
		globalKeyListener = newListenerFunc
	end

	function externalFunctions.GetLobbyInterfaceHolder()
		return lobbyInterfaceHolder
	end
	
	-------------------------------------------------------------------
	-- Listening
	-------------------------------------------------------------------
	local function onConfigurationChange(listener, key, value)
		if key == "panel_layout" then
			if value == 1 then
				externalFunctions.SetPanelDisplayMode(true)
			elseif value == 2 then
				externalFunctions.SetPanelDisplayMode(false, true)
			elseif value == 3 then
				externalFunctions.SetPanelDisplayMode(false, false)
			end
		elseif key == "singleplayer_mode" then
			heading_image.file = Configuration:GetHeadingImage(doublePanelMode)
			heading_image:Invalidate()

			local newShortname = Configuration.shortnameMap[value]
			local replacementTabs = Configuration:GetGameConfig(false, "singleplayerMenu.lua", newShortname) or {}

			mainWindowHandler.SetBackAtMainMenu()
			mainWindowHandler.ReplaceSubmenu(1, replacementTabs)
		end
	end
	Configuration:AddListener("OnConfigurationChange", onConfigurationChange)

	-------------------------------------------------------------------
	-- Initialization
	-------------------------------------------------------------------
	local screenWidth, screenHeight = Spring.GetWindowGeometry()

	battleStatusPanelHandler.Rescale(4, 70)
	rightPanelHandler.Rescale(2, 70)
	RescaleMainWindow(3, 70)

	externalFunctions.ViewResize(screenWidth, screenHeight)
	UpdatePadding(screenWidth, screenHeight)
	UpdateChildLayout()

	return externalFunctions
end

return GetInterfaceRoot