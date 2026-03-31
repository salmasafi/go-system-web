const fs = require('fs');

const enFile = 'assets/translations/en.json';
const arFile = 'assets/translations/ar.json';

let en = JSON.parse(fs.readFileSync(enFile));
let ar = JSON.parse(fs.readFileSync(arFile));

const badKeys = ['return', 'continue', 'break', 'if', 'else', 'for', 'class', 'final', 'const'];

Object.keys(en).forEach(k => {
    if (badKeys.includes(k) || k.includes('$') || k.includes('(') || k.includes(')')) {
        delete en[k];
    }
});

Object.keys(ar).forEach(k => {
    if (badKeys.includes(k) || k.includes('$') || k.includes('(') || k.includes(')')) {
        delete ar[k];
    }
});

fs.writeFileSync(enFile, JSON.stringify(en, null, 2));
fs.writeFileSync(arFile, JSON.stringify(ar, null, 2));

function removeBadLines(file) {
    if (!fs.existsSync(file)) return;
    let lines = fs.readFileSync(file, 'utf8').split('\n');
    lines = lines.filter(l => {
        let text = l.toLowerCase();
        // Specifically remove LocaleKeys with keywords or invalid syntax
        if (l.includes('static const return =') || l.includes('"return"')) return false;
        if (l.includes('errorOrResponse') || l.includes('message:')) return false;
        return true;
    });
    fs.writeFileSync(file, lines.join('\n'));
}

removeBadLines('lib/generated/locale_keys.g.dart');
removeBadLines('lib/translations/codegen_loader.g.dart');
removeBadLines('lib/translations/locale_keys.g.dart');

console.log('Sanitized translations');
