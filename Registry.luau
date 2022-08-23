
-- Registry Editor
-- v1.0.2
-- https://github.com/ayvacs/registry

local manifest = setmetatable({   __version = 3.2,

	["Name"] = "Registry Editor",
	["ProductName"] = "Registry Editor 1.0.2 [Stable Release]",
	["Url"] = "https://github.com/ayvacs/registry",

	["Version"] = {
		["Name"] = "1.0.2"
	}

},{
	["__index"] = function(table, index)
		pcall(function()
			print("Registry | Index [\"" .. tostring(index) .. "\"] does not exist in manifest")
		end)
	end
})

local reg = {}
local isRegInit = false

local Players = game:GetService("Players")

-- HKey references, for initialization
local ValidHKeys = {
	"HKEY_PLAYERS",
	"HKEY_SERVER",
	"HKEY_SERVICES"
}

-- DataType references, for creating -Value Instances
local DataTypes = {
	["bool"] = {"Bool"},
	["brickcolor"] = {"BrickColor"},
	["cframe"] = {"CFrame"},
	["color3"] = {"Color3"},
	["float"] = {"Number"},
	["int"] = {"Int"},
	["object"] = {"Object"},
	["ray"] = {"Ray"},
	["str"] = {"String"},
	["vector3"] = {"Vector3"}
}

-- Initialize the registry
-- If `force` == true, the registry will re-initialize. This might break some things.
function reg.init(force: bool)
	if not force and isRegInit then
		return 0--, warn("The registry is already initialized")
	end

	print("Registry | Successfully initialized")
	isRegInit = true
	return 1
end

-- Improved Instance.new function
function Inst(DataType: string, Parent: Instance, Properties: table)
	if not DataType then
		return warn("Registry | Invalid DataType")
	end
	if not Properties then
		Properties = {}
	end
	if Parent then
		Properties.Parent = Parent
	end

	local inst = Instance.new(DataType)
	for i, v in pairs(Properties) do
		inst[i] = v
	end

	return inst
end

-- Just a testing function
function reg.test()
	reg.init()
	print("Hello there")
end

-- Input a path name, receive an instance.
-- if PathName == "HKEY_SERVER.MyKey.ThisIsAnotherKey", return the ThisIsAnotherKey instance.
function reg.pathNameToInstance(PathName: string)
	local segments = PathName:split(".")

	if #segments == 1 and script:FindFirstChild(segments[1]) then
		return script:FindFirstChild(segments[1])
	end

	local SelectedInstance = script
	for i, v in pairs(segments) do
		if not SelectedInstance:FindFirstChild(v) then
			print("Registry | Key \"" .. v .. "\" did not exist while parsing pathName. It has been created.")
			Inst("Folder", SelectedInstance, { Name = v })
		end

		SelectedInstance = SelectedInstance:FindFirstChild(v)
	end

	return SelectedInstance
end

-- Returns true if a key or entry exists, false if it doesn't.
function reg.doesExist(FullPath)
	if not FullPath then
		return warn("Registry | There was an error while checking if a key exists: Invalid path")
	end

	local segments = FullPath:split(".")
	local SelectedInstance = script

	for i, v in pairs(segments) do
		-- if this is the last key in the path and a key with the same name exists, then it, well, already exists.
		-- if this is NOT the last key in the path and a key with the same name exists, then loop again.
		-- if this is NOT the last key in that path and a key with the same name exists, then break the loop.
		if i == #segments and SelectedInstance:FindFirstChild(v) then
			return true
		end
		if SelectedInstance:FindFirstChild(v) then
			SelectedInstance = SelectedInstance:FindFirstChild(v)
		else break
		end
	end

	return false
end

