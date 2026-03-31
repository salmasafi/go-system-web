const fs = require('fs');

if (!fs.existsSync('analyze_output.txt')) {
    console.log('No analyze_output.txt found');
    process.exit(0);
}

const content = fs.readFileSync('analyze_output.txt', 'utf16le');
let lines = content.split('\n');
if (lines.length < 5) { // fallback
    lines = fs.readFileSync('analyze_output.txt', 'utf8').split('\n');
}

const filesToFix = {}; // { filepath: { lineNum: Set<errorType> } }

lines.forEach(line => {
    // pattern: error - path\to\file.dart:line:col - message
    const match = line.match(/^\s*(?:error|warning|info)\s*-\s*(.+?):(\d+):(\d+)\s*-\s*(.+?)\s*-/);
    if (match) {
        let file = match[1].trim();
        file = 'lib/' + file.replace(/\\/g, '/').replace(/^lib\//, '');
        const lineNum = parseInt(match[2]) - 1; // 0-indexed
        const msg = match[4];

        if (!filesToFix[file]) filesToFix[file] = {};
        if (!filesToFix[file][lineNum]) filesToFix[file][lineNum] = new Set();
        
        if (line.includes('error -') && (msg.includes("Undefined name 'context'") || msg.includes("The argument type 'BuildContext?' can't be assigned to the parameter type 'BuildContext'"))) {
            filesToFix[file][lineNum].add('context');
        } else if (line.includes('error -') && (msg.includes('constant') || msg.includes('const'))) {
            filesToFix[file][lineNum].add('const');
        } else if (line.includes('error -') && msg.includes("The getter 'redBackground'")) {
            filesToFix[file][lineNum].add('redBg');
        }
    }
});

let totalFixed = 0;

for (const file in filesToFix) {
    if (!fs.existsSync(file)) continue;
    let fileLines = fs.readFileSync(file, 'utf8').split('\n');
    let modified = false;

    const errors = filesToFix[file];
    const lineNums = Object.keys(errors).map(Number).sort((a,b) => b-a);
    
    for (const l of lineNums) {
        if (l >= fileLines.length) continue;
        const types = errors[l];
        
        if (types.has('context')) {
            const orig = fileLines[l];
            fileLines[l] = fileLines[l].replace(/ResponsiveUI\.(?:value|padding|spacing|fontSize|iconSize|borderRadius)\((?:context|context!)?,\s*([\d.]+)\)/g, '$1');
            if (fileLines[l] !== orig) Object.keys(errors).map(x => modified = true);
        }
        
        if (types.has('const')) {
            for (let i = l; i >= Math.max(0, l - 10); i--) {
                if (fileLines[i].includes('const ')) {
                    fileLines[i] = fileLines[i].replace(/\bconst\s+/g, '');
                    modified = true;
                }
            }
        }
        
        if (types.has('redBg')) {
            const orig = fileLines[l];
            fileLines[l] = fileLines[l].replace(/AppColors\.redBackground/g, 'AppColors.lightBlueBackground');
            if (fileLines[l] !== orig) modified = true;
        }
    }
    
    // Also perform a global pass for AppColors.redBackground just in case we miss any from the analyzer
    for (let i = 0; i < fileLines.length; i++) {
        if (fileLines[i].includes('AppColors.redBackground')) {
            fileLines[i] = fileLines[i].replace(/AppColors\.redBackground/g, 'AppColors.lightBlueBackground');
            modified = true;
        }
    }
    
    if (modified) {
        fs.writeFileSync(file, fileLines.join('\n'));
        totalFixed++;
    }
}
console.log('Auto-fix applied to ' + totalFixed + ' files.');
