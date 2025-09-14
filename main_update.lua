-- Main update script
-- This script calls the update system in the update folder

print("=== ComputerCraft Update System ===")
print("Loading update system...")

-- Check if update folder exists
if not fs.exists("update") then
    print("Error: Update folder not found!")
    print("Please make sure the 'update' folder exists with all update files.")
    return
end

-- Check if update script exists
if not fs.exists("update/update.lua") then
    print("Error: Update script not found!")
    print("Please make sure 'update/update.lua' exists in the update folder.")
    return
end

-- Run the update script
print("Starting update system...")
shell.run("lua update/update.lua")
