let shaderCode = `
    precision lowp int;
    precision mediump float;

    varying vec2 vTextureCoord;
    uniform sampler2D uSampler;
    uniform vec2 iResolution;
    uniform float affectedHeight;
    uniform float affectedHeight2;
    uniform vec2 resolution;
    uniform float random2;
    uniform float randomw;
    uniform float randomh;
    uniform float dradius;
    uniform float dgridSize;
    uniform float radius;
    uniform float time;
    uniform float alarm;
    
    float random (vec2 xy) {
        return fract(sin(dot(xy.xy, vec2(12, 78))));
    }



    float luminance(vec4 color) {
        return ((color.r * 0.3) + (color.g * 0.6) + (color.b * 0.1)) * color.a;
    }

    float getFirstThresholdPixel(vec2 xy, float threshold) {
        float luma = luminance(texture2D(uSampler, xy / iResolution));

        // Increment the inspected pixel by dividing the image height in sections
        float increment = iResolution.y / 36.0; // Increment fixed

        // Replacing while with fixed loop (max of 30 iterations)
        for (int i = 0; i < 40; ++i) {
            if (luma > threshold || xy.y <= 0.0) break;
            xy.y -= increment;
            luma = luminance(texture2D(uSampler, xy / iResolution));
        }

        return xy.y;
    }

    void putItIn(vec2 startxy, float size, out vec4 colorarray[10]) {
        vec2 xy;
        for (int j = 0; j < 10; ++j) {
            xy = vec2(startxy.x, startxy.y + (size / 9.0) * float(j));
            colorarray[j] = texture2D(uSampler, xy / iResolution);
        }
    }

    void sortArray(inout vec4 colorarray[10]) {
        vec4 tempcolor;
        
        // Bubble sort with fixed loop iterations
        for (int i = 0; i < 9; ++i) {
            for (int j = 0; j < 9; ++j) {  // No more dynamic expressions in loop limits
                if (luminance(colorarray[j]) < luminance(colorarray[j + 1])) {
                    tempcolor = colorarray[j];
                    colorarray[j] = colorarray[j + 1];
                    colorarray[j + 1] = tempcolor;
                }
            }
        }
    }

    vec4 pixelsort(vec2 fragCoord) {
        float firsty = getFirstThresholdPixel(vec2(fragCoord.x, iResolution.y), 0.0);
        float secondy = getFirstThresholdPixel(vec2(fragCoord.x, firsty - 1.0), 0.5);

        if (fragCoord.y < firsty && fragCoord.y > secondy) {
            float size = firsty - secondy;

            vec4 colorarray[10];
            putItIn(vec2(fragCoord.x, secondy), size, colorarray);
            sortArray(colorarray);

            float sectionSize = size / 9.0;
            float location = (fragCoord.y - secondy) / sectionSize;

            // Manual interpolation to replace the use of int(location)
            vec4 topColor = vec4(0.0);
            vec4 bottomColor = vec4(0.0);

            for (int i = 0; i < 9; ++i) {
                float lowBound = float(i);
                float highBound = float(i + 1);
                if (location >= lowBound && location <= highBound) {
                    float locationBetween = (location - lowBound) / (highBound - lowBound);
                    topColor = colorarray[i + 1] * locationBetween;
                    bottomColor = colorarray[i] * (1.0 - locationBetween);
                }
            }

            return topColor + bottomColor;
        } else {
            return texture2D(uSampler, fragCoord / iResolution);
        }
    }


    vec4 applyGridEffect(vec2 fragCoord, vec4 inputColor) {
        float bloomIntensity = 3.0;
        float gridSize = dgridSize;
        vec2 uv = fragCoord / iResolution;
        vec2 gridPosition = floor(uv * iResolution / gridSize);
        vec2 gridUV = fract(uv * iResolution / gridSize);

        // Utiliza el color proporcionado en lugar del color de la textura
        vec4 color = inputColor;

        float luminosity = 0.3 * color.r + 0.59 * color.g + 0.11 * color.b;
        float radius = dradius * luminosity * (luminosity * 0.5 + 0.5);

        // Calculate distance from the center of the grid cell
        float dist = distance(gridUV, vec2(0.5));

        if (dist > radius / gridSize) {
            color = vec4(0.0, 0.0, 0.0, 1.0);
        } else {
            color = vec4(luminosity, 
                        luminosity * luminosity * luminosity - 0.2, 
                        (0.1 + 0.6 * luminosity) * luminosity - 0.1, 1.0);

            // Add bloom effect
            color.rgb *= bloomIntensity;

            // Add circular gradient fade to black
            float gradient = smoothstep(0.0, radius / gridSize, dist);
            color.rgb *= (1.0 - gradient); // Invert the gradient
        }
        return color;
    }


    void putItIn2(vec2 startxy, float size, out vec4 colorarray[10], bool applyGridEffectB) {
        vec2 xy;
        for (int j = 0; j < 10; ++j) {
            xy = vec2(startxy.x, startxy.y + (size / 9.0) * float(j));
            vec4 ogcolor = texture2D(uSampler, xy / iResolution);
            vec4 color = ogcolor;
            // Aplicar el efecto antes de obtener el color
            if (applyGridEffectB) {
                color = applyGridEffect(xy, texture2D(uSampler, xy / iResolution));
            }

            // Guardar el color procesado en el array
            colorarray[j] = color;
        }
    }



    vec4 pixelsortt(vec4 color, vec2 fragCoord, bool applyGridEffectB) {
        float firsty = getFirstThresholdPixel(vec2(fragCoord.x, iResolution.y), 0.0);
        float secondy = getFirstThresholdPixel(vec2(fragCoord.x, firsty - 1.0), 0.5);

        if (fragCoord.y < firsty && fragCoord.y > secondy) {
            float size = firsty - secondy;

            // Create an array of colors
            vec4 colorArray[10];
            putItIn2(vec2(fragCoord.x, secondy), size, colorArray, applyGridEffectB);

            // Sort the array
            sortArray(colorArray);

            float sectionSize = size / 9.0;
            float location = (fragCoord.y - secondy) / sectionSize;

            vec4 topColor = vec4(0.0);
            vec4 bottomColor = vec4(0.0);

            for (int i = 0; i < 9; ++i) {
                float lowBound = float(i);
                float highBound = float(i + 1);
                if (location >= lowBound && location <= highBound) {
                    float locationBetween = (location - lowBound) / (highBound - lowBound);
                    topColor = colorArray[i + 1] * locationBetween;
                    bottomColor = colorArray[i] * (1.0 - locationBetween);
                }
            }

            return topColor + bottomColor;
        } else {
            return color;  // Return the processed color, not original
        }
    }


    void main(void) {
        vec2 fragCoord = vTextureCoord * iResolution;
        vec4 ogColor = texture2D(uSampler, fragCoord / iResolution);
        //vec4 color = pixelsort(fragCoord);
        bool overheight2 = false;
        vec4 finalColor = ogColor;
        float dist = 500.0;
        if (fragCoord.y > affectedHeight2) {
            // Calcula el inicio de la transición y asegúrate de que se inicie después de affectedHeight2
            float transitionStart = affectedHeight2;
            float transitionEnd = affectedHeight2 + dist;
            
            if (fragCoord.y <= transitionEnd) {
                float transition = (fragCoord.y - transitionStart) / dist;
                transition = clamp(transition, 0.0, 1.0); // Asegurarse de que esté en el rango [0.0, 1.0]
                finalColor = mix(ogColor, applyGridEffect(fragCoord, ogColor), transition);
                overheight2 = true;
            } else {
                finalColor = applyGridEffect(fragCoord, ogColor);
                overheight2 = true;
            }
        }

        if (fragCoord.y > affectedHeight) {
            finalColor = pixelsortt(finalColor, fragCoord, overheight2);
        } 
        
        gl_FragColor = finalColor;
    }
`;

