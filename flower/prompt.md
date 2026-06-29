# 任务：构建一个名为 Veldara 的沉浸式滚动落地页

请按本文档的规格，产出一个**单一 HTML 文件**，文件名 `flower.html`。所有 CSS 和 JavaScript 内联在这个文件里，除文档中明确给出的字体 CDN 与视频 CDN 外，不引用任何外部库（不要 Tailwind、不要 GSAP、不要 Three.js、不要 jQuery）。完成后用浏览器直接打开即可运行。

---

## 1. 设计概览

这是一个名为 **Veldara**（虚构产品，定位为 "Svelte 5 + Three.js" 框架）的英雄落地页。整体氛围：深空黑底、一朵盛开的发光花朵作为全屏视频背景，背景上漂浮缓慢游走的白色星点粒子。视觉重心在屏幕下半部分的文案与一对 CTA。

页面的招牌交互是 **滚动驱动的视频帧（scroll-scrubbed video）**：当用户向下滚动，背景视频的播放进度同步推进；向上滚动则倒回，没有真正的"播放"，而是把滚动条当作视频时间轴。

页面纵向分三段：
1. **第一屏（Hero）**：标题 + 代码安装提示 + CTA + 跳动的下箭头。
2. **中段**：一组 3 张介绍卡片以"固定在视口底部 + 横向遮罩擦除"的方式出现又离开。
3. **末段**：一个揭幕式段落 "Presenting / Veldara 8"，进入视口时执行模糊→清晰 + 上移淡入。

色调：以近黑 `#010101` 为底，主点缀色为偏冷的钢蓝 `#2c5c88`（用于强调下划条、代码提示符、CTA 按钮）。文字主色白，辅色灰阶 `#9ca3af` / `#d1d5db` / `#e5e7eb` / `#6b7280`。

---

## 2. 外部资源

只允许引入两类外部资源：

**字体（Google Fonts）**：在 `<head>` 中放置：
```html
<link rel="preconnect" href="https://fonts.googleapis.com" />
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet" />
```

**背景视频（CloudFront 直链）**：
```
https://d8j0ntlcm91z4.cloudfront.net/user_38xzZboKViGWJOttwIXH07lWA1P/hf_20260616_212935_bbf608da-62d1-4f25-9be4-c346e4d09cc8.mp4
```
这是一段大约 5 秒的花朵盛开 + 花瓣飘落短片，分辨率不固定，加载时按本规格在 JS 中处理缩放。

页面 `<title>` 设为 `Veldara`。`<meta charset="UTF-8">`、`<meta name="viewport" content="width=device-width, initial-scale=1.0">` 必须存在。

---

## 3. 全局基础样式

```css
*, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }
html, body { overflow-x: hidden; }
body {
  font-family: "Inter", sans-serif;
  background: #010101;
  color: #fff;
}
```

页面会用到以下 4 个原子定位类（请定义，即使有 DOM 不用，也写出来）：
```css
.fixed    { position: fixed; }
.absolute { position: absolute; }
.relative { position: relative; }
.inset-0  { top: 0; right: 0; bottom: 0; left: 0; }
```

---

## 4. DOM 结构

按从前到后的 z 轴顺序组织 `<body>` 内的元素（视觉上越往后越在上层）：

