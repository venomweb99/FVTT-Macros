let progress = 0;
let progressWindow = new Dialog({
  title: "TRANSFERENCIA EN PROGRESO",
  content: `
  <div style="display: flex; justify-content: center; align-items: center; height: 100px;
  border: none;">
  <div style="position: relative; display: inline-block;">
    
    <img src="Custom/warning.png" alt="Warning" style="display: block;
    border: none;
     width: 100px; height: auto;">
    <div style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; background-color: var(--cp-playerui-color); mix-blend-mode: multiply;"></div>
    <img src="Custom/warningr.png" alt="Warning Mask" style="
    position: absolute;
    box-shadow: 0 0 4px var(--color-cool-5);
     border: none; top: 0; left: 0; width: 100%; height: 100%;">
  </div>
</div>

  <div id="progress-bar" style="width: 100%; 
  background: var(--color-cool-5);
  
  border: 1px solid var(--cp-playerui-color); 
  padding: 3px; box-sizing: border-box;">
  <div id="progress" style="width: ${progress}%; 
  height: 12px; background: var(--cp-playerui-color);
  "></div></div><p id="progress-text" style="text-align: center;">Subiendo ${progress}%</p>`,
  buttons: {},
  close: () => console.log("Progress Completed"),
  render: html => {
    let progressInterval = setInterval(() => {
      progress+=0.7;
      html.find("#progress").css("width", progress + "%");
      html.find("#progress-text").text(`Subiendo ${Math.floor(progress)}%`);
      if (progress >= 100) {
        clearInterval(progressInterval);
        progressWindow.close();
      }
    }, 50);
  }
}, {
    width:800
});

progressWindow.render(true);