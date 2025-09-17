-- Load persistence library
local persistence = require("persistence")

-- Global variables to store starting position and facing direction
local startingPosition = nil
local finalPosition = nil
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
        local logFile = fs.open("debug_log.txt", "a")
        logFile.writeLine("[DEBUG] " .. message)
        logFile.close()
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
    startingFacing = getStartingFacing()
    currentFacing = startingFacing
    print("Starting facing direction: " .. startingFacing)
    finalPosition = getFinalPosition()
    
    return startingPosition, startingFacing
end

function getStartingFacing()
    checkfacingPositionOne = persistence.getCurrentPosition()
    turtle.dig()
    turtle.forward()
    checkfacingPositionTwo = persistence.getCurrentPosition()
    turtle.back()
    if checkfacingPositionOne.z > checkfacingPositionTwo.z then
        startingFacing = "north"
    elseif checkfacingPositionOne.z < checkfacingPositionTwo.z then
        startingFacing = "south"
    elseif checkfacingPositionOne.x > checkfacingPositionTwo.x then
        startingFacing = "east"
    elseif checkfacingPositionOne.x < checkfacingPositionTwo.x then
        startingFacing = "west"
    end
    debugPrint("Starting facing direction: " .. startingFacing)
    return startingFacing
end

function getFinalPosition()
    if startingFacing == "north" then
        if turnDirection == "r" then
            return {
                x = startingPosition.x + width,
                z = startingPosition.z - length
            }
        else
            return {
                x = startingPosition.x - width,
                z = startingPosition.z - length
            }
        end
    elseif startingFacing == "south" then
        if turnDirection == "r" then
            return {
                x = startingPosition.x - width,
                z = startingPosition.z + length
            }
        else
            return {
                x = startingPosition.x + width,
                z = startingPosition.z + length
            }
        end
    elseif startingFacing == "east" then
        if turnDirection == "r" then
            return {
                x = startingPosition.x + length,
                z = startingPosition.z + width
            }
        else
            return {
                x = startingPosition.x + length,
                z = startingPosition.z - width
            }
        end
    elseif startingFacing == "west" then
        if turnDirection == "r" then
            return {
                x = startingPosition.x - length,
                z = startingPosition.z - width
            }
        else
            return {
                x = startingPosition.x - length,
                z = startingPosition.z + width
            }
        end
    end
end

-- Function to get current position differences from starting position
function getCurrentPositionDifferences()
    local currentPos = persistence.getCurrentPosition()
    -- debugPrint("Current position: " .. currentPos.x .. ", " .. currentPos.z)
    -- debugPrint("Starting position: " .. startingPosition.x .. ", " .. startingPosition.z)
    positionDiffs = persistence.calculatePositionDifferences(currentPos, startingPosition)
    -- debugPrint("Position differences: " .. positionDiffs.x .. ", " .. positionDiffs.z)
    return positionDiffs
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
function isMiningComplete()
    local currentPosition = persistence.getCurrentPosition()
    debugPrint("Fin-pos: " .. finalPosition.x .. ", " .. finalPosition.z)
    if currentPosition.z == finalPosition.z and currentPosition.x == finalPosition.x then
        return true
    end
    return false
end

-- Function to check if we've completed the current row
function isRowComplete(positionDiffs, currentFacing, width)
    local currentPosition = persistence.getCurrentPosition()
    local nextPosition = getNextPosition(currentPosition, positionDiffs, currentFacing, width)
    debugPrint("Cur-pos: " .. currentPosition.x .. ", " .. currentPosition.z)
    debugPrint("Nxt-pos: " .. nextPosition.x .. ", " .. nextPosition.z)
    -- error("Cur-pos: " .. currentPosition.x .. ", " .. currentPosition.z)
    -- error("Nxt-pos: " .. nextPosition.x .. ", " .. nextPosition.z)

    if currentPosition.z == nextPosition.z and currentPosition.x == nextPosition.x then
        return true
    end
    return false
end

