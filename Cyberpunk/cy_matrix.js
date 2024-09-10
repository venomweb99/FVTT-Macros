const columns = Math.floor(Math.random() * 7) + 2;
const rows = columns;
let w=50 * columns;
let updatefreq = 300/rows;
let topR = Math.floor(Math.random() * 900);
let leftR = Math.floor(Math.random() * 1500);

function randomHexPair() {
  const hexChars = "0123456789ABCDEF";
  return hexChars[Math.floor(Math.random() * 16)] + hexChars[Math.floor(Math.random() * 16)];
}

let matrix = Array.from({ length: rows }, () => Array.from({ length: columns }, randomHexPair));

function createMatrixHTML(matrix, selectedRow, selectedCol) {
  let html = '<table style=" font-size: 24px; table-layout: fixed; width: 100%; height: 100%; border: none; padding: 0; margin: 0; box-shadow: none">';
  for (let i = 0; i < rows; i++) {
    html += "<tr>";
    for (let j = 0; j < columns; j++) {
      const isSelected = (i === selectedRow && j === selectedCol);
      const cellStyle = isSelected ? "background-color: var(--cp-font-light); padding: 0px; color: black; text-align: center; width: 40px; height: 40px;" : "padding: 0px; text-align: center; width: 40px; height: 40px;";
      html += `<td style="${cellStyle}">${matrix[i][j]}</td>`;
    }
    html += "</tr>";
  }
  html += "</table>";
  return html;
}

let dialog = new Dialog({
  title: "INJ3CT0R",
  content: createMatrixHTML(matrix, 0, 0),
  buttons: {},
}, { width: w, top: topR, left: leftR});

dialog.render(true);

async function updateMatrix() {
  let selectedRow = 0;
  let selectedCol = 0;

  const interval = setInterval(() => {
    matrix[selectedRow][selectedCol] = randomHexPair();
    selectedRow = Math.floor(Math.random() * rows);
    selectedCol = Math.floor(Math.random() * columns);
    dialog.data.content = createMatrixHTML(matrix, selectedRow, selectedCol);
    dialog.render(false);
  }, updatefreq);

  setTimeout(() => {
    clearInterval(interval);
    dialog.close();
  }, 10000);
}

updateMatrix();