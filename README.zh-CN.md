# godot_better_button | 更好的按钮

两个 Godot 编辑器插件（英文版 + 中文版），提供**更好的按钮**——多层纹理复合按钮，所有视觉、动画、音效都是检查器里的可选项。再也不用手写"Button + 正常/按下/阴影 Sprite2D 子节点 + 悬浮缩放脚本"这种样板代码。

本仓库包含**两个插件文件夹**，行为完全一致，仅语言不同：

| 文件夹 | 检查器语言 | 自定义类型 |
|---|---|---|
| `better_godot_button/` | 英文（属性与分组全英文） | **Better Button** |
| `better_godot_button_zh/` | 中文（属性与分组中文） | **更好的按钮** |

只安装**其中一个**——把对应文件夹复制到项目的 `addons/`，然后在 *项目 → 项目设置 → 插件* 里启用。

> 🤖 **让 AI Agent 帮你用**：把 [AI_AGENT_GUIDE.md](AI_AGENT_GUIDE.md) 喂给 AI——文件结构、.tscn 代码路径、核心机制、踩坑清单，全部按自动化执行标准编写。

---

## 功能特性

- 🎨 **三态纹理**——常规/悬停/按下三个槽位，还可在其上叠加自定义纹理层
- 🌑 **快捷阴影**——一个勾选：自动生成跟随状态的阴影（首层纹理调黑偏移），全权托管
- ✍️ **自动文本**——自动创建文本 Label，支持字体/字号/颜色/描边/投影阴影/悬停变色/按下下移
- 🎞️ **14 个动画预设**——悬停放大、按下缩小、点击抖动、点击弹跳、位移摇晃、上下弹动、旋转摆动、位置震动、闪烁、颜色闪烁、心跳、挤压拉伸、点头、下沉；每个可展开，独立配置触发时机与参数
- 🔤 **内置 shader**——描边（可悬停才显示）与 3D预览 预设，无需手动拖文件
- 🔊 **音效回退**——悬停/按下音频槽，音量独立，留空自动回退项目的 `音效` autoload
- 🙈 **场景树清爽**——生成的纹理/阴影/文本节点是内部节点，面板里不可见

## 环境要求

| | |
|---|---|
| 引擎 | Godot 4.5（`master` 分支）/ Godot 4.7（`godot-4.7` 分支） |
| 语言 | GDScript（零依赖） |

### 分支说明

| 分支 | Godot 版本 | 说明 |
|---|---|---|
| `master` | 4.5 | 稳定主线，已实测 |
| `godot-4.7` | 4.7 | 4.7 适配分支，初始与 `master` 相同 |

```bash
git clone -b master      https://github.com/lebrontheg0at/godot_better_button.git   # Godot 4.5
git clone -b godot-4.7   https://github.com/lebrontheg0at/godot_better_button.git   # Godot 4.7
```

## 安装

1. 复制**其中一个**插件文件夹（`better_godot_button` 或 `better_godot_button_zh`）到项目的 `addons/`
2. 在 *项目 → 项目设置 → 插件* 里启用

## 使用

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

## 工作原理

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

## 仓库结构

```
godot_better_button/
├── README.md                  # 本文件
├── LICENSE                    # MIT
├── AI_AGENT_GUIDE.md          # 专为 AI agent 编写的使用指南
├── better_godot_button/       # 英文版插件（Better Button）
│   ├── plugin.cfg / plugin.gd
│   ├── better_button.gd       # 核心脚本（@tool extends Button，class_name BetterButton）
│   ├── button_texture_layer.gd
│   ├── animations/            # 14 个动画配置（animation_base.gd + 各预设）
│   └── shader/preview_3d.gdshader, outline.gdshader
└── better_godot_button_zh/    # 中文版插件（更好的按钮，结构同上）
```

## 许可证

[MIT](LICENSE)
