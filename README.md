# Archean Radar (Xenoncode)

Work in progress. This repository contains an in‑game radar program for the Archean engine, written in Xenoncode. It renders a 2×2 radar scope with smart labels, a world‑time clock, an in‑range contact list, a recent contacts log, and user‑defined map icons. All verification is done in‑game.

> Status: actively evolving; APIs, file layout, and visuals may change.

## What’s Included
Only the radar program sources:

- `main.xc` – minimal entrypoint that loads the modular radar program
- `RadarModular.xc` – module aggregator/loader for the radar
- `modular/` – implementation files (rendering, state, init, logging, icons, etc.)

No external tools, binaries, or assets are included.

## Features (WIP)
- 2×2 radar display with range rings and sweep
- Smart label placement with collision avoidance (4 positions with leader lines)
- Beacon‑driven world‑time clock (12/24‑hour, frequency 1944)
- Top‑right range readout and cardinal marks
- In‑range contacts panel (3‑line entries spanning two HD screens)
- Recent contacts log (ACQ/LOST) with timestamps and positions
- User‑defined static map icons (airports, waypoints, navaids, etc.), drawn under the sweep
- Ground‑station relative projection (lat/lon → km → screen)

## File Layout
- `main.xc` – Entrypoint for this radar
- `RadarModular.xc` – Includes the modules under `modular/`
- `modular/`
  - `init.xc` – Initializes state, sets up the clock beacon and user icons
  - `render.xc` – Draws radar, sweep, labels, logs, and in‑range panels
  - `state.xc` – Global arrays and runtime variables
  - `logs.xc` – Contact logging and formatting
  - `icons.xc` – Icon primitives + registry (`@icons_add`, `@icons_user_config`)
  - `callsigns.xc`, `buzzer.xc`, `geodesic.xc`, etc. – Support modules

## Requirements
- Archean game with an in‑game computer capable of running Xenoncode `.xc` programs
- Displays configured as:
  - `Dashboard_0` (4 screens) for the 2×2 radar
  - `Dashboard_1` (top/bottom) for the recent contacts log (optional fallback to bottom if top is absent)
  - `Dashboard_3` (top/bottom) for the in‑range contacts list
- NAV instrument providing ground station latitude/longitude
- Optional clock beacon broadcasting sun angle 0–360° on frequency `1944`

## Installation
1. Create a new repo with only these files/folders:
   - `main.xc`
   - `RadarModular.xc`
   - `modular/`
2. On your Archean machine/world, place the files where your in‑game computer reads its program (for example, your computer’s HDD path or via a Data Bridge). The radar expects to be the active program.
3. Power on the computer. The radar will initialize and render automatically.

> Note: This project deliberately omits any world save, external assets, or tooling. Only the radar program sources are part of this repo.

## Configuration
- World Time (clock):
  - The program listens to a beacon (alias `CLOCK_BCN`) tuned to frequency `1944` for a sun angle (0–360°). If unavailable, the clock may not reflect world time.
  - Toggle 12/24‑hour format via `USE_24H_CLOCK` in `modular/state.xc`.
- User Icons:
  - Edit `modular/icons.xc` → `@icons_user_config()` and add entries:
    ```
    @icons_add(type, latDeg, lonDeg, headingDeg, color)
    ```
  - Example:
    ```
    @icons_add(1, 37.6195, -122.375, 0, cyan)  ; Airport
    @icons_add(10, 37.62, -122.34, 280, green) ; Final approach 280°
    ```
  - Icons are culled to the current max range and drawn beneath the sweep.
- Range/Scales:
  - Core range/geometry constants live in the modular files (e.g., `utils/state`). Adjust with care.

## Usage Notes
- Labels: Four placement options with automatic fallback; leader lines indicate association.
- In‑Range Panel: Three‑line entries (ID; HDG/SPD/ALT/VS; Lat/Lon) spanning two screens with alternating row bands.
- Logs: ACQ/LOST events in `Dashboard_1` include world‑time stamps and last known positions.
- Draw Order: Rings → icons → sweep/trail → aircraft → labels.

## Limitations
- This is a WIP. Expect visual/behavioral changes.
- Icon rendering near screen seams is conservative; very large icons may clip across quadrants.
- Performance and memory caps (e.g., icon count) are tuned for typical in‑game computers.

## Development
- There is no standalone build/test pipeline; testing and verification happen in‑game.
- Edits to `.xc` files take effect when the in‑game computer reloads the program.

## Contributing
Issues and PRs are welcome. Given the WIP status, please discuss substantial changes in an issue first.

## License
TBD.
