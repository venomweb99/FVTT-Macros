let shader = new PIXI.Filter(null, `
    precision mediump float;

    varying vec2 vTextureCoord;
    uniform sampler2D uSampler;
    uniform float time;
    uniform float distance;
    uniform float speed;

    void main(void)
    {
        vec2 uv = vTextureCoord;
        vec4 color;
        float aberration = distance * abs(sin(time));
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
    shader.uniforms.time = time / 10; // Adjust this value to control the speed of the wiggle
});


shader.uniforms.distance = 0.001;


canvas.app.stage.filters = [shader];