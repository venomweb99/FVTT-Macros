// Obtener los valores actuales de las variables CSS
let computedStyles = getComputedStyle(document.documentElement);
let fontH2Value = computedStyles.getPropertyValue("--font-h2").trim();
let fontBodyValue = computedStyles.getPropertyValue("--font-body").trim();
let titlebarValue = computedStyles.getPropertyValue("--titlebar").trim();
let patternValue = computedStyles.getPropertyValue("--pattern").trim();
let patternBlendModeValue = computedStyles.getPropertyValue("--pattern-blend-mode").trim();
let titleBlendModeValue = computedStyles.getPropertyValue("--title-blend-mode").trim();
let activeColorValue = computedStyles.getPropertyValue("--active-color").trim();
let hoverColorValue = computedStyles.getPropertyValue("--hover-color").trim();
let headerColorValue = computedStyles.getPropertyValue("--header-color").trim();
let buttonColorValue = computedStyles.getPropertyValue("--button-color").trim();
let backgroundColorValue = computedStyles.getPropertyValue("--background-color").trim();
let shadowColorValue = computedStyles.getPropertyValue("--shadow-color").trim();
let titleTextColorValue = computedStyles.getPropertyValue("--title-text-color").trim();
let textColorValue = computedStyles.getPropertyValue("--text-color").trim();
let patternColor1Value = computedStyles.getPropertyValue("--patterncolor-1").trim();
let patternColor2Value = computedStyles.getPropertyValue("--patterncolor-2").trim();
let patternColor3Value = computedStyles.getPropertyValue("--patterncolor-3").trim();
let patternColor4Value = computedStyles.getPropertyValue("--patterncolor-4").trim();
let borderRadiusValue = computedStyles.getPropertyValue("--border-r").trim();


// Verificar si hay un JSON guardado en el almacenamiento local
let storedCSSVariables = localStorage.getItem('cssVariables');

if (storedCSSVariables) {
  // Si hay un JSON guardado, cargar las variables CSS desde él
  let parsedCSSVariables = JSON.parse(storedCSSVariables);

  for (let key in parsedCSSVariables) {
    let value = parsedCSSVariables[key].trim(); // Eliminar espacios en blanco alrededor del valor

    // Verificar si el valor no está vacío
    if (value !== "") {
      // Aplicar las variables CSS cargadas
      document.documentElement.style.setProperty(key, value);

      // Rellenar los campos de entrada con los valores cargados
      if (document.getElementById(key)) {
        document.getElementById(key).value = value;
      }
    }
  }

  console.log("Valores CSS cargados correctamente.");
  showDialog();
} else {
    console.log("No hay valores CSS guardados en el almacenamiento local.");
    showDialog();
}

function loadLoadedCSSVars() {
    fontH2Value = computedStyles.getPropertyValue("--font-h2").trim();
    fontBodyValue = computedStyles.getPropertyValue("--font-body").trim();
    titlebarValue = computedStyles.getPropertyValue("--titlebar").trim();
    patternValue = computedStyles.getPropertyValue("--pattern").trim();
    patternBlendModeValue = computedStyles.getPropertyValue("--pattern-blend-mode").trim();
    titleBlendModeValue = computedStyles.getPropertyValue("--title-blend-mode").trim();
    activeColorValue = computedStyles.getPropertyValue("--active-color").trim();
    hoverColorValue = computedStyles.getPropertyValue("--hover-color").trim();
    headerColorValue = computedStyles.getPropertyValue("--header-color").trim();
    buttonColorValue = computedStyles.getPropertyValue("--button-color").trim();
    backgroundColorValue = computedStyles.getPropertyValue("--background-color").trim();
    shadowColorValue = computedStyles.getPropertyValue("--shadow-color").trim();
    titleTextColorValue = computedStyles.getPropertyValue("--title-text-color").trim();
    textColorValue = computedStyles.getPropertyValue("--text-color").trim();
    patternColor1Value = computedStyles.getPropertyValue("--patterncolor-1").trim();
    patternColor2Value = computedStyles.getPropertyValue("--patterncolor-2").trim();
    patternColor3Value = computedStyles.getPropertyValue("--patterncolor-3").trim();
    patternColor4Value = computedStyles.getPropertyValue("--patterncolor-4").trim();
    borderRadiusValue = computedStyles.getPropertyValue("--border-r").trim();
}

