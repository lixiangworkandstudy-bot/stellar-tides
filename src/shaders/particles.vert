
uniform float uTime;
uniform float uBreath;
uniform vec2 uMouse;
uniform float uTransition; // 0.0 to 1.0 transition between states
uniform int uEnergyState;

// Multi-core support (up to 3)
uniform vec2 uFocusPoints[3];
uniform float uFocusWeights[3];

attribute float aSize;
attribute vec3 aRandom;

varying vec3 vColor;
varying float vAlpha;
varying float vViewDepth;
varying float vStateIntensity;
varying float vSpeed;
varying float vTwinkleRandom; // For independent twinkling



void main() {
    vec3 pos = position;
    float t = uTime * 0.1;

    // --- PHYSICS OF BELIEF 2.0 ---
    // 1. TENSION = uBreath (Direct mapping)
    float tension = uBreath; 
    
    // 2. BREAK REGULARITY (Organic Chaos)
    vec3 basePos = position;
    // Add significant radial noise so rings aren't perfect
    float irregularity = aRandom.z * 15.0; 
    basePos.xy += vec2(cos(aRandom.x * 6.28), sin(aRandom.x * 6.28)) * irregularity;
    
    float radius = length(basePos.xy);
    float angle = atan(basePos.y, basePos.x);
    
    // LAYERS OF MOTION
    
    // A. KEPLERIAN DRIFT (HYPNOTIC SPEED)
    // Reduced to 20% of previous speeds for "Clock Hand" feel
    float distNorm = radius * 0.05; 
    float kepler = 1.0 / (distNorm + 0.5); 
    
    float speedBase = 0.006; // Was 0.03
    if (uEnergyState == 1) speedBase = 0.01; // Was 0.05
    if (uEnergyState == 3) speedBase = 0.004; // Was 0.02
    
    float baseAngle = angle + (uTime * speedBase * kepler);
    
    // B. VORTEX ACCELERATION (Conservation of Angular Momentum)
    float vortexStrength = tension * 2.0;
    float vortex = vortexStrength * kepler; 
    float finalAngle = baseAngle + vortex;
    
    // --- SACRED GEOMETRY (THE DIVINE ORDER) ---
    vec3 sacredPos = basePos;
    
    // We define different target shapes based on the "Soul State"
    // Since we can't do complex branching without performance cost, we mix fundamental math.
    
    // SHAPE 1: THE SPHERE (Unity/Vital) - Energy 4
    if (uEnergyState == 4) {
        // Map grid to sphere surface using fibonacci-like distribution approximation
        float phi = acos(1.0 - 2.0 * aRandom.x);
        float lambda = sqrt(3.1415 * 50.0) * phi;
        
        vec3 spherePos;
        spherePos.x = 10.0 * sin(phi) * cos(lambda);
        spherePos.y = 10.0 * sin(phi) * sin(lambda);
        spherePos.z = 10.0 * cos(phi);
        sacredPos = spherePos;
    }
    // SHAPE 2: THE TORUS (Infinite/Flow) - Energy 0 & 3
    else if (uEnergyState == 0 || uEnergyState == 3) {
        float tubeRadius = 3.0;
        float ringRadius = 8.0;
        float u = aRandom.x * 6.28; // Ring angle
        float v = aRandom.y * 6.28; // Tube angle
        
        vec3 torusPos;
        torusPos.x = (ringRadius + tubeRadius * cos(v)) * cos(u);
        torusPos.y = (ringRadius + tubeRadius * cos(v)) * sin(u);
        torusPos.z = tubeRadius * sin(v);
        
        // Add twist
        float twist = uTime * 0.2;
        float tx = torusPos.x * cos(twist) - torusPos.y * sin(twist);
        float ty = torusPos.x * sin(twist) + torusPos.y * cos(twist);
        torusPos.x = tx; 
        torusPos.y = ty;
        
        sacredPos = torusPos;
    }
    // SHAPE 3: THE SUN (Warmth) - Energy 1
    // "Sphere (Boiling)"
    else if (uEnergyState == 1) {
        // Base Sphere
        float phi = acos(1.0 - 2.0 * aRandom.x);
        float lambda = sqrt(3.1415 * 50.0) * phi;
        
        vec3 sunPos;
        float r = 10.0;
        // Boiling Noise
        float boil = sin(uTime * 5.0 + aRandom.y * 20.0) * 0.5 + sin(uTime * 2.0 + aRandom.z * 10.0) * 1.5;
        r += boil;
        
        sunPos.x = r * sin(phi) * cos(lambda);
        sunPos.y = r * sin(phi) * sin(lambda);
        sunPos.z = r * cos(phi);
        sacredPos = sunPos;
    }
    // SHAPE 4: THE NEBULA (Uplifting) - Energy 2
    // "Cloud (Burst)"
    else if (uEnergyState == 2) {
        // Explosive outward burst
        // Start with spiral/sphere base but explode it
        vec3 cloudPos = basePos;
        
        // Expansion logic
        float burst = 2.0 + sin(uTime + aRandom.x * 10.0);
        // Distribute randomly in a volume
        float r = aRandom.x * 20.0;
        float theta = aRandom.y * 3.1415 * 2.0;
        float phi = aRandom.z * 3.1415;
        
        cloudPos.x = r * sin(phi) * cos(theta);
        cloudPos.y = r * sin(phi) * sin(theta);
        cloudPos.z = r * cos(phi);
        
        // Add turbulence
        cloudPos += vec3(
            sin(uTime + aRandom.y * 10.0),
            cos(uTime + aRandom.z * 10.0),
            sin(uTime + aRandom.x * 10.0)
        ) * 3.0;
        
        sacredPos = cloudPos;
    }
    // SHAPE 5: THE MERKABA (Deep Heal) - Energy 5 & Others
    else {
        // Geometric Crystal Form
        // FIXED: Previously used 'basePos' which made it flat. Now uses 'aRandom' for full 3D.
        
        // 1. Random Direction (Spherical)
        float u = aRandom.x * 6.28;
        float v = aRandom.y * 3.14 - 1.57; // -pi/2 to pi/2
        vec3 dir = vec3(cos(v)*cos(u), cos(v)*sin(u), sin(v));
        
        // 2. Shaping (Crystal Spikes)
        // We modulate the radius to create "Points"
        // Simple "Star" modulation
        float spike = abs(dir.x) + abs(dir.y) + abs(dir.z); // Octahedral distance
        float r = 8.0 + (spike - 1.0) * 4.0; 
        
        // Add some breathing noise to the shape
        r += sin(uTime * 2.0 + aRandom.z * 10.0) * 0.5;
        
        vec3 crystal = dir * r;
        
        // Macroscopic rotation
        float rot = uTime * 0.1;
        float cx = crystal.x * cos(rot) - crystal.z * sin(rot);
        float cz = crystal.x * sin(rot) + crystal.z * cos(rot);
        crystal.x = cx; crystal.z = cz;
        
        sacredPos = crystal;
    }

    // 3. STATE "KONG" & "HUAI" (Release State - The Void)
    vec3 originPos = basePos;
    
    // Fix Bias: Use isotropic noise (not diagonal)
    originPos.x = radius * cos(finalAngle);
    originPos.y = radius * sin(finalAngle);
    
    // Expansion
    float expansion = mix(2.5, 1.0, tension);
    originPos.xy *= expansion;
    
    // Entropy (Decay) with NO BIAS 2.0
    // Previous "Spatial Noise" caused directional drift.
    // Now we use "Local Random" that simply oscillates in place.
    float entropy = (1.0 - tension); 
    
    // Local chaos: Each particle jitters in its own sphere, centered on its orbit.
    // No global wind means no global drift.
    float chaosX = sin(uTime * 1.0 + aRandom.x * 100.0) * 10.0;
    float chaosY = cos(uTime * 0.8 + aRandom.y * 100.0) * 10.0;
    
    originPos.x += chaosX * entropy;
    originPos.y += chaosY * entropy;
    originPos.z += (aRandom.y - 0.5) * 50.0 * entropy; 

    // 4. THE BLEND
    // Inhale (Tension 1.0) -> Sacred Geometry
    // Exhale (Tension 0.0) -> Void Spiral
    vec3 targetPos = sacredPos;
    
    // For default states (Spiral), we keep the original logic if needed,
    // but the user wants "Sacred Geometry on Hold".
    // Let's make "sacredPos" the dominant form for high tension.
    
    float formFactor = smoothstep(0.0, 1.0, tension);
    pos = mix(originPos, targetPos, formFactor);

    // 5. Multi-Core Pull
    // DISABLE gravity when Sacred Shape is fully formed to preserve symmetry
    // Gravity only affects the "Liquid/Chaos" phase (formFactor < 0.8)
    float gravityFade = smoothstep(1.0, 0.5, formFactor); // 1.0 at loose, 0.0 at formed
    
    for(int i = 0; i < 3; i++) {
        vec2 focus = uFocusPoints[i];
        float weight = uFocusWeights[i];
        if (weight <= 0.0) continue;
        
        vec2 d = focus - pos.xy;
        float dist = length(d);
        // Reduced pull strength 
        float pull = (10.0 / (dist + 2.0)) * weight * formFactor * gravityFade;
        
        pos.xy += normalize(d) * pull;
    }
    
    // Z-Axis Wobble (Dampen when formed)
    pos.z += sin(finalAngle * 2.0 + t) * (radius * 0.15) * (1.0 - formFactor);

    vStateIntensity = 0.5 + (speedBase * 20.0); // Normalized intensity
    
    // 6. COSMIC RESONANCE (The Ripple / 涟漪)
    // "Thought is a stone thrown into the lake of mind."
    
    // FIXED: Aspect Ratio Correction
    vec2 mPos = (uMouse - 0.5) * vec2(60.0, 35.0); 
    float mDist = distance(pos.xy, mPos);
    
    // Ripple Physics
    // Range: Reduced from 8.0 to 5.0 (Finger-tip precision)
    float rippleRadius = 5.0;
    float rippleNorm = smoothstep(rippleRadius, 0.0, mDist); // 1.0 at center, 0.0 at edge
    
    // Wave Equation: sin(k * r - w * t)
    // Frequency: 2.0 (Spacing of rings)
    // Speed: 5.0 (Speed of outward travel)
    float wave = sin(mDist * 2.0 - uTime * 5.0); // -1 to 1
    
    // Amplitude decay: Waves get smaller as they go out
    float amplitude = rippleNorm * 3.0; // Max height 3.0
    
    // Apply Wave to Z-axis
    pos.z += wave * amplitude;
    
    // 7. OUTPUTS
    vec4 mvPosition = modelViewMatrix * vec4(pos, 1.0);
    vViewDepth = -mvPosition.z;

    float baseSize = aSize * (uEnergyState == 0 ? 3.5 : 5.0); 
    
    // Ripple Peak Highlight
    // wave is -1 to 1. wave > 0.8 means a peak.
    float peaks = smoothstep(0.4, 1.0, wave) * rippleNorm;
    
    // Size Boost at peaks (Reduced from 0.8 to 0.3)
    // Subtle physical swell, not an explosion.
    float sizeBoost = 1.0 + peaks * 0.3;
    
    gl_PointSize = baseSize * (350.0 / vViewDepth) * sizeBoost;
    gl_PointSize = max(gl_PointSize, 2.0);
    
    gl_Position = projectionMatrix * mvPosition;

    // 8. COLOR & ALPHA LOGIC
    vec3 color = vec3(1.0);
    float stateAlpha = 1.0;
    
    // COLOR BALANCING: Standardized
    if (uEnergyState == 0) { // INFINITE
        color = mix(vec3(0.5, 0.9, 1.0), vec3(1.0, 1.0, 1.0), aRandom.x);
        stateAlpha = 0.4;
    } else if (uEnergyState == 1) { // WARMTH
        color = mix(vec3(1.0, 0.3, 0.1), vec3(1.0, 0.8, 0.4), aRandom.x);
        stateAlpha = 0.3; 
    } else if (uEnergyState == 2) { // UPLIFTING
        color = mix(vec3(0.9, 0.1, 0.5), vec3(1.0, 0.8, 0.9), aRandom.x); 
        stateAlpha = 0.25; 
    } else if (uEnergyState == 3) { // UNIVERSAL
        color = mix(vec3(0.1, 0.3, 0.9), vec3(0.6, 0.2, 1.0), aRandom.x);
        stateAlpha = 0.25; 
    } else if (uEnergyState == 4) { // VITAL
        color = mix(vec3(0.3, 0.8, 0.5), vec3(0.7, 1.0, 0.8), aRandom.x);
        stateAlpha = 0.25; 
    } else if (uEnergyState == 5) { // DEEP HEAL
        color = mix(vec3(0.1, 0.2, 0.8), vec3(0.3, 0.6, 1.0), aRandom.x); 
        stateAlpha = 0.4; 
    }
    
    // --- POLISH 1: VELOCITY TEMPERATURE ---
    float velocityHeat = smoothstep(0.0, 2.0, kepler); 
    color = mix(color, vec3(1.0, 0.95, 0.9), velocityHeat * 0.15); 
    
    // --- COSMIC RESONANCE COLOR MIX ---
    // REMOVED: No Color Enhancement at peaks.
    // color = mix(color, vec3(1.0), peaks * 0.3); 
    
    vColor = color;
    
    // DENSITY COMPENSATION (Restored to Global 45.0)
    // "The Sunglass Effect" - Standardized physics.
    float densityComp = 1.0 / (1.0 + tension * 45.0);
    float releaseFade = mix(0.4, 1.0, smoothstep(0.0, 0.3, tension));
    
    // Base Alpha Calculation
    vAlpha = stateAlpha * densityComp * releaseFade;
    
    // Cap Alpha STRICTLY
    vAlpha = min(vAlpha, 0.5); 
    
    // --- RESONANCE OVERRIDE ---
    // REMOVED: No Opacity Enhancement at peaks.
    // vAlpha = max(vAlpha, peaks * 0.2);
    
    // Breathing Stars
    float pulse = sin(uTime * 2.0 + aRandom.x * 20.0) * 0.5 + 0.5; 
    vAlpha *= (0.7 + 0.3 * pulse);
    gl_PointSize *= (0.9 + 0.2 * pulse);
    
    vTwinkleRandom = aRandom.z;
}
