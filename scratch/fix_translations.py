import json
import re

def fix_json(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    new_data = {}
    for k, v in data.items():
        # Replace spaces and special chars in keys with underscores
        new_key = re.sub(r'[^a-zA-Z0-9_]', '_', k).lower()
        # Collapse multiple underscores
        new_key = re.sub(r'_+', '_', new_key)
        # Remove leading/trailing underscores
        new_key = new_key.strip('_')
        
        if not new_key:
            new_key = "empty_key"
            
        # Handle collisions
        orig_key = new_key
        counter = 1
        while new_key in new_data:
            new_key = f"{orig_key}_{counter}"
            counter += 1
            
        new_data[new_key] = v
        
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(new_data, f, ensure_ascii=False, indent=2)

fix_json('assets/translations/ar.json')
fix_json('assets/translations/en.json')
print("Done")
