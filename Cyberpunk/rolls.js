let applyChanges = false;
  new Dialog({
    title: `Tirar dados`,
    content: `
<form>
    <div class="form-group">
        <h2>Cantidad de d6</h2>
        <input type="hidden" id="dice" name="dice" value="2d6">
    </div>
    <style>
        .myButton {
            height: 3.25rem;
            flex: 1;
            background-color: var(--color-cool-4);
            color: var(--cp-font-light);
            box-shadow: none;
            border: 1px solid var(--cp-font-light);
            border-top: 16px solid var(--cp-font-light);
            text-transform: uppercase;
        }
        .myButton:active,
        .myButton:hover,
        .selectedButton,
        .selectedButton2,
        .selectedButton3 {
            background-color: var(--cp-font-light);
            color: var(--cp-font-dark) !important;
            text-shadow: none !important;
            box-shadow: none;
            font-weight: bold;
        }
        h2 {
            margin-top: 8px;
        }
    </style>
    
<script>
    function activateButton(element) {
        var buttons = document.getElementsByClassName("myButton");
        for (var i = 0; i < buttons.length; i++) {
            buttons[i].classList.remove("selectedButton");
        }
        element.classList.add("selectedButton");
        console.log("script reached");
    }
    function activateButton2(element) {
        var buttons = document.getElementsByClassName("myButton");
        for (var i = 0; i < buttons.length; i++) {
            buttons[i].classList.remove("selectedButton2");
        }
        element.classList.add("selectedButton2");
        console.log("script reached");
    }
    function activateButton3(element) {
        var buttons = document.getElementsByClassName("myButton");
        for (var i = 0; i < buttons.length; i++) {
            buttons[i].classList.remove("selectedButton3");
        }
        element.classList.add("selectedButton3");
        console.log("script reached");
    }
    
</script>
    
    
    <div style="display: flex; flex-wrap: wrap; gap: 5px;">
    <button class="myButton" onclick="activateButton(this); document.getElementById('dice').value='1d6'">1</button>
    <button class="myButton" onclick="activateButton(this); document.getElementById('dice').value='2d6'">2</button>
    <button class="myButton" onclick="activateButton(this); document.getElementById('dice').value='3d6'">3</button>
    <button class="myButton" onclick="activateButton(this); document.getElementById('dice').value='4d6'">4</button>
    <button class="myButton" onclick="activateButton(this); document.getElementById('dice').value='5d6'">5</button>
</div>




    <div class="form-group">
        <h2>Atributo</h2>
        <input type="hidden" id="attribute" name="attribute" value="sue.value">
    </div>
    <div style="display: flex; gap: 5px;">
        <button class="myButton" onclick="activateButton2(this); document.getElementById('attribute').value='int.value'">Int</button>
        <button class="myButton" onclick="activateButton2(this); document.getElementById('attribute').value='vol.value'">Vol</button>
        <button class="myButton" onclick="activateButton2(this); document.getElementById('attribute').value='fue.value'">Fue</button>
        <button class="myButton" onclick="activateButton2(this); document.getElementById('attribute').value='din.value'">Din</button>
        <button class="myButton" onclick="activateButton2(this); document.getElementById('attribute').value='sue.value'">Sue</button>

    </div>
    <div class="form-group">
        <h2>Dominio</h2>
        <input type="hidden" id="skill" name="skill" value="dom.cib.value">
    </div>
    <div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 5px;">
        <button class="myButton" onclick="activateButton3(this); document.getElementById('skill').value='dom.fis.value'">Fisico</button>
        <button class="myButton" onclick="activateButton3(this); document.getElementById('skill').value='dom.bat.value'">Batalla</button>
        <button class="myButton" onclick="activateButton3(this); document.getElementById('skill').value='dom.amb.value'">Ambiental</button>
        <button class="myButton" onclick="activateButton3(this); document.getElementById('skill').value='dom.cib.value'">Cibernetico</button>
        <button class="myButton" onclick="activateButton3(this); document.getElementById('skill').value='dom.rec.value'">Recursos</button>
        <button class="myButton" onclick="activateButton3(this); document.getElementById('skill').value='dom.ocu.value'">Oculto</button>
        <button class="myButton" onclick="activateButton3(this); document.getElementById('skill').value='dom.tec.value'">Tecnico</button>
        <button class="myButton" onclick="activateButton3(this); document.getElementById('skill').value='dom.soc.value'">Social</button>
    </div>
    <div class="form-group">
        <h2>Modificador</h2>
    </div>
    <input id="customNumber" name="customNumber" type="text" value="0" style="margin-bottom: 36px;'" />
</form>
      `,
    buttons: {
      yes: {
        icon: "<i class='fas fa-check'></i>",
        label: `Tirar`,
        callback: () => applyChanges = true
      },
      no: {
        icon: "<i class='fas fa-times'></i>",
        label: `Cancelar`
      },
    },
    default: "yes",
    close: html => {
      if (applyChanges) {
          async function rollDice() {
        let dice = html.find('[name=dice]')[0].value;
        let kattribute = html.find('[name=attribute]')[0].value;
        let kskill = html.find('[name=skill]')[0].value;
        let kcustomNumber = html.find('[name=customNumber]')[0].value;
        let actor = game.actors.getName(game.user.name);
        let attributeb = getProperty(actor.system.attributes, kattribute); // This line is modified
        let skillb = getProperty(actor.system.attributes, kskill);
        let customNumber = Number(kcustomNumber);
        let attribute = Number(attributeb);
        let skill = Number(skillb);
        
        let roll = new Roll(`${dice} + ${attribute} + ${skill} + ${customNumber}`);
        await roll.roll();
        roll.toMessage();
        }

        rollDice();
      }
    }
  }).render(true);