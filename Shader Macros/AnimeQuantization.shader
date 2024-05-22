let shader = new PIXI.Filter(null, `
    precision mediump float;

    varying vec2 vTextureCoord;
    uniform sampler2D uSampler;
    uniform vec2 resolution;
    uniform float color11, color12, color21, color22, color31, color32, color41, color42, color51, color52, color61, color62, color71, color72, color81, color82;

    const colors[] = {vec3(0.95, 0.45, 0.13), vec3(0.67, 0.12, 0.07), vec3(0.05, 0.1, 0.46)};

    vec3 snapToPalette(vec3 color){
        float minDist = 1000.0;
        vec3 closestColor = vec3(0.0, 0.0, 0.0);
        for(int i = 0; i < 3; i++){
            float dist = distance(color, colors[i]);
            if(dist < minDist){
                minDist = dist;
                closestColor = colors[i];
            }
        }
        return closestColor;
    }

    vec3 quantize8(vec3 color)
    {
        float luminance, redgreen, blueyellow;
        redgreen = color.r - color.g;
        blueyellow = color.b - (color.r + color.g) / 2.0;
        luminance = 0.299 * color.r + 0.587 * color.g + 0.114 * color.b;
        if(luminance < 0.125){
            redgreen = color11;
            blueyellow = color12;
        }else
        if(luminance < 0.25 && luminance >= 0.125){
            redgreen = color21;
            blueyellow = color22;
        }else
        if(luminance < 0.375 && luminance >= 0.25){
            redgreen = color31;
            blueyellow = color32;
        }else
        if(luminance < 0.5 && luminance >= 0.375){
            redgreen = color41;
            blueyellow = color42;
        }else
        if(luminance < 0.625 && luminance >= 0.5){
            redgreen = color51;
            blueyellow = color52;
        }else
        if(luminance < 0.75 && luminance >= 0.625){
            redgreen = color61;
            blueyellow = color62;
        }else
        if(luminance < 0.875 && luminance >= 0.75){
            redgreen = color71;
            blueyellow = color72;
        }else
        if(luminance < 1.0 && luminance >= 0.875){
            redgreen = color81;
            blueyellow = color82;
        }
        //convert to rgb
        color.r = ((1.0 - redgreen) + blueyellow)/2.0 * (luminance);
        color.g = (redgreen + blueyellow)/2.0 * (luminance);
        color.b = (1.0 - blueyellow) * (luminance);
        return color; 
    }

    vec3 bnwposterization8(vec3 color){
        float luminance = 0.299 * color.r + 0.587 * color.g + 0.114 * color.b;
        if(luminance < 0.125)color = vec3(0.0625, 0.0625, 0.0625);
        else if(luminance < 0.25)color = vec3(0.1875, 0.1875, 0.1875);
        else if(luminance < 0.375)color = vec3(0.3125, 0.3125, 0.3125);
        else if(luminance < 0.5)color = vec3(0.4375, 0.4375, 0.4375);
        else if(luminance < 0.625)color = vec3(0.5625, 0.5625, 0.5625);
        else if(luminance < 0.75)color = vec3(0.6875, 0.6875, 0.6875);
        else if(luminance < 0.875)color = vec3(0.8125, 0.8125, 0.8125);
        else if(luminance < 1.0)color = vec3(0.9375, 0.9375, 0.9375);
        return color;
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

    vec3 hueClamp(vec3 color){
        //rgb to hsl
        const int steps = 6;
        vec3 hsl = rgbToHsl(color);
        //clamp luminance
        float step = 1.0/float(steps);
        float hue = hsl.x;
        float hueStep = step;
        for(int i = 0; i < steps; i++){
            if(hue < hueStep){
                hsl.x = hueStep - step/2.0;
                break;
            }
            hueStep += step;
        }
        //hsl to rgb
        color = hslToRgb(hsl);

        return color;
    }

    vec3 saturationClamp(vec3 color){
        //rgb to hsl
        const int steps = 16;
        vec3 hsl = rgbToHsl(color);
        //clamp luminance
        float step = 1.0/float(steps);
        float saturation = hsl.y;
        float saturationStep = step;
        for(int i = 0; i < steps; i++){
            if(saturation < saturationStep){
                hsl.y = saturationStep - step/2.0;
                break;
            }
            saturationStep += step;
        }
        //hsl to rgb
        color = hslToRgb(hsl);

        return color;
    }

    void main(void)
    {
        vec2 uv = vTextureCoord;
        vec4 color = texture2D(uSampler, uv);
        //gl_FragColor = vec4(colorClamp(color.rgb), color.a);
        gl_FragColor = vec4(luminanceClamp(hueClamp(saturationClamp(color.rgb))), color.a);
    }
`);

shader.uniforms.resolution = [canvas.app.renderer.width, canvas.app.renderer.height];


canvas.app.stage.filters = [shader];