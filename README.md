# Godot Town Demo

A top-down 2D RPG prototype built in **Godot 4.3**. This serves as a template for how a classic RPG town should be structured — explorable buildings with interiors, NPC dialogue, a minimap, scene transitions, and a full-map overlay.

---

## Features

- **Three explorable outdoor maps** — main town (`main.tscn`), a second town to the west (`town2.tscn`), and a forest overworld (`overworld.tscn`)
- **Enterable buildings** — walk through any building door to enter a full interior scene; walk back to the bottom exit to return outside
- **Five unique interiors** — Tavern, Inn, Weapons Store, Blacksmith, and generic houses
- **Impassable furniture** — bar counters, tables, and shelves all have physics collision
- **NPC dialogue** — approach named characters (Merchant, Tavernkeeper, Villagers) and press interact; desk NPCs require you to stand right in front of the counter
- **Minimap** — always-visible corner map auto-detecting buildings, NPCs, and player via scene groups
- **Full-map overlay** — toggle a full-screen world map at any time
- **Building signs** — the Tavern and Weapons Store display a labeled sign above their roof
- **Spawn position preservation** — player spawns in front of the correct door after every scene transition
- **Impassable borders** — physics walls on all map edges; exits only at marked pathways

---

## Controls

| Action | Key |
|---|---|
| Move | Arrow keys or WASD |
| Interact / advance dialogue | E or Space |
| Close dialogue | E or Escape |
| Toggle full map | M |

---

## Project Structure

```
godot-town-demo/
├── main.tscn               # Main town — 6 buildings, top exit → overworld, left exit → town2
├── main.gd                 # Handles TopExit → overworld, LeftExit → town2
├── town2.tscn              # Second town — 6 buildings, right exit → main town
├── town2.gd                # Handles RightExit → main town
├── overworld.tscn          # Forest overworld scene
├── overworld.gd            # Handles BottomExit → main town
│
├── house.tscn              # Reusable building prefab (bare Node2D + house.gd)
├── house.gd                # Builds collision, door trigger, roof, sign in _ready()
│                           # Exports: house_width, house_height, house_color,
│                           #          roof_color, interior_scene, sign_text
│
├── house_interior.tscn     # Generic house interior (1280×720, table + chairs)
├── shop_interior.tscn      # Weapons Store interior (counter, shelves, Merchant NPC)
├── tavern_interior.tscn    # Tavern interior (bar, two table groups, Tavernkeeper NPC)
├── inn_interior.tscn       # Inn interior (counter, tables, Innkeeper NPC)
├── blacksmith_interior.tscn # Blacksmith interior (dark stone, anvil, Blacksmith NPC)
├── house_interior.gd       # Shared script for all interiors — ExitDoor → return to town
│
├── player.tscn             # Player (CharacterBody2D, 32×32, "player" group)
├── player.gd               # WASD movement, reads GlobalState.spawn_position on ready
│
├── npc.tscn                # NPC template (StaticBody2D + InteractionArea)
├── npc.gd                  # Dialogue trigger; exports: npc_name, dialogue_lines,
│                           #   interaction_offset, interaction_size
│
├── dialogue_box.tscn       # Dialogue UI (CanvasLayer 20)
├── dialogue_box.gd         # Shows dialogue lines, advances/closes on input
│
├── minimap.tscn            # Minimap UI (CanvasLayer 10, top-right corner)
├── minimap.gd              # Redraws every frame; auto-detects "buildings" / "npcs" /
│                           #   "player" groups — no hardcoded positions
│
├── full_map.tscn           # Full-screen map overlay (CanvasLayer 15)
├── full_map.gd             # M key toggle
├── full_map_draw.gd        # Draws full map with grid and entity positions
│
├── global_state.gd         # Autoload singleton — spawn_position, previous_scene,
│                           #   return_position persisted across scene changes
└── project.godot           # Input map, autoloads, 1280×720 viewport
```

---

## World Layout

Both outdoor maps are **2400 × 1800** px. The viewport is **1280 × 720**, giving a 2×2 logical screen grid per map. Interior rooms are **1280 × 720** (one screen, no scrolling).

```
[ Overworld — forest ]
        ↕  (north exit / south exit, x 1100–1300)
[ Town 2 — town2.tscn ] ←→ [  Main Town — main.tscn  ]
                (left/right exit, y 800–1000)
        ↕  (walk through any building door)
[ Interior — tavern / inn / shop / blacksmith / house ]
```

### Main town building grid

```
Col A (x≈300)          Col B (x≈1750)
─────────────────────────────────────
House 1                Tavern         ← row 1 (y≈200)
Weapons Store          House 2        ← row 2 (y≈700)
House 3                House 4        ← row 3 (y≈1300)
```

### Town 2 building grid

```
Col A (x≈300)          Col B (x≈1750)
─────────────────────────────────────
House 1                Inn            ← row 1 (y≈200)
House 2                Blacksmith     ← row 2 (y≈700)
House 3                House 4        ← row 3 (y≈1300)
```

---

## Key Systems

