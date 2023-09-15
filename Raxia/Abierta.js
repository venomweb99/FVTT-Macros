let lastRoll = game.messages?.contents?.reverse()?.find(m => m.isRoll && m.roll.formula.includes("2d6"));
if (lastRoll) {
    let roll = Roll.fromData(lastRoll.rolls[0]);
    let diceResults = roll.terms[0].results;
    if (diceResults[0].result === 6 && diceResults[1].result === 6) {
        game.modules.get('scene-transitions').api.macro({
            sceneID: false,
            content:"",
            fontColor:'#ffffff',
            fontSize:'28px',
            bgImg:'Exalaes/Players/cutintest.png', // pass any relative or absolute image url here.
            bgPos:'center center',
            bgSize:'cover',
            bgColor:'#33333300',
            bgOpacity:1,
            fadeIn: 200, //how long to fade in
            delay:1500, //how long for transition to stay up
            fadeOut: 300, //how long to fade out
            audio: "", //path to audio file
            skippable:false, //Allows players to skip transition with a click before delay runs out.
            gmHide: false, // hide the transistion on other windows logged in as a GM
            gmEndAll: false, // when the GM clicks to end the transition - end for everyone
            showUI: false, // Show the User Interface elements to all players allowing them to interact with character sheets etc
        
        }, true );
    } else {
    }
} else {
    ui.notifications.warn("No 2d6 rolls found in chat log.");
}