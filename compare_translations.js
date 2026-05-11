const fs = require('fs');

const en = JSON.parse(fs.readFileSync('e:/Wego/SysteGo/assets/translations/en.json', 'utf8'));
const ar = JSON.parse(fs.readFileSync('e:/Wego/SysteGo/assets/translations/ar.json', 'utf8'));

const enKeys = Object.keys(en);
const arKeys = Object.keys(ar);

const missingInAr = enKeys.filter(k => !arKeys.includes(k));
const missingInEn = arKeys.filter(k => !enKeys.includes(k));

console.log('Missing in Arabic:', missingInAr);
console.log('Missing in English:', missingInEn);
