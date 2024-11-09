if (canvas.tokens.controlled.length === 0) {
  ui.notifications.warn("Please select a token.");
} else {
  let applyChanges = false;
  new Dialog({
    title: `Tirar dados`,
    content: `
    <form>
    <div class="form-group">
<h2>Cantidad de d6:</h2>
<input type="hidden" id="dice" name="dice" value="2d6">
</div>
<style>
.myButton {
  flex: 1;
  background-color: var(--color-cool-4);
  color: var(--cp-font-light);
  box-shadow: none;
  border: 1px solid var(--cp-font-light);
}
.myButton:active {
  background-color: var(--cp-font-light);
  color: var(--cp-font-dark);
}
</style>

<div style="display: flex; flex-wrap: wrap; gap: 5px;">
  <button class="myButton" onclick="document.getElementById('dice').value='1d6'">1</button>
  <button class="myButton" onclick="document.getElementById('dice').value='2d6'">2</button>
  <button class="myButton" onclick="document.getElementById('dice').value='3d6'">3</button>
  <button class="myButton" onclick="document.getElementById('dice').value='4d6'">4</button>
  <button class="myButton" onclick="document.getElementById('dice').value='5d6'">5</button>
</div>


      <div class="form-group">
      <h2>Atributo:</h2>
      <input type="hidden" id="attribute" name="attribute" value="sue.value">
      <div style="display: flex; gap: 5px;">
        <button onclick="document.getElementById('attribute').value='int.value'">Inteligencia</button>
        <button onclick="document.getElementById('attribute').value='vol.value'">Voluntad</button>
        <button onclick="document.getElementById('attribute').value='fue.value'">Fuerza</button>
        <button onclick="document.getElementById('attribute').value='din.value'">Dinamismo</button>
        <button onclick="document.getElementById('attribute').value='sue.value'">Suerte</button>
        
      </div>
    </div>
      
      
      
      
      
<div class="form-group">
<h2>Dominio:</h2>
<input type="hidden" id="skill" name="skill" value="dom.cib.value">
</div>



<div style="display: flex; flex-wrap: wrap; gap: 5px;">
  <button style="flex: 1;" onclick="document.getElementById('skill').value='dom.fis.value'">Fisico</button>
  <button style="flex: 1;" onclick="document.getElementById('skill').value='dom.bat.value'">Batalla</button>
  <button style="flex: 1;" onclick="document.getElementById('skill').value='dom.amb.value'">Ambiental</button>
  <button style="flex: 1;" onclick="document.getElementById('skill').value='dom.cib.value'">Cibernetico</button>
  <button style="flex: 1;" onclick="document.getElementById('skill').value='dom.rec.value'">Recursos</button>
  <button style="flex: 1;" onclick="document.getElementById('skill').value='dom.ocu.value'">Oculto</button>
  <button style="flex: 1;" onclick="document.getElementById('skill').value='dom.tec.value'">Tecnico</button>
  <button style="flex: 1;" onclick="document.getElementById('skill').value='dom.soc.value'">Social</button>
</div>


      
      
      

      <div class="form-group">
        <h2>Modificador:</h2>
        
      </div>
      <input id="customNumber" name="customNumber" type="text" value="0" style="margin-bottom: 16px;'"/>
    </form>`,
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
          let actor = canvas.tokens.controlled[0].actor;
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




}