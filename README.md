# FABconfig

FABconfig adds an Autodesk Fabrication database to Fabrication (CADmep, ESTmep, CAMduct) as a named configuration, so the database appears in Fabrication's configuration list at start-up. It creates the configuration folder, writes a `map.ini` that points back to the shared database, and registers the configuration with each recent Fabrication version, all in one click.

FABconfig is written in [AutoHotkey v2](https://www.autohotkey.com/) and can be run as a script or compiled into a standalone `.exe`. It is developed by Virtual Building Supply, LLC and released under the GNU General Public License v3.

## Requirements

- Windows 10 or 11. The icons use the Segoe MDL2 Assets font that ships with both.
- [AutoHotkey v2.0](https://www.autohotkey.com/) or later, to run or compile the script. Users of a compiled `.exe` don't need AutoHotkey.
- Autodesk Fabrication, for the configuration to be of any use.

No administrator rights are needed. FABconfig writes only to the current user's registry (`HKEY_CURRENT_USER`) and to the configuration folder you choose.

## How to use it

1. Copy `FabConfig_v26_10_24.ahk` (or the compiled `.exe`) and the `Resources` folder into the root folder of the Fabrication database.
2. Run it. The configuration name is filled in from `DBNAME` in the `[COMPANY-INFO]` section of the database's `map.ini`, if there is one.
3. Check the name and location, then click **Create Configuration** (or press Enter).
4. Start Fabrication. The new configuration appears in the configuration list.

The **What's this?** page in the sidebar explains each step inside the program. Esc returns from that page, or closes the program from the main page.

## What it changes

- **Configuration folder:** Created at `C:\fabrication-configurations\<name>` by default. The location follows the name as you type, until you edit it or choose a folder with **Browse**.
- **map.ini:** Written to the configuration folder. It points the `Database`, `Items`, `Images`, `Profiles`, `Reports` and `Scripts` paths at the shared database. `Projects`, DXFs, `Blocks` and `Backup` stay in the configuration folder, so each user's local work stays separate from the shared database. Its first line, `# Created by Virtual Building Supply, LLC`, marks the configuration as made by FABconfig.
- **config.png:** Copied from the database folder into the configuration folder, if present. Fabrication shows this picture in its configuration list.
- **Registry:** For each Fabrication version from four years before the current year to two years after it, writes the configuration folder to the `Path` value under
  `HKEY_CURRENT_USER\Software\Autodesk\Fabrication <year>\Configuration\<name>`.

Nothing in the database folder itself is changed. Running FABconfig again with the same name updates that configuration.

### Safety checks

- The name can't contain characters Windows doesn't allow in folder names.
- The configuration folder must be a full path, and can't be the database folder or a folder that contains it.
- If a configuration with the same name already points to a different folder, or the chosen folder already has a `map.ini`, FABconfig asks before replacing anything.
- If any file can't be written or any registry entry can't be saved, FABconfig says so instead of reporting success.

### Removing a configuration

To remove a configuration by hand, delete its `Configuration\<name>` key under each `HKEY_CURRENT_USER\Software\Autodesk\Fabrication <year>` key, then delete the configuration folder. Close Fabrication first.

## Building the .exe

1. Make sure the `Resources` folder sits next to the script. The compiler uses `Resources\VBS_Logo.ico` as the `.exe` icon.
2. Right-click the script and choose **Compile Script**. If that option isn't there, open **AutoHotkey Dash** and choose **Compile**, which installs the compiler (Ahk2Exe) the first time.
3. Choose a **v2** base file (for example `AutoHotkey64.exe`) and click **Convert**.

The icon, version and copyright details come from the `;@Ahk2Exe-` lines at the top of the script. The sidebar logo is loaded from the `Resources` folder at runtime, so keep that folder next to the `.exe`. If it's missing, FABconfig shows a plain folder icon instead.

Some antivirus tools are wary of unsigned `.exe` files compiled from AutoHotkey. Signing the `.exe` with a code-signing certificate avoids this.

## Repository layout

```
FabConfig_v26_10_24.ahk   The program
Resources/                VBS logo files (not covered by the GPL, see below)
  VBS_Logo.ico            Window, taskbar and .exe icon
  VBS_Logo_Badge.png      Logo shown in the sidebar
LICENSE                   GNU General Public License v3
README.md                 This file
```

## Contributing

Bug reports, suggestions and pull requests are welcome. Please describe what you changed and how you tested it, including the Windows version, Fabrication version and display scaling you tried. Contributions are accepted under the same license as the project.

## License

Copyright (C) 2026 Virtual Building Supply, LLC. Author: Scott Hendricks.

FABconfig is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. It is distributed in the hope that it will be useful, but **without any warranty**; without even the implied warranty of merchantability or fitness for a particular purpose. See [LICENSE](LICENSE) for the full text.

Additional terms under section 7 of the GPL v3, also stated in the script's header:

- **Attribution (section 7b):** The copyright notice and author attribution in the script's header must be preserved in that file and in any modified version of it.
- **Trademarks (section 7e):** The license grants no rights to use the trade names, trademarks or logos of Virtual Building Supply, LLC, including the logo files in the `Resources` folder. If you distribute a modified version, replace those files with your own (or remove them) and change the program's branding. FABconfig runs without them; to compile without an icon, remove the `;@Ahk2Exe-SetMainIcon` line.

Autodesk, Fabrication, CADmep, ESTmep and CAMduct are registered trademarks or trademarks of Autodesk, Inc. FABconfig is not affiliated with, endorsed by or supported by Autodesk.
