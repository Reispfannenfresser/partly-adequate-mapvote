local extension = {}
extension.name = "zombiesurvival_support"
extension.enabled = true

function extension.OnInitialize()
	if GAMEMODE_NAME ~= "zombiesurvival" then return end

	hook.Add("LoadNextMap", "PAM_Autostart_ZombieSurvival", function()
		PAM.Start()
		return true
	end)

	hook.Add("PostEndRound", "PAM_Autostart_Delayed_RTV_ZombieSurvival", function()
		PAM.CheckForDelayedRTV()
	end)
end

PAM.extension_handler.RegisterExtension(extension)