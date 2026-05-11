const fs = require('fs');

function checkFile(path, lang) {
    console.log(`\nChecking ${lang} translations in ${path}...`);
    const data = JSON.parse(fs.readFileSync(path, 'utf8'));
    let issues = 0;

    for (const [key, value] of Object.entries(data)) {
        if (!value || value.trim() === '') {
            console.log(`[EMPTY] Key: "${key}" has no value.`);
            issues++;
        } else if (value === key) {
            console.log(`[KEY_EQUALS_VAL] Key: "${key}" has same value as key.`);
            issues++;
        }
        
        // In Arabic file, check if value is purely English/ASCII (mostly)
        if (lang === 'ar') {
            const hasArabic = /[\u0600-\u06FF]/.test(value);
            const isEnglish = /^[a-zA-Z0-9\s\p{P}]+$/u.test(value);
            // Ignore some common abbreviations or brands
            const ignoreList = ['POS', 'EGP', 'IMEI', 'GoSystem', 'www.gosystem.com'];
            if (!hasArabic && !ignoreList.includes(value.trim()) && !value.includes('{')) {
                 console.log(`[POTENTIAL_UNTRANSLATED] Key: "${key}" Value: "${value}" might be missing Arabic translation.`);
                 issues++;
            }
        }
    }
    console.log(`Found ${issues} potential issues.`);
}

checkFile('e:/Wego/SysteGo/assets/translations/en.json', 'en');
checkFile('e:/Wego/SysteGo/assets/translations/ar.json', 'ar');
