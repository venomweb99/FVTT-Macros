// Variables globales para los contadores
let counters = {
    up: 0,
    heart: 0,
    down: 0
};

// Nombre del actor controlador
const CONTROLLER_NAME = "game_controller";

// Intervalo de actualización (en ms)
const UPDATE_INTERVAL = 100;

// Escala para números, íconos y botones
const SCALE = 1.2; // Cambia este valor para ajustar el tamaño

// Verificar si el usuario actual es el Gamemaster o se llama "Abril"
const isGM = game.user.isGM;
const isSpecialUser = game.user.name === "Abril";

// Variable para almacenar la ventana de diálogo
let dialog;

// Obtener el actor controlador
let controllerActor = game.actors.getName(CONTROLLER_NAME);
if (!controllerActor) {
    ui.notifications.error(`No se encontró el actor llamado "${CONTROLLER_NAME}".`);
    return;
}

// Función para cargar valores desde el actor
async function loadValues() {
    counters.up = getProperty(controllerActor.system, "Rythm.up") || 0;
    counters.heart = getProperty(controllerActor.system, "Rythm.heart") || 0;
    counters.down = getProperty(controllerActor.system, "Rythm.down") || 0;
    updateCounters();
}

// Función para guardar valores en el actor
async function saveValues() {
    await controllerActor.update({
        "system.Rythm.up": counters.up,
        "system.Rythm.heart": counters.heart,
        "system.Rythm.down": counters.down
    });
}

// Función para actualizar los contadores en la ventana sin recrearla
function updateCounters() {
    if (!dialog) return; // Si no hay diálogo, no hacemos nada
    const container = dialog.element;
    container.find(".counter-value[data-counter='up']").text(counters.up);
    container.find(".counter-value[data-counter='heart']").text(counters.heart);
    container.find(".counter-value[data-counter='down']").text(counters.down);
}

// Renderizar la ventana
function renderWindow() {
    if (dialog) return; // Si ya existe un diálogo, no lo volvemos a crear

    let content = `
        <div style="display: flex; justify-content: center; gap: ${20 * SCALE}px; font-size: ${1 * SCALE}em;">
            <!-- Contador UP -->
            <div style="text-align: center;">
                ${(isGM || isSpecialUser) ? `<button style="font-size: ${0.8 * SCALE}em;" data-counter="up" data-action="increment">+</button>` : ''}
                <div style="font-size: ${1 * SCALE}em;">⬆️</div>
                <div class="counter-value" style="font-size: ${1.2 * SCALE}em;" data-counter="up">${counters.up}</div>
                ${(isGM || isSpecialUser) ? `<button style="font-size: ${0.8 * SCALE}em;" data-counter="up" data-action="decrement">-</button>` : ''}
            </div>
            <!-- Contador HEART -->
            <div style="text-align: center;">
                ${(isGM || isSpecialUser) ? `<button style="font-size: ${0.8 * SCALE}em;" data-counter="heart" data-action="increment">+</button>` : ''}
                <div style="font-size: ${1 * SCALE}em;">❤️</div>
                <div class="counter-value" style="font-size: ${1.2 * SCALE}em;" data-counter="heart">${counters.heart}</div>
                ${(isGM || isSpecialUser) ? `<button style="font-size: ${0.8 * SCALE}em;" data-counter="heart" data-action="decrement">-</button>` : ''}
            </div>
            <!-- Contador DOWN -->
            <div style="text-align: center;">
                ${(isGM || isSpecialUser) ? `<button style="font-size: ${0.8 * SCALE}em;" data-counter="down" data-action="increment">+</button>` : ''}
                <div style="font-size: ${1 * SCALE}em;">⬇️</div>
                <div class="counter-value" style="font-size: ${1.2 * SCALE}em;" data-counter="down">${counters.down}</div>
                ${(isGM || isSpecialUser) ? `<button style="font-size: ${0.8 * SCALE}em;" data-counter="down" data-action="decrement">-</button>` : ''}
            </div>
        </div>
        ${isGM ? `<div style="margin-top: 10px; text-align: center;">
            <button style="font-size: ${1 * SCALE}em;" id="reset-button">Reset</button>
        </div>` : ''}
    `;

    // Crear la ventana de diálogo
    dialog = new Dialog({
        title: "Ritmos",
        content: content,
        buttons: {}, // Sin botones adicionales
        render: (html) => {
            html.find("button[data-action]").on("click", async (event) => {
                let counter = event.currentTarget.dataset.counter;
                let action = event.currentTarget.dataset.action;

                // Modificar los valores de los contadores
                if (action === "increment") counters[counter]++;
                else if (action === "decrement" && counters[counter] > 0) counters[counter]--;

                // Guardar y actualizar
                await saveValues();
                updateCounters();
            });

            if (isGM) {
                html.find("#reset-button").on("click", async () => {
                    counters.up = 0;
                    counters.heart = 0;
                    counters.down = 0;
                    await saveValues();
                    updateCounters();
                });
            }
        },
        // Configurar tamaño y posición inicial
        render: () => {
            const el = dialog.element;
            el.css({
                top: "100px",
                left: "200px",
                width: "100px",
                height: "300px",
                position: "absolute",
                "min-width": "100px",
                background: "transparent"
            });
        }
    }).render(true);
}

// Sincronizar valores periódicamente para jugadores
setInterval(loadValues, UPDATE_INTERVAL);

// Inicializar valores y ventana
loadValues();
renderWindow();