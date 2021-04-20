local extension = {}
local panel = nil
extension.name = "default_votescreen"
extension.enabled = true

function extension.OnVoteStarted()
	panel = vgui.Create("pam_default_votescreen")
end

function extension.OnVoteCanceled()
	panel:Remove()
end

function extension.OnVoterAdded(ply, map_id)
	panel:AddVoter(ply, map_id)
end

function extension.OnVoterRemoved(ply)
	panel:RemoveVoter(ply)
end

function extension.OnWinnerAnnounced()
	panel:AnnounceWinner()
end

function extension.ToggleVisibility()
	panel:SetVisible(not panel:IsVisible())
end

function extension.OnEnable()
	if PAM.state != PAM.STATE_DISABLED then
		extension.OnVoteStarted()
		for steam_id, option_id in pairs(PAM.votes) do
			extension.OnVoterAdded(player.GetBySteamID(steam_id), option_id)
		end
	end
	if PAM.state == PAM.STATE_FINISHED then
		extension.OnWinnerAnnounced()
	end
end

function extension.OnDisable()
	if PAM.state != PAM.STATE_DISABLED then
		panel:Remove()
	end
end

PAM.extension_handler.RegisterExtension(extension)

local setting_namespace = PAM.setting_namespace:AddChild(extension.name)
setting_namespace:AddSetting("scale", pacoman.TYPE_INTEGER, 100):AddCallback("default", function(new_value)
	include("pam/client/extensions/default_votescreen_panel.lua")
	if not extension.enabled then return end

	extension.OnDisable()
	extension.OnEnable()
end)

include("pam/client/extensions/default_votescreen_panel.lua")
