# godot_better_button | 更好的按钮

Two Godot 4.5 editor plugins (English + 中文) providing **Better Button / 更好的按钮** — a multi-texture composite button where every visual, animation, and sound is an optional inspector setting. Stop hand-writing "Button + Normal/Pressed/Shadow Sprite2D children + hover-scale script" boilerplate.

This repository ships **two plugin folders**, identical in behavior, differing only in language:

| Folder | Inspector language | Custom type |
|---|---|---|
| `better_godot_button/` | English (English property names & groups) | **Better Button** |
| `better_godot_button_zh/` | 中文 (中文属性名与分组) | **更好的按钮** |

Install only **one** of them — copy that folder into your project's `addons/` and enable it in *Project → Project Settings → Plugins*.

> 🤖 **For AI agents**: read [AI_AGENT_GUIDE.md](AI_AGENT_GUIDE.md) — file map, `.tscn` code path, core mechanics, and a pitfall checklist written for automated execution.

---

## Highlights

- 🎨 **3-state textures** — normal / hover / pressed slots, plus extra custom layers stacked on top
- 🌑 **Quick shadow** — one checkbox: a state-following darkened copy of the base texture, auto-managed
- ✍️ **Auto text** — auto-created label with font/size/color/outline/drop-shadow, hover color change, and press-move-down
- 🎞️ **14 animation presets** — hover grow, press shrink, click shake, click bounce, offset sway, hop, rotation sway, vibration, blink, color flash, heartbeat, squash & stretch, nod, sink; each expandable with its own trigger checkboxes and parameters
- 🔤 **Built-in shaders** — outline (with hover-only mode) and 3D-preview presets, no manual file dragging
- 🔊 **Sounds with fallback** — hover/press audio slots with independent volumes, falling back to your project's `音效` autoload
- 🙈 **Clean scene dock** — generated texture/shadow/text nodes are internal, fully managed by the plugin

## Requirements

| | |
|---|---|
| Engine | Godot 4.5 |
| Language | GDScript (no dependencies) |

## Installation

1. Copy **one** of the two plugin folders (`better_godot_button` or `better_godot_button_zh`) into your project's `addons/`.
2. Enable it in *Project → Project Settings → Plugins*.

## Usage

After adding the node, every feature is an inspector option and everything is optional:

| Group | What you get |
|---|---|
| Texture | Normal/hover/pressed slots (auto-centered) + extra layers via `texture_layers` |
| Shadow | State-following shadow; offset (5,5) and 50% opacity by default |
| Animation | 14 presets, each with hover/press/click triggers and parameters |
| Text | Auto label: content, font, size, color, outline, shadow, hover color, press move-down |
| Outline | Built-in outline shader, optional hover-only mode |
| Sound | Hover/press audio slots + independent volumes |
| Shader | 3D-preview preset (mouse-follow) or custom shader |

Interactions match classic card-game buttons: pressing swaps to the pressed texture, text moves down, hover grows — all toggleable.

## How it works

```
better_button.gd (@tool, _ready)
  └─► builds internal Sprite2D/Label children from inspector configs
        ├── texture layers: normal/hover/pressed with graceful fallback
        ├── shadow: darkened copy of the base layer, follows state
        └── text label: optional, reused if a same-named label exists
Hover / press / click ──► state swap + animation dispatch (separate
                          position / rotation / modulate / scale channels)
Released ──► scale restores to hover or base size (click-scale takeover aware)
Sounds ──► audio slots, else 音效 autoload (silently skipped if absent)
```

Generated nodes are Godot **internal** nodes — invisible in the scene dock, saved with the scene, never in your way. Manual same-named `Sprite2D`/`Label` children are reused instead of duplicated.

## Repository layout

```
godot_better_button/
├── README.md                    # this file
├── LICENSE                      # MIT
├── AI_AGENT_GUIDE.md            # usage guide written for AI agents
├── better_godot_button/         # English plugin  (Better Button)
│   ├── plugin.cfg / plugin.gd
│   ├── better_button.gd         # core script (@tool extends Button, class_name BetterButton)
│   ├── button_texture_layer.gd
│   ├── animations/              # 14 animation configs (animation_base.gd + presets)
│   └── shader/preview_3d.gdshader, outline.gdshader
└── better_godot_button_zh/      # Chinese plugin  (更好的按钮, same structure)
```

## License

[MIT](LICENSE)
