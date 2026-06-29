# Bloom HTML 复刻提示词

请你生成一个完整、可直接运行的单文件 HTML 页面，文件名可以叫 `bloom.html`。不要使用构建工具，不要依赖 React/Vue/Svelte，也不要拆分 CSS/JS 文件；所有 HTML、CSS、JavaScript 都写在同一个文件里。页面主题是一个高端、未来感、赛博植物学品牌网站，品牌名为 `Bloom`，整体视觉是黑色背景、粉色花朵、生物机械质感、玻璃拟态卡片、紫色点缀。

页面必须还原以下效果：

1. 整个页面是一个 `500vh` 高度的滚动叙事页面，真实滚动容器很长，但视觉内容固定在全屏 viewport 中。使用一个 `position: fixed; inset: 0; overflow: hidden;` 的主舞台承载全部视觉。
2. 背景是滚动驱动的视频画面，不要直接让 video 元素作为可见背景。请放置 3 个隐藏的 MP4 视频和一个全屏 canvas，通过 JavaScript 把视频帧绘制到 canvas 上。
3. 为了滚动时不闪烁，必须采用“预抽帧缓存”的方式：页面加载时分别 fetch 3 个 MP4，转成 Blob URL，再用隐藏 video 按时间抽帧，使用 `createImageBitmap` 缓存帧。滚动时只根据进度选择缓存帧并画到 canvas，不要在滚动过程中持续实时 seek 原始 video。
4. 每段视频抽帧参数：目标帧率约 `18fps`，单段最多 `144` 帧，缓存帧最大宽度约 `840px`，保持视频比例。canvas 绘制使用 cover 裁切逻辑，始终铺满屏幕。
5. 页面加载时显示黑色 loading 层，中间有白色圆形 spinner 和 `Loading experience` 文案。至少等首段缓存帧可用并且其余视频缓存完成或 fallback 判定后再隐藏 loading。视频加载错误时显示黑色错误层，标题 `Video Load Error`，说明 `Unable to load video resources. Please check your connection and try reloading.`
6. 使用这 3 个视频地址：
   - `https://res.cloudinary.com/dsdhxhhqh/video/upload/v1781506095/202606101700_hglz7q.mp4`
   - `https://res.cloudinary.com/dsdhxhhqh/video/upload/v1781506108/202606101702_sd50y0.mp4`
   - `https://res.cloudinary.com/dsdhxhhqh/video/upload/v1781506130/202606101703_jmidj2.mp4`
7. 顶部左侧只保留品牌标识：一个白色花形/有机图标 SVG 加文字 `Bloom`。不要做顶部导航按钮，不要做 `Atelier / Collections / Rituals / About / Contact` 这些按钮，也不要做移动端汉堡菜单。
8. 首屏左下角有一张玻璃拟态主卡片。卡片样式：半透明白色背景 `rgba(255,255,255,0.16)`，`backdrop-filter: blur(80px)`，白色细边框，方角，较大的阴影。卡片标题使用 `Instrument Serif` 字体，字号桌面约 `72px`，移动端约 `38px`。标题文案：
   `Merging Silicon With Organic Life.`
   其中 `Silicon` 和 `Life.` 用 italic。
9. 主卡片副标题使用 Manrope 字体，文案：
   `Developing Next-Generation Cyber-Botanical Systems Designed To Heal Ecosystems And Advance Human Tech.`
10. 主卡片右下侧有一个紫色圆形 CTA 按钮，颜色 `#cb8dff`，里面是白色向右箭头 SVG。hover 时轻微放大并变成 `#d9a8ff`。点击该按钮时平滑滚动到 feature cards 完整展开的位置，约为最大滚动距离的 `32%`。
11. 滚动到前 1/3 区间时，主卡片、品牌标识逐渐淡出、平移并 blur。使用 `requestAnimationFrame` 中的平滑进度，`currentProgress += (targetProgress - currentProgress) * 0.08`。
12. 滚动到约 `p=0.15` 到 `p=0.45` 时出现 3 张 feature cards。三张卡片水平居中排列，桌面端每张约 `280px x 440px`，间距 `16px`，卡片也是半透明玻璃背景、白色细边框、方角、`backdrop-filter: blur(80px)`。移动端改为单列，最大高度可滚动。
13. 三张 feature cards 的内容必须是：
   - `Neural Synthesis`
     描述：`Hybrid bio-computing linking mycelium networks with logical silicon cores.`
     图标：紫色圆环线性 SVG。
   - `Ecosystem Remediation`
     描述：`Self-replicating biomechanical flora actively restoring and cleansing heavily toxic soil bases.`
     图标：紫色星芒线性 SVG。
   - `Kinetic Transduction`
     描述：`Converting natural photosynthesis cycles into electrical energy for local grids.`
     图标：紫色闪电线性 SVG。
14. feature cards 的进入动画要根据滚动进度计算 opacity、translate3d 和 blur：从下方/左右轻微进入，完全展开时三张卡片都接近 opacity 1；离开该段时再淡出并 blur。
15. 中后段要有 3 段居中的 mission text，每段全屏居中、超大 serif 字体、白色文字，中间用紫色胶囊标签突出关键词。文案：
   - `To gracefully cultivate a newly balanced ecosystem we dissolve all boundaries between technology and nature.`
   - `By rewriting the biological code of our planet we employ specialized photosynthesis to heal broken landscapes.`
   - `We believe that growing through botanical symbiosis is the ultimate pathway to power the future of humanity.`
   其中 `ecosystem`、`planet`、`symbiosis` 分别放进紫色圆角 pill。
16. 最后接近底部时出现订阅反馈表单卡片。卡片居中，黑色半透明背景，`backdrop-filter: blur(48px)`，白色细边框。包含白色 Bloom 图标、标题 `Cultivate alignment`、副文案 `Subscribe to biological updates & cybernetic releases.`、email 输入框 placeholder `name@ecosystem.com`、紫色按钮 `CONNECT`。提交后阻止默认行为，把按钮文本改成 `SUBMITTED`，按钮变绿色，并显示成功文案 `Welcome to the digital flora. Check your inbox soon.`
17. 字体需要从 Google Fonts 加载：
   - `Instrument Serif`
   - `Manrope`
   - `Space Grotesk`
   - `JetBrains Mono`
   body 默认使用 `Space Grotesk`。
18. 页面配色：背景黑色，文字白色，弱文字 `rgba(255,255,255,0.64)`，紫色主色 `#cb8dff`，hover 紫色 `#d9a8ff`，成功绿色 `#059669`。滚动条窄、黑色轨道、深灰色 thumb。
19. 所有主要动画和交互都写原生 JavaScript。使用 passive scroll listener 只更新 `targetProgress`；所有视觉更新统一放进 `requestAnimationFrame` 循环里。不要使用 GSAP 或第三方动画库。
20. 页面必须响应式：移动端主卡片宽度 `calc(100vw - 48px)`，feature cards 变成单列，标题缩小，按钮尺寸缩小。确保文字不溢出，控件不重叠。

请直接输出完整 HTML 代码，不要输出解释。最终效果应该是：首屏是赛博花朵人物背景和左下玻璃标题卡；点击紫色圆形箭头会滚动到三张玻璃功能卡完整展开的位置；继续滚动出现三段使命宣言；最后出现订阅表单。滚动背景必须平滑、无闪烁，核心原因是使用预抽帧缓存而不是实时滚动 seek 视频。
