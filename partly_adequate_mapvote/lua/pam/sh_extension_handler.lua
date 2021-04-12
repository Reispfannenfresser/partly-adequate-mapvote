PAM.extension_handler = {}
PAM.extensions = {}

local extension_map = {}

local setting_namespace

if SERVER then
	setting_namespace = pacoman.server_settings
else
	setting_namespace = pacoman.client_settings
end

function PAM.extension_handler.DisableExtension(extension)
	extension.enabled = false

	if not extension.OnDisable then return end

	extension.OnDisable()
end

function PAM.extension_handler.EnableExtension(extension)
	extension.enabled = true

	if not extension.OnEnable then return end

	extension.OnEnable()
end

function PAM.extension_handler.RegisterExtension(extension)
	local extension_name = extension.name
	print('[PAM] Registering extension "' .. extension_name .. '"!')

	local id = extension_map[extension_name] or #PAM.extensions + 1
	extension.id = id

	PAM.extensions[id] = extension
	extension_map[extension_name] = id

	local setting_path = {"pam", extension_name}
	local setting_id = "is_enabled"

	setting_namespace:AddSetting(setting_path, setting_id, pacoman.P_TYPE_BOOLEAN, extension.enabled)

	extension.enabled = setting_namespace:GetActiveValue(setting_path, setting_id)

	setting_namespace:AddCallback(setting_path, setting_id, function(value)
		if value then
			PAM.extension_handler.EnableExtension(extension)
			return
		end
		PAM.extension_handler.DisableExtension(extension)
	end)
end

if SERVER then
	local sv_extensions, _ = file.Find("pam/server/extensions/*.lua", "LUA")
	local cl_extensions, _ = file.Find("pam/client/extensions/*.lua", "LUA")
	for i = 1, #sv_extensions do
		local sv_extension = sv_extensions[i]
		include("pam/server/extensions/" .. sv_extension)
	end

	for i = 1, #cl_extensions do
		local cl_extension = cl_extensions[i]
		AddCSLuaFile("pam/client/extensions/" .. cl_extension)
	end
else
	local cl_extensions, _ = file.Find("pam/client/extensions/*.lua", "LUA")
	for i = 1, #cl_extensions do
		local cl_extension = cl_extensions[i]
		include("pam/client/extensions/" .. cl_extension)
	end
end

function PAM.extension_handler.OnInitialize()
	for i = 1,#PAM.extensions do
		local extension = PAM.extensions[i]
		if extension.enabled and extension.OnInitialize  then
			extension.OnInitialize()
		end
	end
end

hook.Add("Initialize", "PAM_Initialize_Extensions", PAM.extension_handler.OnInitialize)
