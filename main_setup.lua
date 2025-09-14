-- Main setup script
-- This script calls the setup system in the update folder

print("=== ComputerCraft Update Setup ===")
print("Loading setup system...")

-- Check if update folder exists
if not fs.exists("update") then
    print("Error: Update folder not found!")
    print("Please make sure the 'update' folder exists with all update files.")
    return
end

-- Check if setup script exists
if not fs.exists("update/setup_update.lua") then
    print("Error: Setup script not found!")
    print("Please make sure 'update/setup_update.lua' exists in the update folder.")
    return
end

-- Run the setup script
print("Starting setup system...")
shell.run("lua update/setup_update.lua")
