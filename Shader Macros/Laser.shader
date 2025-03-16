let shader = new PIXI.Filter(null, `
    precision mediump float;
    varying vec2 vTextureCoord;
    uniform sampler2D uSampler;
    uniform vec2 filterArea;
    uniform float time;
    
    uniform vec3 color;
    uniform vec3 particleColor;
    uniform float size;
    uniform float angle;
    uniform float smoothness;
    uniform float coreSize;
    uniform float vibrationIntensity;
    uniform float pulseSpeed;
    uniform float pulseIntensity;  // Now directly controls size variation
    uniform float particleDensity;
    uniform float particleSize;
    uniform float particleSpeed;

    float hash(float n) { return fract(sin(n) * 43758.5453); }
    float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898,78.233))) * 43758.5453); }

    void main(void) {
        vec2 uv = vTextureCoord;
        vec2 center = vec2(0.5);
        vec4 originalColor = texture2D(uSampler, uv);
        
        // Beam calculations with controlled size variation
        float angleRad = radians(angle) + hash(time * 8.0) * vibrationIntensity * 0.01;
        vec2 dir = vec2(cos(angleRad), sin(angleRad));
        vec2 normal = vec2(-dir.y, dir.x);
        vec2 toUV = uv - center;
        float dist = abs(dot(toUV, normal));
        
        // Size animation with constrained variation
        float pulse = sin(time * pulseSpeed) * pulseIntensity * 0.5;  // Reduced impact
        float animatedSize = size * (1.0 + pulse);
        float beamRadius = clamp(animatedSize / 2.0, size * 0.4, size * 0.6); // Hard limits
        
        float beamMask = 1.0 - smoothstep(beamRadius - smoothness, beamRadius + smoothness, dist);
        
        // Core gradient
        float core = coreSize * beamRadius;
        float t = smoothstep(core, beamRadius, dist);
        vec3 beamColor = mix(vec3(1.0), color, t);
        
        // Particle system
        float alongBeam = dot(toUV, dir);
        float flowTime = time * particleSpeed;
        vec2 particleUV = vec2(
            alongBeam * 25.0 + flowTime,
            dot(toUV, normal) * 100.0
        );
        
        float particleNoise = hash(vec2(floor(particleUV.x), floor(particleUV.y)));
        float particleFlow = fract(particleUV.x + particleNoise);
        
        float particles = smoothstep(0.7, 1.0, particleNoise) *
                         exp(-abs(particleUV.y) * 0.8) * 
                         smoothstep(0.3, 0.0, particleFlow) *
                         (1.0 - smoothstep(0.0, 0.15, particleFlow));
        
        particles *= particleDensity * 
                    smoothstep(beamRadius * 1.1, beamRadius * 0.9, dist) * 
                    particleSize;
        
        float subtleParticles = sin(particleUV.x * 35.0 + time * 12.0) * 0.12;
        subtleParticles = smoothstep(0.35, 0.4, subtleParticles) * 
                         (1.0 - smoothstep(0.4, 0.45, subtleParticles));
        
        // Final colors
        vec3 mainParticles = particles * mix(particleColor, vec3(1.0), 0.25);
        vec3 subParticles = subtleParticles * particleColor * 0.4;
        vec3 finalColor = mix(originalColor.rgb, beamColor, beamMask);
        finalColor += mainParticles + subParticles;
        
        gl_FragColor = vec4(finalColor, originalColor.a);
    }
`);

// Initialize uniforms
shader.uniforms.color = [0.1, 0.9, 1.0];      // Beam color
shader.uniforms.particleColor = [0.0, 1.0, 0.0];  // Particle color
shader.uniforms.size = 0.35;                  // Base size (0.01-0.15)
shader.uniforms.angle = Math.floor(Math.random() * (180 - 0 + 1) + 0);                 // Direction
shader.uniforms.smoothness = 0.04;           // Edge softness
shader.uniforms.coreSize = 0.35;              // White core size
shader.uniforms.vibrationIntensity = 2.18;     // Shake amount
shader.uniforms.pulseSpeed = 0.87;             // Pulse speed
shader.uniforms.pulseIntensity = 0.15;        // Size variation (0-0.3)
shader.uniforms.particleDensity = 16.7;        // Particle amount
shader.uniforms.particleSize = 24.0;           // Particle scale
shader.uniforms.particleSpeed = 0.17;          // Flow speed

// Animation system
let time = 0;
canvas.app.ticker.add((delta) => {
    time += delta;
    shader.uniforms.time = time;
    
    // Natural vibration decay
    if(shader.uniforms.vibrationIntensity > 0.05) {
        shader.uniforms.vibrationIntensity *= 0.987;
    }

    //as times goes on size decreases
    if( time > 200 && shader.uniforms.size > -0.05) {
        shader.uniforms.size -= 0.05;
    }

    if(time > 200 && shader.uniforms.particleSize > 0.0) {
        shader.uniforms.particleSize *= 0.9;
        shader.uniforms.particleDensity *= 0.9;
    }
    
});

shader.uniforms.filterArea = [canvas.app.renderer.width, canvas.app.renderer.height];
canvas.app.stage.filters = [shader];