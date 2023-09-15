let shader = new PIXI.Filter(null, `
varying vec2 vTextureCoord;
uniform sampler2D uSampler;

uniform vec4 filterArea;
uniform vec4 filterClamp;
uniform vec2 dimensions;
uniform float aspect;

uniform sampler2D displacementMap;
uniform float offset;
uniform float sinDir ;
uniform float cosDir;

uniform float seed;
uniform vec2 red;
uniform vec2 green;
uniform vec2 blue;

uniform float numSlices;

void main(void)
{
   
   vec2 coord = vTextureCoord;

    if (coord.x > 1.0 || coord.y > 1.0) {
        gl_FragColor = vec4(0.0);
        return;
    }

    float cx = coord.x - 0.5;
    float cy = (coord.y - 0.5) * aspect;
    float ny = (-sinDir * cx + cosDir * cy);

    // Calculate the quantized ny value
    float nyQuantized = fract(ny * float(numSlices));

    // Calculate the slice width
    float sliceWidth = 1.0 / float(numSlices);

    vec4 dc = texture2D(displacementMap, vec2(0.5, nyQuantized));

    float displacement = (dc.r - dc.g) * (offset / filterArea.x);

    // Adjust the coordinate based on the slice width
    coord.x += cosDir * displacement * sliceWidth;
    coord.y = clamp(coord.y, 0.0, 1.0);

    gl_FragColor.r = texture2D(uSampler, coord + red * (1.0 - seed * 0.4) / filterArea.xy).r;
    gl_FragColor.g = texture2D(uSampler, coord + green * (1.0 - seed * 0.3) / filterArea.xy).g;
    gl_FragColor.b = texture2D(uSampler, coord + blue * (1.0 - seed * 0.2) / filterArea.xy).b;
    gl_FragColor.a = texture2D(uSampler, coord).a;
    
    
    
}
`);

shader.uniforms.dimensions = [canvas.app.renderer.width,canvas.app.renderer.width];
shader.uniforms.aspect = canvas.app.renderer.width/canvas.app.renderer.width;
shader.uniforms.filterArea = [canvas.app.renderer.width, canvas.app.renderer.width];
shader.uniforms.offset = 100;
shader.uniforms.sinDir = 1;
shader.uniforms.cosDir = 0.5;
shader.uniforms.seed = 1;
shader.uniforms.red = [4.0, 4.0];
shader.uniforms.green = [0.0, 0.0];
shader.uniforms.blue = [0.0, 0.0];
shader.uniforms.numSlices = 0.33;

let time = 0;
let loopduration = 0.3;
let speed=22000;
let mult=1;
let targetCosDir= 0.7;

canvas.app.ticker.add((delta) => {
    time+=delta%1;
    shader.uniforms.sinDir += time/speed*mult;
    if(shader.uniforms.sinDir > targetCosDir+loopduration){
        mult=-1;
        time=0;
    }
    if(shader.uniforms.sinDir < targetCosDir){
        shader.uniforms.sinDir=targetCosDir;
        mult=1;
        time=0;
    }
    
});







canvas.app.stage.filters = [shader];