---
name: algo-page-viz
description: "Generate a single-file interactive HTML page that explains an algorithm contest problem, scoring formula, network topology, or technical scheme from scratch — with SVG diagrams, formula breakdowns, end-to-end scoring walkthroughs, and FAQ. Optionally deploy to public network via existing nginx site injection. Use when the user asks to '做一个网页讲解 / 解释这道题 / 可视化这个算法 / 帮我做个题目讲解页 / visualize this contest problem'."
---

# Algo Page Viz

把一道竞赛题(或一个复杂技术方案)从「看不懂」讲到「会算分」的入门级交互式 HTML。

## 何时触发

- 用户拿到一道算法竞赛题/复杂方案,想要一个网页来理解它(自己看 / 给别人讲 / 做分享)
- 触发短语:「做一个网页解释」「可视化这个算法」「帮我做个题目讲解页」「画图讲一讲」「visualize this problem」
- 典型对象:算法竞赛题面、网络拓扑、嵌套数据结构、评分公式、协议解析、状态机

## 前置:收集素材(必须)

开工前先确认手上有:
1. **题面/方案原文**(PDF/MD/网页) — 没有就要求用户提供
2. **example 输入输出**(至少 1 组,最好带不同分数的多个参考解)
3. **评分公式**(如有)及关键参数上限表
4. **ground-truth 算分实现**(如 `score.py` / 官方判题代码) — **如有,把它当作公式与口径的唯一权威**;若没有,要求用户提供或自己据题面写一份并与 example 反推交叉验证
5. **`expected_output_*.txt` 等参考解文件** — 凡是网页要描述"Output X 用了什么端口分配 / 用了什么策略",**必须 cat 该文件确认**,不要凭印象
6. **用户已踩过的坑**(易错点,通常在 README/note.md 里)
7. **目标读者**(自己看 / 队友看 / 完全门外汉看) — 影响讲解深度

> ⚠️ **硬规则**:网页里所有出现的具体数字(冲突计数、Maxsingle/Maxmulti、各 Step 分数)**必须用 ground-truth 实跑一次校对**。题面 PDF 的公式经 OCR 容易失真,且口径细节(如"按超出量"vs"按命中流"、是否分方向)往往只在实现里能看清楚——单读题面会写错,这是踩过的真实教训。

## 内容架构(默认 14 章)

按这个顺序铺,从故事讲到算法,确保门外汉也能跟下来。每章都要有「具体例子」和「类比」。

| # | 章节 | 内容要点 |
|---|------|----------|
| Hero | 题目大标题 + 一句话总结 | 渐变背景,大字体 |
| 0 | 双列目录 | 锚点跳转,所有章节可点 |
| 1 | **故事** | 为什么有这道题?用日常生活类比(快递柜/电梯/排队) |
| 2 | **拓扑/数据结构** | SVG 画 example 的真实结构,标注所有元素;列规模上限表 |
| 3 | **关键编号公式** | 带交互输入框,实时算结果(如 `card_id ↔ Leaf`) |
| 4 | **输入格式拆解** | 用具体一行讲清"怎么读";列出所有易错读法 |
| 5 | **嵌套概念** | 用 mini 卡片说明 Job/Phase/Flow 等嵌套关系 |
| 6 | **你要做什么** | 一句话 + SVG 画一个完美解 + 输出格式 |
| 7 | **规则/冲突详解** | 每类规则一个小节,带定义、伪代码、类比、实例 |
| 8 | **关键指标** | 如端口比/复杂度/精度等,定义 + 例子 |
| 9 | **评分公式拆解** | 大字公式 + 逐项含义表 + 取值范围 + 满分长什么样 + **实时计算器**(输入 6 个分项实时算总分,默认值=典型 example) |
| 10 | **非线性曲线可视化** | 若评分含反比例/对数等非线性,SVG 画曲线 + 关键点 + **可拖滑块**(拖 x 实时显示 y 和扣分) |
| 11 | **端到端算分演示** | 选一个 example,Step 1-N 走完所有计算,最后用 breakdown 列加减明细;**所有数字必须用 ground-truth 实跑校对** |
| 12 | **多解法对比** | tab 切换不同分数的解,每个解附完整算分公式 |
| 13 | **FAQ** | 10+ 条 details/summary 折叠问答,覆盖容易误解的细节 |
| 14 | **难点小结 + 当前进展** | 4-5 个核心难点 + 当前最佳成绩 + 仍未突破的瓶颈 |

> 简单题或概念性页面可以删 6/10/12,但 1/2/9/11/13 必留——这五章决定能否"讲清楚"。

