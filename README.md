# Registry.lua: the Roblox Registry Editor

Stop using pointer tables and `_G`, switch to authenticated object-based storage. Keep confidential variables away from exploiters' hands. If you're familiar with Windows's `regedit` program, you'll love this.

## How it works

In the Registry, your variables are called Entries. They are stored inside of Keys, and *those* are stored inside of HKeys. You can think of this as documents within folders: documents *(Entries)* contain different types of data, and folders *(Keys)* contain documents. Your folders are stored inside of your Desktop and Documents libraries *(HKeys)*.

Keys and Entries are secure from exploiters and bad actors. *(as long as you set them up properly)*

## Setup

It's easy as 1, 2, 3:

1. Download the file named `Registry.luau` on the [latest release](https://github.com/ayvacs/registry/releases/latest/) page.
2. Copy the contents of this file to a `ModuleScript`.
	* We recommend you name the `ModuleScript` `reg`.
	* We recommend you place the `ModuleScript` in `ServerStorage` to secure your variables.
3. ...That's it!

## Usage

### Initialization

* Call the Registry inside a `Script`.

```
local reg = require(game:GetService("ServerStorage").reg)
```

* Initialize the Registry. *(the registry will automatically initialize when you use it for the first time, but initializing it first helps save time)*

```
reg.init()
```

### Storing your data

Recall that Entries are stored within Keys which are stored within HKeys.

* Create a Key named `foo` under `HKEY_SERVER`:

```
local foo = reg.newKey("HKEY_SERVER.foo")
```

* Create an `string` Entry named `bar` under the `foo` Key we just created.

```
foo.set("bar", "str", "This is my variable!")
```

```
reg.set("HKEY_SERVER.foo.bar", "str", "This is my variable!)
```

* Print the value of `HKEY_SERVER.foo.bar`.

```
print( foo.get("bar") )
```

```
print( reg.get("HKEY_SERVER.foo.bar") )
```

## Valid DataTypes

| Name | Corresponding Lua type |
| --- | --- |
| `bool` | `Bool` |
| `brickcolor` | `BrickColor` |
| `cframe` | `CFrame` |
| `color3` | `Color3` |
| `float` | `Number` |
| `int` | `Int` |
| `object` | `Object` |
| `ray` | `Ray` |
| `str` | `String` |
| `vector3` | `Vector3` |

## Valid HKeys

| Name | Description |
| --- | --- |
| `HKEY_PLAYERS` | Intended for storing information about Players. When a Player joins, a key will be mapped to their `UserId` if it doesn't already exist. A Player's Key will not be removed when they leave the game. |
| `HKEY_SERVER` | The default HKey for server-sided information. |
| `HKEY_SERVICES` | Workspace for installed services. |