PROMPT:

Build a production-ready, cinematic premium basketball e-commerce hero/app named "Slam Dunk Store". The result should feel like a high-end sports product launch page, not a normal shop grid: one immersive full-screen product experience, a live 3D basketball in the center, scroll-driven technical storytelling, add-to-cart flight animation, a customizer modal, cart drawer, custom cursor, and subtle procedural audio feedback.

Use React + TypeScript + Vite. Use Tailwind CSS for styling. Use Three.js through @react-three/fiber and @react-three/drei for the 3D scene. Use GSAP for motion timing and transitions. Do not use external product images or model files; generate the basketball procedurally with Three.js sphere geometry and canvas-generated textures.

VISUAL DIRECTION:

Create a dark luxury sports-commerce interface with aggressive basketball energy. The overall mood is black, orange, metal, glass, spotlight, court-floor perspective grid, and big editorial typography. The first product state uses a vivid orange background behind a black rounded app frame. Inside the app frame everything is almost black with radial center light, reflective stage lighting, giant translucent typography, and one hero basketball floating in front.

Core palette:

- brand orange: #FF5500
- brand dark: #050505
- brand gray: #1F1F1F
- white: #ffffff
- muted text: gray-400 / gray-500
- active product accent color controls price, CTA, glow, second spotlight, badges, and some SVG diagnostics.

Fonts:

- Display font: Anton, sans-serif
- Body font: Inter, sans-serif
- Import both from Google Fonts: Anton and Inter weights 300, 400, 600.

Tailwind/theme requirements:

- Extend colors brand.orange #FF5500, brand.dark #050505, brand.gray #1F1F1F.
- Extend fontFamily.sans = Inter, fontFamily.display = Anton.
- Add boxShadow.glow = 0 0 20px rgba(255, 85, 0, 0.5).
- Hide scrollbars globally.
- Body/html: margin 0, padding 0, overflow hidden, height 100%, background #FF5500.
- Add .text-outline with -webkit-text-stroke: 1px rgba(255,255,255,0.1), color transparent.

APP ROOT AND FRAME:

The root viewport is a full-screen app:

- relative w-full h-screen flex items-center justify-center overflow-hidden select-none
- desktop padding md:p-8, mobile no padding
- background color changes by selected product with a 1.2s cubic-bezier transition.

Inside it place a main container:

- relative w-full h-full md:max-w-[1600px] md:max-h-[900px]
- bg-brand-dark
- md:rounded-[2.5rem]
- shadow-2xl
- flex flex-col
- border-0 md:border border-white/5
- overflow-hidden

Inside the frame add two background overlays:

1. A full inset radial-gradient from gray-800/30 through black to black, opacity 80%, z-0.
2. A bottom half perspective court/grid overlay: absolute bottom-0 left-0 right-0 h-1/2 opacity 20%, repeating-linear-gradient vertical lines every 50px, transform perspective(500px) rotateX(60deg) scale(2), transform-origin bottom center, mask-image linear-gradient(to top, black, transparent).

DATA MODEL:

Create Product type:

- id: number
- namePart1: string
- namePart2: string
- price: number
- primaryColor: string
- lineColor: string
- accentColor: string
- texturePattern: 'classic' | 'cross' | 'street' | 'tech'

Initial products exactly:

1. id 1, namePart1 "SPA", namePart2 "ING", price 34.99, primaryColor #C25E00, lineColor #1a1a1a, accentColor #FF5500, texturePattern classic
2. id 2, namePart1 "VER", namePart2 "TEX", price 49.99, primaryColor #004d25, lineColor #aaffaa, accentColor #00ff41, texturePattern street
3. id 3, namePart1 "NEB", namePart2 "ULA", price 59.99, primaryColor #0077b6, lineColor #FFFFFF, accentColor #00C2FF, texturePattern tech
4. id 4, namePart1 "INF", namePart2 "ERNO", price 64.99, primaryColor #6a040f, lineColor #ffba08, accentColor #d00000, texturePattern street
5. id 5, namePart1 "STE", namePart2 "ALTH", price 79.99, primaryColor #ff0080, lineColor #111111, accentColor #ff0080, texturePattern cross

