--[[

READ ME:
This Script handles the players loading screen when first joining the game.
This process is managed on the client.

]]--


-----------------------------
-- SERVICES --
-----------------------------
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")


-----------------------------
-- VARIABLES --
-----------------------------
local cloneGui = ReplicatedFirst.GUI.IntroMenu:Clone()
cloneGui.Parent = Players.LocalPlayer.PlayerGui
ReplicatedFirst:RemoveDefaultLoadingScreen()
local textLabel = cloneGui.Frame.LoadingText

-- CONSTANTS --
local LOADING_TEXT = "Loading"
local WAIT_FOR_SERVER = "Waiting for server"
local WAIT_FOR_CLIENT = "Waiting for client"


-----------------------------
-- MAIN --
-----------------------------
task.spawn(function()
	textLabel.Text = LOADING_TEXT
	task.wait(0.6)
	while not game:IsLoaded() do
		if textLabel.Text == LOADING_TEXT.."..." then
			textLabel.Text = LOADING_TEXT
			task.wait(0.6)
		end
		textLabel.Text = textLabel.Text.."."
		task.wait(0.6)
	end
end)


if not game:IsLoaded() then
	game.Loaded:Wait()
end


if not workspace:GetAttribute("ServerLoaded") then
	textLabel.Text = WAIT_FOR_SERVER
	task.wait(0.6)
	while not workspace:GetAttribute("ServerLoaded") do
		if textLabel.Text == WAIT_FOR_SERVER.."..." then
			textLabel.Text = WAIT_FOR_SERVER
			task.wait(0.6)
		end
		textLabel.Text = textLabel.Text.."."
		task.wait(0.6)
	end
end


if not workspace:GetAttribute("ClientLoaded") then
	textLabel.Text = WAIT_FOR_CLIENT
	task.wait(0.6)
	while not  workspace:GetAttribute("ClientLoaded") do
		if textLabel.Text == WAIT_FOR_CLIENT.."..." then
			textLabel.Text = WAIT_FOR_CLIENT
			task.wait(0.6)
		end
		textLabel.Text = textLabel.Text.."."
		task.wait(0.6)
	end
end


for _, element in ipairs(cloneGui:GetDescendants()) do
	if element:IsA("Frame") then
		TweenService:Create(element, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
	elseif element:IsA("TextLabel") then
		TweenService:Create(element, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
	end
end


task.wait(0.5)
cloneGui:Destroy()
script:Destroy()