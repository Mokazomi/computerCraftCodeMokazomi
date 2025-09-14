-- Function to check and refuel using the item in slot 1
function checkAndRefuel()
    turtle.select(1) -- Select slot 1
    if turtle.getFuelLevel() < 80 then -- Check if fuel level is below 20
        turtle.refuel(1) -- Refuel using one item from slot 1
        print("Refueled. Current fuel level: " .. turtle.getFuelLevel())
    else
        -- print("Fuel level is sufficient: " .. turtle.getFuelLevel())
    end
end

function placeSapling()
    
    -- Check if the item in slot 2 is a spruce sapling
    local saplingCheck, data = turtle.inspect()
    if saplingCheck and data.name == "minecraft:spruce_log" then
        local airCheck, data = turtle.inspect()
        while airCheck do
            -- print("Found air in tree " .. (i + 1) .. ".")
            turtle.dig()
            airCheck, data = turtle.inspect()
            checkAndRefuel()
        end
    end
    
    turtle.select(2) -- Select slot 2 to place the item
    turtle.place() -- Place the item from slot 2
end

function moveDownUntilMovmentObstructed()
    while not turtle.detectDown() do
        turtle.down()
    end
end

function moveBackUntilMovmentObstructed()
    while turtle.back() do
    end
end

function resetStartingPosition()
    print("Resetting starting position")
    local downCheck, data = turtle.inspectDown()
    if data.name ~= "minecraft:podzol" then
        print("No podzol found, resetting starting position")
        moveDownUntilMovmentObstructed()
        moveBackUntilMovmentObstructed()
        turtle.forward()
        turtle.forward()
        turtle.forward()
        turtle.up()
        turtle.up()
        turtle.up()
    end
    downCheck, data = turtle.inspectDown()
    if downCheck and data.name == "minecraft:podzol" then
        print("Podzol found, resetting starting position")
        turtle.back()
        turtle.back()
        moveDownUntilMovmentObstructed()
        moveBackUntilMovmentObstructed()
        local downCheck2, data2 = turtle.inspectDown()
        if downCheck2 and data2.name == "minecraft:cobblestone" then
            print("Cobblestone found, resetting starting position")
            turtle.forward()
            turtle.forward()
            turtle.forward()
            turtle.forward()
            turtle.turnRight()
            moveBackUntilMovmentObstructed()
            turtle.forward()
            turtle.forward()
            turtle.forward()
            turtle.up()
            turtle.up()
            turtle.up()
        else
            print("No cobblestone found, resetting starting position")
            turtle.forward()
            turtle.forward()
            turtle.forward()
            turtle.up()
            turtle.up()
            turtle.up()
        end

    end

end

function checkCharcoal()
    turtle.select(1)
    if turtle.getItemCount(1) < 10 then
        getMoreCharcoal()
    end
end

function getMoreCharcoal()
    print("Getting more charcoal")
    turtle.select(1)
    moveDownUntilMovmentObstructed()
    turtle.suckDown()
    resetStartingPosition()
end

function checkSapling()
    print("Checking for sapling")
    turtle.select(2)
    if turtle.getItemCount(2) < 32 then
        getMoreSapling()
    end
end

function getMoreSapling()
    print("Getting more sapling")
    turtle.select(2)
    moveDownUntilMovmentObstructed()
    turtle.back()
    turtle.suckDown()
    resetStartingPosition()
    turtle.digUp()
    turtle.up()
end

function clearPlatformAndPlaceSapling()
    print("Clearing platform and placing sapling")
    checkSapling()
    turtle.suckUp()
    turtle.suck()
    turtle.forward()
    turtle.suck()
    turtle.turnLeft()
    turtle.suck()
    turtle.select(2) -- Select slot 2 to place the item
    placeSapling() -- Place the item from slot 2
    turtle.turnRight()
    turtle.forward()
    turtle.turnLeft()
    turtle.suck()
    placeSapling()
    turtle.turnRight()
    turtle.back()
    placeSapling()
    turtle.back()
    placeSapling()
end
function dropInventory()
    for slot = 3, 16 do
        turtle.select(slot)
        turtle.dropDown()
    end
end

function fillFurnace()
    turtle.down()
    turtle.select(3) -- Select slot 3 to place the item
    turtle.place() -- Place the item from slot 3 into the furnace
end

-- Function to check and dig spruce logs
function digSpruceLog(numTrees, startTree)
    local i = startTree or 0
    while i < numTrees do
        checkAndRefuel() -- Check and refuel before digging
        checkCharcoal()
        turtle.digUp()
        turtle.up()
        print("Checking for spruce logs in tree " .. (i + 1) .. "/" .. numTrees)
        -- turtle.forward()
        local logCheck, data = turtle.inspect()
        local blockName = data.name
        if logCheck and blockName == "minecraft:spruce_log" then
            print("Found spruce log in tree " .. (i + 1) .. ".")
            local airCheck, data = turtle.inspect()
            while airCheck do
                -- print("Found air in tree " .. (i + 1) .. ".")
                turtle.dig()
                airCheck, data = turtle.inspect()
                checkAndRefuel()
            end
            os.sleep(5)
            print("Clearing platform and placing sapling in tree " .. (i + 1) .. "/" .. numTrees)
            clearPlatformAndPlaceSapling()
            i = i + 1 -- Increment i only when a tree is chopped down
        end
        local logCheck, data = turtle.inspect()
        local blockName = data.name
        if not logCheck then 
            print("Found air in tree " .. (i + 1) .. "/" .. numTrees)
            clearPlatformAndPlaceSapling()
        end

        turtle.digDown()
        turtle.down()
        print("Dropping inventory in tree " .. (i + 1) .. "/" .. numTrees)
        dropInventory()
        
        -- Save progress after each tree
        local currentPos = persistence.getCurrentPosition()
        local charcoalCount = turtle.getItemCount(1)
        local saplingCount = turtle.getItemCount(2)
        persistence.saveTreeState(numTrees, i, currentPos, charcoalCount, saplingCount)
        
        os.sleep(60) -- Wait for 60 seconds
        print("Finished checking for spruce logs in tree " .. (i + 1) .. "/" .. numTrees)
    end
end

function readInputWithTimeout(timeoutDuration)
    local timerId = os.startTimer(timeoutDuration)
    local input = ""
    while true do
        local event, param1, param2 = os.pullEvent()
        if event == "char" then
            -- User pressed a character key, append to input
            input = input .. param1
        elseif event == "key" and param1 == keys.enter then
            -- User pressed enter, process input
            return input
        elseif event == "timer" and param1 == timerId then
            -- Timeout occurred
            return nil -- No input received within the timeout
        end
    end
end


-- Load persistence library
local persistence = require("persistence")

-- Main execution
checkAndRefuel() -- Initial refuel check before starting
resetStartingPosition()

-- Check for saved state
local savedState = persistence.loadTreeState()
local numTrees, startTree

if savedState and persistence.askResume("tree farming") then
    print("Resuming tree farming operation...")
    numTrees = savedState.numTrees
    startTree = savedState.currentTree
    print("Resuming from tree " .. (startTree + 1) .. " of " .. numTrees)
else
    print("Starting new tree farming operation...")
    print("Enter the number of trees to process (default is 100 if no input in 5 seconds):")
    numTrees = 100

    local input = readInputWithTimeout(5) -- Wait for 5 seconds
    if input then
        numTrees = tonumber(input) or numTrees -- Convert input to number or keep default
    end
    startTree = 0
end

digSpruceLog(numTrees, startTree) -- Process the specified number of trees

-- Clear saved state when operation completes
persistence.clearTreeState()
print("Tree farming operation completed!")
