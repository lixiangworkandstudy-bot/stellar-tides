
import * as Tone from 'tone';
import * as THREE from 'three';
import vertexShader from './shaders/particles.vert?raw';
import fragmentShader from './shaders/particles.frag?raw';
import { SoundManager } from './audio/SoundManager.js';

const STATES = [
  // CORES: All reset to [[0,0], [0,0], [0,0]].
  // 0. New Default: WARMTH (The Essence / Golden Spiral)
  { name: 'ESSENCE', color: '#FFB86C', cores: [[0, 0], [0, 0], [0, 0]], weights: [1, 0, 0] },
  { name: 'PURE', color: '#FFFFFF', cores: [[0, 0], [0, 0], [0, 0]], weights: [1, 0, 0] },
  { name: 'UPLIFTING', color: '#A020C0', cores: [[0, 0], [0, 0], [0, 0]], weights: [1, 0, 0] },
  { name: 'UNIVERSAL', color: '#448AFF', cores: [[0, 0], [0, 0], [0, 0]], weights: [1, 0, 0] },
  { name: 'VITAL', color: '#10A060', cores: [[0, 0], [0, 0], [0, 0]], weights: [1, 0, 0] },
  { name: 'DEEP HEAL', color: '#003388', cores: [[0, 0], [0, 0], [0, 0]], weights: [1, 0, 0] }
];

class StellarTides {
  constructor() {
    this.container = document.querySelector('#app');
    this.scene = new THREE.Scene();
    this.camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
    this.camera.position.z = 22;

    this.renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    this.renderer.setSize(window.innerWidth, window.innerHeight);
    this.renderer.setClearColor(0x0a0a0c, 1);
    this.container.appendChild(this.renderer.domElement);

    this.mouse = new THREE.Vector2(0.5, 0.5);
    this.breath = 0;
    this.currentState = 0;
    this.transition = 0;

    this.particleCount = 30000; // Performance optimized

    // Audio Engine
    try {
      this.audio = new SoundManager();
    } catch (e) {
      console.warn("Audio failed to init", e);
      this.audio = {
        initialize: () => { },
        update: () => { }
      };
    }

    this.setupUI();
    this.setupBreathGuide();
    this.setupParticles();
    this.setupEvents();
    this.setState(0); // Set initial state only once after all is ready
    this.animate();
  }

  setupUI() {
    const ui = document.createElement('div');
    ui.id = 'energy-nav';
    ui.style.cssText = `
      position: absolute; bottom: 30px; left: 50%; transform: translateX(-50%);
      display: flex; gap: 40px; z-index: 100;
    `;

    STATES.forEach((s, i) => {
      const btn = document.createElement('button');

      // Color Indicator Dot
      const dot = `<span style="display:inline-block; width:6px; height:6px; background-color:${s.color}; border-radius:50%; margin-right:10px; box-shadow:0 0 8px ${s.color};"></span>`;

      btn.innerHTML = `${dot}${s.name}`;
      btn.style.cssText = `
        background: rgba(255, 255, 255, 0.02); 
        border: 1px solid rgba(255, 255, 255, 0.05); 
        padding: 10px 20px;
        border-radius: 30px;
        color: rgba(255,255,255,0.4); /* Softer text */
        font-family: 'Outfit', sans-serif; font-size: 10px; letter-spacing: 3px;
        cursor: pointer; transition: all 0.6s cubic-bezier(0.22, 1, 0.36, 1); outline: none;
        display: flex; align-items: center;
        backdrop-filter: blur(2px);
      `;

      btn.onmouseenter = () => {
        btn.style.background = 'rgba(255, 255, 255, 0.08)';
        btn.style.borderColor = s.color;
        btn.style.color = '#fff';
        btn.style.transform = 'translateY(-3px) scale(1.05)';
        btn.style.boxShadow = `0 10px 30px rgba(0,0,0,0.5), 0 0 20px ${s.color}20`;
      };

      btn.onmouseleave = () => {
        if (this.currentState !== i) {
          btn.style.background = 'rgba(255, 255, 255, 0.02)';
          btn.style.borderColor = 'rgba(255, 255, 255, 0.05)';
          btn.style.color = 'rgba(255, 255, 255, 0.4)';
          btn.style.transform = 'translateY(0) scale(1)';
          btn.style.boxShadow = 'none';
        }
      };

      btn.onclick = () => {
        this.setState(i);
        this.audio.initialize(); // Ensure audio starts on interaction
      };
      ui.appendChild(btn);
      s.element = btn;
    });

    this.container.appendChild(ui);
  }

