-- Bootstrap script for ComputerCraft Update System
-- This single file downloads and sets up the entire update system
-- Run this once to get all update files, then use update.lua normally

-- Note: In ComputerCraft, fs is a global API, no require needed

-- Configuration: Pastebin URLs for the update system files
-- Replace these with your actual Pastebin URLs for the update system
local BOOTSTRAP_URLS = {
    main_update = "https://pastebin.com/raw/Tdpivx57",
    main_setup = "https://pastebin.com/raw/9ATsdUDW",
    update_script = "https://pastebin.com/raw/tM1V1gSi",
    setup_script = "https://pastebin.com/raw/MEBn76L9", 
    config_file = "https://pastebin.com/raw/T6GHWDDK"
}

-- File paths for the update system files
local UPDATE_FILES = {
    main_update = "main_update.lua",
    main_setup = "main_setup.lua",
    update_script = "update/update.lua",
    setup_script = "update/setup_update.lua",
    config_file = "update/update_config.lua"
}

-- Function to download content from URL
function downloadFromUrl(url, filename)
    print("Downloading " .. filename .. " from: " .. url)
    local response = http.get(url)
    if response then
        local content = response.readAll()
        response.close()
        return content
    else
        print("Error: Failed to download " .. filename .. " from " .. url)
        return nil
    end
end

-- Function to create directory if it doesn't exist
function createDirectory(path)
    if not fs.exists(path) then
        fs.makeDir(path)
        print("Created directory: " .. path)
        return true
    end
    return false
end

-- Function to write content to file
function writeToFile(filepath, content)
    local file = fs.open(filepath, "w")
    if file then
        file.write(content)
        file.close()
        print("Successfully created: " .. filepath)
        return true
    else
        print("Error: Could not write to " .. filepath)
        return false
    end
end

-- Function to download and set up a single file
function setupFile(fileKey, url, filepath)
    print("\n=== Setting up " .. fileKey .. " ===")
    
    if url:find("YOUR_.*_PASTEBIN_ID") then
        print("Warning: " .. fileKey .. " URL not configured. Please update BOOTSTRAP_URLS table.")
        return false
    end
    
    -- Download content
    local content = downloadFromUrl(url, fileKey)
    if not content then
        print("Failed to download " .. fileKey)
        return false
    end
    
    -- Write to file
    if writeToFile(filepath, content) then
        return true
    else
        return false
    end
end

-- Function to set up the entire update system
function setupUpdateSystem()
    print("=== ComputerCraft Update System Bootstrap ===")
    print("This will download and set up the entire update system.")
    print("You only need to run this once to get all update files.")
    print()
    
    -- Check if update folder already exists
    if fs.exists("update") then
        print("Update folder already exists.")
        print("Do you want to overwrite existing files? (y/n)")
        local input = read()
        if input:lower() ~= "y" and input:lower() ~= "yes" then
            print("Bootstrap cancelled.")
            return false
        end
    end
    
    print("Press Enter to continue or Ctrl+T to cancel...")
    read()
    
    -- Create update directory
    createDirectory("update")
    
    local successCount = 0
    local totalCount = 0
    
    -- Download each file
    for fileKey, filepath in pairs(UPDATE_FILES) do
        local url = BOOTSTRAP_URLS[fileKey]
        totalCount = totalCount + 1
        
        if setupFile(fileKey, url, filepath) then
            successCount = successCount + 1
        end
    end
    
    print("\n=== Bootstrap Summary ===")
    print("Successfully set up: " .. successCount .. "/" .. totalCount .. " files")
    
    if successCount == totalCount then
        print("\n✅ Update system bootstrap completed successfully!")
        print("\nNext steps:")
        print("1. Run 'lua main_setup.lua' to configure Pastebin URLs")
        print("2. Run 'lua main_update.lua' to update your programs")
        print("\nThe update system is now ready to use!")
        return true
    else
        print("\n❌ Some files failed to download.")
        print("Please check the BOOTSTRAP_URLS table and try again.")
        return false
    end
end

-- Function to show current configuration
function showConfig()
    print("=== Bootstrap Configuration ===")
    print("Current URLs for update system files:")
    for fileKey, url in pairs(BOOTSTRAP_URLS) do
        print(fileKey .. ": " .. url)
    end
    print("\nTo update URLs, edit the BOOTSTRAP_URLS table in this script.")
end

-- Main menu
function showMenu()
    print("\n=== ComputerCraft Bootstrap Menu ===")
    print("1. Set up update system")
    print("2. Show configuration")
    print("3. Exit")
    print("\nEnter your choice (1-3):")
end

-- Main execution
function main()
    while true do
        showMenu()
        local choice = read()
        
        if choice == "1" then
            setupUpdateSystem()
        elseif choice == "2" then
            showConfig()
        elseif choice == "3" then
            print("Exiting bootstrap script...")
            break
        else
            print("Invalid choice. Please enter 1-3.")
        end
        
        print("\nPress Enter to continue...")
        read()
    end
end

-- Run main function
main()