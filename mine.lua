-- Load persistence library
local persistence = require("persistence")

-- Global variables to store starting position and facing direction
local startingPosition = nil
local startingFacing = nil
local firstChestFull = false
local secondChestFull = false
local currentFacing = "north"  -- Track current facing direction (north, south, east, west)

-- Debug settings - set to false to disable debug output
local DEBUG_ENABLED = true

-- Debug print function
function debugPrint(message)
    if DEBUG_ENABLED then
        print("[DEBUG] " .. message)
    end
end

-- Function to get and save starting position and facing direction
function getStartingPosition()
    if not startingPosition then
        print("Getting starting position from GPS...")
        startingPosition = persistence.getCurrentPosition()
        if startingPosition.relative then
            print("Warning: GPS not available, using relative positioning")
            print("Starting position: (0, 0, 0) - relative")
        else
            print("Starting position: (" .. startingPosition.x .. ", " .. startingPosition.y .. ", " .. startingPosition.z .. ")")
        end
    end
    
    if not startingFacing then
        startingFacing = currentFacing
        print("Starting facing direction: " .. startingFacing)
    end
    
    return startingPosition, startingFacing
end

-- Function to get current position differences from starting position
function getCurrentPositionDifferences()
    local currentPos = persistence.getCurrentPosition()
    return persistence.calculatePositionDifferences(currentPos, startingPosition, startingFacing)
end

-- Function to calculate mining progress based on the snake pattern
function getMiningProgress(positionDiffs, length, width)
    local absRow = math.abs(positionDiffs.row)
    local absCol = math.abs(positionDiffs.col)
    
    -- In a snake pattern, we need to determine which "row" we're in
    -- and how far along that row we are
    local currentRow = absRow
    local currentCol = absCol
    
    -- If we're on an even row (0, 2, 4...), we're going forward
    -- If we're on an odd row (1, 3, 5...), we're going backward
    if currentRow % 2 == 1 then
        -- On odd rows, we're going backward, so invert the column
        currentCol = length - 1 - currentCol
    end
    
    return {
        row = currentRow,
        col = currentCol,
        totalRows = width,
        totalCols = length
    }
end

-- Function to check if we've completed the mining area
function isMiningComplete(positionDiffs, length, width)
    local absCol = math.abs(positionDiffs.col)
    local isComplete = absCol > length - 1
    debugPrint("Row complete check: col=" .. positionDiffs.col .. " (abs=" .. absCol .. "), length=" .. length .. ", complete=" .. tostring(isComplete))
    return isComplete
end

-- Function to check if we've completed the current row
function isRowComplete(positionDiffs, length)
    local absRow = math.abs(positionDiffs.row)
    local isComplete = absRow > width - 1
    debugPrint("Mining complete check: row=" .. positionDiffs.row .. " (abs=" .. absRow .. "), width=" .. width .. ", complete=" .. tostring(isComplete))
    return isComplete
end

-- Function to update facing direction when turtle turns
-- north(-z) -> east(+x) -> south(+z) -> west(-x)
function updateFacingDirection(turnDirection)
    if turnDirection == "right" then
        if currentFacing == "north" then
            currentFacing = "east"
        elseif currentFacing == "east" then
            currentFacing = "south"
        elseif currentFacing == "south" then
            currentFacing = "west"
        elseif currentFacing == "west" then
            currentFacing = "north"
        end
    elseif turnDirection == "left" then
        if currentFacing == "north" then
            currentFacing = "west"
        elseif currentFacing == "west" then
            currentFacing = "south"
        elseif currentFacing == "south" then
            currentFacing = "east"
        elseif currentFacing == "east" then
            currentFacing = "north"
        end
    end
end

