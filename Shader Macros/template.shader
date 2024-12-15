let shader = new PIXI.Filter(null, `
    //Foundry Definitions
    precision mediump float;
    varying vec2 vTextureCoord;
    uniform sampler2D uSampler;
    uniform vec2 filterArea;
    //User Definitions
    uniform float time;
   

    void main(void) {
        vec2 uv = vTextureCoord;
        vec2 px = vec2(1.0 / filterArea.x, 1.0 / filterArea.y);
        vec2 center = vec2(0.5, 0.5);
        float distanceFromCenter = distance(center, uv);
        vec4 finalColor = texture2D(uSampler, vTextureCoord);
        
        //write the final image
        gl_FragColor = vec4(finalColor.rgb, 1.0);
    }
`);

let time = 0;
canvas.app.ticker.add((delta) => {
    time += delta;
    shader.uniforms.time = time;
});
shader.uniforms.filterArea = [canvas.app.renderer.width, canvas.app.renderer.height];
canvas.app.stage.filters = [shader];