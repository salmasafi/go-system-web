const fs = require('fs');

function fixJson(filePath) {
    const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));
    const newData = {};
    
    for (let k in data) {
        let newKey = k.replace(/[^a-zA-Z0-9_]/g, '_').toLowerCase();
        newKey = newKey.replace(/_+/g, '_').replace(/^_|_$/g, '');
        
        if (!newKey) newKey = "empty_key";
        
        let finalKey = newKey;
        let counter = 1;
        while (newData[finalKey]) {
            finalKey = `${newKey}_${counter}`;
            counter++;
        }
        newData[finalKey] = data[k];
    }
    
    fs.writeFileSync(filePath, JSON.stringify(newData, null, 2), 'utf8');
}

fixJson('assets/translations/ar.json');
fixJson('assets/translations/en.json');
console.log("Done");
