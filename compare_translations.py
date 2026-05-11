import json

def compare_json(file1, file2):
    with open(file1, 'r', encoding='utf-8') as f1, open(file2, 'r', encoding='utf-8') as f2:
        data1 = json.load(f1)
        data2 = json.load(f2)
        
        keys1 = set(data1.keys())
        keys2 = set(data2.keys())
        
        missing_in_file2 = keys1 - keys2
        missing_in_file1 = keys2 - keys1
        
        print(f"Missing in {file2}: {missing_in_file2}")
        print(f"Missing in {file1}: {missing_in_file1}")

compare_json('e:/Wego/SysteGo/assets/translations/en.json', 'e:/Wego/SysteGo/assets/translations/ar.json')
