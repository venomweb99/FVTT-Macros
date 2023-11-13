let shader = new PIXI.Filter(null, `
    uniform vec2 resolution;
    varying vec2 vTextureCoord;
    uniform sampler2D uSampler;
    uniform float random;
    uniform float randomw;
    uniform float randomh;
    uniform float dradius;
    uniform float dgridSize;
    uniform float radius;
    uniform float time;
    uniform float time2;
    uniform float alarm;
    uniform float distan;
    uniform float speed;
    uniform float cut1;
    uniform float cut2;
    uniform float offset1;
    uniform float offset2;
    void main() {
        float bloomIntensity = 3.0;
        float gridSize = dgridSize;
        vec2 uv = gl_FragCoord.xy / resolution;
        vec2 gridPosition = floor(uv * resolution / gridSize);
        vec2 gridUV = fract(uv * resolution / gridSize);
        vec4 color = texture2D(uSampler, vTextureCoord);
        float luminosity = 0.3 * color.r + 0.59 * color.g + 0.11 * color.b;
        float radius = dradius * luminosity * (luminosity * 0.5 + 0.5);
        
        // Calculate distance from the center of the grid cell
        float dist = distance(gridUV, vec2(0.5));

        if (dist > radius / gridSize) {
            color = vec4(0.0, 0.0, 0.0, 1.0);
        } else {
            
            color = vec4(luminosity , luminosity * luminosity * luminosity -0.2, (0.1 + 0.6 * luminosity) * luminosity - 0.1, 1.0);

            // Add bloom effect
            color.rgb *= bloomIntensity;

            // Add circular gradient fade to black
            float gradient = smoothstep(0.0, radius / gridSize, dist);
            color.rgb *= (1.0 - gradient); // Invert the gradient
        }
        
        float aberration;
        if (uv.y < cut1) {
            aberration = distan * abs(sin(time2)) * offset1;
        } else if (uv.y < cut2) {
            aberration = distan * abs(sin(time2)) * offset2;
        } else {
            aberration = distan * abs(sin(time2));
        }
        
        vec4 originalColor;
    originalColor.r = texture2D(uSampler, vec2(vTextureCoord.x + aberration, vTextureCoord.y)).r;
    originalColor.g = texture2D(uSampler, vec2(vTextureCoord.x, vTextureCoord.y)).g;
    originalColor.b = texture2D(uSampler, vec2(vTextureCoord.x - aberration, vTextureCoord.y)).b;
    originalColor.a = 1.0;

    vec4 finalColor;
    if (dist > radius / gridSize) {
        finalColor = vec4(0.0, 0.0, 0.0, 1.0);
    } else {
        finalColor = vec4(luminosity , luminosity * luminosity * luminosity -0.2, (0.1 + 0.6 * luminosity) * luminosity - 0.1, 1.0) * originalColor;

        // Add bloom effect
        finalColor.rgb *= bloomIntensity;

        // Add circular gradient fade to black
        float gradient = smoothstep(0.0, radius / gridSize, dist);
        finalColor.rgb *= (1.0 - gradient); // Invert the gradient
    }

        gl_FragColor = finalColor;
    }
`);

shader.uniforms.dgridSize = 7;
shader.uniforms.dradius = 10;
shader.uniforms.resolution = [canvas.app.renderer.width, canvas.app.renderer.height];
shader.uniforms.distan = 0.02;
shader.uniforms.cut1 = 0.3; // Adjust this value to control the first cut-off point
shader.uniforms.cut2 = 0.7; // Adjust this value to control the second cut-off point
shader.uniforms.offset1 = -3.5; // Adjust this value to control the offset after the first cut-off point
shader.uniforms.offset2 = 6.0;

let time = 0;
let randomn = 1;
let frameCount = 0;
let alarm = 1;
let speed=10;

canvas.app.ticker.add((delta) => {
    time += delta;
    shader.uniforms.time = time / 20; // Adjust this value to control the speed of the wiggle
    shader.uniforms.time2 = time / 1;
    frameCount++;
    if(frameCount >= speed){
        randomn = Math.random();
        frameCount = 0;
        alarm+= speed/60;
    }
    if(alarm>=2){
        alarm = 1;
    }
    shader.uniforms.random = randomn;
    shader.uniforms.randomw = randomn * canvas.app.renderer.width;
    shader.uniforms.randomh = randomn * canvas.app.renderer.height;
    shader.uniforms.alarm = alarm;
});

canvas.app.stage.filters = [shader];