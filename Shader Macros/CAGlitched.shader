let shader = new PIXI.Filter(null, `
    precision mediump float;

    varying vec2 vTextureCoord;
    uniform sampler2D uSampler;
    uniform float time;
    uniform float distance;
    uniform float speed;
    uniform float cut1;
    uniform float cut2;
    uniform float offset1;
    uniform float offset2;

    void main(void)
    {
        vec2 uv = vTextureCoord;
        vec4 color;
        float aberration;
        if (uv.y < cut1) {
            aberration = distance * abs(sin(time)) * offset1;
        } else if (uv.y < cut2) {
            aberration = distance * abs(sin(time)) * offset2;
        } else {
            aberration = distance * abs(sin(time));
        }
        color.r = texture2D(uSampler, vec2(uv.x + aberration, uv.y)).r;
        color.g = texture2D(uSampler, vec2(uv.x, uv.y)).g;
        color.b = texture2D(uSampler, vec2(uv.x - aberration, uv.y)).b;
        color.a = 1.0;
        gl_FragColor = color;
    }
`);

let time = 0;

canvas.app.ticker.add((delta) => {
    time += delta;
    shader.uniforms.time = time / 1; // Adjust this value to control the speed of the wiggle
});

shader.uniforms.distance = 0.002;
shader.uniforms.cut1 = 0.3; // Adjust this value to control the first cut-off point
shader.uniforms.cut2 = 0.8; // Adjust this value to control the second cut-off point
shader.uniforms.offset1 = -3.5; // Adjust this value to control the offset after the first cut-off point
shader.uniforms.offset2 = 6.0; // Adjust this value to control the offset after the second cut-off point

canvas.app.stage.filters = [shader];