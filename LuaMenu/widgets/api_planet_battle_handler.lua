--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Planet Battle Handler",
		desc      = "Handles creating the battle for planet invasion as well as reporting results.",
		author    = "GoogleFrog",
		date      = "6 February 2017",
		license   = "GNU LGPL, v2.1 or later",
		layer     = 0,
		enabled   = true  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Downloads

local function MaybeDownloadArchive(archiveName, archiveType)
	if not VFS.HasArchive(archiveName) then
		VFS.DownloadArchive(archiveName, archiveType)
	end
end

local function MaybeDownloadGame(gameName)
	MaybeDownloadArchive(gameName, "game")
end

local function MaybeDownloadMap(mapName)
	MaybeDownloadArchive(mapName, "map")
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Encording

local function TableToBase64(inputTable)
	if not inputTable then
		return 
	end
	return Spring.Utilities.Base64Encode(Spring.Utilities.TableToString(inputTable))
end

local function MakeCircuitDisableString(unlockedUnits)
	local Configuration = WG.Chobby.Configuration
	local unitList = Configuration.gameConfig.gameUnitInformation.nameList
	if not unitList then
		return nil
	end
	local unlockedMap = {}
	if unlockedUnits then
		for i = 1, #unlockedUnits do
			unlockedMap[unlockedUnits[i]] = true
		end
	end
	local disabled
	for i = 1, #unitList do
		if not unlockedMap[unitList[i]] then
			if not disabled then
				disabled = unitList[i]
			else
				disabled = disabled .. "+" .. unitList[i]
			end
		end
	end
	return disabled
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Start Game

