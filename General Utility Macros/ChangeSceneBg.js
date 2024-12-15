let selectedHour = 1;
let selectedWeather = 1;
let currentNumber = 0;

// Función para obtener los valores del archivo de imagen
const getCurrentBackgroundValues = () => {
  const currentScene = game.scenes.active;
  if (currentScene && currentScene.data.img) {
    const imgPath = currentScene.data.img.split("/").pop().replace(".png", "");
    const parts = imgPath.split("_");
    
    if (parts.length === 3) {
      selectedHour = parseInt(parts[0]);
      selectedWeather = parseInt(parts[1]);
      currentNumber = parseInt(parts[2]);
    }
  }
};

// Actualizar la previsualización
const updatePreview = () => {
  const previewPath = `escenas/${selectedHour}_${selectedWeather}_${currentNumber}.png`;
  document.getElementById("preview-path").innerText = previewPath;

  // Intentar cargar la imagen
  const imgElement = document.getElementById("preview-image");
  imgElement.src = previewPath;
  imgElement.onerror = () => {
    imgElement.src = ""; // Limpia la imagen si no se encuentra
    imgElement.alt = "Imagen no encontrada";
  };
};

// Crear el formulario
new Dialog({
  title: "Selector de Escena",
  content: `
    <div style="display: flex; flex-direction: column; gap: 10px;">
      <!-- Controles en la misma línea -->
      <div style="display: flex; gap: 15px; align-items: center;">
        <!-- Selector de Hora -->
        <div>
          <label for="hour-select">Hora del Día:</label>
          <select id="hour-select">
            ${[...Array(5).keys()].map(i => `<option value="${i + 1}">${i + 1}</option>`).join("")}
          </select>
        </div>
        <!-- Controles de Número -->
        <div style="display: flex; align-items: center; gap: 5px;">
          <label for="number-input">Número:</label>
          <button id="decrease-number" style="width: 30px; height: 30px;">-</button>
          <span id="current-number" style="font-size: 1.2em; min-width: 20px; text-align: center;">${currentNumber}</span>
          <button id="increase-number" style="width: 30px; height: 30px;">+</button>
        </div>
        <!-- Selector de Clima -->
        <div>
          <label for="weather-select">Clima:</label>
          <select id="weather-select">
            ${[...Array(3).keys()].map(i => `<option value="${i + 1}">${i + 1}</option>`).join("")}
          </select>
        </div>
      </div>
      <!-- Ruta de previsualización -->
      <div>
        <strong>Ruta:</strong>
        <div id="preview-path" style="font-family: monospace;">escenas/${selectedHour}_${selectedWeather}_${currentNumber}.png</div>
      </div>
      <!-- Imagen de previsualización -->
      <div>
        <img id="preview-image" src="" alt="Previsualización de la imagen" style="max-width: 100%; border: 1px solid #ccc; margin-top: 10px;">
      </div>
    </div>
  `,
  buttons: {
    ok: {
      label: "Aceptar",
      callback: async () => {
        const previewPath = `escenas/${selectedHour}_${selectedWeather}_${currentNumber}.png`;
        const currentScene = game.scenes.active;

        if (!currentScene) {
          ui.notifications.error("No hay una escena activa para cambiar el fondo.");
          return;
        }

        try {
          // Cambiar la imagen de fondo de la escena actual
          canvas.scene.background.src = previewPath;
          await currentScene.update({ "img": previewPath });
          canvas.draw();
          ui.notifications.info(`Imagen de fondo cambiada a: ${previewPath}`);
        } catch (error) {
          console.error(error);
          ui.notifications.error("Error al cambiar la imagen de fondo.");
        }
      }
    },
    cancel: {
      label: "Cancelar"
    }
  },
  render: (html) => {
    const dialogElement = html.closest(".dialog");
    dialogElement[0].style.width = "600px";
    dialogElement[0].style.height = "400px";

    // Obtener los valores del fondo actual
    getCurrentBackgroundValues();

    // Establecer los valores en los selectores
    html.find("#hour-select").val(selectedHour);
    html.find("#weather-select").val(selectedWeather);
    html.find("#current-number").text(currentNumber);

    // Listeners para los inputs
    html.find("#hour-select").on("change", (event) => {
      selectedHour = event.target.value;
      updatePreview();
    });
    html.find("#weather-select").on("change", (event) => {
      selectedWeather = event.target.value;
      updatePreview();
    });
    html.find("#decrease-number").on("click", () => {
      if (currentNumber > 0) {
        currentNumber -= 1;
        html.find("#current-number").text(currentNumber);
        updatePreview();
      }
    });
    html.find("#increase-number").on("click", () => {
      currentNumber += 1;
      html.find("#current-number").text(currentNumber);
      updatePreview();
    });

    // Forzar la previsualización al cargar el diálogo
    updatePreview();
  }
}).render(true);