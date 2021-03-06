EXIM : Character Importer and Exporter Changelog
=======
# 1.0.5.6
* Initial Release

# 1.1.6.7
Fixes
* The rune issue is now fixed (couldn't load items with runes inside before)
* Some unique equipment now correctly store the inserted runes
* Equipment names are now restored in story mode
* Player characters are now correctly re-dressed when saving and loading in GM mode
* Some items were missing from the save sometimes, this should be fixed now since the inventory saving code have been ported to 100% lua (fuck Osiris, man)
* Saving and Loading process should be faster
* The console isn't cluttered by non-critical errors anymore
* Skills and ItemColor (if available) are now correctly saved

Known issues
* Cannot save any ability boost but will fixed as soon as they will be available in the extender

# 1.1.7.10
Fixes
* The crash issue on ~80% game save loading after using the loading stone on a character is no more !
* Custom items names that weren't saved in GM mode are fixed
* When loading a character the previously known skills get correctly wiped
* You can now correctly save and load Civil abilities boosts on items

# 1.1.8.11
Fixes
* Fixed the issue where equipment names wouldn't be correctly restored in GM mode
* Fixed the runes inserted in sockets not being saved
* Equipment visuals progression are now correctly restored at even level

# 1.1.8.12
Fixes
* Fixed an issue with Unique items crashing the game when loading
* Fixed an issue with quality above Epic that turns into Epic when reloading a map or a save
* Fixed an issue with items without delta modifiers rolling new ones
* Attributes permanent boosts are now not included in the base pool