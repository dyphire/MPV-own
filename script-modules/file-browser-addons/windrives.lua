--[[
    Automatically populates the root with windows drives on startup.
    Ctrl+r will add new drives mounted since startup.

    Drives will only be added if they are not already present in the root.
]]

local mp = require 'mp'
local msg = require 'mp.msg'
local fb = require 'file-browser'

local function get_drives()
    local result = mp.command_native({
        name = 'subprocess',
        playback_only = false,
        capture_stdout = true,
        args = {'wmic', 'logicaldisk', 'get', 'caption'}
    })
    if result.status ~= 0 then return msg.error('could not read windows root') end

    local root = {}
    for drive in result.stdout:gmatch("%a:") do
        table.insert(root, drive..'/')
    end
    return root
end

local function in_root(drive, root)
    for _, item in ipairs(root) do
        if item.name == drive then return true end
    end
    return false
end

local function import_drives()
    local drives = get_drives()
    local root = fb.get_root()

    for _, drive in ipairs(drives) do
        if not in_root(drive, root) then
            fb.insert_root_item({ name = drive })
        end
    end
end

local keybind = {
    key = 'Ctrl+r',
    name = 'import_root_drives',
    command = import_drives,
    parser = 'root',
    passthrough = true
}

return {
    version = '1.3.0',
    setup = import_drives,
    keybinds = { keybind }
}