let shader = new PIXI.Filter(null, shaderCode, {
    iResolution: [canvas.app.screen.width, canvas.app.screen.height],
    resolution: [canvas.app.renderer.width, canvas.app.renderer.height],
    dgridSize: 7,
    dradius: 10,
});

canvas.app.stage.filters = [shader];

let timer = -1000;
let timerincrement = 1;
let timer2 = 0;
let reversed = false;
let timer2increment = 1;
let time2 = 0;
let randomn = 1;
let frameCount = 0;
let alarm = 1;
let speed = 10;

canvas.app.ticker.add((delta) => {
    
    //increase affectedheight until it reaches the maxheight
    timer += timerincrement;
    timerincrement += 1;
    timer2 += timer2increment;
    if (!reversed) {
        //add the absolute value of the sine of delta to timer2increment
        timer2increment += Math.abs(Math.sin(delta));
    } else {
        timer2increment -= 1;
    }
    if(timer2 >= canvas.app.screen.height) {
        reversed = true;
    }

    shader.uniforms.affectedHeight = Math.min(canvas.app.screen.height, Math.max(0, canvas.app.screen.height - timer2));
    shader.uniforms.affectedHeight2 = canvas.app.screen.height - timer/10;

    time2 += delta;
    shader.uniforms.time = time2 / 20; // Adjust this value to control the speed of the wiggle
    frameCount++;
    if (frameCount >= speed) {
        randomn = Math.random();
        frameCount = 0;
        alarm += speed / 60;
    }
    if (alarm >= 2) {
        alarm = 1;
    }
    shader.uniforms.random2 = randomn;
    shader.uniforms.randomw = randomn * canvas.app.renderer.width;
    shader.uniforms.randomh = randomn * canvas.app.renderer.height;
    shader.uniforms.alarm = alarm;


});