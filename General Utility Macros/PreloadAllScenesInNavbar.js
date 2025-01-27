let sceneIndex = 0;

try {
    // Preload all scenes
    for (let scene of game.scenes) {
        try {
            if (scene.navigation === true) {
                await game.scenes.preload(scene.id);
                console.log(`Scene ${sceneIndex + 1} preloaded successfully.`);
            }
        } catch (error) {
            console.error(`Error preloading scene ${scene.id}: ${error.message}`);
            continue; // Skip to the next iteration of the loop
        }
        sceneIndex++;
    }

    // Preload all sounds in all playlists, including folders
    for (let playlist of game.playlists) {
        try {
            for (let sound of playlist.sounds) {
                if (sound.path) {
                    await game.audio.preload(sound.path);
                    console.log(`Sound '${sound.name}' from playlist '${playlist.name}' preloaded successfully.`);
                }
            }
        } catch (error) {
            console.error(`Error preloading sounds in playlist '${playlist.name}': ${error.message}`);
        }
    }

    ui.notifications.info(game.user.name + " finished preloading scenes and sounds.");
} catch (error) {
    console.error("Error during preloading: ", error.message);
    ui.notifications.error("An error occurred during the preloading process.");
}
