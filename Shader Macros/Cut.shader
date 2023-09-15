let shader = new PIXI.Filter(null, `
precision mediump float;
uniform float centerX;
uniform float centerY;
uniform float angle;
uniform float angle2;
uniform float angle3;
uniform float centerX2;
uniform float centerY2;
uniform float centerX3;
uniform float centerY3;
uniform float lineWidth;
uniform float edgeWidth;
uniform sampler2D uSampler;
uniform vec2 dimensions;
uniform vec4 lineColor;
uniform vec2 offset;

vec2 mirror(vec2 v) {
    // This will repeat the value in the range [-1, 1]
    vec2 mirrored = mod(v, 2.0);
    // This will flip the values in the range [1, 2] to make them go from 1 to 0
    return mix(mirrored, 2.0 - mirrored, step(1.0, mirrored));
}

void main() {
    // Calculate the coordinates relative to the center
    float x = gl_FragCoord.x - centerX;
    float y = gl_FragCoord.y - centerY;

    // Calculate the rotated coordinates
    float rotatedX = x * cos(radians(angle)) - y * sin(radians(angle));
    float rotatedY = x * sin(radians(angle)) + y * cos(radians(angle));

    // Calculate the coordinates relative to the center for the second line
    float x2 = gl_FragCoord.x - centerX2;
    float y2 = gl_FragCoord.y - centerY2;

    // Calculate the rotated coordinates for the second line
    float rotatedX2 = x2 * cos(radians(angle2)) - y2 * sin(radians(angle2));
    float rotatedY2 = x2 * sin(radians(angle2)) + y2 * cos(radians(angle2));

    // Calculate the coordinates relative to the center for the third line
    float x3 = gl_FragCoord.x - centerX3;
    float y3 = gl_FragCoord.y - centerY3;

    // Calculate the rotated coordinates for the third line
    float rotatedX3 = x3 * cos(radians(angle3)) - y3 * sin(radians(angle3));
    float rotatedY3 = x3 * sin(radians(angle3)) + y3 * cos(radians(angle3));

    // Sample the color from the canvas texture at the current fragment's UV coordinates
    vec2 uv = gl_FragCoord.xy / dimensions;
    uv.y = 1.0 - uv.y;

    if (rotatedY < 0.0 || rotatedY3 < 0.0) {
        vec2 offsetRotated;
        offsetRotated.x = offset.x * cos(-radians(angle)) - offset.y * sin(-radians(angle));
        offsetRotated.y = offset.x * sin(-radians(angle)) + offset.y * cos(-radians(angle));
        uv += offsetRotated/dimensions;
        uv = mirror(uv);  // Mirror UV coordinates instead of wrapping them
    }

    if (rotatedY2 < 0.0) {
        vec2 offsetRotated;
        offsetRotated.x = offset.x * cos(-radians(angle2)) - offset.y * sin(-radians(angle2));
        offsetRotated.y = offset.x * sin(-radians(angle2)) + offset.y * cos(-radians(angle2));
        uv += offsetRotated/dimensions;
        uv = mirror(uv);  // Mirror UV coordinates instead of wrapping them
    }

    vec4 canvasColor = texture2D(uSampler, uv); // Adjust size as needed

    // Create a line by checking if the pixel is within a certain distance of the center
    float lineDist = abs(rotatedY);
    float lineDist2 = abs(rotatedY2);
    float lineDist3 = abs(rotatedY3);

    // Set the final color
    if(lineDist < lineWidth || lineDist2 < lineWidth || lineDist3 < lineWidth){
        // Add smooth edges
        float edgeDist = min(min(lineDist, lineDist2), lineDist3);
        float alpha = smoothstep(lineWidth, lineWidth - edgeWidth, edgeDist);
        gl_FragColor = mix(canvasColor, lineColor, alpha);
    } else {
        gl_FragColor = canvasColor;
    }
}

`);
shader.uniforms.offset = [30.0, 90.0];
shader.uniforms.lineColor = [1.0, 1.5, 2.0, 1.0];
shader.uniforms.lineWidth = 4;
shader.uniforms.edgeWidth = 6;
shader.uniforms.dimensions = [canvas.app.renderer.width,canvas.app.renderer.height];

shader.uniforms.centerX = canvas.app.renderer.width * -0.1;
shader.uniforms.centerY= canvas.app.renderer.height * -0.2;
shader.uniforms.angle= 0;
shader.uniforms.centerX2 = canvas.app.renderer.width * -0.8;
shader.uniforms.centerY2= canvas.app.renderer.height * -0.2;
shader.uniforms.angle2= 0;
shader.uniforms.centerX3 = canvas.app.renderer.width * -0.1;
shader.uniforms.centerY3= canvas.app.renderer.height * -0.2;
shader.uniforms.angle3= 0;


let time=0;
canvas.app.ticker.add((delta) => {
    time+=delta;
    if(time/60>5.3){
        shader.uniforms.angle= 5;
        shader.uniforms.centerX = canvas.app.renderer.width * 0.1;
        shader.uniforms.centerY= canvas.app.renderer.height * 0.2;
    }
    if(time/60>5.4){
        shader.uniforms.centerX2 = canvas.app.renderer.width * 0.8;
        shader.uniforms.centerY2= canvas.app.renderer.height * 0.2;
        shader.uniforms.angle2= 45;
    }
    
    if(time/60>5.5){
        shader.uniforms.centerX3 = canvas.app.renderer.width * 0.1;
        shader.uniforms.centerY3= canvas.app.renderer.height * 0.2;
        shader.uniforms.angle3= 135;
    }
});






canvas.app.stage.filters = [shader];