  setState(index) {
    this.currentState = index;
    const s = STATES[index];

    // Update UI
    // Update UI
    STATES.forEach((st, i) => {
      const isActive = i === index;
      if (isActive) {
        st.element.style.color = '#fff';
        st.element.style.borderColor = st.color;
        st.element.style.background = 'rgba(255, 255, 255, 0.08)';
        st.element.style.boxShadow = `0 0 30px ${st.color}10, inset 0 0 20px ${st.color}10`; // Very subtle glow
        st.element.style.transform = 'translateY(-2px)';
      } else {
        st.element.style.color = 'rgba(255,255,255,0.4)';
        st.element.style.borderColor = 'rgba(255, 255, 255, 0.05)';
        st.element.style.background = 'rgba(255, 255, 255, 0.02)';
        st.element.style.boxShadow = 'none';
        st.element.style.transform = 'translateY(0)';
      }
    });

    // Update Uniforms
    if (this.material) {
      this.material.uniforms.uEnergyState.value = index;
      this.material.uniforms.uTransition.value = 1.0; // Reset transition for now
      const flatCores = new Float32Array(6);
      s.cores.forEach((c, i) => {
        flatCores[i * 2] = c[0];
        flatCores[i * 2 + 1] = c[1];
      });
      this.material.uniforms.uFocusPoints.value = flatCores;
      this.material.uniforms.uFocusWeights.value = new Float32Array(s.weights);
    }
  }

  setupParticles() {
    const geometry = new THREE.BufferGeometry();
    const positions = new Float32Array(this.particleCount * 3);
    const randoms = new Float32Array(this.particleCount * 3);
    const sizes = new Float32Array(this.particleCount);

    // Golden Spiral (Phyllotaxis) - "Logical" Organic Structure
    const goldenAngle = Math.PI * (3 - Math.sqrt(5));

    for (let i = 0; i < this.particleCount; i++) {
      // Normalized index 0 to 1
      const t = i / this.particleCount;

      // Radius increases with index (sqrt for uniform area, linear for center focus)
      // We use a slight power to keep the core dense but allow reach
      const radius = Math.pow(t, 0.5) * 45.0;

      const theta = i * goldenAngle;

      // Spiral positions (X, Y plane facing viewer)
      const x = radius * Math.cos(theta);
      const y = radius * Math.sin(theta);

      // Thickness (Z axis) - Tapers at the edges like a real galaxy
      const thickness = 20.0 * (1.0 - t * 0.8);
      const z = (Math.random() - 0.5) * thickness;

      positions[i * 3] = x;
      positions[i * 3 + 1] = y * 0.9; // Slightly elliptical
      positions[i * 3 + 2] = z;

      // Randoms for shimmer, not position
      randoms[i * 3] = Math.random();
      randoms[i * 3 + 1] = Math.random();
      randoms[i * 3 + 2] = Math.random();
      sizes[i] = Math.random() * 2.0 + 0.5;
    }

    geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
    geometry.setAttribute('aRandom', new THREE.BufferAttribute(randoms, 3));
    geometry.setAttribute('aSize', new THREE.BufferAttribute(sizes, 1));

    this.material = new THREE.ShaderMaterial({
      vertexShader,
      fragmentShader,
      uniforms: {
        uTime: { value: 0 },
        uBreath: { value: 0 },
        uMouse: { value: this.mouse },
        uEnergyState: { value: 0 },
        uTransition: { value: 0 },
        uFocusPoints: { value: new Float32Array(6) },
        uFocusWeights: { value: new Float32Array(3) }
      },
      transparent: true,
      blending: THREE.AdditiveBlending,
      depthWrite: false
    });

    this.points = new THREE.Points(geometry, this.material);
    this.scene.add(this.points);
  }