-- Creates a new key.
function reg.newKey(FullPath: string, PrintModeDisabled: bool)
	reg.init()

	if not FullPath then
		return warn("Registry | There was an error while creating a key: Invalid path")
	end

	local segments = FullPath:split(".")
	local PathToParentKey = ""
	local KeyName = ""

	-- check if it exists first
	if reg.doesExist(FullPath) then
		return warn("Registry | Key \"" .. FullPath .. "\" already exists. It has not been created.")
	end

	-- cont
	for i, v in pairs(segments) do
		if i == #segments then
			KeyName = v
		else
			if i ~= 1 then
				PathToParentKey ..= "."
			end
			PathToParentKey ..= v
		end
	end

	local key = Inst("Folder", reg.pathNameToInstance(PathToParentKey), { Name = KeyName })
	if not PrintModeDisabled then print("Registry | Key \"" .. KeyName .. "\" has been created inside \"" .. PathToParentKey .. "\"") end

	return {

		set = function(Name: string, EntryType: string, EntryValue: any)
			return reg.set(FullPath .. "." .. Name, EntryType, EntryValue)
		end,

		get = function(Name: string)
			return reg.get(FullPath .. "." .. Name)
		end

	}
end

-- Sets an entry's value.
function reg.set(FullPath: string, EntryType: string, EntryValue: any)
	reg.init()

	if not FullPath then
		return warn("Registry | There was an error while setting an entry: Invalid path")
	end
	if (not EntryType) or (not DataTypes[EntryType]) then
		return warn("Registry | There was an error while setting an entry: Invalid type")
	end
	if not EntryValue then
		return warn("Registry | There was an error while setting an entry: Invalid value")
	end

	-- check if it exists first
	if reg.doesExist(FullPath) then
		return warn("Registry | Key \"" .. FullPath .. "\" already exists. It has not been created.")
	end

	local path = FullPath:split(".")

	-- remove everything after the last period
	local parentPathName = ""
	for i, v in pairs(path) do
		if i ~= 1 and i ~= #path then
			parentPathName ..= "."
		end
		if i ~= #path then
			parentPathName ..= v
		end
	end

	return Inst(DataTypes[EntryType][1] .. "Value", reg.pathNameToInstance(parentPathName), {
		["Name"] = path[#path],
		["Value"] = EntryValue
	})
end

-- Gets an entry's value, if it exists.
function reg.get(FullPath: string)
	reg.init()

	if not FullPath then
		return warn("Registry | There was an error while getting an entry: Invalid path")
	end

	local inst = reg.pathNameToInstance(FullPath)
	if not inst then
		return warn("Registry | There was an error while getting an entry: Entry does not exist")
	end

	return inst.Value
end



-- DEFAULT HKEY DATA


-- create all hkeys
for i, v in pairs(ValidHKeys) do
	Inst("Folder", script, { Name = v })
	print("Registry | Created HKey \"" .. v .. "\"")
end


-- HKEY_PLAYERS

-- when a player joins, create a key in HKEY_PLAYERS
Players.PlayerAdded:Connect(function(plr)
	reg.newKey("HKEY_PLAYERS." .. plr.UserId)
end)


-- HKEY_SERVICES

-- add metadata
reg.newKey("HKEY_SERVICES.RegistryEditor", true)
reg.newKey("HKEY_SERVICES.RegistryEditor.CurrentVersion", true)

reg.newKey("HKEY_SERVICES.Umbra", true)
reg.newKey("HKEY_SERVICES.Umbra.CurrentVersion", true)

reg.set("HKEY_SERVICES.RegistryEditor.CurrentVersion.Name", "str", manifest.Name)
reg.set("HKEY_SERVICES.RegistryEditor.CurrentVersion.ProductName", "str", manifest.ProductName)
reg.set("HKEY_SERVICES.RegistryEditor.CurrentVersion.Url", "str", manifest.Url)
reg.set("HKEY_SERVICES.RegistryEditor.CurrentVersion.Version", "str", manifest.Version.Name)

reg.set("HKEY_SERVICES.Umbra.CurrentVersion.Name", "str", "Umbra Sideloader")
reg.set("HKEY_SERVICES.Umbra.CurrentVersion.ProductName", "str", "Umbra Sideloader X 10.5.49.0091")
reg.set("HKEY_SERVICES.Umbra.CurrentVersion.Url", "str", "https://ave.is-a.dev/umbra")
reg.set("HKEY_SERVICES.Umbra.CurrentVersion.Version", "str", "10.5.49.0091")

-- return
return reg