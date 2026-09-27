# godot_better_button | 更好的按钮

[English](#english) | [中文](#中文)

---

<a id="english"></a>

## English

A [Godot 4.5](https://godotengine.org) editor plugin that provides **Better Button** — a multi-texture composite button where every visual, animation, and sound is an optional inspector setting. Stop hand-writing "Button + Normal/Pressed/Shadow Sprite2D children + hover-scale script" boilerplate.

### Highlights

- 🎨 **3-state textures** — normal / hover / pressed slots, plus extra custom layers stacked on top
- 🌑 **Quick shadow** — one checkbox: a state-following darkened copy of the base texture, auto-managed
- ✍️ **Auto text** — auto-created label with font/size/color/outline/drop-shadow, hover color change, and press-move-down
- 🎞️ **14 animation presets** — hover grow, press shrink, click shake, click bounce, offset sway, hop, rotation sway, vibration, blink, color flash, heartbeat, squash & stretch, nod, sink; each expandable with its own trigger checkboxes and parameters
- 🔤 **Built-in shaders** — outline (with hover-only mode) and 3D-preview presets, no manual file dragging
- 🔊 **Sounds with fallback** — hover/press audio slots with independent volumes, falling back to your project's `音效` autoload
- 🙈 **Clean scene dock** — generated texture/shadow/text nodes are internal, fully managed by the plugin

### Requirements

| | |
|---|---|
| Engine | Godot 4.5 |
| Language | GDScript (no dependencies) |

### Installation

Copy the `better_godot_button` folder into your project's `addons/` directory, then enable **BetterGodotButton** in *Project → Project Settings → Plugins*.

> 🤖 **Let your AI agent use it**: point the agent at [AI_AGENT_GUIDE.md](AI_AGENT_GUIDE.md) — file map, `.tscn` code path, core mechanics, and a pitfall checklist written for automated execution.

### Usage

After adding the node, every feature is an inspector option and everything is optional:

| Group | What you get |
|---|---|
| 纹理 Texture | Normal/hover/pressed slots (auto-centered) + extra layers via `纹理层列表` |
| 阴影 Shadow | State-following shadow; offset (5,5) and 50% opacity by default |
| 动画 Animation | 14 presets, each with hover/press/click triggers and parameters |
| 文本 Text | Auto label: content, font, size, color, outline, shadow, hover color, press move-down |
| 描边 Outline | Built-in outline shader, optional hover-only mode |
| 音效 Sounds | Hover/press audio slots + independent volumes |
| 着色器 Shader | 3D-preview preset (mouse-follow) or custom shader |

Interactions match classic card-game buttons: pressing swaps to the pressed texture, text moves down, hover grows — all toggleable.

### Configuration

| Key | Default | Meaning |
|---|---|---|
| `better_button/language` | `zh` | Node-creation menu name: `zh` → 更好的按钮, `en` → Better Button |

Add to `project.godot`:

```ini
[better_button]
language="en"
```

### How it works

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

### Repository layout

```
godot_better_button/
├── plugin.cfg / plugin.gd        # plugin manifest & registration (language switch)
├── better_button.gd              # core script (@tool extends Button)
├── button_texture_layer.gd       # extra texture layer config resource
├── animations/                   # 14 animation config resources (animation_base.gd + presets)
├── shader/preview_3d.gdshader    # 3D-preview preset (same source as the project's shader)
├── shader/outline.gdshader       # outline shader
├── AI_AGENT_GUIDE.md             # usage guide written for AI agents
└── README.md                     # this file
```

### License

[MIT](LICENSE)

---

<a id="中文"></a>

## 中文

一个 [Godot 4.5](https://godotengine.org) 编辑器插件，提供**更好的按钮**——多层纹理复合按钮，所有视觉、动画、音效都是检查器里的可选项。再也不用手写"Button + 正常/按下/阴影 Sprite2D 子节点 + 悬浮缩放脚本"这种样板代码。

### 功能特性

- 🎨 **三态纹理**——常规/悬停/按下三个槽位，还可在其上叠加自定义纹理层
- 🌑 **快捷阴影**——一个勾选：自动生成跟随状态的阴影（首层纹理调黑偏移），全权托管
- ✍️ **自动文本**——自动创建文本 Label，支持字体/字号/颜色/描边/投影阴影/悬停变色/按下下移
- 🎞️ **14 个动画预设**——悬停放大、按下缩小、点击抖动、点击弹跳、位移摇晃、上下弹动、旋转摆动、位置震动、闪烁、颜色闪烁、心跳、挤压拉伸、点头、下沉；每个可展开，独立配置触发时机与参数
- 🔤 **内置 shader**——描边（可悬停才显示）与 3D预览 预设，无需手动拖文件
- 🔊 **音效回退**——悬停/按下音频槽，音量独立，留空自动回退项目的 `音效` autoload
- 🙈 **场景树清爽**——生成的纹理/阴影/文本节点是内部节点，面板里不可见

### 环境要求

| | |
|---|---|
| 引擎 | Godot 4.5 |
| 语言 | GDScript（零依赖） |

### 安装

把 `better_godot_button` 文件夹复制到项目的 `addons/` 目录，然后在 *项目 → 项目设置 → 插件* 里启用 **BetterGodotButton**。

> 🤖 **让 AI Agent 帮你用**：把 [AI_AGENT_GUIDE.md](AI_AGENT_GUIDE.md) 喂给 AI——文件结构、.tscn 代码路径、核心机制、踩坑清单，全部按自动化执行标准编写。

### 使用

添加节点后，所有功能都是检查器选项，且全部可选：

| 分组 | 功能 |
|---|---|
| 纹理 | 常规/悬停/按下槽位（自动居中）+ `纹理层列表` 追加层 |
| 阴影 | 跟随状态的阴影；默认偏移 (5,5)、透明度 50% |
| 动画 | 14 个预设，各自带悬停/按下/点击触发勾选与参数 |
| 文本 | 自动 Label：内容、字体、字号、颜色、描边、阴影、悬停变色、按下下移 |
| 描边 | 内置描边 shader，可选悬停才显示 |
| 音效 | 悬停/按下音频槽 + 独立音量 |
| 着色器 | 3D预览预设（鼠标跟随）或自定义 shader |

交互手感与经典卡牌按钮一致：按下换纹理、文本下移、悬停放大——全部可开关。

### 配置

| 键 | 默认 | 含义 |
|---|---|---|
| `better_button/language` | `zh` | 新建节点菜单名：`zh` → 更好的按钮，`en` → Better Button |

在 `project.godot` 中添加：

```ini
[better_button]
language="en"
```

### 工作原理

```
better_button.gd (@tool, _ready)
  └─► 按检查器配置生成内部 Sprite2D/Label 子节点
        ├── 纹理层：常规/悬停/按下，缺失状态逐级回落
        ├── 阴影：首层纹理调黑半透明，跟随状态切换
        └── 文本 Label：可选，场景里同名 Label 会被复用
悬停 / 按下 / 点击 ──► 状态切换 + 动画派发（position / rotation /
                       modulate / scale 四通道互不干扰）
松开 ──► 缩放复位到悬停或基准大小（点击缩放接管感知）
音效 ──► 音频槽优先，否则 音效 autoload（不存在则静默跳过）
```

生成节点是 Godot **内部节点**——场景树面板不可见、随场景保存、完全不碍事。场景里手动摆放的同名 `Sprite2D`/`Label` 会被复用而不是重复创建。

### 仓库结构

```
godot_better_button/
├── plugin.cfg / plugin.gd        # 插件清单与注册（含语言切换）
├── better_button.gd              # 核心脚本（@tool extends Button）
├── button_texture_layer.gd       # 追加纹理层配置资源
├── animations/                   # 14 个动画配置资源（animation_base.gd + 各预设）
├── shader/preview_3d.gdshader    # 3D预览预设（与项目主工程 shader 同源）
├── shader/outline.gdshader       # 描边 shader
├── AI_AGENT_GUIDE.md             # 专为 AI agent 编写的使用指南
└── README.md                     # 本文件
```

### 许可证

[MIT](LICENSE)