```html
<body>
  <!-- 1. 滚动驱动的视频背景层（z: -10） -->
  <div id="scroll-video-container">
    <canvas id="video-canvas"></canvas>
    <video id="video-fallback"
           muted playsinline preload="auto" crossorigin="anonymous"
           src="【上文的视频 URL】"></video>
    <div class="overlay"></div>
  </div>

  <!-- 2. 漂浮粒子层（z: 3） -->
  <canvas id="particles-canvas"></canvas>

  <!-- 3. 固定在视口底部的 3 卡片层（z: 4，初始 opacity:0） -->
  <div id="fixed-cards">
    <div class="grid">
      <div class="card">
        <h3>Explore Veldara</h3>
        <p>Veldara merges the elegance of Svelte 5 with the depth of Three.js within easy reach. It's crafted to be robust and adaptable while remaining intuitive and simple to grasp.</p>
      </div>
      <div class="card">
        <h3>Unlock Three.js</h3>
        <p>The web is growing increasingly dimensional. At its heart, Veldara offers a composable declarative API for building performant Three.js experiences on the web.</p>
      </div>
      <div class="card">
        <h3>Connect Everything</h3>
        <p>Veldara ships with tooling for physics, XR, animation, layouting, model loading, and extensive utilities to make building compelling 3D apps for the web effortless.</p>
      </div>
    </div>
  </div>

  <!-- 4. 顶部导航（z: 50） -->
  <nav>
    <div style="display:flex; align-items:center; gap:2rem">
      <span class="logo">veldara</span>
      <div class="nav-links">
        <a href="#">Guides</a>
        <a href="#">Journal</a>
      </div>
    </div>
    <div class="social">
      <a href="#"><svg fill="currentColor" viewBox="0 0 24 24"><path d="【GitHub path，见 §5】"/></svg></a>
      <a href="#"><svg fill="currentColor" viewBox="0 0 24 24"><path d="【Discord path，见 §5】"/></svg></a>
      <a href="#"><svg fill="currentColor" viewBox="0 0 24 24"><path d="【Twitter path，见 §5】"/></svg></a>
    </div>
  </nav>

  <!-- 5. 内容流（z: 2） -->
  <div id="content">

    <!-- Hero -->
    <section id="hero">
      <div class="gradient-overlay"></div>
      <div class="content">
        <p class="subtitle">Our Purpose:</p>
        <h1>
          Instantly craft immersive
          <span class="underlined">
            <span class="line"></span><span>3D worlds</span>
          </span>
          on the web.
        </h1>
        <div class="ctas">
          <div class="code-box">
            <span class="prompt">&gt;</span>
            <code>npm i @veldara/core</code>
          </div>
          <a href="#" class="cta-btn">Get Started <span>&rarr;</span></a>
        </div>
      </div>
      <div class="bounce-arrow">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"
             stroke-width="2" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round"
                d="M19.5 8.25l-7.5 7.5-7.5-7.5"/>
        </svg>
      </div>
    </section>

    <!-- 卡片出现前的纯空白滚动距离 -->
    <div style="height:150vh"></div>

    <!-- 卡片"激活区"：它的位置/高度决定卡片何时进入、何时退出 -->
    <div id="cards-trigger" style="height:200vh"></div>

    <!-- 卡片离开后到末段之间的空白 -->
    <div style="height:100vh"></div>

    <!-- 末段揭幕 -->
    <section id="section-three">
      <div class="inner" id="section-three-inner">
        <p>Presenting</p>
        <h2>Veldara 8</h2>
      </div>
    </section>

  </div>

  <script> /* 见 §7 */ </script>
</body>
```

---

## 5. SVG 图标（必须原样使用以下 path）

**GitHub**（导航右侧第一个图标）：
```
M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z
```

