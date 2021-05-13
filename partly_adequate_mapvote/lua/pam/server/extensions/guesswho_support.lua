PAM_EXTENSION.name = "guesswho_support"
PAM_EXTENSION.enabled = true

function PAM_EXTENSION:OnInitialize()
	if GAMEMODE_NAME ~= "guesswho" then return end

	-- lolleko/guesswho
	-- Reconstructing MiRe's MapVote api, because guesswho supports only their addon natively
	MapVote = {}
	MapVote.Start = PAM.Start

	-- Check for delayed RTV when the round ends
	hook.Add("GWOnRoundEnd", "PAM_Autostart_Delayed_RTV_Guesswho", function()
		PAM.CheckForDelayedRTV()
	end)
end
