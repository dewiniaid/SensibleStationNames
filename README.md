# Sensible Station Names

*a.k.a. OpenTTD-like Station Names*

Sensible Station Names is a simple mod that attempts to provide reasonable default names for newly-placed train stops
based on their surroundings.  These default names include the backer name that Factorio provides by default, but append
a suffix

Some examples:

 * A train stop near stone might be "*NAME* Quarry"
 * Train stops near other types of ore might be "*NAME* Mines"
 * Train stops near oil wells might be "*NAME* Wells"
 * Train stops near chemical plants might be "*NAME* Chemical Plant"
 
The naming only applies to train stops as they are being built, so any station already named can be renamed freely and
won't be touched again.  Furthermore, it only affects train stops that are named after a backer -- so your blueprinted
train stations with preset names will remain unchanged.

Speaking of blueprints, ghosts are considered when determining a station name.  Thus, a train stop in your your prebuilt
blueprints for smelting will be correctly named even before the first furnace is placed.

## Debug Overlay (F11)
Pressing F11 (by default) toggles the display of information at the top of your screen that shows what a station built
at your current location would be named; this display updates every time you move to a different tile.  

**Note that the naming algorithm is rather expensive and your UPS while moving will likely tank while this is on.**

If you are playing in multiplayer, you can disable the overlay altogether or limit it to players who have console 
access.  Also note that having the overlay enabled with no players actively using it will have no effect on UPS. 

## Known Issues
* The naming algorithm is not perfect and is only a best effort.
  
* The naming algorithm is kind of slow.  This is not noticeable in normal usage, but definitely noticeable with the debug overlay turned on. 
  
## Unknown Issues

Found a bug?  Please visit the [Issues page](https://github.com/dewiniaid/SensibleStationNames/issues) to see if it has 
already been reported, and report it at that page if not.  **The Mod Portal does not notify of new posts on the 
discussion page, and messages posted there will likely be ignored.**

 
## Changelog

### 0.1.1 (2019-02-26)
 
* First release.

### 0.1.0 (2017-12-23)
 
* First release.
