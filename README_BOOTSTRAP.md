# ComputerCraft Bootstrap System

This bootstrap system allows you to download and set up the entire update system with just one file!

## Quick Start

1. **Upload update system files to Pastebin**:
   - `main_update.lua`
   - `main_setup.lua`
   - `update/update.lua`
   - `update/setup_update.lua`
   - `update/update_config.lua`

2. **Configure bootstrap URLs**:
   - Edit `bootstrap.lua`
   - Update the `BOOTSTRAP_URLS` table with your Pastebin URLs

3. **Run bootstrap**:
   ```
   lua bootstrap.lua
   ```

4. **Set up update system**:
   ```
   lua main_setup.lua
   ```

5. **Start updating**:
   ```
   lua main_update.lua
   ```

## What Bootstrap Does

The `bootstrap.lua` file downloads and creates:
- `main_update.lua` - Main update script (calls update folder)
- `main_setup.lua` - Main setup script (calls update folder)
- `update/update.lua` - Update system script
- `update/setup_update.lua` - Setup system script
- `update/update_config.lua` - Configuration file


## Configuration

Edit the `BOOTSTRAP_URLS` table in `bootstrap.lua`:

```lua
local BOOTSTRAP_URLS = {
    main_update = "https://pastebin.com/raw/YOUR_MAIN_UPDATE_PASTEBIN_ID",
    main_setup = "https://pastebin.com/raw/YOUR_MAIN_SETUP_PASTEBIN_ID",
    update_script = "https://pastebin.com/raw/YOUR_UPDATE_SCRIPT_PASTEBIN_ID",
    setup_script = "https://pastebin.com/raw/YOUR_SETUP_SCRIPT_PASTEBIN_ID", 
    config_file = "https://pastebin.com/raw/YOUR_CONFIG_FILE_PASTEBIN_ID"
}
```

## Usage

### Option 1: Set up update system
- Downloads all update system files from Pastebin
- Creates the `update/` folder
- Sets up the complete update system

### Option 2: Show configuration
- Displays current Pastebin URLs
- Shows which files will be downloaded

## Benefits

✅ **One-time setup** - Run bootstrap once to get everything
✅ **No manual file copying** - Everything downloads automatically
✅ **Easy configuration** - Just update URLs in one place
✅ **Complete system** - Gets all update files at once
✅ **Self-contained** - Bootstrap file contains everything needed

## File Structure After Bootstrap

```
computercraft/
├── bootstrap.lua           # Bootstrap script (this file)
├── main_update.lua         # Main update script (created by bootstrap)
├── main_setup.lua          # Main setup script (created by bootstrap)
├── mine.lua                # Your programs
├── stair.lua
├── tree.lua
├── persistence.lua
└── update/                 # Created by bootstrap
    ├── update.lua          # Downloaded from Pastebin
    ├── setup_update.lua    # Downloaded from Pastebin
    ├── update_config.lua   # Downloaded from Pastebin
```

## Troubleshooting

### "URL not configured" Error
- Update the `BOOTSTRAP_URLS` table with your actual Pastebin URLs
- Make sure URLs point to raw Pastebin content

### "Failed to download" Error
- Check your internet connection
- Verify the Pastebin URLs are correct
- Make sure the paste is public and accessible

### "Could not write to file" Error
- Check file permissions
- Make sure you have write access to the directory
- Ensure the file isn't being used by another program

## Next Steps After Bootstrap

1. **Configure URLs**: Run `lua main_setup.lua` to set up Pastebin URLs for your programs
2. **Update Programs**: Run `lua main_update.lua` to update your programs
3. **Regular Updates**: Use `lua main_update.lua` whenever you want to update

The bootstrap system gets you started quickly, then the regular update system takes over for ongoing maintenance!
