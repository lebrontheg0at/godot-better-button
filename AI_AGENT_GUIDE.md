# 更好的按钮（godot_better_button）— AI Agent 使用指南

> 本仓库含**两个插件版本**，行为一致仅语言不同：`better_godot_button`（英文版，属性/分组全英文，自定义类型 Better Button）与 `better_godot_button_zh`（中文版，自定义类型 更好的按钮）。让 AI 用哪个版本，就让它把对应文件夹的脚本当作路径基准。本指南以中文版为例，英文版差异仅是标识符英文化。

> 本文档面向 AI Agent（Claude/Codex/Copilot 等），供你在 Godot 4.5 项目中正确使用/修改本插件。
> 人类开发者也可阅读，但内容按"agent 需要知道什么"组织。

## 版本选择

- 英文版 `better_godot_button/`：注册类型 `Better Button`，检查器全英文
- 中文版 `better_godot_button_zh/`：注册类型 `更好的按钮`，检查器中文
- 只安装其一；两版 `.tscn` 属性键不同（英文版用 `normal_texture` 等，中文版用 `常规纹理` 等）

## 插件是什么

`better_godot_button` 是一个 Godot 4.5 编辑器插件，提供 `更好的按钮`（脚本类名 `更好的按钮`，基类 `Button`）——一个多层纹理复合按钮，所有视觉/音效/动画均为可配置选项。设计目标是让项目里不再手写"Button + 正常/按下/阴影 Sprite2D 子节点 + 悬浮缩放脚本"这种样板。

## 文件结构

```
addons/better_godot_button/
├── plugin.cfg            # 插件清单，name=GodotBetterButton, author=luvland
├── 插件.gd               # EditorPlugin，注册自定义类型"更好的按钮"
├── better_button.gd      # 核心脚本 @tool extends Button class_name 更好的按钮
├── button_texture_layer.gd  # Resource：追加纹理层的单项配置
├── animations/            # 14 个动画配置资源（全部继承 按钮动画基类）
│   ├── animation_base.gd  #   触发时机三勾选 + 时长
│   ├── hover_grow_animation.gd   #   默认 悬停时播放，放大量 1.1
│   ├── press_shrink_animation.gd #   默认 按下时播放，缩小量 0.95
│   ├── click_shake_animation.gd  #   默认 点击时播放，角度/次数
│   ├── click_bounce_animation.gd #   默认 点击时播放，弹跳放大量 1.2
│   ├── sway_offset_animation.gd / hop_offset_animation.gd / sway_rotation_animation.gd / vibration_animation.gd
│   ├── blink_animation.gd / color_flash_animation.gd / heartbeat_animation.gd / squash_stretch_animation.gd
│   └── nod_animation.gd / sink_animation.gd
└── shader/
    ├── preview_3d.gdshader  # 与项目 shader/3D预览.gdshader 同源
    └── outline.gdshader     # 透明边缘描边，uniform：描边颜色/描边宽度/显示描边
```

## 快速开始（两种方式）

### 方式 A：检查器操作（人类用户路径）

1. 新建节点搜索"更好的按钮"（或把 `better_button.gd` 拖到已有 Button 上）
2. **纹理**组：拖入 `常规纹理` 即可工作；需要悬停/按下差异就填 `悬停纹理`/`按下纹理`
3. **阴影**组：勾 `启用阴影`（默认偏移 (5,5)、透明度 0.5）
4. **动画**组：每个动画是可展开资源，勾选 触发时机（悬停时/按下时/点击时播放）+ 调参数
5. **文本**组：勾 `自动创建文本` + 填 `文本内容`，可配字体/字号/颜色/描边/阴影/悬停变色/下移
6. **描边**组：勾 `启用描边`（可再勾 `悬停描边` 做到"悬停才显示描边"）
7. **着色器**组：`预设着色器` 选 3D预览，或拖自定义 shader
8. **音效**组：悬停/按下音效槽（拖音频文件优先，留空回退项目 `音效` autoload）

### 方式 B：Agent 直接写 .tscn（代码路径）

最小可用的节点片段（对子选项全默认）：

```ini
[node name="我的按钮" type="Button" parent="."]
offset_right = 92.0
offset_bottom = 76.0
flat = true
script = ExtResource("1")

"常规纹理" = ExtResource("2")
```

要点：**tscn 里中文属性键必须加英文双引号**（如 `"常规纹理" = ExtResource("2")`），不加引号的非 ASCII 键会被 Godot 静默丢弃——这是本插件历史上最大的坑。

动画配置以 sub_resource 挂在节点属性上：

