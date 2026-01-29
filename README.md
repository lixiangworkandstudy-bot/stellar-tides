# Stellar Tides: Design & Physics Documentation

> "The Universe is immutable; Thought creates ripples of light."

This project is a visual meditation on the concept of **"Physics of Belief" (信念物理学)** and the Buddhist cycle of **"Cheng Zhu Huai Kong" (成住坏空)**.

## 1. Core Philosophy (The Soul)

### The Cycle of Breath

- **Inhale (Formation / 成)**: Entropy decreases. Chaos coalesces into order.
- **Hold (Stasis / 住)**: Peak energy. Sacred Geometry forms (Merkaba, Sphere, Torus).
- **Exhale (Degeneration / 坏)**: Entropy increases. Structure dissolves into turbulence.
- **Void (Void / 空)**: Pure potential. Particles return to a chaotic, isotropic nebula.

### The Interaction: Cosmic Resonance (宇宙共鸣)

- **Old Logic (Rejected)**: Repulsion. User "pushes" the universe. (Too dualistic/ego-centric).
- **New Logic (Accepted)**: **Resonance**.
  - The stars follow their own immutable laws (Keplerian orbits).
  - The cursor (Consciousness) does not move them, but **illuminates** them.
  - **Effect**: Ignited particles glow purely white, vibrate (frequency shift), and levitate (dimension shift).
  - **Metaphor**: "Nian Nian Xiang Xu" (念念相续) — Continuity of thought lighting up the void.

---

## 2. Physics Engine (The Laws)

### A. Keplerian Orbitals

- Particles do not just rotate; they **orbit**.
- **Velocity Profile**: $v \propto \frac{1}{\sqrt{r}}$. Inner stars move faster, creating natural spiral arms.
- **Vortex Acceleration**: During "Inhale", angular momentum is conserved. As radius decreases, speed increases.

### B. Density Compensation (The Sunglass Effect)

- **Problem**: When 30,000 particles collapse into a singularity, pixels overexpose to white.
- **Solution**: **Inverse-Square Alpha**.
  - Formula: `alpha *= 1.0 / (1.0 + tension * 45.0)`
  - As density increases (tension -> 1.0), transparency drops drastically (down to ~2%).
- **Result**: Even the densest core remains detailed and structurally visible.

### C. Cinematic Post-Processing

- **Bloom**: UnrealBloomPass.
  - Strength: **0.5** (Low to prevent washout).
  - Threshold: **0.3** (Only core stars glow).
- **Alpha Cap**: Hard limit of **0.5** on all particles.

---

## 3. Cosmic Archetypes (The Colors)

Each energy state corresponds to a specific universal archetype and physical form.

| State | Name | Color | Archetype | Geometry | Concept |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | **Infinite** | Airy Blue | **The Void (Akasha)** | **Torus (Ring)** | The background radiation. Infinite loops. The baseline of reality. |
| **1** | **Warmth** | Amber/Orange | **The Star (Surya)** | **Sphere (Boiling)** | Life-giving heat. A dense, surface-turbulent sun. |
| **2** | **Uplifting** | Magenta | **The Nebula (Shakti)** | **Cloud (Burst)** | Explosive creativity. High entropy, expanding outward like a supernova. |
| **3** | **Universal** | Electric Blue | **The Grid (Indra's Net)** | **Torus (Connected)** | The electromagnetic web connecting all minds. |
| **4** | **Vital** | Green | **Life (Gaia)** | **Sphere (Organic)** | The perfect, self-contained biosphere. |
| **5** | **Deep Heal** | Navy/Indigo | **The Abyss (Oceanus)** | **Merkaba (Crystal)** | The deepest subconscious. A sharp, faceted geometric solid hidden in the deep. |

---

## 4. Key Tuning Parameters

### Rotation Speeds

- **Base Speed**: Extremely slow (0.004 - 0.01) for a "Hypnotic / Timeless" feel.
- **Time Scale**: `uTime * 0.1` in shader.

### Particle Distribution

- **Pole Correction**: Used `acos(2.0 * random - 1.0)` for Spheres to prevent "Pole Clumping" (Z-axis artifacts).
- **Drift Correction**: Removed spatial noise (`sin(pos)`) in favor of local noise (`sin(random)`) to prevent the universe from drifting off-center.
