# Changelog

What changed in each version of FABconfig. Versions are dates (`vYY.MM.DD`); see [README.md](README.md#versions-and-releases).

## Unreleased

### Added
- Before overwriting a configuration that already exists, FABconfig shows which Fabrication versions it's registered with and where it points, and warns if it wasn't made by FABconfig.
- An overwritten `map.ini` is kept as `map.ini.bak`.
- An overwrite also updates the configuration in any other Fabrication version it was registered with, not just the versions shown under "Registers with".

### Changed
- The configuration location can't be inside the database folder. (Tools that mirror the database, such as `robocopy /MIR`, would delete it.)
- A configuration folder (one whose `map.ini` points to a database somewhere else) is no longer accepted as a database folder.
- Only `map.ini` and `config.png` have their read-only flag cleared, instead of every file in the configuration folder.
- When the database's `map.ini` has no `[COMPANY-INFO]` `DBNAME`, the name starts blank but the location still starts at `C:\fabrication-configurations\` and follows the name as you type.
- The script is now always named `FABconfig.ahk`. The compiled file is named after the version, for example `FABconfig_v26.10.24.exe`.

## v26.10.24

First release.

- Registers a Fabrication database as a named configuration for Fabrication versions from four years before to two years after the current year.
- Creates the configuration folder, writes a `map.ini` that points to the shared database, and copies `config.png`.
- Fills in the configuration name from `DBNAME` in the database's `map.ini`.
- Asks for the database folder when FABconfig isn't run from one.
- "What's this?" page explaining each step.
