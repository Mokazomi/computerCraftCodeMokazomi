# ComputerCraft Update System

This update system allows you to automatically download and update your ComputerCraft programs from Pastebin. The update system can also update itself!

## File Structure

```
computercraft/
├── update.lua              # Main update script (calls update folder)
├── setup.lua               # Main setup script (calls update folder)
├── mine.lua                # Mining program with persistence
├── stair.lua               # Stair building program with persistence  
├── tree.lua                # Tree farming program with persistence
├── persistence.lua         # Persistence library
└── update/                 # Update system folder
    ├── update.lua          # Main update script
    ├── setup_update.lua    # Setup script
    ├── update_config.lua   # Configuration file
```

## Quick Start

1. **Upload to Pastebin**: Upload your programs to Pastebin and get the raw URLs
2. **Run Setup**: Execute `setup.lua` to configure the URLs
3. **Update Programs**: Run `update.lua` to update all programs

## Detailed Setup

### Step 1: Upload Programs to Pastebin

1. Go to [pastebin.com](https://pastebin.com)
2. Create a new paste for each program:
   - `mine.lua`
   - `stair.lua` 
   - `tree.lua`
   - `persistence.lua`
   - `update/update.lua` (the update script itself)
   - `update/setup_update.lua` (the setup script)
   - `update/update_config.lua` (the config file)
3. Copy the raw URL for each paste (looks like `https://pastebin.com/raw/XXXXXXXX`)

### Step 2: Configure URLs

Run the setup script:
```
lua setup.lua
```

Follow the prompts to enter your Pastebin URLs for both main programs and update system files.

### Step 3: Update Programs

Run the update script:
```
lua update.lua
```

Choose from the menu:
- **Update all programs** - Downloads and updates all programs + update system
- **Update specific program** - Update just one program
- **Update update system** - Update only the update scripts themselves
- **Show configuration** - View current URLs
- **Restore from backup** - Restore a program from backup
- **Exit** - Close the script

## Self-Update Feature

The update system can update itself! When you choose "Update all programs", it will also update:
- `update/update.lua`
- `update/setup_update.lua`
- `update/update_config.lua`

This means you can keep your update system up to date without manual intervention.

## Features

### Automatic Backups
- Creates `.backup` files before updating
- Can restore from backups if needed
- Configurable backup settings

### Progress Persistence
- All programs save their progress automatically
- Can resume operations after interruption
- GPS positioning support

### Self-Updating
- Update system can update itself
- Configurable self-update behavior
- Separate option to update only the update system

### Error Handling
- Validates URLs before downloading
- Handles network errors gracefully
- Shows detailed error messages

## Configuration

Edit `update/update_config.lua` to customize:

```lua
config.PASTEBIN_URLS = {
    -- Main programs
    mine = "https://pastebin.com/raw/XuTGmjrT",
    stair = "https://pastebin.com/raw/4X1sdnX4", 
    tree = "https://pastebin.com/raw/QHDxs2fD",
    persistence = "https://pastebin.com/raw/nMvKBJF2",
    
    -- Update system files
    update = "https://pastebin.com/raw/YOUR_UPDATE_PASTEBIN_ID",
    setup = "https://pastebin.com/raw/YOUR_SETUP_PASTEBIN_ID",
    config = "https://pastebin.com/raw/YOUR_CONFIG_PASTEBIN_ID"
}

config.SETTINGS = {
    createBackups = true,                    -- Create backups before updating
    backupExtension = ".backup",             -- Backup file extension
    askConfirmation = true,                  -- Ask before updating
    updateSelfWhenUpdatingAll = true         -- Update update system when updating all
}
```

## Usage Examples

### Update All Programs (Including Update System)
```
lua update.lua
# Choose option 1
```

### Update Just Mining Program
```
lua update.lua
# Choose option 2, then enter "mine"
```

### Update Only Update System
```
lua update.lua
# Choose option 3
```

### Restore from Backup
```
lua update.lua
# Choose option 5, then enter program name
```

## Troubleshooting

### "Update folder not found" Error
- Make sure the `update` folder exists
- Check that all update files are in the `update` folder

### "URL not configured" Error
- Run `setup.lua` to configure your Pastebin URLs
- Make sure URLs point to raw Pastebin content

### "Failed to download" Error
- Check your internet connection
- Verify the Pastebin URLs are correct
- Make sure the paste is public and accessible

### "Could not write to file" Error
- Check file permissions
- Make sure you have write access to the directory
- Ensure the file isn't being used by another program

## Tips

- Keep your Pastebin URLs up to date
- Test updates on a copy first
- Use backups to restore if something goes wrong
- The persistence system works independently of updates
- The update system can update itself, so keep those URLs current too!
