let sceneIndex = 0;
try{
for (let scene of game.scenes) {
    try {
        if(scene.navigation == true){
            await game.scenes.preload(scene.id);
            console.log(`Scene ${sceneIndex + 1} preloaded successfully.`);
        }
    } catch (error) {
        console.error(`Error preloading scene ${scene.id}: ${error.message}`);
        continue; // Skip to the next iteration of the loop
    }
    sceneIndex++;
}
}catch(error){
    ui.notifications.info(game.user.name + " finished loading");
}