#!/usr/bin/env python3
"""
Script to remove different_price concept from Flutter codebase
This script updates all files to remove references to:
- differentPrice field
- productPriceId field  
- prices/PriceVariation
- VariationModel
"""

import os
import re
from pathlib import Path

def remove_different_price_from_purchase_model():
    """Update lib/features/admin/purchase/model/purchase_model.dart"""
    file_path = "lib/features/admin/purchase/model/purchase_model.dart"
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Remove differentPrice field from Product class
    content = re.sub(
        r'\s*final bool differentPrice;',
        '',
        content
    )
    
    # Remove differentPrice from constructor
    content = re.sub(
        r',?\s*required this\.differentPrice',
        '',
        content
    )
    
    # Remove differentPrice from fromJson
    content = re.sub(
        r",?\s*differentPrice:\s*json\['different_price'\]\s*\?\?\s*false",
        '',
        content
    )
    
    # Remove productPriceId from PurchaseItemModel
    content = re.sub(
        r'\s*final String\? productPriceId;.*?\n',
        '',
        content
    )
    
    # Remove VariationModel class entirely
    content = re.sub(
        r'class VariationModel \{.*?\n\}',
        '',
        content,
        flags=re.DOTALL
    )
    
    # Remove ProductPrice class entirely  
    content = re.sub(
        r'// product price model\nclass ProductPrice \{.*?\n\}',
        '',
        content,
        flags=re.DOTALL
    )
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"✅ Updated {file_path}")

def update_file_remove_field(file_path, field_name, field_type="String?"):
    """Generic function to remove a field from a Dart class"""
    if not os.path.exists(file_path):
        print(f"⚠️  File not found: {file_path}")
        return
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Remove field declaration
    content = re.sub(
        rf'\s*final {field_type} {field_name};',
        '',
        content
    )
    
    # Remove from constructor parameters
    content = re.sub(
        rf',?\s*(required )?this\.{field_name}',
        '',
        content
    )
    
    # Remove from fromJson
    content = re.sub(
        rf",?\s*{field_name}:\s*[^,\n]+",
        '',
        content
    )
    
    # Remove from toJson
    content = re.sub(
        rf",?\s*'{field_name}':\s*{field_name}",
        '',
        content
    )
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"✅ Updated {file_path} - removed {field_name}")

def remove_different_price_checks(file_path):
    """Remove if (product.differentPrice) checks from UI files"""
    if not os.path.exists(file_path):
        print(f"⚠️  File not found: {file_path}")
        return
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Remove differentPrice checks - this is complex, needs manual review
    # Just flag the file for manual review
    if 'differentPrice' in content or 'different_price' in content:
        print(f"⚠️  Manual review needed: {file_path} (contains differentPrice)")
    
def main():
    print("🚀 Starting removal of different_price concept...")
    print()
    
    # 1. Update purchase model
    print("📝 Updating models...")
    remove_different_price_from_purchase_model()
    
    # 2. Update return item model
    update_file_remove_field(
        "lib/features/pos/return/models/return_item_model.dart",
        "productPriceId",
        "String"
    )
    
    # 3. Update pending sale details model
    update_file_remove_field(
        "lib/features/pos/history/model/pending_sale_details_model.dart",
        "productPriceId",
        "String?"
    )
    
    # 4. Update pandel model
    update_file_remove_field(
        "lib/features/admin/pandel/model/pandel_model.dart",
        "productPriceId",
        "String?"
    )
    
    print()
    print("📋 Files that need manual review:")
    
    # List files that need manual UI updates
    ui_files = [
        "lib/features/admin/product/presentation/screens/edit_product_screen.dart",
        "lib/features/admin/product/presentation/screens/product_details_screen.dart",
        "lib/features/admin/product/presentation/widgets/product_attribute_assignment_widget.dart",
        "lib/features/pos/home/presentation/view/pos_home_screen.dart",
        "lib/features/pos/home/presentation/widgets/product_details_dialog.dart",
        "lib/features/pos/home/presentation/widgets/product_grid.dart",
        "lib/features/pos/home/presentation/widgets/product_card.dart",
        "lib/features/pos/history/presentation/views/pending_sale_details_screen.dart",
        "lib/features/admin/purchase/presentation/view/create_purchase_screen.dart",
        "lib/features/admin/print_labels/presentation/view/print_labels_screen.dart",
        "lib/features/admin/print_labels/presentation/widgets/product_card.dart",
    ]
    
    for file in ui_files:
        remove_different_price_checks(file)
    
    print()
    print("✅ Automated updates complete!")
    print("⚠️  Please manually review and update the UI files listed above")

if __name__ == "__main__":
    main()
