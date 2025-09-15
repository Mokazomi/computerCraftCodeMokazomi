-- Persistence library for ComputerCraft programs
-- Handles saving and loading location and operation state

local persistence = {}

-- File paths for different operations
local MINE_STATE_FILE = "mine_state.json"
local STAIR_STATE_FILE = "stair_state.json"
local TREE_STATE_FILE = "tree_state.json"

-- Function to save state to file
function persistence.saveState(filename, state)
    local file = fs.open(filename, "w")
    if file then
        file.write(textutils.serialize(state))
        file.close()
        -- print("State saved to " .. filename)
        return true
    else
        print("Error: Could not save state to " .. filename)
        return false
    end
end

-- Function to load state from file
function persistence.loadState(filename)
    if fs.exists(filename) then
        local file = fs.open(filename, "r")
        if file then
            local content = file.readAll()
            file.close()
            local success, state = pcall(textutils.unserialize, content)
            if success then
                print("State loaded from " .. filename)
                return state
            else
                print("Error: Could not deserialize state from " .. filename)
                return nil
            end
        else
            print("Error: Could not read state file " .. filename)
            return nil
        end
    else
        print("No saved state found in " .. filename)
        return nil
    end
end

-- Function to delete state file
function persistence.clearState(filename)
    if fs.exists(filename) then
        fs.delete(filename)
        print("Cleared saved state: " .. filename)
        return true
    else
        print("No saved state to clear: " .. filename)
        return false
    end
end

-- Function to get current turtle position and direction
function persistence.getCurrentPosition()
    local x, y, z = gps.locate()
    if x and y and z then
        return {
            x = math.floor(x + 0.5),
            y = math.floor(y + 0.5),
            z = math.floor(z + 0.5)
        }
    else
        print("Warning: GPS not available, using relative positioning")
        return {
            x = 0,
            y = 0,
            z = 0,
            relative = true
        }
    end
end

-- Function to get current turtle facing direction
function persistence.getCurrentFacing()
    -- In ComputerCraft, we need to track facing direction manually
    -- This function should be called with the current facing direction from the main script
    -- Returns the facing direction passed to it
    return turtleFacing or "unknown"
end

-- Function to calculate distance between two positions
function persistence.calculateDistance(pos1, pos2)
    if pos1.relative or pos2.relative then
        return math.abs(pos1.x - pos2.x) + math.abs(pos1.y - pos2.y) + math.abs(pos1.z - pos2.z)
    else
        return math.sqrt((pos1.x - pos2.x)^2 + (pos1.y - pos2.y)^2 + (pos1.z - pos2.z)^2)
    end
end

-- Function to calculate position differences from starting position
function persistence.calculatePositionDifferences(currentPos, startingPos)
    if not currentPos or not startingPos then
        return {x = 0, z = 0, row = 0, col = 0}
    end
    
    -- Calculate raw differences
    local deltaX = math.abs(currentPos.x - startingPos.x)
    local deltaZ = math.abs(currentPos.z - startingPos.z)
    local deltaY = math.abs(currentPos.y - startingPos.y)
        
    return {
        x = deltaX,
        z = deltaZ,
        y = deltaY
    }
end

-- Mine-specific state management
function persistence.saveMineState(startingPosition, finalPosition, startingFacing, currentFacing, length, width, turnDirection, torchBool, offset, autoClearInventory, lengthCompleted, widthCompleted, torchesMovements, startRow, inMiddleOfTurn)
    -- Calculate current position differences from starting position
    local positionDiffs = persistence.calculatePositionDifferences(currentPos, startingPos)
    
    local state = {
        operation = "mine",
        startingPosition = startingPosition,
        finalPosition = finalPosition,
        startingFacing = startingFacing,
        currentFacing = currentFacing,
        length = length,
        width = width,
        turnDirection = turnDirection,
        torchBool = torchBool,
        offset = offset,
        autoClearInventory = autoClearInventory,
        lengthCompleted = lengthCompleted,
        widthCompleted = widthCompleted,
        torchesMovements = torchesMovements,
        startRow = startRow,
        inMiddleOfTurn = inMiddleOfTurn,
        timestamp = os.time()
    }
    return persistence.saveState(MINE_STATE_FILE, state)
end

function persistence.loadMineState()
    return persistence.loadState(MINE_STATE_FILE)
end

function persistence.clearMineState()
    return persistence.clearState(MINE_STATE_FILE)
end

-- Stair-specific state management
function persistence.saveStairState(length, currentLevel, currentPos)
    local state = {
        operation = "stair",
        length = length,
        currentLevel = currentLevel,
        currentPosition = currentPos,
        timestamp = os.time()
    }
    return persistence.saveState(STAIR_STATE_FILE, state)
end

function persistence.loadStairState()
    return persistence.loadState(STAIR_STATE_FILE)
end

function persistence.clearStairState()
    return persistence.clearState(STAIR_STATE_FILE)
end

-- Tree-specific state management
function persistence.saveTreeState(numTrees, currentTree, currentPos, charcoalCount, saplingCount)
    local state = {
        operation = "tree",
        numTrees = numTrees,
        currentTree = currentTree,
        currentPosition = currentPos,
        charcoalCount = charcoalCount,
        saplingCount = saplingCount,
        timestamp = os.time()
    }
    return persistence.saveState(TREE_STATE_FILE, state)
end

function persistence.loadTreeState()
    return persistence.loadState(TREE_STATE_FILE)
end

function persistence.clearTreeState()
    return persistence.clearState(TREE_STATE_FILE)
end

-- Function to ask user if they want to resume
function persistence.askResume(operationName)
    print("Found saved " .. operationName .. " operation.")
    print("Do you want to resume? (y/n)")
    local input = read()
    return input:lower() == "y" or input:lower() == "yes"
end

return persistence
