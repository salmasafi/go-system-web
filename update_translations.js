const fs = require('fs');
const path = require('path');

const enFile = 'assets/translations/en.json';
const arFile = 'assets/translations/ar.json';

const en = JSON.parse(fs.readFileSync(enFile));
const ar = JSON.parse(fs.readFileSync(arFile));

function searchFiles(dir) {
    let results = [];
    const list = fs.readdirSync(dir);
    list.forEach(file => {
        file = path.join(dir, file);
        const stat = fs.statSync(file);
        if (stat && stat.isDirectory()) {
            results = results.concat(searchFiles(file));
        } else if (file.endsWith('_cubit.dart') || file.endsWith('cubit.dart')) {
            results.push(file);
        }
    });
    return results;
}

const cubitFiles = searchFiles('lib/features');

let newStrings = new Set();
const scanRegexes = [
    /emit\([^''""(]*\s*'([^']+)'\s*\)/g,
    /emit\([^''""(]*\s*\"([^\"]+)\"\s*\)/g,
    /\?\?\s*'([^']+)'/g,
    /\?\?\s*\"([^\"]+)\"/g
];


cubitFiles.forEach(file => {
    const content = fs.readFileSync(file, 'utf8');
    scanRegexes.forEach(regex => {
        let match;
        while ((match = regex.exec(content)) !== null) {
            const str = match[1];
            if (str && str.length > 2) {
                newStrings.add(str);
            }
        }
    });
});

newStrings.forEach(str => {
    if (!en[str]) {
        en[str] = str;
    }
    if (!ar[str]) {
        let arTrans = str;
        const lower = str.toLowerCase();
        if (lower.includes('created successfully')) arTrans = 'تم الإنشاء بنجاح';
        else if (lower.includes('updated successfully')) arTrans = 'تم التحديث بنجاح';
        else if (lower.includes('deleted successfully')) arTrans = 'تم الحذف بنجاح';
        else if (lower.includes('exceeds')) arTrans = 'الحجم يتجاوز الحد المسموح';
        else if (lower.includes('error') || lower.includes('failed')) arTrans = 'حدث خطأ';
        else if (lower.includes('already exists')) arTrans = 'موجود بالفعل';
        else if (lower.includes('required')) arTrans = 'مطلوب';
        else if (lower.includes('not found')) arTrans = 'غير موجود';
        else if (lower.includes('invalid')) arTrans = 'غير صالح';
        else arTrans = str; // fallback to English if unknown

        ar[str] = arTrans;
    }
});

fs.writeFileSync(enFile, JSON.stringify(en, null, 2));
fs.writeFileSync(arFile, JSON.stringify(ar, null, 2));
console.log('Added ' + newStrings.size + ' cubit strings to translations.');