function showDialog() {
    loadLoadedCSSVars();
    // Crear el contenido del diálogo con los valores actuales de las variables CSS
    let dialogContent = `
    <div>
    <label for="fontH2">Font H2:</label>
    <input type="text" id="fontH2" value="${fontH2Value}"><br>

    <label for="fontBody">Font Body:</label>
    <input type="text" id="fontBody" value="${fontBodyValue}"><br>

    <label for="titlebar">Titlebar:</label>
    <input type="text" id="titlebar" value="${titlebarValue}"><br>

    <label for="pattern">Pattern:</label>
    <input type="text" id="pattern" value="${patternValue}"><br>

    <label for="patternBlendMode">Pattern Blend Mode:</label>
    <input type="text" id="patternBlendMode" value="${patternBlendModeValue}"><br>

    <label for="titleBlendMode">Title Blend Mode:</label>
    <input type="text" id="titleBlendMode" value="${titleBlendModeValue}"><br>

    <label for="activeColor">Active Color:</label>
    <input type="text" id="activeColor" value="${activeColorValue}"><br>

    <label for="hoverColor">Button hover Color:</label>
    <input type="text" id="hoverColor" value="${hoverColorValue}"><br>

    <label for="headerColor">Header Color:</label>
    <input type="text" id="headerColor" value="${headerColorValue}"><br>

    <label for="buttonColor">Button Color:</label>
    <input type="text" id="buttonColor" value="${buttonColorValue}"><br>

    <label for="backgroundColor">Background Color:</label>
    <input type="text" id="backgroundColor" value="${backgroundColorValue}"><br>

    <label for="shadowColor">Shadow Color:</label>
    <input type="text" id="shadowColor" value="${shadowColorValue}"><br>

    <label for="titleTextColor">Title Text Color:</label>
    <input type="text" id="titleTextColor" value="${titleTextColorValue}"><br>

    <label for="textColor">Text Color:</label>
    <input type="text" id="textColor" value="${textColorValue}"><br>

    <label for="patternColor1">Pattern Color 1:</label>
    <input type="text" id="patternColor1" value="${patternColor1Value}"><br>

    <label for="patternColor2">Pattern Color 2:</label>
    <input type="text" id="patternColor2" value="${patternColor2Value}"><br>

    <label for="patternColor3">Pattern Color 3:</label>
    <input type="text" id="patternColor3" value="${patternColor3Value}"><br>

    <label for="patternColor4">Pattern Color 4:</label>
    <input type="text" id="patternColor4" value="${patternColor4Value}"><br>

    <label for="borderRadius">Border Radius:</label>
    <input type="text" id="borderRadius" value="${borderRadiusValue}"><br>
    </div>
    `;

    // Mostrar el diálogo con el contenido generado
    new Dialog({
    title: "Editar Valores CSS",
    content: dialogContent,
    buttons: {
        save: {
        label: "Guardar",
        callback: saveCSSVariables
        },
        cancel: {
        label: "Cancelar"
        }
    },
    close: () => {
        console.log("Ventana cerrada");
    }
    }).render(true);
}
function saveCSSVariables() {
  let cssVariables = {
    "--font-h2": document.getElementById("fontH2").value,
    "--font-body": document.getElementById("fontBody").value,
    "--titlebar": document.getElementById("titlebar").value,
    "--pattern": document.getElementById("pattern").value,
    "--pattern-blend-mode": document.getElementById("patternBlendMode").value,
    "--title-blend-mode": document.getElementById("titleBlendMode").value,
    "--active-color": document.getElementById("activeColor").value,
    "--hover-color": document.getElementById("hoverColor").value,
    "--header-color": document.getElementById("headerColor").value,
    "--button-color": document.getElementById("buttonColor").value,
    "--background-color": document.getElementById("backgroundColor").value,
    "--shadow-color": document.getElementById("shadowColor").value,
    "--title-text-color": document.getElementById("titleTextColor").value,
    "--text-color": document.getElementById("textColor").value,
    "--patterncolor-1": document.getElementById("patternColor1").value,
    "--patterncolor-2": document.getElementById("patternColor2").value,
    "--patterncolor-3": document.getElementById("patternColor3").value,
    "--patterncolor-4": document.getElementById("patternColor4").value,
    "--border-r": document.getElementById("borderRadius").value
  };

  localStorage.setItem('cssVariables', JSON.stringify(cssVariables));

  // Aplica los valores a las variables CSS
  for (let key in cssVariables) {
    document.documentElement.style.setProperty(key, cssVariables[key]);
  }

  // Cierra la ventana emergente
  ui.notifications.info("Valores CSS actualizados correctamente.");
}