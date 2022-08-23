
-- Registry Editor
-- v1.0.0
-- https://github.com/ayvacs/registry

local reg = {}


local isRegInit = false
function reg.init(force: bool)
	if not force and isRegInit then
		return 0--, warn("The registry is already initialized")
	end
	
	local HANDLE_SERVER = Inst("Folder", script, { Name = "HANDLE_SERVER" })
	print("Registry | Successfully initialized")
	isRegInit = true
	return 1
end

-- DataTypes for creating -Value Instances
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



function reg.test()
	reg.init()
	print("Hello there")
end

function reg.pathNameToInstance(PathName: string)
	-- Input a path name, receive an instance.
	-- e.g.: if PathName == "HANDLE_SERVER.MyKey.ThisIsAnotherKey", return ThisIsAnotherKey instance.
	
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

function reg.newKey(FullPath: string)
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
	print("Registry | Key \"" .. KeyName .. "\" has been created inside \"" .. PathToParentKey .. "\"")
	
	return {
		
		set = function(Name: string, EntryType: string, EntryValue: any)
			return reg.set(FullPath .. "." .. Name, EntryType, EntryValue)
		end,

		get = function(Name: string)
			return reg.get(FullPath .. "." .. Name)
		end
		
	}
end

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


return reg