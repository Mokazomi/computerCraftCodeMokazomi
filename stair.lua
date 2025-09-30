-- Function to check and refuel using the item in slot 1
function checkAndRefuel()
    turtle.select(1) -- Select slot 1
    if turtle.getFuelLevel() < 20 then -- Check if fuel level is below 20
        turtle.refuel(1) -- Refuel using one item from slot 1
        print("Refueled. Current fuel level: " .. turtle.getFuelLevel())
    else
        -- print("Fuel level is sufficient: " .. turtle.getFuelLevel())
    end
end

-- Function to check if inventory is full
function isInventoryFull()
    for slot = 1, 16 do
        if turtle.getItemCount(slot) == 0 then
            return false -- Found an empty slot, inventory is not full
        end
    end
    return true -- All slots are filled
end

-- Function to make stairs down
function makeStairsDown(length, startLevel)
    local start = startLevel or 1
    for i = start, length do
        checkAndRefuel() -- Check and refuel often during the process
        if isInventoryFull() then
            print("Inventory is full. Stopping mining.")
            -- Save progress before stopping
            -- local currentPos = persistence.getCurrentPosition()
            -- persistence.saveStairState(length, i, currentPos)
            return -- Stop mining if inventory is full
        end
        turtle.digUp()
        if turtle.detectDown() then
            turtle.digDown() -- Dig down if there's a block
        end
        turtle.down() -- Move down
        if turtle.detect() then
            turtle.dig() -- Dig forward if there's a block
        end
        turtle.forward() -- Move forward
        
        -- Save progress after each level
        -- local currentPos = persistence.getCurrentPosition()
        -- persistence.saveStairState(length, i, currentPos)
        
        print("lvl" .. i .. "/" .. length .. "|fuel:" .. turtle.getFuelLevel())
    end
end

-- Load persistence library
-- local persistence = require("persistence")

-- Main execution
checkAndRefuel() -- Initial refuel check before starting

-- Check for saved state
-- local savedState = persistence.loadStairState()
local length, startLevel

-- if savedState and persistence.askResume("stair building") then
--     print("Resuming stair building operation...")
--     length = savedState.length
--     startLevel = savedState.currentLevel
--     print("Resuming from level " .. startLevel .. " of " .. length)
-- else
print("Starting new stair building operation...")
-- Ask user for the length of the stairs
print("Enter the length of the stairs:")
length = tonumber(io.read())
startLevel = 1
-- end

makeStairsDown(length, startLevel) -- Start making stairs down

-- Clear saved state when operation completes
-- persistence.clearStairState()
print("Stair building operation completed!")