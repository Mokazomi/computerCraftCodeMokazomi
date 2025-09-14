-- Setup script for the update system
-- Helps configure Pastebin URLs for automatic updates

-- Note: In ComputerCraft, fs is a global API, no require needed

print("=== ComputerCraft Update Setup ===")
print("This script will help you configure the update system.")
print("You'll need to upload your programs to Pastebin first.")
print()

-- Function to update a single URL in the config
function updateUrl(programName, currentUrl)
    print("\nCurrent " .. programName .. " URL: " .. currentUrl)
    print("Enter new Pastebin raw URL (or press Enter to keep current):")
    local newUrl = read()
    
    if newUrl and newUrl ~= "" then
        return newUrl
    else
        return currentUrl
    end
end

-- Function to read current config
function readConfig()
    local configContent = ""
    if fs.exists("update/update_config.lua") then
        local file = fs.open("update/update_config.lua", "r")
        if file then
            configContent = file.readAll()
            file.close()
        end
    end
    return configContent
end

-- Function to write updated config
function writeConfig(content)
    local file = fs.open("update/update_config.lua", "w")
    if file then
        file.write(content)
        file.close()
        return true
    else
        print("Error: Could not write to update/update_config.lua")
        return false
    end
end

-- Main setup process
function main()
    print("Step 1: Upload your programs to Pastebin")
    print("1. Go to pastebin.com")
    print("2. Upload each program as a new paste")
    print("3. Get the raw URL for each paste")
    print("4. Raw URLs look like: https://pastebin.com/raw/XXXXXXXX")
    print()
    print("Press Enter when you have your Pastebin URLs ready...")
    read()
    
    -- Read current config
    local configContent = readConfig()
    
    -- Extract current URLs
    local urls = {}
    for program in configContent:gmatch('([%w_]+) = "([^"]*)"') do
        urls[program] = program
    end
    
    -- Update each URL
    print("\nStep 2: Configure Pastebin URLs")
    print("For each program, enter the Pastebin raw URL:")
    
    local newUrls = {}
    newUrls.mine = updateUrl("mine", urls.mine or "https://pastebin.com/raw/XuTGmjrT")
    newUrls.stair = updateUrl("stair", urls.stair or "https://pastebin.com/raw/4X1sdnX4")
    newUrls.tree = updateUrl("tree", urls.tree or "https://pastebin.com/raw/QHDxs2fD")
    newUrls.persistence = updateUrl("persistence", urls.persistence or "https://pastebin.com/raw/nMvKBJF2")
    
    print("\nStep 3: Configure Update System URLs")
    print("Now configure the update system files themselves:")
    newUrls.update = updateUrl("update", urls.update or "https://pastebin.com/raw/tM1V1gSi")
    newUrls.setup = updateUrl("setup", urls.setup or "https://pastebin.com/raw/MEBn76L9")
    newUrls.config = updateUrl("config", urls.config or "https://pastebin.com/raw/T6GHWDDK")
    
    -- Generate new config content
    local newConfig = [[-- Configuration file for update script
-- Update these URLs with your actual Pastebin links

local config = {}

-- Pastebin URLs for each program
-- Replace the placeholder URLs with your actual Pastebin raw URLs
config.PASTEBIN_URLS = {
    -- Main programs
    mine = "]] .. newUrls.mine .. [[",
    stair = "]] .. newUrls.stair .. [[", 
    tree = "]] .. newUrls.tree .. [[",
    persistence = "]] .. newUrls.persistence .. [[",
    
    -- Update system files
    update = "]] .. newUrls.update .. [[",
    setup = "]] .. newUrls.setup .. [[",
    config = "]] .. newUrls.config .. [["
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
]]
    
    -- Write new config
    if writeConfig(newConfig) then
        print("\nConfiguration updated successfully!")
        print("You can now run 'update.lua' to update your programs.")
    else
        print("Failed to update configuration.")
    end
    
    print("\nSetup completed!")
end

-- Run setup
main()
