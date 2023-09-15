let script = document.createElement('script');
script.src = 'https://apis.google.com/js/api.js';
document.head.appendChild(script);

await new Promise((resolve) => {
  script.onload = resolve;
});

await new Promise((resolve) => {
  gapi.load('client', resolve);
});

gapi.client.setApiKey('a');
gapi.client.load('https://sheets.googleapis.com/$discovery/rest?version=v4');

let spreadID = 'idFicha';

let actorNames = ["Abril", "Alathor", "Ott"];

let attributeRanges = [
  {attribute: "system.attributes.DES.value", range: "J22"},
  {attribute: "system.attributes.AGI.value", range: "J24"},
  {attribute: "system.attributes.FUE.value", range: "J26"},
  {attribute: "system.attributes.VIT.value", range: "J28"},
  {attribute: "system.attributes.INT.value", range: "J30"},
  {attribute: "system.attributes.ESP.value", range: "J32"},
  {attribute: "system.health.value", range: "V7"},
  {attribute: "system.health.max", range: "X6"},
  {attribute: "system.power.value", range: "V9"},
  {attribute: "system.power.max", range: "Y6"},
  {attribute: "system.attributes.FORT.value", range: "AC21"},
  {attribute: "system.attributes.VOL.value", range: "AC23"},
  {attribute: "system.attributes.DEMO.value", range: "AC25"},
  {attribute: "system.attributes.INI.value", range: "AC27"},
  {attribute: "system.attributes.DEF.value", range: "AH54"},
  {attribute: "system.attributes.EVA.value", range: "AH52"}
];

for (let actorName of actorNames) {
  let cactor = game.actors.find(a => a.name === actorName);
  if (cactor) {
    for (let attributeRange of attributeRanges) {
      let response = await gapi.client.sheets.spreadsheets.values.get({
        spreadsheetId: spreadID,
        range: `${actorName}!${attributeRange.range}`,
      });
      let values = response.result.values;
      for (let row of values) {
          let update = {[attributeRange.attribute]: row.join(', ')};
          cactor.update(update);
      };
    };
  };
};