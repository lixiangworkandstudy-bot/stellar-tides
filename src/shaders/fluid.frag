
uniform float uTime;
uniform float uSpeed;
uniform vec2 uResolution;
uniform vec3 uBaseColor;
uniform vec3 uAccentColor;
uniform float uBreath;
uniform vec2 uMouse;

varying vec2 vUv;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
    float v = 0.0;
    float a = 0.5;
    vec2 shift = vec2(100.0);
    for (int i = 0; i < 5; ++i) {
        v += a * noise(p);
        p = p * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

void main() {
    vec2 p = vUv * 3.0;
    
    float dist = distance(vUv, uMouse);
    float mouseInfluence = smoothstep(0.4, 0.0, dist) * 0.5;
    
    float time = uTime * uSpeed * (1.0 + uBreath * 0.5);
    
    vec2 q = vec2(
        fbm(p + vec2(0.0, 0.0) + time * 0.1),
        fbm(p + vec2(5.2, 1.3) + time * 0.15)
    );
    
    vec2 r = vec2(
        fbm(p + 4.0 * q + vec2(1.7, 9.2) + time * 0.05),
        fbm(p + 4.0 * q + vec2(8.3, 2.8) + time * 0.08)
    );
    
    float f = fbm(p + 4.0 * r + mouseInfluence);
    
    vec3 color = mix(uBaseColor, uAccentColor, clamp(f * f * 4.0, 0.0, 1.0));
    color = mix(color, uAccentColor * 1.5, clamp(length(q), 0.0, 1.0) * 0.2);
    
    color *= (0.8 + uBreath * 0.4);
    
    float vignette = smoothstep(1.5, 0.5, length(vUv - 0.5));
    color *= vignette;

    gl_FragColor = vec4(color, 1.0);
}
