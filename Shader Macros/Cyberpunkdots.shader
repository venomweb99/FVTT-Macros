let shader = new PIXI.Filter(null, `
    uniform vec2 resolution;
    uniform sampler2D uSampler;
    uniform float random;
    uniform float dradius;
    uniform float dgridSize;
    uniform float radius;
    uniform float time;
    
    varying vec2 vTextureCoord;

    void main() {
        float gridSize = dgridSize;
        
        float bloomIntensity = 2.5 ;

        vec2 uv = gl_FragCoord.xy / resolution;
        vec2 gridPosition = floor(uv * resolution / gridSize);
        vec2 gridUV = fract(uv * resolution / gridSize);
        
        
        
        float radius = dradius + sin(time)*0.5 * mod(gridPosition.x, 3.0) + 0.1 *mod(gridPosition.y, 3.0);
        
        vec4 color = texture2D(uSampler, vTextureCoord);
        
        // Calculate distance from the center of the grid cell
        float dist = distance(gridUV, vec2(0.5));

        if (dist > radius / gridSize) {
            color = vec4(0.0, 0.0, 0.0, 1.0);
        } else {
            float luminosity = 0.3 * color.r + 0.59 * color.g + 0.11 * color.b;
            color = vec4(luminosity * 1.0, luminosity * luminosity * 0.9, luminosity * luminosity, 1.0);

            // Add bloom effect
            color.rgb *= bloomIntensity;

            // Add circular gradient fade to black
            float gradient = smoothstep(0.0, radius / gridSize, dist);
            color.rgb *= (1.0 - gradient); // Invert the gradient
        }
        
        gl_FragColor = color;
    }
`);

shader.uniforms.dgridSize = 8;
shader.uniforms.dradius = 4.0;
shader.uniforms.resolution = [canvas.app.renderer.width, canvas.app.renderer.height];

let time = 0;

canvas.app.ticker.add((delta) => {
    time += delta;
    shader.uniforms.time = time / 20; // Adjust this value to control the speed of the wiggle
     
    
    
});

canvas.app.stage.filters = [shader];