function mmine(length, width, startRow, startT, startI)
    torchnum = 0
    local length = tonumber(length)
    local width = tonumber(width)
    t = startT or 0
    
    -- Get current position differences
    local positionDiffs = getCurrentPositionDifferences()
    
    -- If resuming, start from the saved position
    if startRow and startI then
        print("Resuming from row " .. startRow .. " of " .. width .. ", position " .. startI .. " of " .. length)
    end
    
    while not isMiningComplete(positionDiffs, length, width) do
        print("Row:   ", positionDiffs.row, "/", width)
        RefuelIfNeeded()
        print("Fuel:  ", turtle.getFuelLevel())
        
        -- Save progress at the start of each row
        local currentPos = persistence.getCurrentPosition()
        persistence.saveMineState(length, width, currentPos, direction, torchBool, offset, torchnum, t, startingPosition, startingFacing)
        
        while not isRowComplete(positionDiffs, length) do
            debugPrint("Mining at position: row=" .. positionDiffs.row .. " (abs=" .. math.abs(positionDiffs.row) .. "), col=" .. positionDiffs.col .. " (abs=" .. math.abs(positionDiffs.col) .. ") (target length=" .. length .. ")")
            turtle.digUp()
            turtle.digDown()
            DigUntilEmpty()
            PlaceTorch(t)
            CheckForwrd()
            
            -- Update position differences after moving
            positionDiffs = getCurrentPositionDifferences()
            debugPrint("After moving: row=" .. positionDiffs.row .. " (abs=" .. math.abs(positionDiffs.row) .. "), col=" .. positionDiffs.col .. " (abs=" .. math.abs(positionDiffs.col) .. ")")
            
            -- Save progress after each forward movement
            if persistence and width and length then
                local currentPos = persistence.getCurrentPosition()
                persistence.saveMineState(length, width, currentPos, direction, torchBool, offset, torchnum, t, startingPosition, startingFacing)
            end
            t = t + 1
        end
        
        -- Check if we need to turn to the next column
        if positionDiffs.col + 1 < length then
            if positionDiffs.col % 2 == 0 then
                corner(true)
            else
                corner(false)
            end
            -- Update position differences after turning
            positionDiffs = getCurrentPositionDifferences()
        end
        
    end
    turtle.digUp()
    turtle.digDown()
end

function corner(right)
    if right == true then
        if direction == "r" then
            CornerRight()
        else
            CornerLeft()
        end
    else
        if direction == "r" then
            CornerLeft()
        else
            CornerRight()
        end
    end
end

function CornerRight()
    turtle.digUp()
    turtle.digDown()
    turtle.turnRight()
    updateFacingDirection("right")
    DigUntilEmpty()
    PlaceTorch(t)
    turtle.forward()
    -- Save progress after corner movement
    if persistence and width and length then
        local currentPos = persistence.getCurrentPosition()
        persistence.saveMineState(length, width, currentPos, direction, torchBool, offset, torchnum, t, startingPosition, startingFacing)
    end
    turtle.turnRight()
    updateFacingDirection("right")
end

function CornerLeft()
    turtle.digUp()
    turtle.digDown()
    turtle.turnLeft()
    updateFacingDirection("left")
    DigUntilEmpty()
    PlaceTorch(t)
    turtle.forward()
    -- Save progress after corner movement
    if persistence and width and length then
        local currentPos = persistence.getCurrentPosition()
        persistence.saveMineState(length, width, currentPos, direction, torchBool, offset, torchnum, t, startingPosition, startingFacing)
    end
    turtle.turnLeft()
    updateFacingDirection("left")
end

function comeBack(length, width)
    local length = tonumber(length)
    local width = tonumber(width)
    local positionDiffs = getCurrentPositionDifferences()
    
    if width % 2 == 0 then
        TrueTurn()
        -- Move back to starting row
        while math.abs(positionDiffs.row) > 0 do
            turtle.forward()
            positionDiffs = getCurrentPositionDifferences()
            -- Save progress after each movement in comeBack
            if persistence and width and length then
                local currentPos = persistence.getCurrentPosition()
                persistence.saveMineState(length, width, currentPos, direction, torchBool, offset, torchnum, t, startingPosition, startingFacing)
            end
        end
        TrueTurn()
    else
        turtle.turnRight()
        turtle.turnRight()
        -- Move back to starting column
        while math.abs(positionDiffs.col) > 0 do
            turtle.forward()
            positionDiffs = getCurrentPositionDifferences()
            -- Save progress after each movement in comeBack
            if persistence and width and length then
                local currentPos = persistence.getCurrentPosition()
                persistence.saveMineState(length, width, currentPos, direction, torchBool, offset, torchnum, t, startingPosition, startingFacing)
            end
        end
        TrueTurn()
        -- Move back to starting row
        while math.abs(positionDiffs.row) > 0 do
            turtle.forward()
            positionDiffs = getCurrentPositionDifferences()
            -- Save progress after each movement in comeBack
            if persistence and width and length then
                local currentPos = persistence.getCurrentPosition()
                persistence.saveMineState(length, width, currentPos, direction, torchBool, offset, torchnum, t, startingPosition, startingFacing)
            end
        end
        TrueTurn()
    end
end

function TrueTurn()
    if direction == "r" then
        turtle.turnRight()
        updateFacingDirection("right")
    else
        turtle.turnLeft()
        updateFacingDirection("left")
    end
end

function PlaceTorch(i)
    if torchBool == 1 then
        if i % offset == 0 then
            if torchnum % 10 == 0 then
                turtle.select(2)
                turtle.digDown()
                turtle.placeDown()
            end
            torchnum = torchnum + 1
        end
    end
    --torchnum = torchnum + 1
end

function DigUntilEmpty()
    InvCheck()
    while turtle.detect() do
        turtle.dig()
        InvCheck()
    end
    InvCheck()
