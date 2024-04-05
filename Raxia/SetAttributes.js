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
await gapi.client.load('https://sheets.googleapis.com/$discovery/rest?version=v4');

let spreadID = '1UuJjh4C6FIIGXLuB21G8NqsULFRywMbgLbSI1xZ0ydg';

let actorNames = ["Abril", "Alathor", "Ott"];

let attributeRanges = [
  {attribute: "system.attributes.NV.value", range: "B1"},
  {attribute: "system.attributes.DES.value", range: "B4"},
  {attribute: "system.attributes.AGI.value", range: "B5"},
  {attribute: "system.attributes.FUE.value", range: "B6"},
  {attribute: "system.attributes.VIT.value", range: "B7"},
  {attribute: "system.attributes.INT.value", range: "B8"},
  {attribute: "system.attributes.ESP.value", range: "B9"},
  {attribute: "system.attributes.DESbase.value", range: "B10"},
  {attribute: "system.attributes.AGIbase.value", range: "B11"},
  {attribute: "system.attributes.FUEbase.value", range: "B12"},
  {attribute: "system.attributes.VITbase.value", range: "B13"},
  {attribute: "system.attributes.INTbase.value", range: "B14"},
  {attribute: "system.attributes.ESPbase.value", range: "B15"},
  {attribute: "system.attributes.FORT.value", range: "B16"},
  {attribute: "system.attributes.VOL.value", range: "B17"},
  {attribute: "system.attributes.DEMO.value", range: "B18"},
  {attribute: "system.attributes.INI.value", range: "B19"},
  {attribute: "system.attributes.MOVI.value", range: "B20"},
  {attribute: "system.attributes.MOVImax.value", range: "B21"},
  {attribute: "system.attributes.PODMAG.value", range: "B22"},
  {attribute: "system.attributes.EVA.value", range: "B23"},
  {attribute: "system.attributes.DEF.value", range: "B24"},
  {attribute: "system.attributes.REDMAG.value", range: "B25"},
  {attribute: "system.health.value", range: "B2"},
  {attribute: "system.health.max", range: "B2"},
  {attribute: "system.power.value", range: "B3"},
  {attribute: "system.power.max", range: "B3"},
  {attribute: "system.attributes.GUERRERO.value", range: "F2"},
  {attribute: "system.attributes.LUCHADOR.value", range: "F3"},
  {attribute: "system.attributes.ESPADACHIN.value", range: "F4"},
  {attribute: "system.attributes.TIRADOR.value", range: "F5"},
  {attribute: "system.attributes.HECHICERO.value", range: "F6"},
  {attribute: "system.attributes.CONJURADOR.value", range: "F7"},
  {attribute: "system.attributes.SACERDOTE.value", range: "F8"},
  {attribute: "system.attributes.DOMHADAS.value", range: "F9"},
  {attribute: "system.attributes.MAGITEK.value", range: "F10"},
  {attribute: "system.attributes.ARCANISTA.value", range: "F11"},
  {attribute: "system.attributes.DOMDEMONIOS.value", range: "F12"},
  {attribute: "system.attributes.EXPLORADOR.value", range: "F13"},
  {attribute: "system.attributes.RANGER.value", range: "F14"},
  {attribute: "system.attributes.SABIO.value", range: "F15"},
  {attribute: "system.attributes.BARDO.value", range: "F16"},
  {attribute: "system.attributes.ARTESANO.value", range: "F17"},
  {attribute: "system.attributes.ARISTOCRATA.value", range: "F18"},
  {attribute: "system.attributes.MISTICO.value", range: "F19"},
  {attribute: "system.attributes.TECNICISTA.value", range: "F20"},
  {attribute: "system.attributes.HEREDERO.value", range: "F21"},
  {attribute: "system.attributes.GEOMANTE.value", range: "F22"},
  {attribute: "system.attributes.DRUIDA.value", range: "F23"},
  {attribute: "system.attributes.ESTRATEGA.value", range: "F24"},
  {attribute: "system.attributes.BATTLEDANCER.value", range: "F25"}
];

for (let actorName of actorNames) {
  let cactor = game.actors.find(a => a.name === actorName);
  if (cactor) {
    for (let attributeRange of attributeRanges) {
      await new Promise(resolve => setTimeout(resolve, 1000));
      let response = await gapi.client.sheets.spreadsheets.values.get({
        spreadsheetId: spreadID,
        range: `${actorName}db!${attributeRange.range}`,
      });
      let values = response.result.values;
      console.log(response);
        console.log(values);
      for (let row of values) {
          let update = {[attributeRange.attribute]: row.join(', ')};
          cactor.update(update);
      };
    };
  };
};