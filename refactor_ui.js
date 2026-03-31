const fs = require('fs');
const path = require('path');

function searchFiles(dir) {
    let results = [];
    if (!fs.existsSync(dir)) return results;
    const list = fs.readdirSync(dir);
    list.forEach(file => {
        const fullPath = path.join(dir, file);
        const stat = fs.statSync(fullPath);
        if (stat.isDirectory()) {
            results = results.concat(searchFiles(fullPath));
        } else if (fullPath.endsWith('.dart')) {
            results.push(fullPath);
        }
    });
    return results;
}

const targetFiles = [
    ...searchFiles('lib/features'),
    ...searchFiles('lib/core/widgets')
];

let filesModified = 0;

const propMapping = {
    'height': 'ResponsiveUI.value',
    'width': 'ResponsiveUI.value',
    'elevation': 'ResponsiveUI.value',
    'thickness': 'ResponsiveUI.value',
    'fontSize': 'ResponsiveUI.fontSize',
    'size': 'ResponsiveUI.iconSize',
    'radius': 'ResponsiveUI.borderRadius',
    'top': 'ResponsiveUI.padding',
    'bottom': 'ResponsiveUI.padding',
    'left': 'ResponsiveUI.padding',
    'right': 'ResponsiveUI.padding',
    'start': 'ResponsiveUI.padding',
    'end': 'ResponsiveUI.padding',
    'horizontal': 'ResponsiveUI.padding',
    'vertical': 'ResponsiveUI.padding'
};

const propsRegex = new RegExp(`\\b(${Object.keys(propMapping).join('|')})\\s*:\\s*([0-9]+(?:\\.[0-9]+)?)\\b(?!\\s*\\()`, 'g');

targetFiles.forEach(file => {
    let content = fs.readFileSync(file, 'utf8');
    let original = content;

    // 1. Strip 'const ' from specific widgets that we are likely touching
    content = content.replace(/\bconst\s+(SizedBox|EdgeInsets|EdgeInsetsDirectional|BorderRadius|Radius|Icon|TextStyle|Padding|Container|BoxDecoration|Column|Row|Expanded|Flexible|Center|Align)\b/g, '$1');

    // 2. Named properties matching
    content = content.replace(propsRegex, (match, prop, valStr) => {
        const val = parseFloat(valStr);
        if (val === 0 || valStr === '0.0' || valStr === '0') return match; // Keep zeros
        const method = propMapping[prop];
        return `${prop}: ${method}(context, ${valStr})`;
    });

    // 3. Positional values (EdgeInsets.all / Radius.circular)
    content = content.replace(/\bEdgeInsets(?:Directional)?\.all\(\s*([0-9]+(?:\.[0-9]+)?)\s*\)/g, (match, valStr) => {
        const val = parseFloat(valStr);
        if (val === 0) return match;
        return match.replace(valStr, `ResponsiveUI.padding(context, ${valStr})`);
    });

    content = content.replace(/\b(?:Radius|BorderRadius)\.circular\(\s*([0-9]+(?:\.[0-9]+)?)\s*\)/g, (match, valStr) => {
        const val = parseFloat(valStr);
        if (val === 0) return match;
        return match.replace(valStr, `ResponsiveUI.borderRadius(context, ${valStr})`);
    });

    // 4. If modified, ensure import exists
    if (content !== original) {
        if (!content.includes('responsive_ui.dart')) {
            content = "import 'package:systego/core/utils/responsive_ui.dart';\n" + content;
        }
        fs.writeFileSync(file, content);
        filesModified++;
    }
});

console.log(`Refactoring complete. Modified ${filesModified} files.`);
