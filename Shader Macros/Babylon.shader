let shader = new PIXI.Filter(null, `
    precision mediump float;
    varying vec2 vTextureCoord;
    uniform sampler2D uSampler;
    uniform vec2 filterArea;
    uniform sampler2D uMaskSampler;
    uniform vec2 maskRes;
    uniform sampler2D uMask2Sampler;
    uniform vec2 mask2Res;
    uniform sampler2D uMask3Sampler;
    uniform vec2 mask3Res;
   

    vec3 blur5(vec2 uv) {
        vec2 px = vec2(1.0 / filterArea.x, 1.0 / filterArea.y);
        vec3 blurColor = vec3(0.0);
        const float blurRadius = 5.0;
        for (float i = -blurRadius; i <= blurRadius; i++) {
            for (float j = -blurRadius; j <= blurRadius; j++) {
                vec2 offset = vec2(i, j) * px;
                blurColor += texture2D(uSampler, uv + offset).rgb;
            }
        }
        blurColor /= (2.0 * blurRadius + 1.0) * (2.0 * blurRadius + 1.0);
        return blurColor;
    }

    vec3 sharpen01(vec3 color){
        vec2 uv = vTextureCoord;
        vec2 px = vec2(1.0 / filterArea.x, 1.0 / filterArea.y);
        //Sharpen
        float sharpenStr = 0.105;
        vec3 sharpColor = vec3(0.0);
        //center pixel formula
        color *= sharpenStr * 4.0 +1.0;
        //neighbor formula: neighbor * sharpenStr * -1.0
        //set the neighbors to the pixels on top, left, right and bottom of the current pixel
        vec3 neighbors[4];
        neighbors[0] = texture2D(uSampler, uv + vec2(0.0, px.y)).rgb;
        neighbors[1] = texture2D(uSampler, uv + vec2(-px.x, 0.0)).rgb;
        neighbors[2] = texture2D(uSampler, uv + vec2(px.x, 0.0)).rgb;
        neighbors[3] = texture2D(uSampler, uv + vec2(0.0, -px.y)).rgb;
        //add the neighbors to the sharpColor
        for (int i = 0; i < 4; i++) {
            sharpColor += neighbors[i] * sharpenStr * -1.0;
        }
        //add the center pixel to the sharpColor
        sharpColor += color;
        //set the finalColor to the sharpColor
        color = sharpColor;
        return color;
    }

    vec3 kuwahara39(vec2 uv){
        const float uRadius = 2.9;
        vec2 px = vec2(1.0 / filterArea.x, 1.0 / filterArea.y);
        float aspectRatio = max(filterArea.x / filterArea.y, 1.0);
        //uv2.x *= aspectRatio;
        vec2 scaledUV = uv;
        vec4 maskColor = texture2D(uMaskSampler, scaledUV);
        vec2 uv2 = vTextureCoord * maskRes / filterArea;
        float aspectRatio2 = max(filterArea.x / filterArea.y, 1.0);
        //uv3.x *= aspectRatio2;
        vec2 scaledUV2 = uv2;
        vec4 maskColor2 = texture2D(uMask2Sampler, scaledUV2);
        vec3 tcolor = texture2D(uSampler, vTextureCoord).rgb;
        float luminance = dot(tcolor.rgb, vec3(0.299, 0.587, 0.114));
        
        
        
        float n = pow(uRadius + 1.0, 2.0);
        vec3 m[4];
        vec3 s[4];
        //Initialize the mean and variance accumulator
        for (int k = 0; k < 4; k++) {
            m[k] = vec3(0.0); //donde se va a mediar los colores
            s[k] = vec3(0.0);
        }
        //Compute the mean and variance of the source texture by iterating over a NxN window
        for (float i = -uRadius; i <= uRadius; i++) {
            for (float j = -uRadius; j <= uRadius; j++) {
                vec2 d = vec2(i, j);
                vec2 coord = uv + d * px;
                vec3 color = texture2D(uSampler, coord).rgb;
                int idx;
                if (d.x < 0.0) {
                    if (d.y < 0.0) {
                        m[0] += color; //suma el color para mediarlo luego
                        s[0] += color *color; //suma el color al cuadrado para calcular la varianza
                    } else {
                        m[1] += color;
                        s[1] += color *color;
                    }
                } else {
                    if (d.y < 0.0) {
                        m[2] += color;
                        s[2] += color *color;
                    } else {
                        m[3] += color;
                        s[3] += color *color;//si no se multiplica no lo hace bien
                    }
                }
            }
        }
        //Checking the minimum variance condition
        float minSigma2 = 1.0;
        vec3 color = texture2D(uSampler, uv).rgb;
        vec3 colordiff[4];
        float minColorDiff = 1.0;
        for (int l = 0; l < 4; l++) {
            //Aqui es donde media los colores
            m[l] /= n;
            //formula varianza
            s[l] = abs(s[l] / n - m[l] * m[l]);

            float sigma2 = s[l].r + s[l].g + s[l].b;
            if (sigma2 < minSigma2) {
                minSigma2 = sigma2;
                color = m[l];
            }
        }
        return color;
    }

    vec3 kuwahara79(vec2 uv){
        const float uRadius = 7.9;
        vec2 px = vec2(1.0 / filterArea.x, 1.0 / filterArea.y);
        float aspectRatio = max(filterArea.x / filterArea.y, 1.0);
        //uv2.x *= aspectRatio;
        vec2 scaledUV = uv;
        vec4 maskColor = texture2D(uMaskSampler, scaledUV);
        vec2 uv2 = vTextureCoord * maskRes / filterArea;
        float aspectRatio2 = max(filterArea.x / filterArea.y, 1.0);
        //uv3.x *= aspectRatio2;
        vec2 scaledUV2 = uv2;
        vec4 maskColor2 = texture2D(uMask2Sampler, scaledUV2);
        vec3 tcolor = texture2D(uSampler, vTextureCoord).rgb;
        float luminance = dot(tcolor.rgb, vec3(0.299, 0.587, 0.114));
        float n = pow(uRadius + 1.0, 2.0);
        vec3 m[4];
        vec3 s[4];
        //Initialize the mean and variance accumulator
        for (int k = 0; k < 4; k++) {
            m[k] = vec3(0.0); //donde se va a mediar los colores
            s[k] = vec3(0.0);
        }
        //Compute the mean and variance of the source texture by iterating over a NxN window
        for (float i = -uRadius; i <= uRadius; i++) {
            for (float j = -uRadius; j <= uRadius; j++) {
                vec2 d = vec2(i, j);
                vec2 coord = uv + d * px;
                vec3 color = texture2D(uSampler, coord).rgb;
                int idx;
                if (d.x < 0.0) {
                    if (d.y < 0.0) {
                        m[0] += color; //suma el color para mediarlo luego
                        s[0] += color *color; //suma el color al cuadrado para calcular la varianza
                    } else {
                        m[1] += color;
                        s[1] += color *color;
                    }
                } else {
                    if (d.y < 0.0) {
                        m[2] += color;
                        s[2] += color *color;
                    } else {
                        m[3] += color;
                        s[3] += color *color;//si no se multiplica no lo hace bien
                    }
                }
            }
        }
        //Checking the minimum variance condition
        float minSigma2 = 1.0;
        vec3 color = texture2D(uSampler, uv).rgb;
        vec3 colordiff[4];
        float minColorDiff = 1.0;
        for (int l = 0; l < 4; l++) {
            //Aqui es donde media los colores
            m[l] /= n;
            //formula varianza
            s[l] = abs(s[l] / n - m[l] * m[l]);

            float sigma2 = s[l].r + s[l].g + s[l].b;
            if (sigma2 < minSigma2) {
                minSigma2 = sigma2;
                color = m[l];
            }
        }
        return color;
    }

    vec3 darken(vec3 color, float amount){
        return color * (1.0 - amount);
    }

    vec3 vignette(vec3 color){
        vec3 black = vec3(0.0, 0.0, 0.0);
        vec2 uv = vTextureCoord;
        uv -= vec2(0.5);
        float dToCenter = length(uv);
        color = color*(1.0 - dToCenter*dToCenter);
        return color;
    }

    vec3 applyPaintHighlight(vec3 color, vec4 maskColor2, float displacement, int i){
        vec2 uv = vTextureCoord;
        vec2 px = vec2(1.0 / filterArea.x, 1.0 / filterArea.y);
        float rightd = displacement;
        vec2 rightUV = vec2(uv.x + rightd *px.x, uv.y);
        vec3 rightColor = texture2D(uSampler, rightUV).rgb;
        rightColor = kuwahara39(rightUV);
        vec3 preColor = mix(color, rightColor.rgb, maskColor2.r);
        return preColor;
    }

    vec3 rgbToHsl(vec3 color) {
        float maxVal = max(max(color.r, color.g), color.b);
        float minVal = min(min(color.r, color.g), color.b);
        float delta = maxVal - minVal;
        
        float hue = 0.0;
        float saturation = 0.0;
        float lightness = (maxVal + minVal) / 2.0;

        if (delta > 0.0) {
            saturation = (lightness < 0.5) ? (delta / (maxVal + minVal)) : (delta / (2.0 - maxVal - minVal));

            if (maxVal == color.r) {
                hue = (color.g - color.b) / delta + ((color.g < color.b) ? 6.0 : 0.0);
            } else if (maxVal == color.g) {
                hue = (color.b - color.r) / delta + 2.0;
            } else {
                hue = (color.r - color.g) / delta + 4.0;
            }

            hue /= 6.0;
        }

        return vec3(hue, saturation, lightness);
    }


    float hueToRgbComponent(float p, float q, float t) {
            if (t < 0.0) t += 1.0;
            if (t > 1.0) t -= 1.0;

            if (t < 1.0 / 6.0) return p + (q - p) * 6.0 * t;
            if (t < 1.0 / 2.0) return q;
            if (t < 2.0 / 3.0) return p + (q - p) * (2.0 / 3.0 - t) * 6.0;

            return p;
    }

    vec3 hslToRgb(vec3 hslColor) {
        float hue = hslColor.x;
        float saturation = hslColor.y;
        float lightness = hslColor.z;

        float q = (lightness < 0.5) ? lightness * (1.0 + saturation) : lightness + saturation - lightness * saturation;
        float p = 2.0 * lightness - q;

        vec3 rgbColor = vec3(
            hueToRgbComponent(p, q, hue + 1.0/3.0),
            hueToRgbComponent(p, q, hue),
            hueToRgbComponent(p, q, hue - 1.0/3.0)
        );

        return rgbColor;
    }
    vec3 luminanceClamp(vec3 color){
        //rgb to hsl
        const int steps = 16;
        vec3 hsl = rgbToHsl(color);
        //clamp luminance
        float step = 1.0/float(steps);
        float luminance = hsl.z;
        float luminanceStep = step;
        for(int i = 0; i < steps; i++){
            if(luminance < luminanceStep){
                hsl.z = luminanceStep - step/2.0;
                break;
            }
            luminanceStep += step;
        }
        //hsl to rgb
        color = hslToRgb(hsl);

        return color;
    }
    vec3 colorClamp(vec3 color){
        const int steps = 12;
        bool enableIntention = true;
        float step = 1.0/float(steps);
        float colorStep = step;
        for(int i = 0; i < steps; i++){
            if (color.r < colorStep) {
                color.r = colorStep - step/2.0;
                break;
            }
            if
            (color.g < colorStep) {
                color.g = colorStep - step/2.0;
                break;
            }
            if
            (color.b < colorStep) {
                color.b = colorStep - step/2.0;
                break;
            }
            colorStep += step;
        }
        
        //color intention
        if(enableIntention){
            float colordiff1 = color.r - color.g;
            float colordiff2 = color.r - color.b;
            float range = step/4.0;
            if( colordiff1 > range && colordiff2 < range && colordiff2 > -range){
                color.r += range * 0.229;
            }else if( colordiff1 < -range && colordiff2 < range && colordiff2 > -range){
                color.g += range * 0.587;
            }else if(colordiff2 < -range && colordiff1 < range && colordiff1 > -range){
                color.b += range * 0.114;
            }else if(colordiff1 > range && colordiff2 > range){
                color.r += range * 0.229;
                color.g += range * 0.587;
            }else if(colordiff1 > range && colordiff2 < -range){
                color.r += range * 0.229;
                color.b += range * 0.114;
            }else if(colordiff1 < -range && colordiff2 > range){
                color.g += range * 0.587;
                color.r += range * 0.229;
            }else if(colordiff1 < -range && colordiff2 < -range){
                color.g += range * 0.587;
                color.b += range * 0.114;
            }else if(colordiff2 > range && colordiff1 < range && colordiff1 > -range){
                color.b += range * 0.114;
                color.g += range * 0.587;
            }
        }
        



        return color;
    }

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
        finalColor.rgb = mix(finalColor.rgb, vignette(finalColor.rgb), 0.5);
        //colort1 = applyPaintHighlight(finalColor.rgb, maskColor2, 1.0, 0);
        //colort2 = applyPaintHighlight(finalColor.rgb, maskColor2, 2.0, 1);
        //finalColor.rgb = mix(colort1, colort2, distance);
        
        finalColor.rgb = mix(finalColor.rgb, colort2, distance + 0.5 * (1.0 - luminance));
        finalColor.rgb = sharpen01(finalColor.rgb);
        
        finalColor = finalColor * maskColor;
        
        finalColor.rgb = finalColor.rgb + 0.2 * vec3(blur5(uv));
        finalColor.rgb = mix(finalColor.rgb, maskColor3.rgb, 0.9 * maskColor3.r);
        finalColor.rgb = mix(finalColor.rgb, maskColor3.rgb, (0.2 - maskColor3.r) * (1.0 - luminance));
        //the mask shows as it gets darker
        //finalColor.rgb = mix(finalColor.rgb, maskColor3.rgb, maskColor3.rgb);
        gl_FragColor = vec4(finalColor.rgb, 1.0);
    }
`);
shader.uniforms.uMaskSampler = PIXI.Texture.from('/CustomResources/PaintMask.png');
shader.uniforms.maskRes = [1920,1080];
shader.uniforms.uMask2Sampler = PIXI.Texture.from('/CustomResources/harshNoise.png');
shader.uniforms.mask2Res = [1920,1080];
shader.uniforms.uMask3Sampler = PIXI.Texture.from('/CustomResources/brushpaint1.png');
shader.uniforms.mask3Res = [1920,1080];
let time = 0, index = 0;

canvas.app.ticker.add((delta) => {
    time += delta;
    if(time>17){
        time = 0;
        index++;
        if(index%4==0)
            shader.uniforms.uMask3Sampler = PIXI.Texture.from('/CustomResources/brushpaint1.png');
        else if(index%4==1){
            shader.uniforms.uMask3Sampler = PIXI.Texture.from('/CustomResources/brushpaint3.png');
        }else if(index%4==2){
            shader.uniforms.uMask3Sampler = PIXI.Texture.from('/CustomResources/brushpaint2.png');
        }else{
            shader.uniforms.uMask3Sampler = PIXI.Texture.from('/CustomResources/brushpaint3.png');
        }
        
    }
});
shader.uniforms.filterArea = [canvas.app.renderer.width, canvas.app.renderer.height];
canvas.app.stage.filters = [shader];