# cr-scraptheft

This script allows players to steal scrap materials from various objects on the map (i.e. air conditioning units).

**Requirements**

* Qbox Framework
* ox_inventory
* ox_lib
* ps-dispatch (optional for police alerts) (cd-dispatch has not been tested.)

**Features**

* Highly configurable
* Exploit protection checks on the server side (feel free to suggest additional checks, open an issue or PR) -
* Support for ps-dispatch (feel free to open a PR for more)
* Customisable random dispatch messages and callers -Configurable rewards for each object

**Preview**
https://youtu.be/aHsVkWgBlr8


**Installation**

* Drag & drop this resource into your resource folder

**Ox Inventory Items**
* In ox_inventory/data/items.lua
* Add the oxycutter.png from the images folder into ox_inventory/web/images
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

**Notes**

Feel free to share, adapt and modify.