end

function CheckForwrd()
    while turtle.forward() == false do
        DigUntilEmpty()
        turtle.attack()
    end
    -- Save progress after each forward movement
    if persistence and width and length then
        local currentPos = persistence.getCurrentPosition()
        persistence.saveMineState(length, width, currentPos, direction, torchBool, offset, torchnum, t, startingPosition, startingFacing)
    end
    --turtle.forward()
end

function InvCheck()
    if turtle.getItemCount(15) > 0 then
        if autoClearInventory then
            InvClear()
        else
            print("Inventory full. Press Enter to continue mining after clearing manually.")
            read()
        end
    end
end

function InvClear()
    turtle.digDown()
    if firstChestFull == false then
        turtle.select(3)
        turtle.placeDown()
        local i = 5
        while i <= 16 do
            turtle.select(i)
            if turtle.dropDown() == false then
                firstChestFull = true
                turtle.select(3)
                turtle.digDown()
                i = 16
            else
                turtle.dropDown()
            end
            i = i + 1
        end
    end
    if secondChestFull == false and firstChestFull == true then
        turtle.select(4)
        turtle.placeDown()
        local i = 5
        while i <= 16 do
            turtle.select(i)
            if turtle.dropDown() == false then
                secondChestFull = true
                turtle.select(4)
                turtle.digDown()
                i = 16
                print("Second chest full. Press Enter to continue mining after clearing manually.")
                read()
            else
                turtle.dropDown()
            end
            i = i + 1
        end
    end
end

function RefuelIfNeeded()
    if turtle.getFuelLevel() < 100 then
        print("Refueling...")
        turtle.select(1)
        turtle.refuel(1)
        print("Fuel level after refueling: ", turtle.getFuelLevel())
    end
end

print("Current Fuel Level: ", turtle.getFuelLevel())
print("Fuel should be placed in slot 1 of the inventory.")
print("Torches should be placed in slot 2 of the inventory if used.")

-- Check for saved state
local savedState = persistence.loadMineState()
-- Make these variables global so functions can access them
-- Initialize with default values to prevent nil errors
length, width, direction, torchBool, offset, autoClearInventory = 0, 0, "r", 0, 5, false
j, t, torchnum, i = 0, 0, 0, 0  -- Initialize global variables used by functions
local startRow, startT, startI = 0, 0, 0
firstChestFull = false
secondChestFull = false

if savedState and persistence.askResume("mining") then
    print("Resuming mining operation...")
    length = savedState.length
    width = savedState.width
    direction = savedState.direction
    torchBool = savedState.torchBool
    offset = savedState.offset
    startRow = savedState.currentRow
    startT = savedState.t
    torchnum = savedState.torchnum
    startI = savedState.currentCol or 0
    -- Use saved starting position and facing direction if available
    startingPosition = savedState.startingPosition
    startingFacing = savedState.startingFacing
    if startingPosition then
        if startingPosition.relative then
            print("Using saved starting position: (0, 0, 0) - relative")
        else
            print("Using saved starting position: (" .. startingPosition.x .. ", " .. startingPosition.y .. ", " .. startingPosition.z .. ")")
        end
    else
        print("No saved starting position found, getting current position...")
        getStartingPosition()
    end
    
    if startingFacing then
        print("Using saved starting facing direction: " .. startingFacing)
        currentFacing = startingFacing  -- Set current facing to match saved starting facing
    else
        print("No saved starting facing direction found, using current facing...")
        getStartingPosition()
    end
    
    -- Get current position differences for display
    local currentPosDiffs = getCurrentPositionDifferences()
    print("Resuming from row " .. currentPosDiffs.row .. " of " .. width .. ", position " .. currentPosDiffs.col .. " of " .. length)
else
    print("Starting new mining operation...")
    print("MineShaft Length")
    length = read()

    print("MineShaft Width")
    width = read()

    print("Turn left or right(left:l ;right:r)")
    direction = read()

    print("Place Torches?(0 for no;1 for yes)")
    torchBool = read()
    torchBool = tonumber(torchBool)
    t = 0
    torchnum = 0

    if torchBool == 1 then
        print("Torche offset?")
        offset = read()
        offset = tonumber(offset)
    end

    print("Auto clear inventory when full? (0 for no; 1 for yes)")
    autoClearInventory = read()
    autoClearInventory = tonumber(autoClearInventory) == 1
    
    -- Get starting position and facing direction for new operation
    getStartingPosition()
end

RefuelIfNeeded()
mmine(length, width, startRow, startT, startI)
comeBack(length, width)
InvClear()

-- Clear saved state when operation completes
persistence.clearMineState()
print("Mining operation completed!")
print("Final fuel level: " .. turtle.getFuelLevel())