let shader = new PIXI.Filter(null, `
    //Foundry Definitions
    precision mediump float;
    varying vec2 vTextureCoord;
    uniform sampler2D uSampler;
    uniform vec2 filterArea;
    //Special Definitions
    uniform float time;
    //User Definitions
    uniform float timedDisplace;
    uniform bool applyLights;
    uniform float fadeAmt;

    //Functions
    vec3 vignette(vec3 color, float strength){
        vec3 black = vec3(0.0, 0.0, 0.0);
        vec2 uv = vTextureCoord;
        uv -= vec2(0.5);
        float dToCenter = length(uv);
        color = color*(1.0 - dToCenter)*strength;
        return color;
    }

    vec3 Displace(vec3 finalcolor, float verticalDisplacement){
        if(verticalDisplacement == 0.0){
            return finalcolor;
        }else{
            vec2 displacedUV = vTextureCoord; // Toma las coordenadas originales
            displacedUV.y += verticalDisplacement; // Desplaza la coordenada y
            displacedUV.y = mod(displacedUV.y, 1.0); // Envuelve la coordenada en [0, 1] para evitar salir de los límites
            vec4 displacedColor = texture2D(uSampler, displacedUV); // Obtén el color de la nueva posición
            vec3 displacedColorrgb = vignette(displacedColor.rgb, 1.0); // Aplica el efecto de viñeta
            return displacedColorrgb; // Devuelve el color desplazado
        }
    }

    vec3 applyLight(vec3 originalColor, vec2 lightPosition, float radius, vec3 lightColor) {
        vec2 uv = vTextureCoord; // Coordenadas de textura
        float distanceToLight = distance(uv, lightPosition); // Distancia al punto de luz

        // Crear un gradiente basado en la distancia
        float intensity = smoothstep(0.0, radius, distanceToLight); // Gradiente desde el centro hacia fuera

        // Mezclar el color original con el color del punto de luz
        vec3 blendedColor = mix(lightColor, originalColor, intensity);

        return blendedColor; // Devolver el color final
    }

    

    void main(void) {
        vec2 uv = vTextureCoord;
        vec2 px = vec2(1.0 / filterArea.x, 1.0 / filterArea.y);
        vec2 center = vec2(0.5, 0.5);
        float distanceFromCenter = distance(center, uv);
        vec4 baseColor = texture2D(uSampler, vTextureCoord);
        vec3 finalColor = baseColor.rgb;
        finalColor = Displace(finalColor, timedDisplace * time);

        if(applyLights){
            finalColor = applyLight(finalColor, vec2(0.5, 1.1), 0.5, vec3(0.0, 0.9, 0.5));
            finalColor = applyLight(finalColor, vec2(0.9, 0.8), 0.4, vec3(0.0, 1.0, 0.7));
            finalColor = applyLight(finalColor, vec2(0.95, 1.0), 0.3, vec3(0.0, 1.0, 0.4));
            finalColor = applyLight(finalColor, vec2(0.8, 0.7), 0.07, vec3(0.0, 0.9, 0.9));
            finalColor = applyLight(finalColor, vec2(0.81, 0.69), 0.02, vec3(0.0, 0.7, 0.9));
            finalColor = applyLight(finalColor, vec2(0.75, 0.7), 0.05, vec3(0.0, 0.9, 0.9));
            finalColor = applyLight(finalColor, vec2(0.74, 0.69), 0.01, vec3(0.0, 0.7, 0.9));
            finalColor = applyLight(finalColor, vec2(0.95, 0.5), 0.17, vec3(0.0, 0.9, 0.9));
            finalColor = applyLight(finalColor, vec2(0.6, 0.9), 0.08, vec3(0.0, 0.9, 0.9));
            finalColor = applyLight(finalColor, vec2(0.59, 0.89), 0.03, vec3(0.0, 0.7, 0.9));
        }
        
        //write the final image
        finalColor = mix(finalColor, baseColor.rgb, fadeAmt);
        gl_FragColor = vec4(finalColor, 1.0);
    }
`);

shader.uniforms.timedDisplace = 0.001;
shader.uniforms.applyLights = false;
shader.uniforms.fadeAmt = 0.0;
let boolTwistedTD = false;
let doneMoving = false;
let finished = false;
let displaceCap = 0.5;
let time = 0;
let timerFade = 0;
if(!finished){
canvas.app.ticker.add((delta) => {
    if(!finished){
        time += delta;
        shader.uniforms.time = time;

        if(!doneMoving){
            if(shader.uniforms.timedDisplace > displaceCap){
                boolTwistedTD = true;
            }
            if(shader.uniforms.timedDisplace <= 0.0){
                    shader.uniforms.timedDisplace = 0.0;
                    doneMoving = true;
                    shader.uniforms.fadeAmt = 0.2;
            }else
            if(shader.uniforms.timedDisplace > 0.0){
                if(boolTwistedTD){
                    shader.uniforms.timedDisplace -= 0.007;
                }else{
                    shader.uniforms.timedDisplace += 0.01;
                }
            }
        }else{
            shader.uniforms.applyLights = true;
            timerFade += delta;
            if(timerFade > 50 && shader.uniforms.fadeAmt < 1.0){
                shader.uniforms.fadeAmt += 0.01;
            }
            if(shader.uniforms.fadeAmt >= 1.0){
                finished = true;
            }
        }
    }
});}
shader.uniforms.filterArea = [canvas.app.renderer.width, canvas.app.renderer.height];
canvas.app.stage.filters = [shader];
AudioHelper.play({
    src: "https://cdn.discordapp.com/attachments/973270427902291980/1317898483969167400/DiscoElisium.mp3?ex=67605c1b&is=675f0a9b&hm=5d1cbe582fd3e98d5650893f03bd2051d55b11dc669bc949a4c6f77b5bb85de7",
    volume: 0.3,
    autoplay: true,
    loop: false
});