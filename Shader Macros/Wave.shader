let shader = new PIXI.Filter(null, `
    precision mediump float;
    varying vec2 vTextureCoord;
    uniform sampler2D uSampler;
    uniform float time;
    uniform float distance;
    uniform float amplitude;
    uniform float wavelength;
    uniform vec3 wavecolor;
    uniform vec2 resolution;
    uniform float opacity;
    uniform float speedmult;
    uniform float distance2;
    uniform float amplitude2;
    uniform float wavelength2;
    uniform vec3 wavecolor2;
    uniform float opacity2;
    uniform float speedmult2;
    uniform float distance3;
    uniform float amplitude3;
    uniform float wavelength3;
    uniform vec3 wavecolor3;
    uniform float opacity3;
    uniform float speedmult3;


    void main(void)
    {
        vec2 uv = vTextureCoord;
        vec4 color;
        if(uv.y > distance3){
            color = texture2D(uSampler, uv);
            color = mix(color, vec4(wavecolor3, 1.0), opacity3);
        }
        else if(uv.y <= distance3 && uv.y > distance3 - amplitude3){
            //Wave 3
            float wavelengthcenter3 = wavelength3 / 2.0;
            float xmodulo3 = mod(uv.x, wavelength3);
            float speed3 = time*speedmult3;
            xmodulo3 = xmodulo3 + speed3;
            if(xmodulo3 > wavelength3){
                xmodulo3 = xmodulo3 - wavelength3;
            }
            float ycenter3 = amplitude3 / 2.0;
            float ywave3 = sin(xmodulo3 * 3.1415926535897932384626433832795 / wavelengthcenter3) * amplitude3 / 2.0;
            ywave3 = ywave3 + ycenter3;
            if(uv.y > distance3 - ywave3){
                color = texture2D(uSampler, uv);
                color = mix(color, vec4(wavecolor3, 1.0), opacity3);
            }
            else{
                color = texture2D(uSampler, uv);
            }
        }
        else{
            color = texture2D(uSampler, uv);
        }

        if(uv.y > distance2){
            color = texture2D(uSampler, uv);
            color = mix(color, vec4(wavecolor2, 1.0), opacity2);
        }
        else if(uv.y <= distance2 && uv.y > distance2 - amplitude2){
            //Wave 2
            float wavelengthcenter2 = wavelength2 / 2.0;
            float xmodulo2 = mod(uv.x, wavelength2);
            float speed2 = time*speedmult2;
            xmodulo2 = xmodulo2 + speed2;
            if(xmodulo2 > wavelength2){
                xmodulo2 = xmodulo2 - wavelength2;
            }
            float ycenter2 = amplitude2 / 2.0;
            float ywave2 = sin(xmodulo2 * 3.1415926535897932384626433832795 / wavelengthcenter2) * amplitude2 / 2.0;
            ywave2 = ywave2 + ycenter2;
            if(uv.y > distance2 - ywave2){
                color = texture2D(uSampler, uv);
                color = mix(color, vec4(wavecolor2, 1.0), opacity2);
            }
            else{
                //color = texture2D(uSampler, uv);
            }
        }
        else{
            //color = texture2D(uSampler, uv);
        }

        if(uv.y > distance){
            color = texture2D(uSampler, uv);
            color = mix(color, vec4(wavecolor, 1.0), opacity);
        }
        else if(uv.y <= distance && uv.y > distance - amplitude){
            //Wave 1
            float wavelengthcenter = wavelength / 2.0;
            float xmodulo = mod(uv.x, wavelength);
            xmodulo = xmodulo + time*speedmult;
            if(xmodulo > wavelength){
                xmodulo = xmodulo - wavelength;
            }
            float ycenter = amplitude / 2.0;
            float ywave = sin(xmodulo * 3.1415926535897932384626433832795 / wavelengthcenter) * amplitude / 2.0;
            ywave = ywave + ycenter;
            if(uv.y > distance - ywave){
                color = texture2D(uSampler, uv);
                color = mix(color, vec4(wavecolor, 1.0), opacity);
            }
            else{
                //color = texture2D(uSampler, uv);
            }
        }
        else{
            //color = texture2D(uSampler, uv);
        }
        gl_FragColor = color;
    }
`);

let time = 0;

canvas.app.ticker.add((delta) => { 
    time += delta;
    shader.uniforms.time = time / 30;
});


shader.uniforms.distance = 0.8;
shader.uniforms.amplitude = 0.1;
shader.uniforms.wavelength = 0.7;
shader.uniforms.resolution = [canvas.app.renderer.width, canvas.app.renderer.height];
shader.uniforms.wavecolor = [0.21, 0.16, 0.22];
shader.uniforms.opacity = 0.99;
shader.uniforms.speedmult = 0.03;

shader.uniforms.distance2 = 0.77;
shader.uniforms.amplitude2 = 0.15;
shader.uniforms.wavelength2 = 0.8;
shader.uniforms.wavecolor2 = [0.44, 0.23, 0.37];
shader.uniforms.opacity2 = 0.75;
shader.uniforms.speedmult2 = 0.05;

shader.uniforms.distance3 = 0.75;
shader.uniforms.amplitude3 = 0.2;
shader.uniforms.wavelength3 = 0.9;
shader.uniforms.wavecolor3 = [0.66, 0.3, 0.5];
shader.uniforms.opacity3 = 0.5;
shader.uniforms.speedmult3 = 0.07;



canvas.app.stage.filters = [shader];