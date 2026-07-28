# BrokeWatch

A Windower 4 addon for Final Fantasy XI that tracks your gil spent while utilizing the Hoxne Ampulla enchantment.

![BrokeWatch HUD](brokewatch_preview.png)

## Features
* 📈 **Dynamic Visibility**: The HUD automatically pops up on your screen when you equip the **Hoxne Ampulla**, and hides itself as soon as you unequip it to keep your UI clutter-free.
* 🔊 **Arcade Audio & Text Milestones**: 
  * Plays register chime sound effects and displays floating milestone flairs when crossing key session milestones (10K, 25K, 50K, 100K, etc.).
  * Milestone sounds scale dynamically in length and bell count as the milestones grow.
  * A dramatic Windows `tada.wav` fanfare triggers when you cross all-time million-gil milestones.
  * All audio chimes and alert texts are clean table-driven lookups at the top of `BrokeWatch.lua` for easy editing and custom expansions.
* 🌙 **OLED Burn-in Protection (Auto-Dimming & Muted Colors)**:
  * **Auto-Dimming**: Fades the HUD opacity smoothly to **30% (alpha 80)** after **3 minutes** of idle time (no combat, gear changes, or command inputs).
  * **Instant Wake-up**: Wakes up immediately back to **100% opacity (alpha 255)** upon any gil loss, equipment change, or command execution.
  * **Pastel Color Palette**: Uses lower-luminance pastel colors (Goldenrod, Coral Red, Sage Green, and Slate Red) to reduce screen stress on OLED monitors/TVs.

## Installation
1. Download or clone this repository.
2. Place the `BrokeWatch` folder inside your Windower addons directory:
   `C:\Windower4\addons\`
3. Load the addon in-game:
   ```windower
   //lua load BrokeWatch
   ```
   *(To auto-load on startup, add `lua load BrokeWatch` to your `Windower4/scripts/init.txt`)*

## Commands
Interact with the addon using `//broke` or `//brokewatch`:
* `//broke reset` or `//broke reset session` – Resets current session loss and milestones to 0.
* `//broke reset all` – Resets total all-time loss and milestones to 0.
* `//broke show` / `//broke hide` – Manually toggle HUD visibility.
* `//broke sound [on/off]` – Enable or disable milestone sound chimes.
* `//broke sound set [1/2/5]` – Switch and play a preview of the cash register sounds (1, 2, or 5).
* `//broke font` – Print current fonts and commands.
* `//broke font header <font_name>` – Set the font face for the header.
* `//broke font body <font_name>` – Set the font face for the stats body.
* `//broke font size [header/body] <size>` – Set the font size for the header or body.
