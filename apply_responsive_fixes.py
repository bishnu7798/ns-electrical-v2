#!/usr/bin/env python3
"""
Script to automatically apply responsive design fixes to all Flutter screens
"""

import os
import re

def apply_responsive_fixes(file_path):
    """Apply responsive design fixes to a Flutter Dart file"""
    
    # Read the file
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Check if already has responsive imports
    if "import '../../shared/utils/responsive_utils.dart';" in content:
        print(f"✓ Already has responsive imports: {file_path}")
        return False
    
    # Add responsive import after existing imports
    import_pattern = r"(import\s+'[^']+';)"
    last_import_match = list(re.finditer(import_pattern, content))[-1] if re.search(import_pattern, content) else None
    
    if last_import_match:
        insert_pos = last_import_match.end()
        new_import = "\nimport '../../shared/utils/responsive_utils.dart';"
        content = content[:insert_pos] + new_import + content[insert_pos:]
        
        # Write back the modified content
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
            
        print(f"✓ Added responsive import to: {file_path}")
        return True
    
    return False

def main():
    # Define the project root
    project_root = r"d:\Download\my apps\nselectrical"
    
    # Define patterns for screens that need responsive fixes
    screen_patterns = [
        "*_screen.dart"
    ]
    
    # Walk through the features directory
    features_dir = os.path.join(project_root, "lib", "src", "features")
    
    if not os.path.exists(features_dir):
        print(f"Features directory not found: {features_dir}")
        return
    
    modified_files = []
    
    # Process all screen files
    for root, dirs, files in os.walk(features_dir):
        for file in files:
            if file.endswith("_screen.dart"):
                file_path = os.path.join(root, file)
                if apply_responsive_fixes(file_path):
                    modified_files.append(file_path)
    
    print(f"\nResponsive design fixes applied to {len(modified_files)} files:")
    for file in modified_files:
        print(f"  - {os.path.relpath(file, project_root)}")

if __name__ == "__main__":
    main()