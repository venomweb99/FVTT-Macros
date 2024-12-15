let shader = new PIXI.Filter(null, `
    precision mediump float;
    varying vec2 vTextureCoord;
    uniform sampler2D uSampler;
    uniform vec2 filterArea;
   

    void main(void) {
        vec2 uv = vTextureCoord;
        vec2 px = vec2(1.0 / filterArea.x, 1.0 / filterArea.y);
        vec2 center = vec2(0.5, 0.5);
        float distance = distance(center, uv);
        vec2 uv2 = vTextureCoord * maskRes / filterArea;
        vec4 maskColor = texture2D(uMaskSampler, uv2);
        vec2 uv3 = vTextureCoord;
        vec4 maskColor2 = texture2D(uMask2Sampler, uv3);
        vec2 uv4 = vTextureCoord;
        vec4 maskColor3 = texture2D(uMask3Sampler, uv4);
        vec3 tcolor = texture2D(uSampler, vTextureCoord).rgb;
        float luminance = dot(tcolor.rgb, vec3(0.299, 0.587, 0.114));
        vec4 finalColor = texture2D(uSampler, vTextureCoord);
        vec3 colort1, colort2;

        //colort1 = kuwahara39(uv);
        colort2 = kuwahara79(uv);
        finalColor.rgb = colorClamp(luminanceClamp(finalColor.rgb));
        finalColor.rgb = mix(finalColor.rgb, vignette(finalColor.rgb), 0.2);
        //colort1 = applyPaintHighlight(finalColor.rgb, maskColor2, 1.0, 0);
        //colort2 = applyPaintHighlight(finalColor.rgb, maskColor2, 2.0, 1);
        //finalColor.rgb = mix(colort1, colort2, distance);
        
        finalColor.rgb = mix(finalColor.rgb, colort2, distance + 0.5 * (1.0 - luminance));
        finalColor.rgb = sharpen01(finalColor.rgb);
        
        finalColor = finalColor * maskColor;
        
        finalColor.rgb = finalColor.rgb + 0.2 * vec3(blur5(uv));
        finalColor.rgb = mix(finalColor.rgb, maskColor3.rgb, 0.9 * maskColor3.r);
        finalColor.rgb = mix(finalColor.rgb, maskColor3.rgb, (0.2 - maskColor3.r) * (1.0 - luminance));

        //write the final image
        gl_FragColor = vec4(finalColor.rgb, 1.0);
    }
`);

let time = 0;
canvas.app.ticker.add((delta) => {
    time += delta;
});
shader.uniforms.filterArea = [canvas.app.renderer.width, canvas.app.renderer.height];
canvas.app.stage.filters = [shader];