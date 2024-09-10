let shaderCode = `
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
    uniform float alarm;

    vec4 applyGridEffect(vec2 fragCoord) {
        float bloomIntensity = 3.0;
        float gridSize = dgridSize;
        vec2 uv = fragCoord / resolution;
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
            color = vec4(luminosity, 
                         luminosity * luminosity * luminosity - 0.2, 
                         (0.1 + 0.6 * luminosity) * luminosity - 0.1, 1.0);

            // Add bloom effect
            color.rgb *= bloomIntensity;

            // Add circular gradient fade to black
            float gradient = smoothstep(0.0, radius / gridSize, dist);
            color.rgb *= (1.0 - gradient); // Invert the gradient
        }
        return color;
    }

    void main() {
        vec2 fragCoord = gl_FragCoord.xy;
        gl_FragColor = applyGridEffect(fragCoord); // Using the extracted function here
    }
`;

let shader = new PIXI.Filter(null, shaderCode, {
    resolution: [canvas.app.renderer.width, canvas.app.renderer.height],
    dgridSize: 7,
    dradius: 10,
});

let time = 0;
let randomn = 1;
let frameCount = 0;
let alarm = 1;
let speed = 10;

canvas.app.ticker.add((delta) => {
    time += delta;
    shader.uniforms.time = time / 20; // Adjust this value to control the speed of the wiggle
    frameCount++;
    if (frameCount >= speed) {
        randomn = Math.random();
        frameCount = 0;
        alarm += speed / 60;
    }
    if (alarm >= 2) {
        alarm = 1;
    }
    shader.uniforms.random = randomn;
    shader.uniforms.randomw = randomn * canvas.app.renderer.width;
    shader.uniforms.randomh = randomn * canvas.app.renderer.height;
    shader.uniforms.alarm = alarm;
});

canvas.app.stage.filters = [shader];