**Discord**（导航右侧第二个图标）：
```
M20.317 4.3698a19.7913 19.7913 0 00-4.8851-1.5152.0741.0741 0 00-.0785.0371c-.211.3753-.4447.8648-.6083 1.2495-1.8447-.2762-3.68-.2762-5.4868 0-.1636-.3933-.4058-.8742-.6177-1.2495a.077.077 0 00-.0785-.037 19.7363 19.7363 0 00-4.8852 1.515.0699.0699 0 00-.0321.0277C.5334 9.0458-.319 13.5799.0992 18.0578a.0824.0824 0 00.0312.0561c2.0528 1.5076 4.0413 2.4228 5.9929 3.0294a.0777.0777 0 00.0842-.0276c.4616-.6304.8731-1.2952 1.226-1.9942a.076.076 0 00-.0416-.1057c-.6528-.2476-1.2743-.5495-1.8722-.8923a.077.077 0 01-.0076-.1277c.1258-.0943.2517-.1923.3718-.2914a.0743.0743 0 01.0776-.0105c3.9278 1.7933 8.18 1.7933 12.0614 0a.0739.0739 0 01.0785.0095c.1202.099.246.1981.3728.2924a.077.077 0 01-.0066.1276 12.2986 12.2986 0 01-1.873.8914.0766.0766 0 00-.0407.1067c.3604.698.7719 1.3628 1.225 1.9932a.076.076 0 00.0842.0286c1.961-.6067 3.9495-1.5219 6.0023-3.0294a.077.077 0 00.0313-.0552c.5004-5.177-.8382-9.6739-3.5485-13.6604a.061.061 0 00-.0312-.0286z
```

**Twitter**（导航右侧第三个图标）：
```
M23.953 4.57a10 10 0 01-2.825.775 4.958 4.958 0 002.163-2.723c-.951.555-2.005.959-3.127 1.184a4.92 4.92 0 00-8.384 4.482C7.69 8.095 4.067 6.13 1.64 3.162a4.822 4.822 0 00-.666 2.475c0 1.71.87 3.213 2.188 4.096a4.904 4.904 0 01-2.228-.616v.06a4.923 4.923 0 003.946 4.827 4.996 4.996 0 01-2.212.085 4.936 4.936 0 004.604 3.417 9.867 9.867 0 01-6.102 2.105c-.39 0-.779-.023-1.17-.067a13.995 13.995 0 007.557 2.209c9.053 0 13.998-7.496 13.998-13.985 0-.21 0-.42-.015-.63A9.935 9.935 0 0024 4.59z
```

**Hero 下方跳动箭头**：使用 `viewBox="0 0 24 24"`、`fill="none"`、`stroke="currentColor"`、`stroke-width="2"`、`stroke-linecap="round"`、`stroke-linejoin="round"`，path：
```
M19.5 8.25l-7.5 7.5-7.5-7.5
```

---

## 6. 全部 CSS

### 6.1 视频背景层
```css
#scroll-video-container {
  position: fixed;
  inset: 0;
  z-index: -10;
  background: #0a0a0a;
  top: -20%;                /* 故意把视频上方拉出视口，构图重心略下移 */
}
#scroll-video-container canvas,
#scroll-video-container video {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
}
#scroll-video-container .overlay {
  position: absolute;
  inset: 0;
  background: rgba(0, 0, 0, 0.2);   /* 全局压暗 20% */
}
```

### 6.2 粒子层
```css
#particles-canvas {
  position: fixed;
  inset: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
  z-index: 3;
}
```

### 6.3 顶部导航
```css
nav {
  position: fixed;
  top: 0; left: 0; right: 0;
  z-index: 50;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 1.25rem 2.5rem;
}
nav .logo {
  font-weight: 700;
  font-size: 1.25rem;
  color: #fff;
  letter-spacing: -0.025em;
}
nav .nav-links {
  display: flex;
  align-items: center;
  gap: 1.5rem;
}
nav .nav-links a {
  font-size: 0.875rem;
  color: #d1d5db;
  text-decoration: none;
  transition: color 0.2s;
}
nav .nav-links a:hover { color: #fff; }
nav .social {
  display: flex;
  align-items: center;
  gap: 1rem;
}
nav .social a {
  color: #d1d5db;
  transition: color 0.2s;
}
nav .social a:hover { color: #fff; }
nav .social svg { width: 1.25rem; height: 1.25rem; }
```

