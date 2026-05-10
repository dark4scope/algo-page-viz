# algo-page-viz

面向 AI 编程助手生态的 Skill 插件。

> 一个 AI coding agent [Skill](https://docs.claude.com/en/docs/claude-code/skills)，用于把一道竞赛题或一个复杂技术方案，从「看不懂」讲到「会算分」的入门级交互式 HTML。

## 它能做什么

输入：题面 PDF / 评分公式 / 参考解 / 已知踩过的坑
输出：一个**单文件 HTML**（无 CDN、无构建步骤），包含：

- Hero + 双列目录 + 14 章默认骨架
- SVG 拓扑图（不依赖 D3 / mermaid）
- 评分公式拖拽计算器（实时算分）
- 非线性曲线可视化（带滑块）
- 端到端算分演示（每一步加减明细）
- 多解法 tab 切换 + FAQ 折叠 + 难点总结

不依赖任何前端框架。文件大小通常 70–200 KB，可离线打开，可一键托管到任何静态服务器。

## 真实案例

用此 skill 已生产两个讲解页：

| 主题 | 章节数 | 说明 |
|------|------:|------|
| 网络拓扑均衡分担（NSLB） | 14 | Leaf-Spine + 反比例评分曲线 + 78 分完整算分演示 |
| 气象降水预报（YHMFC） | 12 | 100 站 SVG 地图 + YPSI 8 项权重计算器 + 6 步算法链路 + QM 映射曲线 |

`examples/yhmfc_2026.html` 是 YHMFC 案例的成品 HTML，可直接浏览器打开预览效果。

## 安装

把这个仓库克隆到 `~/.claude/skills/`：

```bash
mkdir -p ~/.claude/skills
cd ~/.claude/skills
git clone https://gitee.com/niji123/algo-page-viz.git
```

下次启动 AI coding agent 时，skill 会被自动加载。在对话里说「做一个网页讲解」「可视化这个算法」「visualize this problem」之类，agent 会触发它。

## 用法

最简单的工作流：

1. 把题面 PDF / `score.py` / 参考解文件准备在工作目录
2. 在 AI coding agent 中说：「用 algo-page-viz 给这道题做一个讲解页」
3. Skill 会按 `SKILL.md` 里的 14 章默认结构生成单文件 HTML 到 `/tmp/<topic>.html`
4. 浏览器直接打开，或用 `python3 -m http.server` 起一个临时服务

完整流程见 [`SKILL.md`](./SKILL.md)。

## 仓库结构

```
.
├── SKILL.md                          # Skill 主文件（描述 + 触发条件 + 工作流）
├── templates/
│   ├── skeleton.html                 # 14 章完整骨架（直接复制改内容）
│   ├── components.html               # UI 组件单独样例（formula/ann/breakdown/tabs/curve-plot）
│   ├── portal.html                   # 入口卡片墙（深色主题）
│   └── portal_light.html             # 入口卡片墙（浅色主题）
├── scripts/
│   └── deploy_to_remote.sh           # 一键部署到远端 nginx 的参考脚本
├── examples/
│   └── yhmfc_2026.html               # 真实成品 — 雅安降水预报讲解页 (76 KB)
├── README.md
└── LICENSE
```

## 设计原则

- **单文件 HTML**：CSS / JS / SVG 全内嵌，可离线打开
- **零依赖**：不引外部 CDN、不用 React / Vue / D3 / chart.js
- **中文默认**：除代码标识符外全中文
- **响应式**：mobile-first，`@media (max-width: 720px)` 自动切单列
- **不入项目仓库**：产出文件默认写到 `/tmp/`，避免污染工作目录

## 部署到自己的服务器

`scripts/deploy_to_remote.sh` 是一个把 `/tmp/<topic>.html` 部署到远端 nginx 的参考脚本。需要用户自行：

1. 替换 `<your-host-alias>`（已配置 ssh 的 host 名，如 `~/.ssh/config` 里的某个 Host）
2. 替换 `<your-server-ip>`（公网 IP）
3. 替换 `<your-sudo-password>`（远端 sudo 密码）或改用免密 sudo
4. 替换 `<existing-site>`（要注入的 nginx 现有 site 名）

详见 `SKILL.md` 的 §Step 7 部署模板。

## 反模式

`SKILL.md` 末尾沉淀了一些**踩过的坑**，简要列几条：

- ❌ 凭题面 PDF / OCR 推算分公式 — 必须读 ground-truth 实现代码
- ❌ 凭印象写 Example 多解法 — 必须 `cat` 参考解文件确认实际值
- ❌ 引外部 CDN（tailwind / d3 / highlight.js）— 代理拦截会 hang
- ❌ 用 React / Vue — 杀鸡用牛刀且需 build
- ❌ 跳过 FAQ — 它是用户唯一的"反思入口"，不能省

## 许可

MIT License — 详见 [LICENSE](./LICENSE)。

## 致谢

灵感来自实际打多场算法竞赛后的痛点：题面看一遍记不住，Examples 算分手动复现一遍才能理解评分语义。这个 skill 把这个"算分演练"做成了网页，方便讲给队友听 / 给自己复盘。
