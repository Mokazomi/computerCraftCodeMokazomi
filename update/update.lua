-- Update script for ComputerCraft programs
-- Downloads and updates all programs from Pastebin
-- This script can also update itself

-- Note: In ComputerCraft, http and fs are global APIs, no require needed

-- Load configuration
local config = require("update_config")
local PASTEBIN_URLS = config.PASTEBIN_URLS
local FILE_PATHS = config.FILE_PATHS
local SETTINGS = config.SETTINGS

-- Function to download content from URL
function downloadFromUrl(url)
    print("Downloading from: " .. url)
    local response = http.get(url)
    if response then
        local content = response.readAll()
        response.close()
        return content
    else
        print("Error: Failed to download from " .. url)
        return nil
    end
end

-- Function to backup existing file
function backupFile(filepath)
    print("Backup setting: " .. tostring(SETTINGS.createBackups))
    -- if SETTINGS.createBackups and fs.exists(filepath) then
    --     local backupPath = filepath .. SETTINGS.backupExtension
    --     fs.copy(filepath, backupPath)
    --     print("Backed up " .. filepath .. " to " .. backupPath)
    --     return true
    -- end
    return false
end

-- Function to update a single program
function updateProgram(programName)
    print("\n=== Updating " .. programName .. " ===")
    
    local url = PASTEBIN_URLS[programName]
    local filepath = FILE_PATHS[programName]
    
    if not url or url:find("YOUR_.*_PASTEBIN_ID") then
        print("Warning: " .. programName .. " URL not configured. Please update the PASTEBIN_URLS table.")
        return false
    end
    
    -- Backup existing file
    backupFile(filepath)
    
    -- Download new content
    local content = downloadFromUrl(url)
    if not content then
        print("Failed to download " .. programName)
        return false
    end
    
    -- Write new content to file
    local file = fs.open(filepath, "w")
    if file then
        file.write(content)
        file.close()
        print("Successfully updated " .. filepath)
        return true
    else
        print("Error: Could not write to " .. filepath)
        return false
    end
end

-- Function to update all programs
function updateAll()
    print("Starting update process...")
    print("This will download and update all programs from Pastebin.")
    if SETTINGS.createBackups then
        print("Existing files will be backed up with " .. SETTINGS.backupExtension .. " extension.")
    end
    if SETTINGS.askConfirmation then
        print("\nPress Enter to continue or Ctrl+T to cancel...")
        read()
    end
    
    local successCount = 0
    local totalCount = 0
    
    -- Update main programs
    for programName, _ in pairs(FILE_PATHS) do
        totalCount = totalCount + 1
        if updateProgram(programName) then
            successCount = successCount + 1
        end
    end
    
    -- Update update system if enabled
    if SETTINGS.updateSelfWhenUpdatingAll then
        print("\n=== Updating Update System ===")
        local updateSuccess = updateSelf()
        if updateSuccess then
            successCount = successCount + 1
        end
        totalCount = totalCount + 1
    end
    
    print("\n=== Update Summary ===")
    print("Successfully updated: " .. successCount .. "/" .. totalCount .. " programs")
    
    if successCount == totalCount then
        print("All programs updated successfully!")
    else
        print("Some programs failed to update. Check the URLs in the script.")
    end
    
    print("\nUpdate process completed.")
end

-- Function to update a specific program
function updateSpecific(programName)
    if not FILE_PATHS[programName] then
        print("Error: Unknown program '" .. programName .. "'")
        print("Available programs: " .. table.concat(table.keys(FILE_PATHS), ", "))
        return
    end
    
    print("Updating " .. programName .. "...")
    if updateProgram(programName) then
        print(programName .. " updated successfully!")
    else
        print("Failed to update " .. programName)
    end
end

-- Function to update the update system itself
function updateSelf()
    print("\n=== Updating Update System ===")
    print("This will update the update scripts themselves.")
    
    if SETTINGS.askConfirmation then
        print("Press Enter to continue or Ctrl+T to cancel...")
        read()
    end
    
    local updateUrls = {
        update = PASTEBIN_URLS.update or "https://pastebin.com/raw/tM1V1gSi",
        setup = PASTEBIN_URLS.setup or "https://pastebin.com/raw/MEBn76L9",
        config = PASTEBIN_URLS.config or "https://pastebin.com/raw/T6GHWDDK"
    }
    
    local updateFiles = {
        update = "update/update.lua",
        setup = "update/setup_update.lua", 
        config = "update/update_config.lua"
    }
    
    local successCount = 0
    local totalCount = 0
    
    for scriptName, url in pairs(updateUrls) do
        if not url:find("YOUR_.*_PASTEBIN_ID") then
            totalCount = totalCount + 1
            print("\nUpdating " .. scriptName .. "...")
            
            -- Backup existing file
            backupFile(updateFiles[scriptName])
            
            -- Download new content
            local content = downloadFromUrl(url)
            if content then
                -- Write new content to file
                local file = fs.open(updateFiles[scriptName], "w")
                if file then
                    file.write(content)
                    file.close()
                    print("Successfully updated " .. updateFiles[scriptName])
                    successCount = successCount + 1
                else
                    print("Error: Could not write to " .. updateFiles[scriptName])
                end
            else
                print("Failed to download " .. scriptName)
            end
        else
            print("Skipping " .. scriptName .. " (URL not configured)")
        end
    end
    
    print("\n=== Update System Summary ===")
    print("Successfully updated: " .. successCount .. "/" .. totalCount .. " update scripts")
    
    if successCount > 0 then
        print("Update system updated! You may need to restart the script.")
    end
    
    return successCount > 0
end

-- Function to show current configuration
function showConfig()
    print("=== Current Configuration ===")
    for programName, url in pairs(PASTEBIN_URLS) do
        print(programName .. ": " .. url)
    end
    print("\nTo update URLs, edit the PASTEBIN_URLS table in update_config.lua")
end

-- Function to restore from backup
function restoreFromBackup(programName)
    local filepath = FILE_PATHS[programName]
    local backupPath = filepath .. SETTINGS.backupExtension
    
    if fs.exists(backupPath) then
        fs.copy(backupPath, filepath)
        print("Restored " .. programName .. " from backup")
        return true
    else
        print("No backup found for " .. programName)
        return false
    end
end

-- Main menu
function showMenu()
    print("\n=== ComputerCraft Update Script ===")
    print("1. Update all programs")
    print("2. Update specific program")
    print("3. Update update system")
    print("4. Show configuration")
    print("5. Restore from backup")
    print("6. Exit")
    print("\nEnter your choice (1-6):")
end

-- Main execution
function main()
    while true do
        showMenu()
        local choice = read()
        
        if choice == "1" then
            updateAll()
        elseif choice == "2" then
            print("Enter program name (mine, stair, tree, persistence):")
            local programName = read()
            updateSpecific(programName)
        elseif choice == "3" then
            updateSelf()
        elseif choice == "4" then
            showConfig()
        elseif choice == "5" then
            print("Enter program name to restore (mine, stair, tree, persistence):")
            local programName = read()
            restoreFromBackup(programName)
        elseif choice == "6" then
            print("Exiting update script...")
            break
        else
            print("Invalid choice. Please enter 1-6.")
        end
        
        print("\nPress Enter to continue...")
        read()
    end
end

-- Run main function
main()