### 6.4 Hero 段落
```css
#hero {
  position: relative;
  height: 100vh;
  width: 100%;
  display: flex;
  flex-direction: column;
}
#hero .gradient-overlay {
  position: absolute;
  inset: 0;
  background: linear-gradient(to top, rgba(0,0,0,0.6), transparent, transparent);
}
#hero .content {
  position: relative;
  z-index: 10;
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: flex-end;        /* 内容贴底 */
  text-align: center;
  padding: 0 1.5rem 6rem;
}
#hero .subtitle {
  font-size: 0.875rem;
  color: #9ca3af;
  margin-bottom: 1rem;
  letter-spacing: 0.05em;
}
#hero h1 {
  font-size: clamp(1.5rem, 5vw, 3.75rem);
  font-weight: 600;
  line-height: 1.15;
  max-width: 48rem;
}
#hero h1 .underlined {
  position: relative;
  display: inline-block;
}
#hero h1 .underlined .line {       /* 蓝色横条压在文字下方 */
  position: absolute;
  bottom: 0.25rem;
  left: 0;
  width: 100%;
  height: 10px;
  background: #2c5c88;
  border-radius: 2px;
}
#hero h1 .underlined span {        /* 让文字盖在条之上 */
  position: relative;
}
#hero .ctas {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-top: 2.5rem;
  flex-wrap: wrap;
  justify-content: center;
}
#hero .code-box {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  background: #1a1a1a;
  border: 1px solid rgba(55, 65, 81, 0.5);
  border-radius: 0.5rem;
  padding: 0.875rem 2rem;
}
#hero .code-box .prompt {
  color: #2c5c88;
  font-family: monospace;
  font-size: 0.875rem;
}
#hero .code-box code {
  font-size: 0.875rem;
  color: #e5e7eb;
  font-family: monospace;
}
#hero .cta-btn {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  background: #2c5c88;
  color: #fff;
  font-weight: 500;
  border-radius: 0.5rem;
  padding: 0.875rem 2rem;
  font-size: 0.875rem;
  text-decoration: none;
  transition: background 0.2s;
}
#hero .cta-btn:hover { background: #3a7aad; }
#hero .bounce-arrow {
  position: relative;
  z-index: 10;
  display: flex;
  justify-content: center;
  padding-bottom: 2rem;
}
#hero .bounce-arrow svg {
  width: 1.5rem;
  height: 1.5rem;
  color: #6b7280;
  animation: bounce 1s infinite;
}
@keyframes bounce {
  0%, 100% { transform: translateY(0); }
  50%      { transform: translateY(-25%); }
}
```

### 6.5 固定卡片层
```css
#fixed-cards {
  position: fixed;
  bottom: 0; left: 0; right: 0;
  z-index: 4;
  padding: 2rem 2.5rem;
  opacity: 0;                       /* 初始隐藏，由 JS 控制 */
  pointer-events: none;
}
#fixed-cards .grid {
  max-width: 72rem;
  margin: 0 auto;
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 2.5rem;
}
#fixed-cards .card h3 {
  font-size: 1.5rem;
  font-weight: 700;
  color: #fff;
  margin-bottom: 1rem;
}
#fixed-cards .card p {
  color: #d1d5db;
  font-size: 0.875rem;
  line-height: 1.6;
}
```

### 6.6 末段揭幕
```css
#section-three {
  position: relative;
  min-height: 100vh;
  display: flex;
  align-items: flex-end;            /* 文案贴底 */
  justify-content: center;
  padding: 0 2.5rem 8rem;
}
#section-three .inner {
  position: relative;
  z-index: 10;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  opacity: 0;
  transform: translateY(32px);
  filter: blur(8px);
  transition:
    opacity   1s ease-out,
    transform 1s ease-out,
    filter    1s ease-out;
}
#section-three .inner.visible {
  opacity: 1;
  transform: translateY(0);
  filter: blur(0);
}
#section-three .inner p {
  color: #d1d5db;
  font-size: 1rem;
  margin-bottom: 0.75rem;
}
#section-three .inner h2 {
  font-size: clamp(1.875rem, 6vw, 4.5rem);
  font-weight: 700;
}
```

