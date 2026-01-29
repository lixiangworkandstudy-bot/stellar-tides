
varying vec3 vColor;
varying float vAlpha;
varying float vViewDepth;
varying float vStateIntensity;
varying float vSpeed;
varying float vTwinkleRandom;

uniform float uTime;

vec3 aces(vec3 x) {
  const float a = 2.51;
  const float b = 0.03;
  const float c = 2.43;
  const float d = 0.59;
  const float e = 0.14;
  return clamp((x * (a * x + b)) / (x * (c * x + d) + e), 0.0, 1.0);
}

void main() {
    vec2 uv = gl_PointCoord - vec2(0.5);
    float dist = length(uv);
    
    if (dist > 0.5) discard;
    
    // --- RESTORED VISIBILITY & AESTHETIC ---
    // 1. Core: Diamond-like but WIDER
    // Problem: 0.25 was too small -> invisible on screen
    // Solution: 0.45 covers almost the whole point sprite
    
    // --- BALANCED VISIBILITY (Restore Glow) ---
    // 1. Core: Defined center
    float radius = 0.45;
    float normDist = clamp(dist / radius, 0.0, 1.0);
    float core = pow(1.0 - normDist, 4.0); 
    
    // 2. Glow: Soft atmosphere (Restored & Widened)
    // Reduce decay from 5.0 to 3.5 for a wider halo (Dreamy look)
    float glow = exp(-dist * 3.5) * 0.45; 
    
    // Composite: Core + Glow
    float light = core + glow;
    
    // Color
    vec3 baseColor = vColor;
    // RESTORE WHITE CORE: Adds the "Crystal/Star" clarity back
    vec3 finalColor = mix(baseColor, vec3(1.0), core * 0.8); 
    
    // Alpha
    // Linear alpha (Safe)
    float finalAlpha = vAlpha * light;
    finalAlpha = min(finalAlpha, 1.0);
    
    // Twinkle integration
    // Twinkle integration
    // Slower, more hypnotic twinkle.
    float twinkle = 0.7 + 0.3 * sin(uTime * 2.0 + vTwinkleRandom * 20.0);
    finalAlpha *= twinkle;
    
    finalColor = aces(finalColor);
    finalColor = clamp(finalColor, 0.0, 1.0);
    finalAlpha = clamp(finalAlpha, 0.0, 1.0);

    gl_FragColor = vec4(finalColor, finalAlpha);
}