Background color per product:

- id 1 -> #FF5500
- id 2 -> #004d25
- id 3 -> #003f5c
- id 4 -> #6a040f
- id 5 -> #9d174d
- custom product -> primaryColor

GLOBAL STATE:

Maintain products, currentIndex, cartItems, cartTriggerTime, isConfiguratorOpen, isCartOpen. The current product controls 3D material, UI accent, app background, price, and hero title. Next/previous buttons cycle through products with wraparound. Add to cart triggers a flight animation immediately, then after 800ms pushes the current product into cartItems and plays a success chord. Customize opens the configurator modal. Cart icon opens the cart sidebar.

CUSTOM CURSOR:

Hide the default cursor globally for body, links and buttons. Create two fixed pointer-events-none elements:

- inner dot: w-2 h-2 bg-white rounded-full z-[9999], mix-blend-difference, centered on mouse with near-instant GSAP quickTo duration 0.001
- outer ring: w-8 h-8 border border-white rounded-full z-[9998], mix-blend-difference, follows mouse with GSAP quickTo duration 0.2 ease power3
  When hovering button, anchor, or any .interactive element: outer ring scales to 3, opacity 0.15, backgroundColor #FF5500, inner dot scales to 0.5 and becomes transparent. Otherwise outer ring scale 1 opacity 0.5 background white, inner dot white.

NAVIGATION:

Absolute top nav, z-50, full width, px-6 md:px-10 py-6 md:py-8, flex justify-between, pointer-events-none on mobile but child controls pointer-events-auto.

Left logo:

- white circular 32px badge with simple black basketball SVG: circle, half arc, horizontal line.
- stacked text SLAM / DUNK in Anton, white, text-lg, tracking-wider, second line -mt-1.

Center desktop links hidden below md, gap-12:

- Products active in brand orange
- Customize opens configurator
- Contacts static
  Links are text-sm font-medium tracking-wide, gray-300 hover white, active brand-orange, transition colors, .interactive.

Right icons:

- user outline icon button, hover brand orange
- cart bag outline icon button with id cart-target; when cart count > 0 show a min-w 18px h 18px orange badge at top-right with count. Badge scales to 125% for 300ms after cart count changes.

SCROLLING HERO UI STRUCTURE:

Create an absolute UI scroll container over the full app frame:

- absolute inset-0 z-30 w-full h-full overflow-y-auto overflow-x-hidden scroll-smooth no-scrollbar snap-y snap-mandatory
  The Three.js canvas is another absolute layer behind/through this UI at z-40 pointer-events-none, but Canvas eventSource should be the app root so the basketball can still be dragged.

The UI contains six full-screen snap sections, each w-full h-full min-h-full snap-start.

SECTION 1: HERO

Layout:

- relative w-full h-full flex flex-col md:block
- Navigation at top.
- BackgroundTitle fills absolute inset-0 z-0 pointer-events-none.
- Content layer relative w-full h-full pointer-events-none flex flex-col justify-end z-10.
- On mobile reserve a top spacer h-[20vh] so the ball has room.

BackgroundTitle:

- Huge text behind the ball, using current product namePart1 and namePart2 as two separate animated word chunks.
- Container absolute inset-0 flex row items-start justify-center pt-[48vh] on mobile; md:items-center md:pt-0.
- H1: Anton, font-bold, text-[16vw] md:text-[18vw], leading-none, text-white, tracking-widest, mix-blend-overlay, flex row items-center, gap-3 md:gap-[12vw].
- Each word chunk uses character spans animated with GSAP whenever product changes: from y 120, opacity 0, scale .8, filter blur(15px), rotateX -45; to y 0, opacity .4, scale 1, blur 0, rotateX 0, duration 1.4, stagger .06, ease power4.out. First word delay 0, second word delay .2.
- Also include a separate footer "SLAM" word behind the ball that is hidden until scroll progress > .8; then opacity .1 and translateY upward as final section starts.

Hero decorative elements:

- Desktop-only left promo video row at left 10%, top 20%, group hover scale 105: 48px circular border button with triangle play icon, text "Promotion" line break "video", opacity changes on hover.
- Desktop-only right vertical line at right-10 top-1/2 h-40 with gradient from transparent via white/20 to transparent. Put rotated text "90/10" in product.accentColor.

Bottom hero controls:

- Full width px-6 md:px-16 pb-6 md:pb-12 flex flex-col md:flex-row items-center md:items-end justify-between gap-6.
- Left price block: centered mobile, left desktop. Price uses Inter, text-6xl mobile md:text-5xl, font-light, tracking-wide, drop shadow, color product.accentColor. Animate on product change with GSAP from y 30 opacity 0 blur 8 to y 0 opacity 1 blur 0 duration .8 ease power2.out delay .4.
- Under price: "Size: 29.5\" Official" in text-xs uppercase tracking-wider gray, with a tiny white dot separator.
- Center bottom Add to cart button: rounded-sm, px-14 py-5, background product.accentColor, white uppercase text "Add to cart" with tracking .2em. Add relative overflow shimmer: hover bg-white/10 overlay and a skewed white/30 gradient sliding left to right over 700ms. Hover moves button up slightly and adds glow.
- Right slide controls: previous and next circular buttons 48px mobile / 56px desktop, border white/20, bg-black/20 backdrop-blur-md, hover bg-white text-black scale 110, active scale 95. Use left/right chevron SVG.

SECTION 2: HIGH-END TECH SPECS / PERFORMANCE METRICS

Full-screen section with grid lines:

- relative w-full h-full flex items-center px-6 md:px-20 py-20 pointer-events-none overflow-hidden
- background vertical guide lines at left, 1/3 and 2/3, plus horizontal line at center.
- Content z-10 flex items-center justify-between.
- Left panel width full md:w-1/3, gap-12.

Text:

- Mono label "PERFORMANCE METRICS" with orange dot.
- Heading "ELITE" line break "CONTROL" in Anton, text-5xl md:text-7xl, white, tight leading.
- Stat 1: "100%" / "Microfiber Composite" / paragraph "Exclusive coating material providing superior grip management in all weather conditions."
- Stat 2: "0.5mm" / "Pebble Depth" / paragraph "Optimized surface texture for precision handling and rotational feedback."
- Stats have border-left white/20, pl-6.

Right desktop cards:

- hidden below md, width 1/3, flex column justify-center items-end gap-6.
- Card 1: "WEIGHT BALANCE", progress bar 95%, labels "95%" and "PERFECT".
- Card 2: "BOUNCE CONSISTENCY", progress bar 99% with brand orange fill, labels "99%" and "UNIFORM".
- Cards: p-4 border white/10 bg-black/40 backdrop-blur-md rounded-lg max-w 200px.

SECTION 3: AERODYNAMICS

Full-screen section justify-end, px-6 md:px-16 py-20, overflow hidden.

- Background SVG wind lines: 10 curved dashed white paths, opacity 20%, each pulse with durations 3+i seconds.
- Right panel w-full md:w-5/12 text-right.
- Badge: "AERODYNAMICS" px-3 py-1 border white/30 rounded-full text-[10px] mono tracking-widest.
- Heading "PERFECT" line break "FLIGHT" in Anton text-5xl md:text-8xl white.
- Metrics:
  - 0.85 / Drag Coefficient with circular marker.
  - 28.5 / Rotational Stability with circular marker.
  - On group hover metric number changes to brand orange.
- Paragraph: "Symmetrically balanced weight distribution ensures true flight path and consistent rotation speed, critical for long-range precision."

SECTION 4: RINGS / TECHNICAL ANNOTATION

Full-screen center stage with diagnostic rings and callouts:

- Center three absolute SVG circles at 550px, 400px, and 700px.
- 550px ring rotates over 30s, dashed outer circle r270 with opacity .3, cardinal line marks in product.accentColor.
- 400px ring rotates reverse over 20s, white low opacity circle plus product.accentColor dashed segment.
- 700px static crosshair lines with dashed strokes, circles r100 and r340, and tick marks every 45 degrees.