```ini
[ext_resource type="Script" path="res://addons/better_godot_button/动画配置/悬停放大动画.gd" id="2_afd"]

[sub_resource type="Resource" id="Resource_anim1"]
script = ExtResource("2_afd")
"悬停时播放" = false
"按下时播放" = false
"点击时播放" = true

[node name="我的按钮" type="Button" parent="."]
"悬停放大" = SubResource("Resource_anim1")
```

## 核心机制（agent 必须理解）

1. **自动生成内部节点**：插件按配置在 `_ready`（@tool，编辑器里也跑）生成 Sprite2D/Label 子节点，全部是 **internal 节点**（场景树面板不可见）并带 `plugin_created` meta。场景树里看不到它们是正常的，不是丢了。插件每次构建会删除带此 meta 的节点再重建；场景里**手动摆放的同名 Sprite2D/Label 会被复用**（无 meta 即视为手动的）。
2. **纹理三态回落**：每层纹理按 常规/悬停/按下 三态取图，缺失的态逐级回落到常规。`纹理层列表` 的层叠在基础纹理之上；快捷阴影跟随**首层**当前状态的纹理。
3. **动画通道**：位置类动画动 `position`、旋转类动 `rotation`、透明度/颜色动 `modulate`、缩放类动 `scale`。不同通道可同时播放；同通道后触发者接管。点击触发的缩放类（弹跳/心跳/挤压拉伸/放大/缩小）会跳过松开还原，避免打架。
4. **状态型 vs 一次性**：悬停放大/按下缩小是状态型（进入改、退出复位）；其余动画是一次性播放后自动回基准。
5. **音效回退**：悬停/按下音效槽为空时调 `get_node_or_null("/root/音效")` 的 `播放选中音效()`/`播放开关音效()`，autoload 不存在则静默跳过。音量参数只作用于拖入的音频文件。

## Agent 踩坑清单（血泪教训，务必遵守）

- **tscn 中文属性键必须带引号**（见上）。裸中文键加载时被静默丢弃，且编辑器一保存就把这些属性永久删掉。
- **`set_meta()` 的标识符不允许中文/非 ASCII**（报 `Invalid metadata identifier`）。插件内部用 `plugin_created`，你写代码时同理。
- **业务脚本必须加 `@tool`**：节点挂的是你的业务脚本（继承 `更好的按钮`）时，不加 `@tool` 编辑器里不执行任何构建逻辑，纹理不可见、自动节点也不会保存。
- **业务脚本覆盖 `_on_pressed` 等信号方法时必须调 `super.`**，否则插件的音效/点击动画全部失效。插件在 `_ready` 里连信号，业务脚本如需自定义 `_ready` 记得 `super._ready()`。
- **不要手动编辑自动生成的子节点**：改检查器配置即可，节点会被重建。名字可以随便起（`名字` 字段），想复用场景里已有节点就让配置的 `名字` 与之同名。
- **编辑器里阴影/纹理"看起来没变"**：编辑器中按钮永远处于常规状态，悬停/按下纹理与阴影切换只有运行时可见。
- **改完插件脚本后让编辑器重新扫描**（重启或 focus 触发），新 `class_name` 注册前检查器/解析会报 "Could not find type"。CLI 验证可用：
  `godot --headless --path <项目> --editor --quit-after 200`（跑两次直到无新错误）。
- **shadow/视觉验证别信 `snappedf(x, 3)`**：那是按步长 3 取整不是保留 3 位小数，要用 `snappedf(x, 0.001)`。
- pivot：缩放动画以按钮中心为轴（`pivot_offset = size/2`），`resized` 时自动跟随。

## API 速查（节点方法/状态，均带下划线前缀 = 内部）

- `_on_mouse_entered/exited/button_down/button_up/pressed`：信号处理器，状态切换+动画派发
- `_当前配置()`：基础纹理层 + 纹理层列表 合成后的层配置数组
- `_悬停目标倍数()`：悬停态缩放基准（供弹跳/心跳等回落目标）
- `_触发通用动画("悬停时播放"|"按下时播放"|"点击时播放")`：通用动画派发入口
- `_播放缩放动画(目标大小, 时长, 缓动, 过渡)`：状态型缩放
- `_刷新纹理/_刷新层/_刷新阴影/_构建纹理层/_构建文本`：构建与刷新
- 信号连接在 `_ready` 且运行时才连（`Engine.is_editor_hint()` 守卫），编辑器里不会误触发

## 设计约定

- 中文命名：检查器 UI 用"悬停"（hover），代码内部沿用"悬浮"；三态译名 normal=常规 / hover=悬停 / press=按下
- 注释简短中文；引擎内置 API 之外的函数/变量全部中文
- 所有视觉效果都是可选项，默认值保持"拖入常规纹理即可用"