function getNextPosition(currentPosition, positionDiffs, currentFacing, width)
    local nextPosition = nil
    local currentRow = nil
    local isX = false
    -- debugPrint("Current facing: " .. currentFacing)
    -- debugPrint("Position differences: " .. positionDiffs.z .. ", " .. positionDiffs.x)
    if currentFacing == "north" then
        currentRow = positionDiffs.x
        isX = false
    elseif currentFacing == "south" then
        currentRow = positionDiffs.x
        isX = false
    elseif currentFacing == "east" then
        currentRow = positionDiffs.z
        isX = true
    elseif currentFacing == "west" then
        currentRow = positionDiffs.z
        isX = true
    end
    -- debugPrint("Current row: " .. currentRow)
    -- if currentRow is odd, we need to go backward
    if currentRow % 2 == 1 then -- odd row so we need to go backward
        if currentFacing == "north" then
            nextPosition = startingPosition.z
        elseif currentFacing == "south" then
            nextPosition = startingPosition.z
        elseif currentFacing == "east" then
            nextPosition = startingPosition.x
        elseif currentFacing == "west" then
            nextPosition = startingPosition.x
        end
    else -- even row so we need to go forward
        if currentFacing == "north" then
            nextPosition = startingPosition.z - width
        elseif currentFacing == "south" then
            nextPosition = startingPosition.z + width
        elseif currentFacing == "east" then
            nextPosition = startingPosition.x + width
        elseif currentFacing == "west" then
            nextPosition = startingPosition.x - width
        end
    end
    if isX then
        return {
            x = nextPosition,
            z = currentPosition.z
        }
    else
        return {
            x = currentPosition.x,
            z = nextPosition
        }
    end
end

-- Function to update facing direction when turtle turns
-- north(-z) -> east(+x) -> south(+z) -> west(-x)
function updateFacingDirection(turnedDirection)
    if turnedDirection == "right" then
        if currentFacing == "north" then
            currentFacing = "east"
        elseif currentFacing == "east" then
            currentFacing = "south"
        elseif currentFacing == "south" then
            currentFacing = "west"
        elseif currentFacing == "west" then
            currentFacing = "north"
        end
    elseif turnedDirection == "left" then
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
    persistence.saveMineState(startingPosition, finalPosition, startingFacing, currentFacing, length, width, turnDirection, torchBool, offset, autoClearInventory, lengthCompleted, widthCompleted, torchesMovements, startRow, inMiddleOfTurn)
end

function mmine()
    
    -- Get current position differences
    local positionDiffs = getCurrentPositionDifferences()
        
    while not isMiningComplete() do
        RefuelIfNeeded()
        print("Row:   ", positionDiffs.row, "/", width , " | Fuel: ", turtle.getFuelLevel())
        positionDiffs = getCurrentPositionDifferences()
        
        -- Save progress at the start of each row
        local currentPos = persistence.getCurrentPosition()
        persistence.saveMineState(startingPosition, finalPosition, startingFacing, currentFacing, length, width, turnDirection, torchBool, offset, autoClearInventory, lengthCompleted, widthCompleted, torchesMovements, startRow, inMiddleOfTurn)
        
        while not isRowComplete(positionDiffs, currentFacing, width) do
            debugPrint("pos-diffs=" .. positionDiffs.z .. "," .. positionDiffs.x .. "(len=" .. length .. ")||cur-facing=" .. currentFacing)
            turtle.digDown()
            turtle.digUp()
            DigUntilEmpty()
            PlaceTorch()
            CheckForwrd()
            
            -- Update position differences after moving
            positionDiffs = getCurrentPositionDifferences()
            -- debugPrint("After moving: row=" .. positionDiffs.z .. " (abs=" .. math.abs(positionDiffs.z) .. "), col=" .. positionDiffs.x .. " (abs=" .. math.abs(positionDiffs.x) .. ")")
            
            -- Save progress after each forward movement
            if persistence and width and length then
                local currentPos = persistence.getCurrentPosition()
                persistence.saveMineState(startingPosition, finalPosition, startingFacing, currentFacing, length, width, turnDirection, torchBool, offset, autoClearInventory, lengthCompleted, widthCompleted, torchesMovements, startRow, inMiddleOfTurn)
            end
        end
        if not isMiningComplete() then
            inMiddleOfTurn = true
            corner()
            inMiddleOfTurn = false
        end
    end
    turtle.digUp()
    turtle.digDown()
