let lastRoll = game.messages?.contents?.reverse()?.find(m => m.isRoll && m.rolls[0].formula.includes("2d6"));
if (lastRoll) {
    let roll = Roll.fromData(lastRoll.rolls[0]);
    let diceResults = roll.terms[0].results;
    if (diceResults[0].result === 6 && diceResults[1].result === 6) {
        let userl = game.messages.contents[game.messages.contents.length - 1].user.name;
        let bgImg, audio, duration, voicelines, vlpick, vldelay;
        switch (userl) {
            case "Alathor":
              bgImg = "CustomResources/SplashAlathor.png";
              audio = "uploaded-ensemble/Alathor.mp3";
              duration = 2500;
              voicelines = ["Raxia/SFX/Alathorv1.mp3"];
              vlpick = voicelines[Math.floor(Math.random() * voicelines.length)];
              vldelay = 100;
              break;
            case "Abril":
              bgImg = "CustomResources/SplashAbril.png";
              audio = "uploaded-ensemble/Abril.mp3";
              duration = 3500;
              voicelines = ["Raxia/SFX/Abrilv1.mp3"];
              vlpick = voicelines[Math.floor(Math.random() * voicelines.length)];
              vldelay = 400;
              break;
            case "Ott":
              bgImg = "CustomResources/SplashOtt.png";
              audio = "uploaded-ensemble/Ott.mp3";
              duration = 2500;
              voicelines = [];
              vlpick = voicelines[Math.floor(Math.random() * voicelines.length)];
              vldelay = 200;
              break;
            default:
                bgImg = "Exalaes/Players/cutintest.png";
                audio = "";
                duration = 1500;
                vlpic = "";
              return;
          }
          game.modules.get('scene-transitions').api.macro({
            sceneID: false,
            content:"",
            fontColor:'#ffffff',
            fontSize:'28px',
            bgImg: bgImg,
            bgPos:'center center',
            bgSize:'cover',
            bgColor:'#33333300',
            bgOpacity:1,
            fadeIn: 200,
            delay: duration,
            fadeOut: 300,
            audio: "",
            skippable: false,
            gmHide: false,
            gmEndAll: false,
            showUI: false,
          }, true );
          AudioHelper.play({src: audio, volume: 0.8, autoplay: true, loop: false}, true);
          setTimeout(() => {
              AudioHelper.play({src: vlpick, volume: 1, autoplay: true, loop: false}, true);
          }, vldelay);
    } else {
    }
} else {
    ui.notifications.warn("No 2d6 rolls found in chat log.");
}