### 6.7 内容容器
```css
#content { position: relative; z-index: 2; }
```

### 6.8 响应式（断点 768px）
```css
@media (max-width: 768px) {
  nav { padding: 1rem 1.5rem; }
  nav .nav-links { display: none; }
  #hero .content { padding-bottom: 5rem; }
  #hero h1 { font-size: 1.5rem; }
  #hero .ctas { flex-direction: column; }
  #fixed-cards .grid { grid-template-columns: 1fr; gap: 1.5rem; }
  #fixed-cards { padding: 1.5rem 1rem; }
  #section-three { padding-bottom: 5rem; }
}
```

---

## 7. JavaScript 行为

整个脚本用 IIFE 包裹：`(function () { /* ... */ })();`。内部分五个相对独立的模块。

### 7.1 模块 A：滚动驱动的视频帧（核心特效）

**意图**：把视频时间轴绑定到滚动进度。理想路径是预先抽取所有关键帧到 `ImageBitmap` 数组，rAF 循环里按滚动 progress 取索引画到 canvas；如果跨域抽帧失败，则回退为直接修改 `<video>` 的 `currentTime`（虽然在某些浏览器上 seek 较慢）。

**步骤**：

```js
const VIDEO_URL = "【§2 的视频 URL】";
const canvas   = document.getElementById("video-canvas");
const videoEl  = document.getElementById("video-fallback");
const ctx      = canvas.getContext("2d");

let frames = [];
let framesReady = false;
let lastFrameIndex = -1;
let videoSeeking  = false;

function resizeCanvas() {
  const dpr = Math.min(devicePixelRatio, 2);
  const rect = canvas.getBoundingClientRect();
  const w = Math.round(rect.width  * dpr);
  const h = Math.round(rect.height * dpr);
  if (canvas.width !== w || canvas.height !== h) {
    canvas.width  = w;
    canvas.height = h;
  }
  lastFrameIndex = -1;  // 强制下一帧重绘
}

async function extractFrames() {
  try {
    const response  = await fetch(VIDEO_URL, { mode: "cors" });
    const blob      = await response.blob();
    const objectUrl = URL.createObjectURL(blob);

    const video = document.createElement("video");
    video.muted = true;
    video.playsInline = true;
    video.crossOrigin = "anonymous";
    video.preload = "auto";
    video.src = objectUrl;

    await new Promise((resolve, reject) => {
      video.onloadedmetadata = () => resolve();
      video.onerror = () => reject();
      setTimeout(() => reject(), 15000);
    });

    const scale       = Math.min(1, 1280 / video.videoWidth);
    const scaledWidth  = Math.round(video.videoWidth  * scale);
    const scaledHeight = Math.round(video.videoHeight * scale);

    // 帧数：按 24fps 折算，钳制到 [30, 120]
    const frameCount = Math.max(30, Math.min(120, Math.round(video.duration * 24)));

    for (let i = 0; i < frameCount; i++) {
      const time = (i / (frameCount - 1)) * (video.duration - 0.05);
      video.currentTime = time;
      await new Promise((resolve, reject) => {
        const onSeeked = () => {
          video.removeEventListener("seeked", onSeeked);
          resolve();
        };
        video.addEventListener("seeked", onSeeked);
        setTimeout(() => {
          video.removeEventListener("seeked", onSeeked);
          reject();
        }, 3000);
      });
      const bitmap = await createImageBitmap(video, {
        resizeWidth: scaledWidth,
        resizeHeight: scaledHeight,
      });
      frames.push(bitmap);
    }

    if (frames.length > 0) {
      framesReady = true;
      canvas.style.visibility = "visible";
      videoEl.style.display = "none";
    }
    URL.revokeObjectURL(objectUrl);
  } catch (e) {
    /* 静默：失败则走 videoEl seek 回退路径 */
  }
}

function getScrollBounds() {
  const vh = window.innerHeight;
  return {
    start: vh * 0.5,
    end:   document.documentElement.scrollHeight - vh,
  };
}

function getProgress() {
  const { start, end } = getScrollBounds();
  const range = end - start;
  if (range <= 0) return 0;
  return Math.max(0, Math.min(1, (window.scrollY - start) / range));
}

function drawFrame(frame) {
  const cw = canvas.width, ch = canvas.height;
  const s  = Math.max(cw / frame.width, ch / frame.height);   // cover 适配
  const dw = frame.width  * s;
  const dh = frame.height * s;
  ctx.drawImage(frame, (cw - dw) / 2, (ch - dh) / 2, dw, dh);
}

function videoTick() {
  const progress = getProgress();

  if (framesReady && frames.length > 0) {
    const idx = Math.round(progress * (frames.length - 1));
    if (idx !== lastFrameIndex) {
      lastFrameIndex = idx;
      if (frames[idx]) drawFrame(frames[idx]);
    }
  } else if (videoEl.duration && isFinite(videoEl.duration) && videoEl.readyState >= 1) {
    const target = progress * videoEl.duration;
    if (!videoSeeking && Math.abs(videoEl.currentTime - target) > 0.001) {
      videoSeeking = true;
      videoEl.currentTime = target;
    }
  }
  requestAnimationFrame(videoTick);
}

videoEl.addEventListener("seeked",     () => { videoSeeking = false; });
videoEl.addEventListener("stalled",    () => { videoSeeking = false; });
videoEl.addEventListener("loadeddata", () => { videoEl.currentTime = 0; });

canvas.style.visibility = "hidden";   // 抽帧成功才显示，避免空白闪烁

resizeCanvas();
window.addEventListener("resize", resizeCanvas);
requestAnimationFrame(videoTick);
extractFrames();
```

