const vscode = require('vscode');

const NAMED = {
  Black: '000000', DarkGray: '444444', Gray: '888888', LightGray: 'CCCCCC', White: 'FFFFFF',
  Red: 'FF0000', Green: '00FF00', Blue: '0000FF', Yellow: 'FFFF00', Cyan: '00FFFF', Magenta: 'FF00FF',
};
const HEX_RE = /\bColor\(\s*(0[xX]([0-9A-Fa-f_]{6,10}))\s*\)/g;
const NAMED_RE = new RegExp('\\bColor\\.(' + Object.keys(NAMED).join('|') + ')\\b', 'g');

function toColor(argbHex) {
  const h = argbHex.replace(/_/g, '').padStart(8, '0');
  const a = parseInt(h.slice(0, 2), 16) / 255;
  return new vscode.Color(parseInt(h.slice(2, 4), 16) / 255, parseInt(h.slice(4, 6), 16) / 255, parseInt(h.slice(6, 8), 16) / 255, a);
}

const hex2 = (v) => Math.round(v * 255).toString(16).toUpperCase().padStart(2, '0');

function activate(context) {
  const provider = {
    provideDocumentColors(doc) {
      const text = doc.getText();
      const out = [];
      let m;
      HEX_RE.lastIndex = 0;
      while ((m = HEX_RE.exec(text))) {
        const start = m.index + m[0].indexOf(m[1]);
        out.push(new vscode.ColorInformation(new vscode.Range(doc.positionAt(start), doc.positionAt(start + m[1].length)), toColor(m[2])));
      }
      NAMED_RE.lastIndex = 0;
      while ((m = NAMED_RE.exec(text))) {
        out.push(new vscode.ColorInformation(new vscode.Range(doc.positionAt(m.index), doc.positionAt(m.index + m[0].length)), toColor('FF' + NAMED[m[1]])));
      }
      return out;
    },
    provideColorPresentations(color, ctx) {
      const orig = ctx.document.getText(ctx.range);
      if (/^Color\./.test(orig)) return []; // named colors are not rewritten
      const label = `0x${hex2(color.alpha)}${hex2(color.red)}${hex2(color.green)}${hex2(color.blue)}`;
      return [new vscode.ColorPresentation(label)];
    },
  };
  context.subscriptions.push(vscode.languages.registerColorProvider({ language: 'kotlin' }, provider));
}

module.exports = { activate };
