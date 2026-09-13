import os
import re
import json

ROOT_DIR = r"D:\Hospital"
EXCLUDES = ['node_modules', '.next', 'build', '.dart_tool', 'dist', '.git']

def analyze_file(filepath):
    ext = os.path.splitext(filepath)[1]
    info = {
        'path': os.path.relpath(filepath, ROOT_DIR).replace('\\', '/'),
        'exports': [],
        'classes': [],
        'functions': [],
        'imports': []
    }
    
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            
            # Simple heuristics
            if ext in ['.ts', '.tsx', '.js', '.dart']:
                # Find imports
                if ext == '.dart':
                    imports = re.findall(r"^import\s+['\"](.*?)['\"]", content, re.M)
                    info['imports'].extend(imports)
                    classes = re.findall(r"class\s+([A-Za-z0-9_]+)", content)
                    info['classes'].extend(classes)
                    funcs = re.findall(r"([A-Za-z0-9_]+)\([^)]*\)\s*{", content)
                    info['functions'].extend(funcs)
                else:
                    imports = re.findall(r"import\s+.*?from\s+['\"](.*?)['\"]", content, re.M)
                    info['imports'].extend(imports)
                    exports = re.findall(r"export\s+(?:const|function|class|interface|type)\s+([A-Za-z0-9_]+)", content)
                    info['exports'].extend(exports)
                    classes = re.findall(r"class\s+([A-Za-z0-9_]+)", content)
                    info['classes'].extend(classes)
    except Exception as e:
        info['error'] = str(e)
        
    return info

def main():
    results = []
    
    for root, dirs, files in os.walk(ROOT_DIR):
        dirs[:] = [d for d in dirs if d not in EXCLUDES]
        
        for file in files:
            if file.endswith(('.ts', '.tsx', '.dart')):
                filepath = os.path.join(root, file)
                if any(x in filepath for x in EXCLUDES): continue
                results.append(analyze_file(filepath))
                
    with open('analysis_output.json', 'w', encoding='utf-8') as f:
        json.dump(results, f, indent=2)

if __name__ == '__main__':
    main()
