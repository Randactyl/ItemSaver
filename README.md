This Add-on is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its affiliates. The Elder Scrolls and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. All rights reserved.

---

This started as a simple mod that allowed you to place a little marker on your items so you could remember to not accidentally sell or deconstruct them.

With Item Saver 2.0.0.0, that simple functionality is extended with some awesome new features:
 - Choose to filter marked items from any combination of vendors, the deconstruction list, the research list, the guild store tell tab, the send mail window, and the trading window.
 - Create as many different sets of items as you like, all with their own marker texture, color, and filtering rules.
 - Add your own marker textures to use for Item Saver sets (details below).

Full feature list:
 - Create a new item set with the "+ Create Set" context menu option.
 - Choose a set name, marker, color, and filters.
 - Choose your default save set.
 - Keybind for saving items to the default set.
 - Choose marker position.
 - Item sets are listed in a submenu when right clicking an item.
 - The context submenu can be deferred until there are more than a specified number of sets created (1 - 5).
 - Edit created sets including the marker properties and which filters are active. These will update immediately without needing a UI reload.
 - Quickly clear all items from a set.
 - Delete sets you no longer need.

---

Item Saver features an API for other addons to integrate with Item Saver's functionality. The full Item Saver API is listed here:

```
function ItemSaver_IsItemSaved(bagIdOrItemId, slotIndex)
--returns true and the string set name if the item is saved. Returns false if the item is not saved.

function ItemSaver_ToggleItemSave(setName, bagIdOrItemId, slotIndex)
--returns true if item was saved successfully. Returns false if item was unsaved.
--if setName is nil, Item Saver will use the default set.

function ItemSaver_GetFilters(setName)
--if the given set exists, returns a table with the following keys: store, deconstruction, research, guildStore, mail, trade.
--each will have a value of true if they are filtered or false if they are not.
--if the set does not exist, returns nil

function ItemSaver_GetMarkerOptions()
--returns array of the names of available markers.

function ItemSaver_GetMarkerTextures()
--returns table with key/value pairs of markerName/markerPath

function ItemSaver_GetSaveSets()
--returns an alphabetically sorted array of the names of available save sets.
```

---

The new API for adding marker textures takes its inspiration from Inventory Grid View's skins and Advanced Filters' dropdown filters.

There are code examples in the markertextures folder in this directory.

You may submit your filters as plugins for Item Saver on ESOUI.
Do this by:

1. Go to http://www.esoui.com/downloads/info300-ItemSaver.html
2. Click on "Other Files" between "Change Log" and "Comments"
3. Click on "Upload Optional Addon"
4. Enter all relevant information and attach a .zip file containing the folder that contains your plugin. The archive hierarchy should look something like:

        IS_MyMarkerTexture-1.0.0.0.zip
            IS_MyMarkerTexture
                markertextures
                    MyMarkerTexture.dds
                IS_MyMarkerTexture.txt
                IS_MyMarkerTexture.lua
5. Submit

Remember to include all readme and disclaimer information required by ZOS.

Your addon manifest should look similar to the following:

    ## Title: Item Saver - My Marker Texture
    ## Author: Randactyl
    ## Version: 1.0.0.0
    ## APIVersion: 100012
    ## DependsOn: ItemSaver

    IS_MyMarkerTexture.lua

Your title should retain the leading "Item Saver - " in order to keep things organized in the game's addon menu.
ItemSaver must always be included in the DependsOn line.