### 7.2 模块 B：漂浮粒子

```js
const pCanvas = document.getElementById("particles-canvas");
const pCtx    = pCanvas.getContext("2d");
let particles = [];

function resizeParticles() {
  pCanvas.width  = window.innerWidth;
  pCanvas.height = window.innerHeight;
  createParticles();
}

function createParticles() {
  particles = [];
  const count = Math.floor((pCanvas.width * pCanvas.height) / 12000);
  for (let i = 0; i < count; i++) {
    particles.push({
      x: Math.random() * pCanvas.width,
      y: Math.random() * pCanvas.height,
      vx: (Math.random() - 0.5) * 0.3,
      vy: (Math.random() - 0.5) * 0.3,
      size: Math.random() * 1.5 + 0.5,
      opacity: Math.random() * 0.6 + 0.2,
    });
  }
}

function animateParticles() {
  pCtx.clearRect(0, 0, pCanvas.width, pCanvas.height);
  for (const p of particles) {
    p.x += p.vx;
    p.y += p.vy;
    // 边界环绕
    if (p.x < 0) p.x = pCanvas.width;
    if (p.x > pCanvas.width) p.x = 0;
    if (p.y < 0) p.y = pCanvas.height;
    if (p.y > pCanvas.height) p.y = 0;
    pCtx.beginPath();
    pCtx.arc(p.x, p.y, p.size, 0, Math.PI * 2);
    pCtx.fillStyle = `rgba(255,255,255,${p.opacity})`;
    pCtx.fill();
  }
  requestAnimationFrame(animateParticles);
}

resizeParticles();
window.addEventListener("resize", resizeParticles);
animateParticles();
```

### 7.3 模块 C：Hero 渐隐

```js
function updateHeroOpacity() {
  const fade = Math.max(0, 1 - window.scrollY / (window.innerHeight * 0.3));
  document.getElementById("hero").style.opacity = fade;
}
window.addEventListener("scroll", updateHeroOpacity, { passive: true });
```
含义：向下滚动 30% 视口高度时，Hero 透明度从 1 线性降到 0。

### 7.4 模块 D：固定卡片层（mask 揭示）

