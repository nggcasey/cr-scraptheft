# cr-thief

Be a thief. Run around the city stealing things: copper off buildings, catalytic converters from under parked cars, wheels, batteries, gloveboxes, wallets, vending machines, payphones, shop shelves and building sites. Build a reputation as you go.

Nothing is a static farm. Every spot you hit is gone for everyone until it respawns. Neighbourhoods get jumpy if they're hit too often. A rotating tip pulls thieves to the same part of town, so they run into each other and the server feels alive.

> Formerly **cr-scraptheft**. Name the resource folder `cr-thief`, although the code doesn't depend on the folder name.

## Jobs

All jobs are in `config/jobs/*.lua`, grouped by category. Add your own by copying one; see `config/jobs/README.md` for every field.

| Category | Jobs |
| --- | --- |
| **Street** | Pickpocketing (approach from behind; they might feel it), vending machines, parking meters, payphones, newspaper boxes, mailboxes |
| **Vehicles** | Car break-ins (smash the window, rummage the glovebox), catalytic converters (under the car with a grinder; hybrids pay most), wheels (jack, five lug nuts, car left on a block), batteries (car won't start afterwards) |
| **Shops** | Shoplifting. Browse, then pocket it, while the clerk might be watching |
| **Copper** | A/C units (panel drops, cut lines, rip out the coil), electrical cabinets (live cables: electrocution unless you're wearing insulated gloves) |
| **Construction** | Tool chests (steal the tools you need for bigger jobs), cable drums, pipe stacks, generators (carry the whole thing off) |

## How it feels

- **Physical:**
  - You walk into position, tools appear in your hands, animations loop while you work, and skill checks happen mid-animation.
  - Sparks fly, panels and cinder blocks drop and stay in the world, and windows smash.
  - Heavy loot is carried (no sprinting, no weapons, drop it if you're knocked over) and loaded into any vehicle's trunk.
  - Small loot goes straight into your pockets.
- **Synced aftermath:**
  - Stripped A/C units show their damaged model.
  - Generators disappear, missing wheels stay missing, and smashed windows stay smashed.
  - A car with no catalytic converter roars, and a car with no battery won't start.
- **Tools** have durability and break.

## The neighbourhood notices

Three independent ways a job gets reported; any of them can happen on the same job:

1. **Noise complaints**: nobody saw anything, but somebody heard it. More likely during noisy stages and while a car alarm is going, and less likely at night.
2. **Unseen callers**: named people calling from their apartment across the road, like *"Mrs Doyle (upstairs)"* or *"Gamer, apartment 12"*. Nobody is spawned. Sometimes you get a hint (*a curtain twitches*), sometimes nothing.
3. **Encounters**: someone actually turns up, with a generated name and traits rolled for that visit:
   - **Nosy neighbour (Karen)**: films you and whinges. She calls if you stay; threaten or shove her and she calls immediately.
   - **Angry local**: warns you, then fights, sometimes with a rottweiler. He may back off if you pull a gun.
   - **Timid passer-by**: quietly calls it in and runs if you aim at them.
   - **Security guard**: flashlight and radio; hard to scare.
   - **Grumpy pensioner**: heckles from the porch while looking for his glasses.
   - **Dog walker**: the dog runs over and barks at you.
   - **Drunk**: stumbles over, slurs, might shout about you to the whole street, might pass out.
   - **Teen with a phone**: films you; the clip goes viral a minute later and gets reported. Knock the phone away and there's no upload.
   - **Rival thief**: wants a cut. Pay up, or he snitches, swings at you, or storms off.

On top of that:

- **Bystanders** stare, mutter, film you or hurry away, but they never call.
- **Off-screen events** happen: a window slams, a dog barks, "WHAT IS THAT NOISE?!"
- **Ambient cops** who see you report it instantly.
- **Shop clerks** and **pickpocket victims** react as one of the types above.

**Dispatch messages are generated from what's actually happening.** Each one includes:

- the caller's name and how they talk;
- what you're doing ("lying under a Sultan with a grinder");
- the street;
- a description of the suspect that's sometimes wrong;
- your getaway car's colour and model, sometimes with a partial plate.

Your original callers and lines are still in rotation. Example output:

> **Old Luis** - It's Old Luis from Grove Street. Some lout's cutting the pipes off an a/c unit. In MY day they'd get the cane.
>
> **Traffic unit** - Witnessed active theft, Grove Street. Suspect sweaty female in a hi-vis vest. Possible vehicle: purple Sultan, plate starting with 4AB.
>
> **Copper Col Singh** - Anonymous tip. Some amateur's stripping the copper out of an aircon on Grove Street. Short male in a beanie. You didn't hear it from me.

## Keeping thieves moving

- **One hit per spot, for everyone.** World objects respawn after their timer. Cars and pedestrians remember being robbed.
- **Area heat.** The map is split into cells, and each job heats its cell for every player. The hotter the cell, the more likely you are to be reported and the more often people show up. At max heat the area is on lockdown until it cools.
- **Repetition.** Working the same cell over and over earns you much less rep ("people are starting to recognise you").
- **Word on the street.** Every 30 minutes someone starts paying well for one job type in one district, which earns bonus rep and extra loot. Experienced thieves get a text when it changes. Everyone else can check with `/thief`.

## Rep

Thief reputation (per character) runs from *Nobody* to *Ghost*. Higher rep means faster work and, with the optional buyers, better prices.

`/thief` shows your rep, how hot the current area is, and the current tip (select it to mark the district on your map).

## Selling

The resource just gives items, so sell them through your own pawn shops. Catalytic converters, wheels and gift cards carry `metadata.value` for your shop to price. Converters and wheels also carry a description with the car and plate they came from, so police can trace them.

Optional built-in buyers (`EnableBuyers = true`) add a scrapyard and a roaming night fence, with a live market that drops as people sell.

## Requirements

- OneSync
- [ox_lib](https://github.com/overextended/ox_lib), [ox_target](https://github.com/overextended/ox_target), [ox_inventory](https://github.com/overextended/ox_inventory)
- Framework: Qbox (recommended), QBCore or ESX. It also runs standalone; only money, IDs and police counts use the framework.
- Optional: ps-dispatch or cd_dispatch (or hook your own in `client/modules/dispatch.lua`), oxmysql (only for `protectOwned`)

## Installation

1. Put the resource in your resources folder as `cr-thief` and `ensure` it after ox_lib, ox_target and ox_inventory.
2. Add the items from `install/ox_items.lua` to `ox_inventory/data/items.lua`. Copy `images/*.png` to `ox_inventory/web/images`.
3. Get tools to players however you like (hardware store, crafting, or stealing them from tool chests):
   `crowbar`, `screwdriverset`, `angle_grinder` / `oxycutter`, `bolt_cutters`, `lug_wrench`, `car_jack`, and optionally `insulated_gloves`.
4. Go through the config.

Debug logging: `setr ox:printlevel:cr-thief debug`

## Configuration

| File | What's in it |
| --- | --- |
| `config/shared.lua` | Integrations, tools, heat basics, world (area heat, repetition, tips + districts), carrying, rep, vehicles, anti-exploit |
| `config/jobs.lua` + `config/jobs/*.lua` | Which job categories load, and every job (stages, tools, anims, skill checks, sparks, hazards, debris, loot) |
| `config/people.lua` | Names, every encounter type and its lines and traits, bystanders, off-screen events |
| `config/dispatch.lua` | Callers and message templates for every kind of report, plus the suspect description pools |
| `config/buyers.lua` | Optional scrapyard and fence |

Props, animations and particle effects are referenced by name. A missing prop model falls back to `FallbackProp` instead of breaking. Some interior shelf models (shoplifting) differ between MLOs, so add yours to the list.

## Security

The server is authoritative. It opens a session per job and checks timing on every stage (no instant completes). It also checks distance, tools and durability, minimum cops, target locks and area lockdown. Loot is rolled server-side, and loot and debris props are checked by model before they're accepted.

## Upgrading from cr-scraptheft v2

- Rename the folder to `cr-thief`. The config is now split across the files above, and models are given by name, not hash.
- `oxycutter` still works as a cutting tool. Make it `stack = false` so durability works.
- The `cr-scraptheft_debugMode` convar is replaced by the ox_lib print level above.

## Notes

Feel free to share, adapt and modify. Issues and PRs welcome.