Overlay SVG annotations:

- Define arrow marker.
- Top-left path from 20% 25% to 40% 40%, label "MICRO-TEXTURE".
- Bottom-right path from 80% 75% to 60% 60%, label "CHANNEL DEPTH".
- Right side text "AZIMUTH: 45.2°", left side "ELEVATION: 12.8°", both monospace small and pulsing.
- Bottom center small product accent pulse rectangle.

Additional callout boxes:

- Top-left: border-left white, "1.2mm" and "Pebble Height".
- Bottom-right: border-right white, "High-Tack" and "Coating Spec".

SECTION 5: PODIUM / CHAMPION

Full-screen section flex column center top, pt-16 px-6.

- Header centered, -mt-7: mono label "LIMITED EDITION", heading "THE CHAMPION" in Anton text-5xl md:text-7xl, tracking .1em, drop shadow.
- Info columns spaced left/right after mt-32:
  - Left: label "RANK 01", heading "Elite Tier", divider, paragraph "Constructed for the highest level of competition."
  - Right: label "CERTIFIED", heading "Gold Standard", divider, paragraph "Meets all regulation weight and size requirements."

3D Podium visible only in scroll stage 5:

- Three-layer cylindrical podium rises from y -10 to y -1.5 using lerp .08.
- Bottom cylinder radius 3.5 height .6 color #0a0a0a.
- Middle cylinder radius 2.5 height .6 color #151515.
- Top cylinder radius 1.5 height .6 color #202020.
- Add thin white rim rings on each tier.
- Top circle uses MeshReflectorMaterial with blur [300,100], resolution 1024, mixBlur 1, mixStrength 20, roughness .2, metalness .8, mirror .7.
- Add glowing white ring on top and two white spotlights from x +/-4 y5.

SECTION 6: FINAL CTA / GAME TIME

Full-screen section center, pb-20, overflow hidden.

- BackgroundTitle "SLAM" becomes faint behind the scene.
- 3D main ball flies/vanishes upward as scroll reaches this stage.
- Activate anti-gravity debris: 50 instanced tetrahedrons drifting upward across the full viewport, random x spread 30, y spread 20, z spread 12. 30% use product accent color, rest #2a2a2a. Scale lerps up when active, down when inactive. Wrap particles from topLimit 12 to bottomLimit -12.

CTA content:

- Badge "NEXT LEVEL PERFORMANCE" in orange border rounded-full bg-black/50 backdrop-blur.
- Huge heading in two lines, text-[15vw] md:text-[9rem], Anton uppercase leading .8:
  - "DEFY" transparent outline with WebkitTextStroke 2px rgba(255,255,255,0.2)
  - "GRAVITY." white bold with orange period.
- Information bar: flex column mobile / row desktop, border-y white/10, py-8 my-10, bg-black/20 backdrop-blur, px-8.
  - Left: mono uppercase items "OFFICIAL STORE" and "GLOBAL SHIPPING" with small orange dots.
  - Center: three social icons for Twitter/X bird, Instagram, YouTube; hover brand orange and scale 110.
  - Right: "SECURE CHECKOUT".
- Button: "Shop Collection" bg-white text-black px-16 py-5 uppercase tracking-wider; hover brand orange text white, shadow glow. It calls add-to-cart.
- Bottom copyright: "© 2024 SLAM DUNK STORE. ENGINEERED FOR GREATNESS." in tiny white/10 uppercase.

IN-VIEW ANIMATIONS:

Use IntersectionObserver on all .animate-item elements inside the scroll container with threshold .3. When visible, add class .in-view; when not visible, remove it. CSS .in-view forces opacity 1 and transform translateY(0) translateX(0). Each item defines initial opacity 0 and translate-y or translate-x plus transition-all duration-1000 and a delay class.

THREE.JS SCENE:

Canvas layer:

- absolute inset-0 z-10 w-full h-full pointer-events-none inside a wrapping div.
- Canvas shadows, dpr [1,2], camera position [0,0,8], fov 35.
- gl antialias true, toneMapping THREE.ACESFilmicToneMapping.
- Use eventSource as app root and eventPrefix "client".
- Lights: ambientLight intensity .4; SpotLight position [-5,10,5], angle .3, penumbra 1, intensity 2, castShadow, shadow-bias -0.0001, white; spotLight position [5,0,-5], angle .5, penumbra 1, intensity 5, color currentProduct.accentColor; pointLight [-5,0,5] intensity .8 color #4a5568.
- Add Environment preset "studio" and ContactShadows opacity .6 scale 10 blur 2.5 far 4 resolution 256 color black.

Scroll manager:

- In useFrame read scrollTop / (scrollHeight - clientHeight) from the UI scroll container.
- Stage 1 if progress <= .16.
- Stage 2 if > .16.
- Stage 3 if > .33.
- Stage 4 if > .50.
- Stage 5 if > .66.
- Stage 6 if > .83.
  Use stage to show Podium only at 5 and debris only at 6.

MAIN BASKETBALL:

Use a mesh sphereGeometry args [1,64,64], castShadow receiveShadow. Material meshStandardMaterial:

- map = procedural albedo canvas texture
- normalMap = procedural normal canvas texture
- normalScale = Vector2(.8,.8)
- color = product.primaryColor
- roughness .55 except product id 3 uses .4
- metalness .1 except product id 3 uses .2
- envMapIntensity .6
- FrontSide, opaque

On product change:

- Animate an internal animation rotation with GSAP: y += Math.PI*3, x += Math.PI*.75, duration 1.4, ease power4.inOut.
- Scale mesh down to .75 for .2s ease power2.in then up to .85 for 1.2s ease elastic.out(1,.4).

Pointer drag:

- On pointer down capture pointer, set dragging, remember clientX/clientY, cursor grabbing.
- On pointer move while dragging: manualRot.y += dx*.005, manualRot.x += dy*.005.
- On pointer up/leave release capture, cursor grab.
- Pointer over cursor grab, pointer out auto.

Scroll-driven ball positions and scale:

- Detect mobile if viewport width < viewport height; tablet if not mobile and viewportWidth < 6.5.
- Stage 1 hero position pos1 = [0, heroY, 0], heroY mobile 1.2, tablet -0.3, desktop 0; scale1 mobile .75 else .85.
- Stage 2 details position pos2 = [viewportWidth/2, 0, 0]; scale2 mobile 1.2 else 2.5.
- Stage 3 aero position pos3 = [-viewportWidth/2, 0, 0]; scale3 mobile 1.2 else 2.5.
- Stage 4 rings position pos4 = [0,0,0]; scale4 mobile .9 else 1.
- Stage 5 podium position pos5 = [0,.2,0]; scale5 mobile .9 else 1.
- Stage 6 slam position pos6 = [0,15,0]; scale6 1.
- Interpolate with cosine ease t = -(cos(pi\*t)-1)/2.
- 0-.2: lerp pos1 to pos2, scale1 to scale2.
- .2-.4: lerp pos2 to pos3, scale2 to scale3.
- .4-.6: lerp pos3 to pos4, add arc y += sin(t*pi)*4, scale3 to scale4.
- .6-.8: lerp pos4 to pos5, scale4 to scale5, rotationSpeed 1-t.
- .8-1: lerp pos5 to pos6, scale5 to scale6, rotationSpeed t\*5.
- Mesh position lerps to target with .08; scale lerps with .1.
- Rotation: animRot.z lerps to 0. If rotationSpeed > .01, animRot.x = scrollProgress*pi*6 and animRot.y += (0.005 + scrollProgress*.1)*rotationSpeed. Else animRot.x lerps to 0 and animRot.y += .002.
- If scrollProgress > .05 and not dragging, manual rotation offsets lerp back to 0.
- Apply rotation x=animRot.x+manualRot.x, y=animRot.y+manualRot.y, z=animRot.z.
- In hero idle scrollProgress < .05, add tiny sine float to y.

PROCEDURAL BASKETBALL TEXTURES:

Generate two canvas textures at 1024x512.

Albedo canvas:

- Fill with primaryColor.
- Add per-pixel noise of +/-10 RGB (random -0.5 \* 20).
- Draw channel pattern with ctx.lineCap round, lineJoin round, lineWidth 6, strokeStyle lineColor.
- Convert to THREE.CanvasTexture with colorSpace THREE.SRGBColorSpace.

Normal map canvas:

- Fill with #8080ff then create noisy normal pixels: R 128 +/-30, G 128 +/-30, B 255, A 255.
- Draw the same channel pattern in #2020ff with lineWidth 8.
- Convert to THREE.CanvasTexture.

Patterns:

- classic: horizontal line at height/2; vertical lines at width/4 and width*.75; sine curve y = height/2 + sin(x/width*2pi)_height_.42.
- cross: two cosine curves mirrored around center using +/- cos _ height_.45 plus horizontal center line.
- street: horizontal lines at 30% and 70%; vertical lines at 25%, 50%, 75%.
- tech: horizontal lines at 35% and 65%; 8 diagonal segment links from x at 35% to x+50 at 65%; albedo version adds shadowBlur 10 in lineColor and filled circular nodes radius 8 at each segment endpoint.

ADD TO CART FLIGHT ANIMATION:

When add-to-cart trigger time changes, create a temporary Three.js mini-ball flight using the same product texture.

- Start at [0,0,0], or y=1.2 on portrait/mobile.
- Target top-right cart area: [(viewportWidth/2)-xOffset, (viewportHeight/2)-yOffset, 0], xOffset 0.8 mobile else 1.5, yOffset 0.8 mobile else 1.2, plus tiny random jitter +/-0.1.
- Pullback vector is opposite flight direction times 3.5.
- Base scale .75 mobile else .85.
- Timeline: play swoosh. Over .4s move group to pullback x/y and z -5 with back.out(1.5); raise ball material emissiveIntensity to 3.
- Then shoot to target over .55s ease power4.in.
- Rotate ball x and y by Math.PI\*6 over .95s.
- Add 12 trailing small spheres. Each starts at startPos, appears after 0.4 + i\*.015, moves to target, scales to 0 near end, fades opacity .4 to 0.
- Impact at 0.95s: ball scale to 0 in .1s, show a white circle flash at target z .1, scale flash from .01 to 2.5 and opacity to 0 over .3s, play success chord.
- Remove the temporary flight from state after timeline completes.

AUDIO:

Create a lazy AudioManager initialized on first window click.

- master gain .3.
- Hover: sine oscillator 400Hz exponentially to 800Hz over .05s, gain .1 to .001.
- Click: triangle oscillator 150Hz to .01 over .1s, gain .5 to .001.
- Swoosh: 0.5s white noise buffer through lowpass filter 200Hz -> 2000Hz -> 100Hz, gain 0 -> .5 -> 0.
- Success: C major chord [523.25, 659.25, 783.99, 1046.50], stagger .05s, each sine fades in .05s and out .8s.
  Call hover sounds on interactive hover, click sound on next/prev/customize/open cart, success on add-to-cart and AI design success.

CONFIGURATOR MODAL:

Open as fixed inset-0 z-50 bg-black flex flex-col md:flex-row animate fade-in. It covers the app.

Desktop layout:

- left controls panel width 1/3, bg #0a0a0a, border-l white/10, shadow-2xl, full height.
- right 3D view width 2/3, bg #050505, cursor-move, with Canvas camera fov 40 position [0,0,4.5], Environment studio, same lighting as hero, Basketball in configurator mode, OrbitControls makeDefault autoRotate autoRotateSpeed 2.
  Mobile: 3D view top 40vh, controls bottom 60vh.

Configurator 3D overlay title:

- top-right text "Custom" in white/20 Anton text-4xl md:text-8xl tracking-widest uppercase.
- subtitle "Lab Edition" in white/30 mono text-xs/md:text-sm tracking .5em.

Controls:

- Header back button: arrow left SVG + "Back to Shop", gray hover white.
- Title: "DESIGN YOUR" line break "LEGACY" in Anton text-3xl/md:text-4xl; subtitle "Create a ball that matches your game."
- Base Color buttons: #C25E00, #004d25, #0077b6, #6a040f, #ff0080, #1a1a1a, #ffffff. Round 40px swatches. Selected border white scale 110.
- When choosing base color, set primaryColor and update accent heuristically: black -> white; white -> black; #004d25 -> #00ff41; #0077b6 -> #00C2FF; #6a040f -> #ffba08; otherwise accent = selected color.
- Line Color buttons: #1a1a1a, #ffffff, #ffba08, #aaffaa, #00C2FF. Round 32px swatches.
- Grip Texture grid two columns: classic, street, tech, cross. Selected is bg-white text-black border-white; unselected transparent gray border white/20.

AI Texture Lab:

- Card p-4 border rounded-lg bg-white/5, border color current accent at 25% opacity.
- Label "AI Texture Lab" in accent.
- Textarea placeholder: Describe a vibe (e.g. "Cyberpunk neon tiger" or "90s Miami Vice").
- Button "Generate Design" or spinner + "Generating..."; disabled when empty.
- Use @google/genai with model gemini-3-flash-preview if API key exists. Ask the AI to output JSON with primaryColor, lineColor, accentColor, texturePattern, explanation based on a vibe prompt. Available patterns classic/street/tech/cross. Enforce color logic: Ice/Frozen/Cold -> whites/cyans/pale blues; Lava/Fire -> reds/oranges/blacks; Dark/Stealth -> blacks/dark grays with subtle neon/white; Luxury/Royal -> gold/purple/black/white. Apply response to configProduct and show explanation in italic small text with accent border-left. If unavailable, fail gracefully with "Connection error. Try again."
- Footer button "Add to Collection" full width, background accent, white uppercase tracking-widest. On save, create custom product using current config, id Date.now(), namePart1 "CUS", namePart2 "TOM", append to product list, switch to it, close modal.

CART SIDEBAR:

Fixed inset-0 z-[100] pointer-events-none. Overlay absolute inset-0 bg-black/60 backdrop-blur-sm, fades opacity with GSAP; click closes.

Sidebar:

- absolute top-0 right-0 h-full w-full md:w-[450px] bg #080808, border-left white/10, shadow-2xl, translate-x-full initially.
- On open, body overflow hidden, overlay opacity 1, sidebar x 0 over .6s ease power3.out.
- On close, overlay opacity 0, sidebar x 100% over .5s ease power3.in.
- Header p-8 border-b white/10: "YOUR CART (n)" Anton text-3xl, close X.
- Empty state centered with bag/cart icon, text "Your cart is empty".
- Cart item card: bg-white/5 p-4 rounded-lg border white/5, slide-in fade-in, delay index\*100ms. Left mini swatch square w20 h20 with colored ball circle. Right title namePart1+namePart2, subtitle "{texturePattern} Edition", remove X, primaryColor string in brand orange, price.
- Footer when items exist: subtotal row and full-width Checkout button bg-white text-black, hover brand orange text-white, plus "Free shipping worldwide".

RESPONSIVENESS:

Mobile must keep the central ball high enough not to cover bottom CTA; use heroY 1.2, scale .75, title pt 48vh and text 16vw. Hero bottom controls stack vertically: price centered, add-to-cart full-width-ish, slide arrows on right side. Hide desktop center nav links below md. Configurator becomes top preview + bottom controls. Section text sizes should scale with md breakpoints and never overflow.

IMPORTANT QUALITY BAR:

This should feel like a polished premium interactive product microsite. Preserve the exact text labels, product names, prices, colors, scroll stages, 3D motion path, procedural texture patterns, add-to-cart flight, cart drawer, customizer modal, and custom cursor behavior. The first screen should immediately show the SLAM DUNK logo, giant split SPA / ING background title, central rotating textured basketball, orange price $34.99, size 29.5" Official, Add to cart button, previous/next circular arrows, and dark rounded app frame on orange page background.