`#cards-trigger` 高度 200vh，它作为"激活区间"参考体。卡片层的出现/消失透明度根据视口位置计算；卡片内的 `.grid` 用 `mask-image` 实现"从左到右擦除"的逐张显现（移动端改为从上到下）。

```js
const fixedCards = document.getElementById("fixed-cards");
const cardsGrid  = fixedCards.querySelector(".grid");

function tickCards() {
  const trigger       = document.getElementById("cards-trigger");
  const rect          = trigger.getBoundingClientRect();
  const triggerTop    = rect.top + window.scrollY;
  const triggerHeight = rect.height;
  const scrollY       = window.scrollY;
  const vh            = window.innerHeight;

  const start = triggerTop - vh * 0.5;
  const end   = triggerTop + triggerHeight - vh * 0.3;
  const range = end - start;

  let progress = range > 0 ? (scrollY - start) / range : 0;
  progress = Math.max(0, Math.min(1, progress));

  const isActive = scrollY >= start - vh * 0.2 && scrollY <= end + vh * 0.3;
  const fadeIn   = Math.min(1, Math.max(0, (scrollY - (start - vh * 0.2)) / (vh * 0.2)));
  const fadeOut  = Math.min(1, Math.max(0, (end + vh * 0.3 - scrollY) / (vh * 0.3)));
  const containerOpacity = isActive ? Math.min(fadeIn, fadeOut) : 0;

  fixedCards.style.opacity       = containerOpacity;
  fixedCards.style.pointerEvents = containerOpacity > 0.1 ? "auto" : "none";

  const isMobile  = window.innerWidth < 768;
  const revealPct = progress * 130;

  if (isMobile) {
    cardsGrid.style.maskImage =
      `linear-gradient(to bottom, black ${revealPct}%, transparent ${revealPct + 20}%)`;
    cardsGrid.style.webkitMaskImage =
      `linear-gradient(to bottom, black ${revealPct}%, transparent ${revealPct + 20}%)`;
  } else {
    cardsGrid.style.maskImage =
      `linear-gradient(to right, black ${revealPct}%, transparent ${revealPct + 15}%)`;
    cardsGrid.style.webkitMaskImage =
      `linear-gradient(to right, black ${revealPct}%, transparent ${revealPct + 15}%)`;
  }

  requestAnimationFrame(tickCards);
}
requestAnimationFrame(tickCards);
```

### 7.5 模块 E：末段揭幕 IntersectionObserver

```js
const sectionThreeInner = document.getElementById("section-three-inner");
const observer = new IntersectionObserver(([entry]) => {
  if (entry.isIntersecting) {
    sectionThreeInner.classList.add("visible");
    observer.unobserve(sectionThreeInner);
  }
}, { threshold: 0.15 });
observer.observe(sectionThreeInner);
```

进入视口达 15% 时触发 `.visible`，CSS transition 接管 1s 的模糊→清晰 + 上移淡入。

---

## 8. 色板速查表

| 用途 | 颜色 |
|------|------|
| 页面底色 | `#010101` |
| 视频容器底色 | `#0a0a0a` |
| 强调蓝（下划条 / 代码提示符 / CTA 背景） | `#2c5c88` |
| CTA hover | `#3a7aad` |
| 代码框背景 | `#1a1a1a` |
| 代码框边框 | `rgba(55,65,81,0.5)` |
| 代码框内文字 | `#e5e7eb` |
| 副标题文字 | `#9ca3af` |
| 卡片正文 / 导航链接 / 末段副标题 | `#d1d5db` |
| 跳动箭头 | `#6b7280` |
| Hero 渐变叠层 | `linear-gradient(to top, rgba(0,0,0,0.6), transparent, transparent)` |
| 视频压暗叠层 | `rgba(0,0,0,0.2)` |
| 粒子 | `rgba(255,255,255, x)`，x 在 0.2~0.8 间随机 |

