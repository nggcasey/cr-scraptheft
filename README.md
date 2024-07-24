# cr-scraptheft

This script allows players to steal scrap materials from various objects on the map (i.e. air conditioning units).

**Requirements**

* QBCore or Qbox Framework
* ps-dispatch (optional for police alerts)

**Features**

* Highly configurable
* Protected against LUA injectors: Uses a server generated randomised token to authenticate before sending rewards to the clients (not tested) -
* Support for ps-dispatch
* Customisable random dispatch messages and callers -Configurable rewards for each object

**Preview**
https://youtu.be/aHsVkWgBlr8



**Installation**

* Drag & drop this resource into your resource folder
* In qb-core/shared/items.lua, add this code under Tools

**QBCore Items**
* In qb-core/shared/items.lua, add this code under Tools
```

	['oxycutter'] 				 	 = {['name'] = 'oxycutter', 			    	['label'] = 'Oxy Cutter', 				['weight'] = 10000, 	['type'] = 'item', 		['image'] = 'oxycutter.png', 			['unique'] = false, 	['useable'] = false, 	['shouldClose'] = false,   ['combinable'] = nil,   ['description'] = 'A handy tool for cutting metal'},
```
**Ox Inventory Items**
* In ox_inventory/data/items.lua
```
	["oxycutter"] = {
		label = "Oxy Cutter",
		weight = 1000,
		stack = true,
		close = false,
		description = "Careful this gets hot, good for cutting metal",
		client = {
			image = "oxycutter.png",
		}
	},
```

* Add the oxycutter.png from the images folder into in qb-inventory/html/images

**Notes**

This is my first actual resource and I am still learning, so if you have any constructive feedback, thoughts or suggestions please let me know or open a pull request. Feel free to modify, adapt and share this.
