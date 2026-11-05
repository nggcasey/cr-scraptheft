# cr-scraptheft v3

Steal things for cash. Unbolt A/C units, rip copper out of live electrical cabinets, walk off with a construction generator, slide under parked cars to cut catalytic converters, or jack them up and leave them on blocks.

v3 is a full rewrite. It aims for the hands-on feel of open-world games: every job is a sequence of physical steps. Tools appear in your hands and sparks fly. Panels clatter to the ground and stay there. The goods drop as real props you have to pick up, and heavy items have to be carried to a vehicle.

## Features

**Jobs (all configurable, add your own in `config/profiles.lua`)**

| Job | Steps | Loot |
| --- | --- | --- |
| A/C unit | Unscrew service panel (panel drops) → cut refrigerant lines (sparks + skill checks) → wrench out the coil | Condenser coil (carried) + bag of copper/aluminium/scrap |
| Electrical cabinet | Pry door → cut live cables (each cable is a skill check, **electrocution risk** unless you wear insulated gloves) → yank the loom | Bag of copper wire |
| Site generator | Disconnect leads → cut the security chain → heave it off | **The generator itself.** It vanishes from the world and you carry it |
| Catalytic converter | Slide under the car → cut the pipe (sparks under the car) → work it loose | Converter (value depends on the car; hybrids are worth the most) |
| Wheel | Jack placed at the wheel → crack 5 lug nuts (one skill check each) → pull the wheel | Wheel (carried). The car is left sitting on a cinder block |

**It feels physical**
- Your character walks into a working position (beside the car, lying under it, facing the unit) instead of teleporting.
- Animations loop through the whole stage, including during skill checks. Failing a check makes noise and you redo that step.
- Debris (panels, cinder blocks) stays in the world until the spot resets.
- Stripped A/C units become their damaged model, and stolen generators disappear. This is synced for everyone.
- Missing wheels stay missing for everyone. A car without its catalytic converter **sounds** like it, for everyone.
- Heavy loot puts you in a box-carry: no sprinting, jumping, weapons or getting in vehicles. Get knocked over and you drop it. Target any vehicle to load it into the trunk, or press `X` (rebindable) to put it down. Anyone can pick up loot left lying around.
- Tools have durability and break.

**Heat**
- Every stage rolls a noise report (less likely at night, more likely while a car alarm is going).
- Locked cars may go off when you start working on them.
- **Encounters.** Sometimes someone turns up. It isn't every job, and not every NPC in range. Weighted random types:
  - **Nosy neighbour (Karen)** walks over, films you on her phone and whinges. She calls if you're still there when she runs out of patience. Threaten or shove her and she calls immediately.
  - **Angry local** marches over, warns you, then fights with fists or a bat, which interrupts your job. Pull a gun and he might back off.
  - **Timid passer-by** keeps their distance and calls it in quietly. Point a gun at them and they'll probably run.
  - **Security guard** walks over with a flashlight and radios it in. Hard to scare off.
  - Ambient cops who see you report it instantly.
- Catalytic converters and wheels carry metadata (`value`, plus a description with the car and plate). Police can trace them, and your own pawn shop can read `metadata.value`.

**Progression.** Reputation (stored per character) makes you work faster. With the optional buyers it also gets you better prices, and the fence only deals with known scrappers. Check it with `/scraprep`.

**Optional buyers** (`EnableBuyers = true`): a scrapyard plus a night-only fence who moves around. The scrapyard can point you to the fence once you've earned some rep. Prices follow a live market: selling floods it, it recovers over time, and it drifts daily. These are off by default, so the resource just gives items and you sell through your own shops.

**Security.** The server is authoritative. It opens a session per job and checks timing on every stage (no instant completes). It also checks distance, tools and durability, minimum cops and per-target locks. Loot is rolled server-side, and loot or debris props are checked by model before they're accepted.

## Requirements

- OneSync
- [ox_lib](https://github.com/overextended/ox_lib), [ox_target](https://github.com/overextended/ox_target), [ox_inventory](https://github.com/overextended/ox_inventory)
- Framework: Qbox (recommended), QBCore or ESX. It also runs standalone; only money payouts, IDs and police counts use the framework.
- Optional: ps-dispatch or cd_dispatch (or hook your own in `client/modules/dispatch.lua`), oxmysql (only for `protectOwned`)

## Installation

1. Drop `cr-scraptheft` into your resources and `ensure` it after ox_lib, ox_target and ox_inventory.
2. Add the items from `install/ox_items.lua` to `ox_inventory/data/items.lua`. Copy `images/*.png` to `ox_inventory/web/images`.
3. Give tools out however you like (hardware store, crafting, etc.):
   `angle_grinder` / `oxycutter`, `screwdriverset`, `bolt_cutters`, `lug_wrench`, `car_jack`, and optionally `insulated_gloves`.
4. Review `config/shared.lua` (framework, dispatch, heat, encounters) and `config/profiles.lua` (jobs, loot, timings).

Debug logging: `setr ox:printlevel:cr-scraptheft debug`

## Configuration overview

- `config/shared.lua`: integrations, tools, heat and encounters, carrying, rep, market, vehicles, anti-exploit.
- `config/profiles.lua`: each job is a list of **stages** (label, duration, tool, animation, skill checks, steps, sparks, hazards, debris) plus a **loot** table. Add a new world-object job by copying a profile and changing `models`.
- `config/buyers.lua`: only used with `EnableBuyers = true`.

Props and particle effects are referenced by name. If a model doesn't exist in your game build, the script falls back to `FallbackProp` instead of breaking. Swap any of them freely.

## Upgrading from v2

- Config is now split across `config/shared.lua`, `config/profiles.lua` and `config/buyers.lua`. Models are given by name, not hash.
- `oxycutter` still works as a cutting tool. Make it `stack = false` so durability works.
- The old `cr-scraptheft_debugMode` convar is replaced by the ox_lib print level above.

## Notes

Feel free to share, adapt and modify. Issues and PRs welcome.