---

## 9. 层级（z-index）速查表

| 层 | z-index |
|----|---------|
| `#scroll-video-container` | -10 |
| `#content` | 2 |
| `#particles-canvas` | 3 |
| `#fixed-cards` | 4 |
| `nav` | 50 |
| `#hero .content` / `.bounce-arrow` / `#section-three .inner` | 10（在各自定位上下文里） |

---

## 10. 滚动时间轴一览

页面总滚动高度 ≈ Hero 100vh + 150vh + cards-trigger 200vh + 100vh + section-three ≥100vh ≈ 650vh+。

- `scrollY: 0 → 0.3 × vh`：Hero 透明度 1 → 0。
- `scrollY: 0.5 × vh → 文档底`：视频帧 progress 0 → 1。
- 滚动进入 cards-trigger 上沿前 0.2vh 时卡片层开始淡入，离开下沿后 0.3vh 时完全消失；其间内部 `.grid` 的 mask 从 0% 推到 130%。
- 末段 `.inner` 进入视口 15% 时触发 `.visible`，1s 内完成 blur(8px)→0、translateY(32px)→0、opacity 0→1。

---

## 11. 验收清单

完成后请逐项自检：

- [ ] 单文件 HTML，可直接双击在 Chrome/Safari 中打开运行。
- [ ] 顶部固定导航：左侧品牌 `veldara` + `Guides` / `Journal` 两个文字链接（< 768px 隐藏文字链接）；右侧 GitHub / Discord / Twitter 三个 SVG 图标。
- [ ] Hero 文案完全一致：副标题 `Our Purpose:`、H1 `Instantly craft immersive 3D worlds on the web.`、代码框 `> npm i @veldara/core`、CTA `Get Started →`。
- [ ] "3D worlds" 下方有蓝色横条压在文字下方（条用 `position:absolute`，文字 `position:relative` 后渲染）。
- [ ] 代码框前缀 `>` 为蓝色等宽字体；CTA 蓝底白字，hover 变浅蓝。
- [ ] 底部 chevron 以 1s 循环上下跳动。
- [ ] 背景视频从指定 URL 加载；首屏被 `rgba(0,0,0,0.2)` 压暗；滚动时帧随之推进。
- [ ] 全屏漂浮白色粒子，数量按窗口面积自适应，边界环绕。
- [ ] 向下滚动 30% 视口高度时 Hero 完全淡出。
- [ ] 进入 `cards-trigger` 区间时固定卡片层从底部出现，`.grid` 通过 `mask-image` 从左到右（移动端从上到下）渐进显现，三张卡片标题与正文完全一致。
- [ ] 末段 `Presenting / Veldara 8` 在进入视口时执行模糊→清晰 + 上移淡入。
- [ ] 浏览器控制台无 JS 报错（视频跨域抽帧失败应静默回退到 `currentTime` seek 模式，不抛错）。
- [ ] < 768px 下：导航文字链接隐藏；CTA 纵向排列；卡片单列；末段下内边距收窄。

---

## 12. 实现纪律（请严格遵守）

- **不引入**任何第三方 JS/CSS 库或框架，全部用原生 DOM + Canvas 2D + 内联样式。
- **不要**给 `<canvas id="video-canvas">` 初始 `visibility:visible`——必须等抽帧成功后再显示，避免空白闪烁。
- **不要**用 `scroll` 事件直接驱动视频帧绘制——必须用 `requestAnimationFrame` 循环读取 `scrollY`，否则慢机上会丢帧。
- **不要**修改视频 URL；CORS 失败属于预期，回退路径会处理。
- §5 的四个 SVG path 字符串必须**逐字符照搬**，不要自行重画或简化。
- 整个脚本用一个 IIFE 包裹，避免全局变量泄漏。
- 文字内容必须与本文档完全一致，**不要**改成"Lorem ipsum"或其它占位文案。

按以上规范产出，即视为合格。