local function StartBattleForReal(planetID, gameConfig, gameName)
	local allyTeams = {}
	local allyTeamCount = 0
	local teams = {}
	local teamCount = 0
	local players = {}
	local ais = {}
	local aiCount = 0
	local commanderTypes = {}
	
	local localLobby = WG.LibLobby.localLobby
	local Configuration = WG.Chobby.Configuration
	local playerName = Configuration.userName or Configuration.suggestedNameFromSteam or "Player"
	local bitExtension = (Configuration:GetIsRunning64Bit() and "64") or "32"

	-- Add the player, this is to make the player team 0.
	local playerCount = 1
	local players = {
		[0] = {
			Name = playerName,
			Team = teamCount,
			IsFromDemo = 0,
			rank = 0,
		},
	}
	
	local playerUnlocks = WG.CampaignData.GetUnitsUnlocks()
	local playerAbilities = WG.CampaignData.GetAbilityUnlocks()
	local fullPlayerUnlocks = Spring.Utilities.CopyTable(playerUnlocks.list)

	if gameConfig.playerConfig.extraUnlocks then
		local extra = gameConfig.playerConfig.extraUnlocks
		for i = 1, #extra do
			if not playerUnlocks.map[extra[i]] then
				fullPlayerUnlocks[#fullPlayerUnlocks + 1] = extra[i]
			end
		end
	end
	
	commanderTypes.player_commander = WG.CampaignData.GetPlayerCommander()
	
	teams[teamCount] = {
		TeamLeader = 0,
		AllyTeam = gameConfig.playerConfig.allyTeam,
		rgbcolor = '0 0 0',
		start_x = gameConfig.playerConfig.startX,
		start_z = gameConfig.playerConfig.startZ,
		staticcomm = "player_commander",
		static_level = WG.CampaignData.GetPlayerCommanderLevel(),
		campaignunlocks = TableToBase64(fullPlayerUnlocks),
		campaignabilities = TableToBase64(playerAbilities.list),
		commanderparameters = TableToBase64(gameConfig.playerConfig.commanderParameters),
		extrastartunits = TableToBase64(gameConfig.playerConfig.startUnits),
		retinuestartunits = TableToBase64(WG.CampaignData.GetActiveRetinue()),
	}
	teamCount = teamCount + 1
	
	-- Add the AIs
	for i = 1, #gameConfig.aiConfig do
		local aiData = gameConfig.aiConfig[i]
		local shortName = WG.CampaignData.GetAI(aiData.aiLib)
		if aiData.bitDependant then
			shortName = shortName .. bitExtension
		end
		
		ais[aiCount] = {
			Name = aiData.humanName,
			Team = teamCount,
			IsFromDemo = 0,
			ShortName = shortName,
			comm_merge = 0,
			Host = 0,
			Options = {
				comm_merge = 0,
				disabledunits = MakeCircuitDisableString(aiData.unlocks)
			}
		}
		aiCount = aiCount + 1
		
		local commanderName, noCommander
		if aiData.commander then
			commanderName = "ai_commander_" .. aiCount
			commanderTypes[commanderName] = aiData.commander
		else
			noCommander = 1
		end
		
		teams[teamCount] = {
			TeamLeader = 0,
			AllyTeam = aiData.allyTeam,
			rgbcolor = '0 0 0',
			start_x = aiData.startX,
			start_z = aiData.startZ,
			nocommander = noCommander,
			staticcomm = commanderName,
			static_level = aiData.commanderLevel or 1,
			campaignunlocks = TableToBase64(aiData.unlocks),
			commanderparameters = TableToBase64(aiData.commanderParameters),
			extrastartunits = TableToBase64(aiData.startUnits),
		}
		teamCount = teamCount + 1
	end
	
	-- Add allyTeams
	for i, teamData in pairs(teams) do
		if not allyTeams[teamData.AllyTeam] then
			allyTeams[teamData.AllyTeam] = {
				numallies = 0,
			}
		end
	end
	
	local script = {
		gametype = gameName,
		hostip = '127.0.0.1',
		hostport = 0,
		ishost = 1,
		mapname = gameConfig.mapName,
		myplayername = playerName,
		nohelperais = 0,
		numplayers = playerCount,
		numusers = playerCount + aiCount,
		startpostype = 0, -- Fixed
		modoptions = {
			commandertypes = TableToBase64(commanderTypes),
			defeatconditionconfig = TableToBase64(gameConfig.defeatConditionConfig),
			objectiveconfig = TableToBase64(gameConfig.objectiveConfig),
			bonusobjectiveconfig = TableToBase64(gameConfig.bonusObjectiveConfig),
			fixedstartpos = 1,
			singleplayercampaignbattleid = planetID
		},
	}

	for i, ai in pairs(ais) do
		script["ai" .. i] = ai
	end
	for i, player in pairs(players) do
		script["player" .. i] = player
	end
	for i, team in pairs(teams) do
		script["team" .. i] = team
	end
	for i, allyTeam in pairs(allyTeams) do
		script["allyTeam" .. i] = allyTeam
	end

	local scriptString = localLobby:MakeScriptTXT(script)
	--Spring.Echo("scriptString", scriptString)
	localLobby:StartGameFromString(scriptString)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External Functions
local PlanetBattleHandler = {}

function PlanetBattleHandler.StartBattle(planetID, planetData)
	local Configuration = WG.Chobby.Configuration
	local gameConfig = planetData.gameConfig

	if gameConfig.missionStartscript then
		Spring.Echo("PlanetBattleHandler implement missionStartscript.")
		return false
	end
	
	local gameName = Configuration:GetDefaultGameName()
	local haveGame = VFS.HasArchive(gameName)
	if not haveGame then
		WG.Chobby.InformationPopup("You do not have the game file required. It will now be downloaded.")
		MaybeDownloadGame(gameName)
		return
	end
	
	local haveMap = VFS.HasArchive(gameConfig.mapName)
	if not haveMap then
		WG.Chobby.InformationPopup("You do not have the map file required. It will now be downloaded.")
		MaybeDownloadMap(gameConfig.mapName)
		return
	end
	
	local function StartBattleFunc()
		if StartBattleForReal(planetID, gameConfig, gameName) then
			Spring.Echo("Start battle success!")
		end
	end
	
	if Spring.GetGameName() == "" then
		StartBattleFunc()
	else
		WG.Chobby.ConfirmationPopup(StartBattleFunc, "Are you sure you want to leave your current game to attack this planet?", nil, 315, 200)
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Widget Interface

function widget:Initialize()
	WG.PlanetBattleHandler = PlanetBattleHandler
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Circuit Config Handling

local function LoadCircuitConfig(circuitName, version)
	local path = "AI/Skirmish/" .. circuitName .. "/" .. version .. "/config/circuit.json"
	if VFS.FileExists(path) then
		local file = VFS.LoadFile(path)
		return Spring.Utilities.json.decode(file)
	end
	return false
end

local function SaveCircuitConfig(circuitName, version, index, configTable)
	local path = "AI/Skirmish/" .. circuitName .. "/" .. version .. "/config/temp" .. index .. ".json"
	local configFile = io.open(path, "w")
	configFile:write(Spring.Utilities.json.encode(configTable))
	configFile:close()
	return "temp" .. index
end

local function IsBadUnit(str)
	if string.len(str) < 9 then
		return false
	end
	if string.find(str, "cloak") or string.find(str, "gunship") or string.find(str, "plane") then
		return false
	end
	if string.find(str, "factory") or string.find(str, "hub") then
		return true
	end
	return false
end

function RecursivelyDeleteFactories(config)
	-- All passed by reference
	for key, value in pairs(config) do
		if IsBadUnit(key) then
			config[key] = nil
		end
		if type(value) == "table" then
			RecursivelyDeleteFactories(value)
		elseif type(value) == "string" and IsBadUnit(value) then
			if type(key) == "number" then
				local i = 1
				while i <= #config do
					if IsBadUnit(config[i]) then
						config[i] = config[#config]
						config[#config] = nil
					else
						i = i + 1
					end
				end
			else
				config[key] = nil
			end
		end
	end
end

--local config = LoadCircuitConfig(shortName, "stable")
--RecursivelyDeleteFactories(config)
--local configName = SaveCircuitConfig(shortName, "stable", aiCount, config)