## 视觉规范

### 强制约束

- **单文件 HTML**:CSS、JS、SVG 全内嵌,**不引任何 CDN**(外网受限环境会卡住)
- **中文 zh-CN**:除代码标识符外,全中文
- **响应式**:mobile-first,`@media (max-width: 720px)` 切单列
- **目录极简**:产出 `/tmp/<topic>.html`,**不入仓库**;若需归档进项目,先确认用户同意

### 配色变量(深色主题)

```css
:root {
  --bg: #0b1020;       /* 页面底色 */
  --bg-2: #121a33;     /* 二级底色 */
  --card: #18223f;     /* 章节卡片 */
  --line: #283354;     /* 边框 */
  --text: #e5ecff;     /* 主文字 */
  --muted: #9ba8c9;    /* 次要文字 */
  --accent: #6ee7ff;   /* 主色:青 */
  --accent-2: #b794f6; /* 辅色:紫 */
  --good: #6ee7a3;     /* 成功/正确 */
  --warn: #f7b955;     /* 警告/中等 */
  --bad: #ff6e8a;      /* 错误/严重 */
}
```

### 必备组件(模板见 `templates/components.html`)

- **`.hero`**:渐变背景 + 大标题(`background-clip: text` 文字渐变)
- **`.toc`**:双列目录,锚点跳转
- **`section h2 .num`**:章节序号圆形 badge
- **`.formula`**:左侧 accent border 公式块,`.formula.big` 居中大字
- **`.ann`/`.ann.good`/`.ann.bad`**:带左 border 的标注块(易错/经验/坑)
- **`.breakdown`**:加减明细行,最后一行 total 高亮
- **`.tabs` + `.tab-panel`**:多解法切换
- **`details/summary`**:FAQ 折叠
- **`.curve-plot`** + 滑块:SVG 曲线图(反比例 40/x 等),底部 `<input type="range">` 控制可移动点 `#curveDot`,JS 监听 input 事件实时更新 `cx/cy` + tip 文本
- **`.calc-row`**:输入框 + 实时输出,纯原生 JS 绑 input 事件
- **`.score-calc`**:评分公式实时计算器(6 输入框 + 实时分项明细 + 总分),第 9 章必备

## 工作流

### Step 1 — 建文件

```bash
# 写到 /tmp/,不入库
TOPIC=<simple-name>           # 比如 nslb_intro
FILE=/tmp/${TOPIC}.html
```

复制 `templates/skeleton.html` 作为骨架,把 14 章逐个填实。每章至少 1 个 SVG 图或具体计算表格——**绝对不要纯文字段落叠加**。

### Step 2 — SVG 拓扑图

用纯 SVG 画(不引 D3/mermaid)。以 NSLB 的 Leaf-Spine 为例:

- Spine/Leaf 用 `<rect rx="8">` 圆角矩形,深色 fill + 强色 stroke
- 算力卡用 `<circle r="20">`,加文字编号
- 链路用 `<line>`,流动效果用 `stroke-dasharray + animation flow`
- 标注 port 编号、连线含义在 `<text>` 里
- viewBox 用 `0 0 720 360` 之类比例,内部坐标随便,外面响应式缩放

### Step 3 — 评分公式逐项拆解

第 9 章的核心是这张表(必有):

| 项 | 取值范围 | 含义 |
|---|---|---|
| 常数项 | = 20 | 无条件基础分 |
| 惩罚项 | ≤ 0 | 哪种冲突扣多少 |
| 加分项 | (0, 40] | 哪种平衡加多少 |

然后**至少给出一个完整算分例子**(第 11 章),用 `.breakdown` 列出每一项加减,最后 total 行高亮。这是用户唯一能"自己验证理解"的地方。

### Step 4 — 非线性曲线(若适用)

评分若含反比例(`40/x`)、对数、二次等,**必画曲线**。在 SVG 里:
- 横轴标关键 x 值(1.0 / 1.5 / 2.0 / 3.0)
- 纵轴标对应 y 值
- 关键点用 circle + text 标注 "(1.5, 26.7) 退 13.3"
- 文字解释"从 1.0 → 1.5 比 1.5 → 2.0 更要命"——边际不均匀的反直觉性是题目难点

### Step 5 — FAQ(必有 ≥10 条)

用 `<details>` 折叠,题目里所有"反直觉、易错、容易问"的点都列上。NSLB 那篇的 12 条覆盖:为什么内部流不占端口 / r 是什么 / 在线协议 / 评分分母是什么 / max(1, x) 截断 / 不同 Leaf 同号端口算不算冲突…

