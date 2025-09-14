-- Configuration file for update script
-- Update these URLs with your actual Pastebin links

local config = {}

-- Pastebin URLs for each program
-- Replace the placeholder URLs with your actual Pastebin raw URLs
config.PASTEBIN_URLS = {
    -- Main programs
    mine = "https://pastebin.com/raw/XuTGmjrT",
    stair = "https://pastebin.com/raw/4X1sdnX4", 
    tree = "https://pastebin.com/raw/QHDxs2fD",
    persistence = "https://pastebin.com/raw/nMvKBJF2",
    
    -- Update system files
    update = "https://pastebin.com/raw/tM1V1gSi",
    setup = "https://pastebin.com/raw/MEBn76L9",
    config = "https://pastebin.com/raw/T6GHWDDK"
}

-- File paths for each program (relative to the main directory)
config.FILE_PATHS = {
    mine = "mine.lua",
    stair = "stair.lua", 
    tree = "tree.lua",
    persistence = "persistence.lua"
}

-- Update settings
config.SETTINGS = {
    -- Whether to create backups before updating
    createBackups = false,
    
    -- Backup file extension
    backupExtension = ".backup",
    
    -- Whether to ask for confirmation before updating
    askConfirmation = true,
    
    -- Whether to update the update system when updating all
    updateSelfWhenUpdatingAll = true
}

return config
