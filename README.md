# Vibe Clicker

Vibe Clicker is a fully data-driven idle/physics collector prototype built with Godot 4.3.
The loop focuses on striking a central geode, managing shard physics, and optimizing
collector routes through modular buildings and prestige resets.

## Getting started

1. Install Godot 4.3 or later.
2. Open `project.godot` from the Godot project manager.
3. Run the project (F5) to launch the simulation.

### Controls

- Left Click: Interact with UI buttons.
- Space: Toggle pause.
- P: Toggle prestige panel.
- F1: Toggle debug overlay.
- Esc: Quit.

## Data & tuning

All balance tuning lives in `content/balance.json`. The file is safe to edit while the
project is closed; relaunch to apply changes. Key sections include:

- `economy`: starting shiny, prestige thresholds, Fluxium gains.
- `spawns`: shard counts, launch speeds, angular spreads.
- `physics`: gravity, damping, arena bounds, shard radius.
- `collectors` & `strikers`: unit stats and AI parameters.
- `buildings`: per-building cost and field strengths.
- `upgrades`, `talents`, and `status_effects`: UI-driven progression hooks.

## Performance tips

- The shard simulation runs on a deterministic 1/120 s tick and uses a spatial hash for
  collector targeting. Keep shard radius and arena size reasonable to sustain 10–20k shards.
- Buildings update descriptors once per physics tick, avoiding allocations inside the hot loop.
- MultiMesh-based rendering batches all shard sprites into a single draw call.

## Save system

Progress autosaves every 10 seconds to `user://save.json`. Save files include run state,
upgrades, currency totals, and placed buildings. Delete the file to reset the profile.

## Steam integration roadmap

A stub `SteamService.gd` is already present with achievement/stat/cloud placeholders.
To integrate Steam later:

1. Add the [GodotSteam](https://github.com/GodotSteam/GodotSteam) plugin under `/addons`.
2. Replace the stub methods in `SteamService.gd` with real GodotSteam API calls.
3. Forward achievements, stats, and cloud save payloads through the new service.
4. Enable Steamworks SDK initialization during project startup and guard against offline mode.

## Exporting

Export presets for Windows Desktop and Linux/X11 ship with the project (`export_presets.cfg`).
Use Godot's export dialog to build platform binaries.

## Acceptance self-check

- Physics tick maintains performance with pooled shards and batched rendering.
- Prestige retains Fluxium while resetting the field via the `Prestige` system.
- Collector retargeting leverages the spatial hash API, avoiding quadratic scans.