### Step 6 — 本地预览

```bash
cd /tmp && nohup python3 -m http.server 8765 --bind 0.0.0.0 > /tmp/${TOPIC}_server.log 2>&1 &
```

给用户 `http://<本机 IP>:8765/${TOPIC}.html`。如果浏览器无法访问,可改用 `file:///tmp/${TOPIC}.html` 直接打开。

### Step 7 — 静态托管(可选)

生成的 HTML 是单文件静态资源,可托管到任意支持静态文件的服务上(GitHub Pages / Vercel / Netlify / Cloudflare Pages / 自建 web server 等)。仓库里 `scripts/deploy_to_remote.sh` 是一个把 HTML 通过 ssh 上传到远端 web 目录的参考脚本,具体细节按用户自己的环境调整。

### Step 8 — 收尾

- 服务器端口、临时备份、临时脚本随手清(目录极简原则)
- 给用户:本地 URL / 公网 URL / 文件路径 / 章节速览
- 如果做了部署,记一下"如何回滚"(删 `/var/www/${TOPIC}/` + 还原 nginx config)

## 模板文件

- `templates/skeleton.html` — 14 章完整骨架(直接复制改内容)
- `templates/components.html` — 各种 UI 组件单独样例(formula/ann/breakdown/tabs/details/curve-plot)
- `templates/portal.html` — 入口卡片墙(深色主题,沉浸感强)
- `templates/portal_light.html` — 入口卡片墙(浅色主题,与浅色站点风格一致;your-domain.example `/algorithms/` 用此版本)

## Portal 入口页

<your-host-alias> 根路径 `http://<your-server-ip>/` 是统一入口,卡片化展示所有已上线算法,点击进入具体页面。

### 如何把新算法加入 portal

1. 按 §1-§7 流程做出 `<topic>` 的 HTML,部署到 `/var/www/<topic>/`
2. 编辑 `/var/www/portal/index.html`,在 `ALGORITHMS` 数组里追加一项:

```js
{
  id: "<topic>",
  title: "中文标题",
  subtitle: "副标题(比赛名 / 类别)",
  desc: "1-2 句话描述这道题讲什么",
  tags: ["标签1", "标签2", "标签3"],
  href: "/<topic>/",
  status: "已上线",                 // 或 "进行中" / "TODO"
  statusClass: "status-good",       // status-good / status-warn / status-bad / status-mute
  date: "YYYY-MM-DD",
  chapters: 14
}
```

3. 不需 reload nginx,静态文件改完即生效

### Portal 设计要点

- 卡片来源是 `ALGORITHMS` JS 数组,JS 渲染——加新算法只需追加一条数据,不写 HTML
- 顶部 Hero + 三项 stats(已上线 / 主题分类 / ∞)
- chip filter 按 tag 筛选(自动从所有卡片的 tags 聚合)
- < 3 张卡片时自动追加占位卡片("更多算法陆续加入中"),避免页面太空

## 已沉淀的成功案例

- **算法可视化 Portal**(2026-05-10):入口卡片墙,公网 `http://<your-server-ip>/`
- **NSLB 题目讲解页**(2026-05-10):14 章 ~1300 行,含 SVG 拓扑、反比例曲线、78 分完整算分演示、12 条 FAQ。本地 `/tmp/nslb_intro.html`,公网 `http://<your-server-ip>/nslb/`(注入 <your-host-alias> 的 <existing-site> 站)

## 反模式(别做这些)

- ❌ **凭题面 PDF/OCR 推算分公式与口径**:必须读 ground-truth 实现代码;OCR 会把减号丢成加号、把"超出量"和"命中流数"两种口径混淆
- ❌ **凭印象写 Example 多解法的端口/策略分配**:必须 cat `expected_output_*.txt` 确认实际值;NSLB v1 把 Output 1(全堆同一端口)写成了 Output 3(对称分两端口)的样子,直接误导读者
- ❌ 引外部 CDN(tailwind/d3/highlight.js):外网受限环境会 hang
- ❌ 用 React/Vue 之类框架:杀鸡用牛刀,且需 build
- ❌ 写一堆纯文字段落不带图:这是讲解页不是博客
- ❌ 把页面放到项目仓库(违反目录极简原则,除非是项目交付物)
- ❌ 公网部署时新建 server block:大概率被 server_name 冲突 ignore,直接改现有 site
- ❌ 跳过 FAQ:它是用户唯一的"反思入口",不能省
- ❌ 第 9/10 章只放静态公式和静态曲线:实时计算器和滑块是这两章的标配,跳过它们等于浪费交互讲解的最佳位置
