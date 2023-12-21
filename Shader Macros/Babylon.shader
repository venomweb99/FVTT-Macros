let shader = new PIXI.Filter(null, `
    precision mediump float;
    varying vec2 vTextureCoord;
    uniform sampler2D uSampler;
    uniform vec2 filterArea;
    uniform sampler2D uMaskSampler;
    uniform vec2 maskRes;
    uniform sampler2D uMask2Sampler;
    uniform vec2 mask2Res;

    void main(void) {
        vec2 uv = vTextureCoord;
        vec2 px = vec2(1.0 / filterArea.x, 1.0 / filterArea.y);
        vec2 uv2 = vTextureCoord * maskRes / filterArea;
        float aspectRatio = max(filterArea.x / filterArea.y, 1.0);
        //uv2.x *= aspectRatio;
        vec2 scaledUV = uv2;
        vec4 maskColor = texture2D(uMaskSampler, scaledUV);
        vec2 uv3 = vTextureCoord * mask2Res / filterArea;
        float aspectRatio2 = max(filterArea.x / filterArea.y, 1.0);
        //uv3.x *= aspectRatio2;
        vec2 scaledUV2 = uv3;
        vec4 maskColor2 = texture2D(uMask2Sampler, scaledUV2);
        vec3 tcolor = texture2D(uSampler, vTextureCoord).rgb;
        float luminance = dot(tcolor.rgb, vec3(0.299, 0.587, 0.114));
        
        
            const float uRadius = 2.9 ;
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
            //pilla la variacion, la divide por la potencia del radio y le resta potencia del color??
            s[l] = abs(s[l] / n - m[l] * m[l]);

            float sigma2 = s[l].r + s[l].g + s[l].b;
            if (sigma2 < minSigma2) {
                minSigma2 = sigma2;
                color = m[l];
            }

        }
        vec4 finalColor = vec4(color, 1.0);

        
        if(luminance > 0.5 && luminance < 0.9){
            float rightd = 3.0;
            vec2 rightUV = vec2(uv.x + rightd *px.x, uv.y + 1.0 *px.y);
            vec4 rightColor = texture2D(uSampler, rightUV);
            vec3 preColor = mix(finalColor.rgb, rightColor.rgb, 0.50 - maskColor2.r/2.0);
            finalColor = vec4(preColor,1.0);
        }
        
        vec3 white = vec3(1.0,1.0,1.0);
        //if(luminance > 0.01 && luminance < 0.5 || luminance > 0.6 && luminance < 0.7){
        finalColor = finalColor * maskColor;
        //} 
        
        
        

        //Sharpen
        float sharpenStr = 0.15;
        vec3 sharpColor = vec3(0.0);
        //center pixel formula
        finalColor.rgb *= sharpenStr * 4.0 +1.0;
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
        sharpColor += finalColor.rgb;
        //set the finalColor to the sharpColor
        finalColor.rgb = sharpColor;
        


        
        
        vec3 blurColor = vec3(0.0);
        const float blurRadius = 5.0;
        for (float i = -blurRadius; i <= blurRadius; i++) {
            for (float j = -blurRadius; j <= blurRadius; j++) {
                vec2 offset = vec2(i, j) * px;
                blurColor += texture2D(uSampler, uv + offset).rgb;
            }
        }
        blurColor /= (2.0 * blurRadius + 1.0) * (2.0 * blurRadius + 1.0);
        vec3 bloomColor = finalColor.rgb + 0.6 * blurColor;
        gl_FragColor = vec4(bloomColor, 1.0);
    }
    
    
`);
shader.uniforms.uMaskSampler = PIXI.Texture.from('/CustomResources/PaintMask.png');
shader.uniforms.maskRes = [2000,1333];
shader.uniforms.uMask2Sampler = PIXI.Texture.from('/CustomResources/Paint.png');
shader.uniforms.mask2Res = [1000,750];
shader.uniforms.filterArea = [canvas.app.renderer.width, canvas.app.renderer.height];
canvas.app.stage.filters = [shader];