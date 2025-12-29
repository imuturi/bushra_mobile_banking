# extract_texts.py
import os
import re
import json
from pathlib import Path

def extract_all_texts(directory='lib'):
    texts = {}
    dart_files = []

    # Find all Dart files
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                dart_files.append(os.path.join(root, file))

    print(f"Found {len(dart_files)} Dart files")

    for file_path in dart_files:
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()

                # Find Text('...') or Text("...")
                matches = re.findall(r'Text\([\'"]([^\'"]+)[\'"]\)', content)

                # Find InputDecoration hintText/labelText
                matches += re.findall(r'hintText[\s]*:[\s]*[\'"]([^\'"]+)[\'"]', content)
                matches += re.findall(r'labelText[\s]*:[\s]*[\'"]([^\'"]+)[\'"]', content)

                # Find AppBar titles
                matches += re.findall(r'title[\s]*:[\s]*Text\([\'"]([^\'"]+)[\'"]\)', content)

                # Find Button texts
                matches += re.findall(r'child[\s]*:[\s]*Text\([\'"]([^\'"]+)[\'"]\)', content)

                if matches:
                    # Create key from filename and index
                    filename = os.path.basename(file_path).replace('.dart', '')
                    for i, text in enumerate(set(matches)):  # Remove duplicates
                        # Skip very short texts (likely variables)
                        if len(text.strip()) > 1 and not text.strip()[0].isupper() and text.strip() != text.strip().upper():
                            key = f"{filename}_{i}_{hash(text) % 10000}"
                            texts[key] = text.strip()

        except Exception as e:
            print(f"Error reading {file_path}: {e}")

    return texts

# Run extraction
all_texts = extract_all_texts()

# Save to JSON
with open('extracted_texts.json', 'w', encoding='utf-8') as f:
    json.dump(all_texts, f, indent=2, ensure_ascii=False)

print(f"Extracted {len(all_texts)} unique texts")
print("Saved to extracted_texts.json")