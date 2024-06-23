--[[

RAED ME:
This script is designed to load all the module scripts on the Server's side and hook them up to events before they start executing code.

]]--

-------------------------
-- SERVICES --
-------------------------
local ServerScriptService = game:GetService("ServerScriptService")


-------------------------
-- VARIABLES --
-------------------------
local services = ServerScriptService.Server.Services

local tracker = {
    Load = {},
    Init = {},
    Start = {}
}


-------------------------
-- PRIVATE FUNCTIONS --
-------------------------
local function ServerPrint(...)
    print("[S]", ...)
end


local function ServerWarn(...)
    warn("[S]", ...)
end


local function LoadModule(module: ModuleScript)
    local startTime = tick()
    ServerPrint(`Loading module {module.Name}`)

    local success, result = pcall(function()
        local loadedModule = require(module)
        tracker.Load[module.Name] = loadedModule -- Appending the Module's returned table to the Load table so that we can start/initalize it.

        if loadedModule.Init then
            tracker.Init[module.Name] = false -- Telling the script that this module hasn't been initialized yet and will need to.
        end
        if loadedModule.Start then
            tracker.Start[module.Name] = false -- Telling the script that this module hasn't set itself up yet and will need to.
        end
    end)

    local endTime = tick()
    if success then
		ServerPrint(("|| Loaded module '%s'"):format(module.Name), ("(took %.3f seconds)"):format(endTime-startTime))
	else
		ServerWarn(("|| Failed to load module '%s'"):format(module.Name), ("(took %.3f seconds)\n%s"):format(endTime-startTime, result))
	end
end


local function InitializeModule(loadedModule, moduleName)
    -- Attaching functions to events.
    if not loadedModule.Init then
        return
    end

    ServerPrint(`|| Initialzing modue '{moduleName}' ||`)
    local startTime = tick()
    local success, result = pcall(function()
        loadedModule:Init()
        tracker.Init[moduleName] = true
    end)
    local endTime = tick()

    if success then
        ServerPrint(("|| Initialized module '%s'"):format(moduleName) ("(took %.3f seconds)"):format(endTime-startTime))
    else
        ServerWarn(("|| Failed to initialize module '%s'"):format(moduleName) ("(took %.3f seconds)\n%s"):format(endTime-startTime, result))
    end
end


local function StartModule (loadedModule, moduleName)
    -- Executing any code needed for this module.
    if not loadedModule.Start then
        return
    end

    ServerPrint(`|| Starting module '{moduleName}' ||`)
    local startTime = tick()
    local success, result = pcall(function()
        loadedModule:Start()
        tracker.Start[moduleName] = true
    end)
    local endTime = tick()

    if success then
        ServerPrint(("|| Started module '%s'"):format(moduleName) ("(took %.3f seconds)"):format(endTime-startTime))
    else
        ServerWarn(("|| Failed to start module '%s'"):format(moduleName) ("(took %.3f seconds)\n%s"):format(endTime-startTime), result)
    end
end

-------------------------
-- MAIN --
-------------------------
ServerWarn("=== STARTING SERVER || LOADING SERVICES ===")
for _, module in ipairs(services:GetChildren()) do
    LoadModule(module)
end


ServerWarn("=== INITIALZING MODULES ===")
for moduleName, _ in pairs(tracker.Init) do
    InitializeModule(tracker.Loaded[moduleName], moduleName)
end


ServerWarn("=== STARTING MODULES ===")
for moduleName, _ in pairs(tracker.Start) do
    StartModule(tracker.Loaded[moduleName], moduleName)
end


ServerWarn("=== SERVER LOADING FINISHED ===")
workspace:SetAttribute("ServerLoaded", true)