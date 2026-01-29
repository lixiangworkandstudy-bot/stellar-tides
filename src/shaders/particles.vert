
uniform float uTime;
uniform float uBreath; // 0.0 to 1.0 (Inhale -> Hold)
uniform vec2 uMouse;
uniform int uEnergyState;

// Multi-core (Optional, kept for future)
uniform vec2 uFocusPoints[3];
uniform float uFocusWeights[3];

attribute float aSize;
attribute vec3 aRandom;

varying vec3 vColor;
varying float vAlpha;
varying float vTwinkleRandom;

void main() {
    vec3 pos = position; // Initial random sphere position
    
    // --- 1. SHAPE LOGIC (Restored) ---
    vec3 targetPos = pos;
    
    // SHAPE 0: ESSENCE (Tesseract Hypercube 🧊)
    if (uEnergyState == 0) {
        // "Essence" - Higher Dimensional Intelligence.
        // Concept: Tesseract (Cube within a Cube).
        
        // 1. Cube Surface Mapping
        // Map 0..1 randoms to the 6 faces of a cube.
        // We do this twice: Once for Outer, once for Inner.
        
        vec3 cubePos;
        float face = floor(aRandom.x * 6.0);
        float u = fract(aRandom.x * 6.0) * 2.0 - 1.0; // -1..1
        float v = aRandom.y * 2.0 - 1.0;              // -1..1
        
        if (face < 1.0)      cubePos = vec3(1.0, u, v);   // +X
        else if (face < 2.0) cubePos = vec3(-1.0, u, v);  // -X
        else if (face < 3.0) cubePos = vec3(u, 1.0, v);   // +Y
        else if (face < 4.0) cubePos = vec3(u, -1.0, v);  // -Y
        else if (face < 5.0) cubePos = vec3(u, v, 1.0);   // +Z
        else                 cubePos = vec3(u, v, -1.0);  // -Z
        
        // 2. Nested Structure (Inner vs Outer)
        // 70% Outer, 30% Inner
        float isInner = (aRandom.z > 0.7) ? 1.0 : 0.0;
        
        float size = mix(12.0, 5.0, isInner); // Outer=12, Inner=5
        cubePos *= size;
        
        // 3. Rotation (The "4D" tumble)
        // Inner and Outer cubes rotate on different axes/speeds
        vec3 p = cubePos;
        
        float t = uTime * 0.2;
        
        if (isInner > 0.5) {
             // Inner: Fast Complex Spin
             float rotX = t * 2.0;
             float rotY = t * 1.5;
             
             // Rot X
             float y1 = p.y * cos(rotX) - p.z * sin(rotX);
             float z1 = p.y * sin(rotX) + p.z * cos(rotX);
             p.y = y1; p.z = z1;
             
             // Rot Y
             float x2 = p.x * cos(rotY) - p.z * sin(rotY);
             float z2 = p.x * sin(rotY) + p.z * cos(rotY);
             p.x = x2; p.z = z2;
             
        } else {
             // Outer: Slow Majestic Tumble
             float rotZ = t * 0.5;
             float rotY = t * 0.3;
             
             // Rot Z
             float x2 = p.x * cos(rotZ) - p.y * sin(rotZ);
             float y2 = p.x * sin(rotZ) + p.y * cos(rotZ);
             p.x = x2; p.y = y2;
             
             // Rot Y
             float x3 = p.x * cos(rotY) - p.z * sin(rotY);
             float z3 = p.x * sin(rotY) + p.z * cos(rotY);
             p.x = x3; p.z = z3;
        }
        
        targetPos = p;
    }
    // SHAPE 1: INFINITE (Crystal Infinity ♾️)
    else if (uEnergyState == 1) {
        // "Infinite" - Hollow Crystal Tube 8.
        // User found the "Stranded" logic weird (distortion).
        // Solution: Standard Figure-8, but HOLLOW TUBE surface distribution.
        // This creates sharp edges (high contrast) which looks like structure/strands.
        
        float t = aRandom.x * 6.28;
        float tubeRadius = 1.5; // Thin, defined tube
        float scale = 12.0;
        
        // 1. Centerline (Lemniscate)
        float denom = 1.0 + sin(t) * sin(t);
        float cx = scale * cos(t) / denom;
        float cy = scale * sin(t) * cos(t) / denom;
        
        // 2. Hollow Tube Logic (Surface Only)
        // We need a stable local frame.
        // Approximate Tangent vector (derivative of Lemniscate)
        // dx/dt 
        float num_x = -sin(t) * (1.0 + sin(t)*sin(t)) - cos(t) * (2.0*sin(t)*cos(t));
        // It's getting complex. 
        // Simplification: In 3D, just adding a ring in YZ plane works if curve is mostly X.
        // But curve is XY. So ring should be in Z and "Normal".
        
        // Simple stable ring:
        // Use the Z axis and the "Radial from center" axis as the basis for the tube cross-section.
        // It's an approximation but consistent enough for particles.
        vec3 centerDir = normalize(vec3(cx, cy, 0.0));
        vec3 upDir = vec3(0.0, 0.0, 1.0);
        
        float angle = aRandom.y * 6.28; // Ring angle
        
        // Tube Surface Position offset
        vec3 tubeOffset = (centerDir * cos(angle) + upDir * sin(angle)) * tubeRadius;
        
        // Add random scatter to make it "Crystal Dust" not perfectly smooth
        tubeOffset += (aRandom - 0.5) * 0.5;
        
        // 3. 3D Rotation
        float rot = uTime * 0.1;
        float px = cx + tubeOffset.x;
        float py = cy + tubeOffset.y;
        float pz = tubeOffset.z;
        
        float finalX = px * cos(rot) - pz * sin(rot);
        float finalZ = px * sin(rot) + pz * cos(rot);
        float finalY = py;
        
        targetPos = vec3(finalX, finalY, finalZ);
    }
    // SHAPE 2: UPLIFTING (DNA Double Helix)
    else if (uEnergyState == 2) {
        // "Uplifting" - Rising Life Energy (DNA)
        // Two intertwining spirals rising up the Y axis
        
        float helicalRise = aRandom.x * 20.0 - 10.0; // Y height: -10 to +10
        float angle = helicalRise * 0.5; // Twist rate
        float radius = 4.0;
        
        // Split into 2 strands based on random.z
        float strandOffset = (aRandom.z > 0.5) ? 3.14159 : 0.0;
        
        float finalAngle = angle + strandOffset + uTime * 0.2; // Slowly rotating
        
        targetPos.x = radius * cos(finalAngle);
        targetPos.y = helicalRise;
        targetPos.z = radius * sin(finalAngle);
        
        // Add some "Cloud" volume around the strands so it's not just a thin line
        targetPos += (aRandom - 0.5) * 2.0;
    }
    // SHAPE 3: UNIVERSAL (Atomic Rings)
    else if (uEnergyState == 3) {
         float ringId = floor(aRandom.z * 3.0);
         float angle = aRandom.x * 6.28;
         float r = 12.0;
         
         // Base Ring on XY plane
         vec3 ring = vec3(r * cos(angle), r * sin(angle), 0.0);
         
         // Tilt rotations for the 3 rings (Classic Atom Look)
         // Ring 1: Flat-ish (XY)
         // Ring 2: Tilted 60 deg X
         // Ring 3: Tilted 60 deg Y ? 
         // Better: Rotate around Y axis then tilt X.
         
         float tiltAngle = 0.0;
         float spinAngle = 0.0;
         
         if (ringId < 1.0) { 
             // Ring 1: Horizontal-ish diagonal
             spinAngle = 0.0;
             tiltAngle = 1.0; // ~60 deg
         } else if (ringId < 2.0) { 
             // Ring 2: Other diagonal
             spinAngle = 2.09; // 120 deg
             tiltAngle = 1.0;
         } else { 
             // Ring 3: Vertical-ish
             spinAngle = 4.18; // 240 deg
             tiltAngle = 1.0;
         }
         
         // 1. Tilt on X axis
         float y1 = ring.y * cos(tiltAngle) - ring.z * sin(tiltAngle);
         float z1 = ring.y * sin(tiltAngle) + ring.z * cos(tiltAngle);
         ring.y = y1; ring.z = z1;
         
         // 2. Spin on Z axis (to spread them out like a flower/atom)
         float x2 = ring.x * cos(spinAngle) - ring.y * sin(spinAngle);
         float y2 = ring.x * sin(spinAngle) + ring.y * cos(spinAngle);
         ring.x = x2; ring.y = y2;
         
         targetPos = ring;
         targetPos += (aRandom - 0.5) * 1.0; // Light Jitter
    }
    // SHAPE 4: VITAL (Living Cell 🦠)
    else if (uEnergyState == 4) {
        // "Vital" - A Breathing Living Cell.
        // Concept: A biological sphere with a pulsating membrane.
        
        // 1. Base Sphere (Spherical Coordinates)
        float u = aRandom.x;
        float v = aRandom.y;
        float theta = 2.0 * 3.14159 * u;
        float phi = acos(2.0 * v - 1.0);
        
        float r = 10.0; // Base radius
        
        // 2. Cellular Membrane Texture (Interference Pattern)
        // Create a "net" or "hives" pattern using high-freq sine waves
        float freq = 10.0;
        float membrane = sin(theta * freq) * sin(phi * freq);
        
        // 3. Pulsation (Breathing)
        // The membrane expands and contracts rhythmically
        // Combined with uBreath logic:
        // Hold (1.0) = Expanded/Tension. Release (0.0) = Relaxed.
        float pulse = sin(uTime * 2.0 - length(vec3(theta, phi, 0.0)) * 2.0);
        
        // Apply texture displacement
        // "Cell Walls" push out, centers dip in? Or vice versa.
        float displacement = membrane * (0.5 + 0.5 * sin(uTime)); 
        
        r += displacement * 1.5;
        
        // 4. Convert to Cartesian
        float sinPhi = sin(phi);
        vec3 p = vec3(
            r * sinPhi * cos(theta),
            r * sinPhi * sin(theta),
            r * cos(phi)
        );
        
        // 5. Rotation (Slow Drift)
        float rot = uTime * 0.1;
        float cx = p.x * cos(rot) - p.z * sin(rot);
        float cz = p.x * sin(rot) + p.z * cos(rot);
        
        targetPos = vec3(cx, p.y, cz);
    }
    // SHAPE 5: DEEP HEAL (Energy Torus 🍩)
    else {
        // "Deep Heal" - Toroidal Energy Flow.
        // Concept: Self-sustaining energy field (Cyclic).
        
        // Torus Parametric Equation:
        // x = (R + r * cos(theta)) * cos(phi)
        // y = (R + r * cos(theta)) * sin(phi)
        // z = r * sin(theta)
        
        float u = aRandom.x;
        float v = aRandom.y;
        
        float phi = u * 6.28; // Ring angle (0..2PI)
        float theta = v * 6.28; // Tube angle (0..2PI)
        
        // Flow Animation:
        // Particles flow "around" the tube (theta) 
        // to create a circulation effect.
        theta += uTime * 0.5;
        
        float R = 9.5; // Wider Ring
        float r = 2.5; // Thinner Tube = Larger Hole
        
        // HOLLOW TUBE (Surface Only)
        // Instead of filling the volume, we keep them on the surface
        // to define the shape clearly (like the Infinite Loop).
        // Add minimal scatter for "Energy Field" fuzziness
        r += (aRandom.z - 0.5) * 1.0; 
        
        float x = (R + r * cos(theta)) * cos(phi);
        float y = (R + r * cos(theta)) * sin(phi);
        float z = r * sin(theta);
        
        // 3D Rotation (Tilted to show structure)
        vec3 p = vec3(x, y, z);
        
        // Optimize Angle: Gentle "Nodding" Tilt
        // Varies between ~28 deg and ~45 deg to show both the hole and the volume.
        float tilt = 0.5 + 0.15 * sin(uTime * 0.5); 
        
        float y1 = p.y * cos(tilt) - p.z * sin(tilt);
        float z1 = p.y * sin(tilt) + p.z * cos(tilt);
        p = vec3(p.x, y1, z1);
        
        // Rotate Y (Spin)
        float spin = uTime * 0.1;
        float x2 = p.x * cos(spin) - p.z * sin(spin);
        float z2 = p.x * sin(spin) + p.z * cos(spin);
        
        targetPos = vec3(x2, p.y, z2);
    }

    // --- 2. TRANSITION LOGIC (Breath) ---
    // Breath 0.0 (Release) -> Chaos
    // Breath 1.0 (Hold) -> Order (Target Shape)
    
    // Animate Chaos
    float t = uTime * 0.1;
    vec3 chaosPos = pos;
    // Rotation
    float cx = chaosPos.x * cos(t) - chaosPos.y * sin(t);
    float cy = chaosPos.x * sin(t) + chaosPos.y * cos(t);
    chaosPos.x = cx; chaosPos.y = cy;
    chaosPos *= 1.5; // Expand a bit
    
    // Mix
    float mixFactor = smoothstep(0.0, 0.8, uBreath);
    vec3 finalPos = mix(chaosPos, targetPos, mixFactor);
    
    // --- 2.5 COSMIC RESONANCE (Ripple) ---
    // Project to Screen Space to check mouse proximity
    vec4 clipPos = projectionMatrix * modelViewMatrix * vec4(finalPos, 1.0);
    vec3 ndc = clipPos.xyz / clipPos.w; // Perspective divide
    vec2 screenPos = ndc.xy * 0.5 + 0.5; // Map -1..1 to 0..1
    
    float dist = distance(screenPos, uMouse);
    float radius = 0.2; // Slightly larger (Compromise)
    
    if (dist < radius) {
        // "Resonance" - A gentle sine wave ripple
        // Strength fades at edge of radius
        float strength = smoothstep(radius, 0.0, dist);
        
        // Ripple oscillation - Lower freq (50.0) for clearer waves
        float ripple = sin(dist * 50.0 - uTime * 10.0) * strength;
        
        // Apply to Z (Depth) -> Stronger Water Surface Effect
        // Reduced to 1.5 (Subtle/Gentle)
        finalPos.z += ripple * 1.5;
    }

    // --- 3. OUTPUT & SIZING ---
    vec4 mvPosition = modelViewMatrix * vec4(finalPos, 1.0);
    gl_Position = projectionMatrix * mvPosition;
    
    // DYNAMIC MOOD: Clear (Release) -> Dreamy (Hold)
    // uBreath: 0.0 (Release) -> 1.0 (Hold)
    
    // DYNAMIC MOOD: Clear (Release) -> Dreamy (Hold)
    // uBreath: 0.0 (Release) -> 1.0 (Hold)
    
    // Size: Release=Small(Sharp), Hold=Large(Dreamy Halo)
    // REDUCED MAX SIZE: 3.5 was too big for denser clustering.
    float sizeMood = mix(1.0, 2.0, uBreath); 
    gl_PointSize = aSize * (300.0 / -mvPosition.z) * sizeMood;
    gl_PointSize = clamp(gl_PointSize, 2.0, 60.0);
    
    // --- 4. SAFE VISIBILITY ---
    // Color Logic & Density Factor
    vColor = vec3(1.0);
    float densityFactor = 0.1; // Default
    
    if (uEnergyState == 0) {
        vColor = vec3(1.0, 0.9, 0.6); // Essence: Gold
        densityFactor = 0.05;         // Boosted from 0.012 (Sphere needs more density than Galaxy core)
    } 
    else if (uEnergyState == 1) {
        vColor = vec3(1.0, 1.0, 1.0); // Infinite: White (Pure/Void)
        densityFactor = 0.03;         // Increased slightly for strands (from 0.015)
    }
    else if (uEnergyState == 2) {
        vColor = vec3(1.0, 0.6, 0.8); // Uplifting: Sakura Pink
        densityFactor = 0.035;        // Reduced from 0.08 to prevent DNA strand burnout
    }
    else if (uEnergyState == 3) {
        vColor = vec3(0.2, 0.5, 1.0); // Universal: Electric
        densityFactor = 0.04;         // Reduced from 0.2 (Was too bright at intersections)
    }
    else if (uEnergyState == 4) {
        vColor = vec3(0.2, 0.9, 0.5); // Vital: Green
        densityFactor = 0.05;         // Flattened density, reduced for volume to fix white edge
    }
    else {
        vColor = vec3(0.2, 0.3, 0.9); // Deep Blue
        densityFactor = 0.1;
    }
    
    // Alpha: Release=Opaque(Distinct), Hold=Transparent(Misty/Glow)
    // FIX OVEREXPOSURE (State Specific):
    // Use densityFactor to determine the "Hold" alpha.
    float releaseProgress = 1.0 - uBreath; 
    float curve = releaseProgress * releaseProgress * releaseProgress; // Cubic Ease-In
    
    // Low (densityFactor) -> High (0.9)
    float alphaMood = mix(densityFactor, 0.9, curve);
    
    // Safety clamp (Prevent 0)
    vAlpha = max(alphaMood, 0.01);
    
    // Twinkle: Only twinkle in the Dreamy state for magic
    vTwinkleRandom = aRandom.z;
}