end

function corner()
    if startingFacing == currentFacing then
        if turnDirection == "r" then
            CornerRight()
        else
            CornerLeft()
        end
    else
        if turnDirection == "r" then
            CornerLeft()
        else
            CornerRight()
        end
    end
end

function CornerRight()
    turtle.digDown()
    turtle.digUp()
    turtle.turnRight()
    updateFacingDirection("right")
    PlaceTorch()
    CheckForwrd()

    turtle.turnRight()
    updateFacingDirection("right")
end

function CornerLeft()
    turtle.digDown()
    turtle.digUp()
    turtle.turnLeft()
    updateFacingDirection("left")
    PlaceTorch()
    CheckForwrd()

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
                persistence.saveMineState(startingPosition, finalPosition, startingFacing, currentFacing, length, width, turnDirection, torchBool, offset, autoClearInventory, lengthCompleted, widthCompleted, torchesMovements, startRow, inMiddleOfTurn)
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
                persistence.saveMineState(startingPosition, finalPosition, startingFacing, currentFacing, length, width, turnDirection, torchBool, offset, autoClearInventory, lengthCompleted, widthCompleted, torchesMovements, startRow, inMiddleOfTurn)
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
                persistence.saveMineState(startingPosition, finalPosition, startingFacing, currentFacing, length, width, turnDirection, torchBool, offset, autoClearInventory, lengthCompleted, widthCompleted, torchesMovements, startRow, inMiddleOfTurn)
            end
        end
        TrueTurn()
    end
end

function TrueTurn()
    if turnDirection == "r" then
        turtle.turnRight()
        updateFacingDirection("right")
    else
        turtle.turnLeft()
        updateFacingDirection("left")
    end
end

function PlaceTorch()
    if torchBool == true then
        if torchesMovements % offset == 0 then
            turtle.select(2)
            turtle.digDown()
            turtle.placeDown()
        end
    end
    torchesMovements = torchesMovements + 1
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
    local currentPos = persistence.getCurrentPosition()
    persistence.saveMineState(startingPosition, finalPosition, startingFacing, currentFacing, length, width, turnDirection, torchBool, offset, autoClearInventory, lengthCompleted, widthCompleted, torchesMovements, startRow, inMiddleOfTurn)
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
            if turtle.getItemCount(i) == 0 then
                break
            end
            if turtle.dropDown() == false then
                firstChestFull = true
                turtle.select(3)
                turtle.digDown()
                break
            else
                turtle.dropDown()
            end
            i = i + 1
            if turtle.getItemCount(i) == 0 then
                break
            end
        end
    end
    if secondChestFull == false and firstChestFull == true then
        turtle.select(4)
        turtle.placeDown()
        local i = 5
        while i <= 16 do
            turtle.select(i)
            if turtle.getItemCount(i) == 0 then
                break
            end
            if turtle.dropDown() == false then
                secondChestFull = true
                turtle.select(4)
                turtle.digDown()
                break
                print("Second chest full. Press Enter to continue mining after clearing manually.")
                read()
            else
                turtle.dropDown()
            end
            i = i + 1
            if turtle.getItemCount(i) == 0 then
                break
            end
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
print("Slots||Fuel-1|Torches(o)-2|Chests(o)-3|Chests(o)-4|")
-- INSERT_YOUR_CODE
local logFile = fs.open("debug_log.txt", "w")
logFile.close()


-- Check for saved state
local savedState = persistence.loadMineState()
-- Make these variables global so functions can access them
-- Initialize with default values to prevent nil errors
length = 0 -- how far along the length we are
width = 0 -- how many columns we are mining
turnDirection = "r" -- whether to turn left or right
torchBool = 0 -- whether to place torches
offset = 5 -- how many blocks until a torch is placed
autoClearInventory = false -- whether to auto clear the inventory when it is full