  setupEvents() {
    window.addEventListener('resize', () => {
      this.camera.aspect = window.innerWidth / window.innerHeight;
      this.camera.updateProjectionMatrix();
      this.renderer.setSize(window.innerWidth, window.innerHeight);
    });

    // Audio Start (User Interaction)
    window.addEventListener('click', async () => {
      console.log("🖱️ User Clicked: Attempting to start Audio...");

      try {
        await Tone.start();
        console.log("✅ Tone.start() resolved. AudioContext state:", Tone.context.state);

        // Simple Beep Test
        const beep = new Tone.Synth().toDestination();
        beep.triggerAttackRelease("C5", "8n");
        console.log("🔊 Beep command sent.");

        await this.audio.initialize();
        console.log("🎵 Audio Engine Initialized.");
      } catch (e) {
        console.error("❌ Audio Init Error:", e);
      }
    }, { once: true });

    // Smooth Mouse Tracking
    this.targetMouse = new THREE.Vector2(0.5, 0.5);
    this.currentMouse = new THREE.Vector2(0.5, 0.5);

    window.addEventListener('mousemove', (e) => {
      this.targetMouse.x = e.clientX / window.innerWidth;
      this.targetMouse.y = 1.0 - (e.clientY / window.innerHeight);
    });
  }

  setupBreathGuide() {
    this.breathLabel = document.createElement('div');
    this.breathLabel.style.cssText = `
      position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%);
      font-family: 'Outfit', sans-serif; font-size: 24px; letter-spacing: 12px;
      color: rgba(255, 255, 255, 0.9); pointer-events: none; opacity: 0;
      transition: opacity 1.5s, transform 0.1s;
      mix-blend-mode: normal; text-transform: uppercase;
      font-weight: 300;
      text-shadow: 0 0 30px rgba(255,255,255,0.6);
    `;
    this.container.appendChild(this.breathLabel);
  }

  updateBreath(time) {
    // 4-7-8 Rhythm (Total 19s)
    const cycle = 19.0;
    const t = time % cycle;

    let label = "";
    let opacity = 0;
    let scale = 1.0;

    if (t < 4.0) {
      // INHALE (0 to 4s)
      this.breath = t / 4.0;
      label = "Inhale";
      opacity = Math.sin((t / 4.0) * Math.PI) * 0.8;
      // Scale: 1.0 -> 1.2 (Expanding lungs)
      scale = 1.0 + (this.breath * 0.2);
    } else if (t < 11.0) {
      // HOLD (4s to 11s)
      this.breath = 1.0;
      label = "Hold";
      opacity = 0.5;
      // Scale: 1.2 (Steady)
      scale = 1.2;
    } else {
      // EXHALE (11s to 19s)
      const releaseProgress = (t - 11.0) / 8.0;
      this.breath = 1.0 - releaseProgress;
      label = "Release";
      opacity = Math.sin(releaseProgress * Math.PI) * 0.8;
      // Scale: 1.2 -> 1.0 (Releasing)
      scale = 1.2 - (releaseProgress * 0.2);
    }

    // Shader Uniform
    this.material.uniforms.uBreath.value = this.breath;

    // UI Update
    if (this.breathLabel.innerText !== label) {
      this.breathLabel.innerText = label;
    }
    this.breathLabel.style.opacity = opacity;
    this.breathLabel.style.transform = `translate(-50%, -50%) scale(${scale})`;
  }

  animate() {
    requestAnimationFrame((time) => {
      const t = time * 0.001;
      if (this.material) {
        // Smooth Mouse Lerp
        this.currentMouse.x += (this.targetMouse.x - this.currentMouse.x) * 0.25;
        this.currentMouse.y += (this.targetMouse.y - this.currentMouse.y) * 0.25;

        this.material.uniforms.uTime.value = t;
        this.material.uniforms.uMouse.value = this.currentMouse;
      }
      this.updateBreath(t);

      // AUDIO UPDATE
      this.audio.update(this.breath, this.currentState);

      // dampening factor: When breath is high (Hold), speed drops
      // uBreath is 0..1. 1 = Hold. 
      // Speed factor: 1.0 when breath is 0, 0.1 when breath is 1.
      const speedFactor = 1.0 - (this.breath * 0.9);

      this.points.rotation.y += 0.0001 * speedFactor; // Gentle drift
      this.points.rotation.z += 0.00005 * speedFactor;

      this.renderer.render(this.scene, this.camera);
      this.animate();
    });
  }
}

new StellarTides();