### Building interiors (`house.gd` + `house_interior.gd`)
`house.gd` programmatically creates all collision, the roof strip, the door visual, a door trigger `Area2D`, and an optional sign `Label` at runtime in `_ready()`. No child nodes need to be placed in the editor — only export properties on the instance.

When the player enters the door trigger:
1. `GlobalState.previous_scene` and `GlobalState.return_position` are saved
2. `GlobalState.spawn_position` is set to the interior door spawn point
3. Scene changes to `interior_scene`

`house_interior.gd` (attached to all three interior roots) connects `ExitDoor.body_entered`: on player contact it restores `spawn_position = return_position` and changes back to `previous_scene`.

### NPC interaction zones (`npc.gd`)
Each NPC instance exposes `interaction_offset` and `interaction_size` exports. In `_ready()` a fresh `RectangleShape2D` is created (avoiding shared resource mutation across instances) and applied to the `InteractionArea`. Desk NPCs set a forward offset so the "!" indicator and interact trigger appear in front of the counter, not behind it.

### Minimap auto-sync (`minimap.gd`)
No hardcoded building arrays. Buildings register their Floor `ColorRect` into the `"buildings"` group via `house.gd`. The minimap queries the group each frame, reads `global_position` and `size`, and draws scaled rects in the correct color. The same pattern applies to `"npcs"` and `"player"` groups.

---

## Adding a New Town

Follow these steps every time you add a new outdoor town scene:

### 1. Create `townN.tscn`
- Copy the structure of `town2.tscn` as a starting point
- Set a unique `uid` string at the top (e.g. `uid://town3_001`)
- Place 6 `house.tscn` instances in the standard 2-column × 3-row grid (Col A x≈300, Col B x≈1750; rows at y≈200 / 700 / 1300)
- Wire up your exit: split whichever border wall needs a gap into two `CollisionShape2D` segments with a 200px opening centered at y=900 (for left/right exits) or x=1200 (for top/bottom)
- Add the corresponding `Area2D` exit trigger at the gap
- Add gray `ColorRect` visual strips flanking the gap (width/height 120px, matching the gap edges), same as `LeftSideTopWall` / `LeftSideBottomWall` in `main.tscn`
- Include `Player`, `Camera2D`, `DialogueBox`, `Minimap`, and `FullMap` instances — copy directly from an existing town scene

### 2. Create `townN.gd`
```gdscript
extends Node2D

func _ready() -> void:
    $YourExit.body_entered.connect(_on_exit)

func _on_exit(body: Node2D) -> void:
    if body.is_in_group("player"):
        GlobalState.spawn_position = Vector2(...)  # spawn near the matching gap in the destination scene
        get_tree().change_scene_to_file("res://destination.tscn")
```

### 3. Update the connecting scene's `.gd` script
Add a new `body_entered` connection for the exit that leads into your new town, and set `GlobalState.spawn_position` to land the player near the gap on the new town's matching edge.

### 4. Update `minimap.gd`
- Add a new constant for your town's exit wall strips, e.g.:
```gdscript
const TOWN3_LEFT_EXIT_WALLS := [
    [0.0, 0.0, 120.0, 800.0],
    [0.0, 1000.0, 120.0, 1800.0],
]
```
- Update the `is_town` check to include the new scene filename:
```gdscript
var is_town := scene_path.ends_with("main.tscn") or scene_path.ends_with("town2.tscn") or scene_path.ends_with("town3.tscn")
```
- Add a branch in the exit walls selection block:
```gdscript
elif scene_path.ends_with("town3.tscn"):
    exit_walls = TOWN3_LEFT_EXIT_WALLS
```

### 5. NPC placement rules
- **Never** place outdoor NPCs at a position that overlaps a building footprint
- Building footprints: `position.x` → `position.x + house_width`, `position.y` → `position.y + house_height`
- Safe zones: center of the map (x≈900–1400), between building rows, or any position clearly in the open ground
- Desk NPCs (behind counters) must have `interaction_offset` and `interaction_size` set so the trigger zone appears **in front of** the counter, not behind it

### 6. Interior scenes
- All interior scenes must be **1280 × 720** to match the viewport — smaller rooms cause the camera to render incorrectly
- Attach `house_interior.gd` to the root node — it handles the `ExitDoor` trigger automatically
- Set `Camera2D` limits to `limit_left=0`, `limit_top=0`, `limit_right=1280`, `limit_bottom=720`
- Keep furniture away from the center walkway; only add `StaticBody2D` collision to furniture the player should not pass through

---

## Color Guide

| Color | Represents |
|---|---|
| Blue dot (white center) | Player on minimap |
| Yellow dots | NPCs on minimap |
| Bright green | Town grass |
| Dark green | Forest ground |
| Brown dirt strip | Overworld path |
| Warm brown rectangles | Buildings |
| Dark brown | Doors / counters |
| Medium gray | Impassable walls / exit borders |

---

## How to Run

1. Open **Godot 4.3+**
2. Click **Import** and select `project.godot` in this folder
3. Press **F5** to play (`main.tscn` is the default scene)