lengthCompleted = 0 -- how far along the length we are completed
widthCompleted = 0 -- how many columns we have completed

torchesMovements = 0 -- the number of torches movements
startRow = 0 -- the row we started on
firstChestFull = false -- whether the first chest is full
secondChestFull = false -- whether the second chest is full
inMiddleOfTurn = false -- whether we are in the middle of a turn

if savedState and persistence.askResume("mining") then
    print("Resuming mining operation...")
    length = savedState.length
    width = savedState.width
    turnDirection = savedState.turnDirection
    torchBool = savedState.torchBool
    offset = savedState.offset
    autoClearInventory = savedState.autoClearInventory
    lengthCompleted = savedState.lengthCompleted
    widthCompleted = savedState.widthCompleted
    torchesMovements = savedState.torchesMovements
    startRow = savedState.startRow
    inMiddleOfTurn = savedState.inMiddleOfTurn

    currentFacing = savedState.currentFacing
    startingPosition = savedState.startingPosition
    startingFacing = savedState.startingFacing
    finalPosition = savedState.finalPosition
    debugPrint("Starting position: " .. startingPosition.x .. ", " .. startingPosition.z)
    debugPrint("Starting facing: " .. startingFacing)
    debugPrint("Final position: " .. finalPosition.x .. ", " .. finalPosition.z)
    debugPrint("Current facing: " .. currentFacing)
    debugPrint("Length: " .. length)
    debugPrint("Width: " .. width)
    debugPrint("Turn direction: " .. turnDirection)

    if torchBool == true then
        debugPrint("Torch bool: true")
    else
        debugPrint("Torch bool: false")
    end
    debugPrint("Offset: " .. offset)

    if autoClearInventory == true then
        debugPrint("Auto clear inventory: true")
    else
        debugPrint("Auto clear inventory: false")
    end
    debugPrint("Length completed: " .. lengthCompleted)
    debugPrint("Width completed: " .. widthCompleted)
    debugPrint("Torches movements: " .. torchesMovements)
    debugPrint("Start row: " .. startRow)

    if inMiddleOfTurn == true then
        debugPrint("In middle of turn: true")
    else
        debugPrint("In middle of turn: false")
    end

    if firstChestFull == true then
        debugPrint("First chest full: true")
    else
        debugPrint("First chest full: false")
    end

    if secondChestFull == true then
        debugPrint("Second chest full: true")
    else
        debugPrint("Second chest full: false")
    end

else
    print("Starting new mining operation...")
    print("MineShaft Length(how far forward from turtle start position)")
    length = read()
    length = tonumber(length)

    print("MineShaft Width(how many columns to mine)")
    width = read()
    width = tonumber(width)

    print("Turn left or right(left:l | right:r || default:r)")
    turnDirection = read()

    print("Place Torches?(no-n | yes-y || default:no)")
    torchBool = read()
    if torchBool == "y" then
        torchBool = true
    else
        torchBool = false
    end

    if torchBool == true then
        print("Torch offset(how many blocks until a torch is placed)?")
        offset = read()
        offset = tonumber(offset)
    end

    print("Auto clear inventory when full? (no-n | yes-y || default:no)")
    autoClearInventory = read()
    if autoClearInventory == "y" then
        autoClearInventory = true
    else
        autoClearInventory = false
    end
    
    -- Get starting position and facing direction for new operation
    getStartingPosition()
    finalPosition = getFinalPosition()
    startingFacing = getStartingFacing()
    persistence.saveMineState(startingPosition, finalPosition, startingFacing, currentFacing, length, width, turnDirection, torchBool, offset, autoClearInventory, lengthCompleted, widthCompleted, torchesMovements, startRow, inMiddleOfTurn)
end

RefuelIfNeeded()
mmine()
-- comeBack(length, width)
InvClear()

-- Clear saved state when operation completes
persistence.clearMineState()
print("Mining operation completed!")
print("Final fuel level: " .. turtle.getFuelLevel())