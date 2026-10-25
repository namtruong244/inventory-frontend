part of 'inventory_provider.dart';

/// Seeding sample data into the backend.
extension InventorySeed on InventoryProvider {
  // ==========================================
  // SEED SAMPLE DATA TO BACKEND
  // ==========================================

  Future<bool> seedBackendWithSampleData() async {
    _isSyncing = true;
    _notify();

    try {
      final now = DateTime.now();

      // Create hierarchy
      final f1 = await _apiService.createBox(Box(
        name: '1st Floor',
        type: StorageType.room,
        label: 'loc_floor_1',
        description: 'Main ground level of the residence',
      ));
      final f2 = await _apiService.createBox(Box(
        name: '2nd Floor',
        type: StorageType.room,
        label: 'loc_floor_2',
        description: 'Upper living and working quarters',
      ));
      final living = await _apiService.createBox(Box(
        name: 'Living Room',
        type: StorageType.room,
        parentId: f1.id,
        label: 'loc_living_room',
        description: 'Family entertainment area',
      ));
      final office = await _apiService.createBox(Box(
        name: 'Home Office',
        type: StorageType.room,
        parentId: f2.id,
        label: 'loc_home_office',
        description: 'Workspace and study room',
      ));
      final kitchen = await _apiService.createBox(Box(
        name: 'Kitchen & Pantry',
        type: StorageType.room,
        parentId: f1.id,
        label: 'loc_kitchen',
        description: 'Cooking and dry food storage',
      ));

      final mediaConsole = await _apiService.createBox(Box(
        name: 'TV Media Console',
        type: StorageType.cabinet,
        parentId: living.id,
        label: 'cab_media_01',
        description: 'Cabinet underneath OLED TV',
      ));
      final oakBookshelf = await _apiService.createBox(Box(
        name: 'Oak Bookshelf',
        type: StorageType.shelf,
        parentId: office.id,
        label: 'shelf_oak_01',
        description: 'Main library and tech shelf',
      ));
      final medCupboard = await _apiService.createBox(Box(
        name: 'First Aid Cabinet',
        type: StorageType.cabinet,
        parentId: kitchen.id,
        label: 'cab_med_01',
        description: 'Wall mounted medical cabinet',
      ));

      final elecBox = await _apiService.createBox(Box(
        name: 'Electronics & Cables Box',
        type: StorageType.box,
        parentId: oakBookshelf.id,
        label: 'elec_001',
        description: 'High-speed cables, adapters, chargers',
      ));
      final gamingDrawer = await _apiService.createBox(Box(
        name: 'Gaming Accessories Drawer',
        type: StorageType.drawer,
        parentId: mediaConsole.id,
        label: 'box_game_01',
        description: 'Controllers, headsets, cartridges',
      ));
      final emergencyBox = await _apiService.createBox(Box(
        name: 'Emergency Medical Box',
        type: StorageType.box,
        parentId: medCupboard.id,
        label: 'box_med_01',
        description: 'Bandages, ointments, daily supplies',
      ));

      _boxes.clear();
      _boxes.addAll([
        f1,
        f2,
        living,
        office,
        kitchen,
        mediaConsole,
        oakBookshelf,
        medCupboard,
        elecBox,
        gamingDrawer,
        emergencyBox,
      ]);

      // Create items
      final macbook = await _apiService.createItem(Item(
        name: 'MacBook Pro 14" M3',
        description: 'Space Black, 18GB Unified Memory, 512GB SSD',
        boxId: office.id,
        categoryId: 'Electronics',
        quantity: 1,
        unit: 'unit',
        photos: const [
          'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1611186871348-b1ce696e52c9?w=800&auto=format&fit=crop&q=80',
        ],
        receiptPhotos: const [
          'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=800&auto=format&fit=crop&q=80',
        ],
        purchaseDate: now.subtract(const Duration(days: 90)),
        purchasePrice: 1999.00,
        serialNumber: 'SN-MBP14-M3-9821',
        barcode: '194253714201',
        warrantyExpiryDate: now.add(const Duration(days: 275)),
        status: ItemStatus.inUse,
        customAttributes: {'Color': 'Space Black', 'RAM': '18GB'},
      ));

      final charger = await _apiService.createItem(Item(
        name: '65W GaN Dual USB-C Charger',
        description: 'Compact fast charger for laptop and mobile devices',
        boxId: elecBox.id,
        categoryId: 'Electronics',
        quantity: 2,
        minQuantity: 3, // Low stock: 2 <= 3
        unit: 'pcs',
        photos: const [
          'https://images.unsplash.com/photo-1583863788434-e58a36330cf0?w=800&auto=format&fit=crop&q=80',
        ],
        purchaseDate: now.subtract(const Duration(days: 60)),
        purchasePrice: 42.00,
        barcode: '6934177712345',
        warrantyExpiryDate: now.add(const Duration(days: 305)),
        status: ItemStatus.stored,
        customAttributes: {'Max Output': '65W', 'Ports': '2x USB-C'},
      ));

      final hdmi = await _apiService.createItem(Item(
        name: 'Ultra High-Speed HDMI 2.1 Cable (2m)',
        description: '8K@60Hz / 4K@120Hz Braided Nylon Cable',
        boxId: elecBox.id,
        categoryId: 'Electronics',
        quantity: 3,
        unit: 'pcs',
        photos: const [
          'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=800&auto=format&fit=crop&q=80',
        ],
        purchasePrice: 18.50,
        status: ItemStatus.stored,
        customAttributes: {'Length': '2 meters', 'Bandwidth': '48Gbps'},
      ));

      final ps5 = await _apiService.createItem(Item(
        name: 'Sony PS5 DualSense Controller',
        description: 'Midnight Black wireless gamepad with haptic feedback',
        boxId: gamingDrawer.id,
        categoryId: 'Gaming & Media',
        quantity: 1,
        unit: 'pcs',
        photos: const [
          'https://images.unsplash.com/photo-1600080972464-8e5f35f63d08?w=800&auto=format&fit=crop&q=80',
        ],
        purchaseDate: now.subtract(const Duration(days: 120)),
        purchasePrice: 69.99,
        serialNumber: 'SN-DS5-77312',
        barcode: '711719541028',
        warrantyExpiryDate: now.add(const Duration(days: 245)),
        status: ItemStatus.stored,
        customAttributes: {'Color': 'Midnight Black'},
      ));

      final ointment = await _apiService.createItem(Item(
        name: 'Neosporin First Aid Antibiotic',
        description: 'Triple antibiotic infection protection ointment 1oz',
        boxId: emergencyBox.id,
        categoryId: 'Medicine & Health',
        quantity: 2,
        minQuantity: 4, // Low stock: 2 <= 4
        unit: 'tubes',
        photos: const [
          'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=800&auto=format&fit=crop&q=80',
        ],
        purchaseDate: now.subtract(const Duration(days: 350)),
        purchasePrice: 9.99,
        barcode: '300810733877',
        expiryDate: now.add(const Duration(days: 12)), // Expiring soon in 12 days
        status: ItemStatus.stored,
        customAttributes: {'Dosage': 'Topical'},
      ));

      final batteries = await _apiService.createItem(Item(
        name: 'AAA Alkaline Batteries (8-Pack)',
        description: 'Heavy duty backup cells for emergency remotes',
        boxId: elecBox.id,
        categoryId: 'Electronics',
        quantity: 8,
        unit: 'pcs',
        photos: const [
          'https://images.unsplash.com/photo-1619725002198-6a689b72f41d?w=800&auto=format&fit=crop&q=80',
        ],
        purchaseDate: now.subtract(const Duration(days: 400)),
        purchasePrice: 12.00,
        expiryDate: now.subtract(const Duration(days: 3)), // Expired 3 days ago
        status: ItemStatus.stored,
      ));

      final jacket = await _apiService.createItem(Item(
        name: 'North Face Waterproof Puffer Jacket',
        description: 'ThermoBall Eco insulated winter coat',
        boxId: mediaConsole.id,
        categoryId: 'Clothing',
        quantity: 1,
        unit: 'pcs',
        photos: const [
          'https://images.unsplash.com/photo-1544923246-77307dd654cb?w=800&auto=format&fit=crop&q=80',
        ],
        purchaseDate: now.subtract(const Duration(days: 200)),
        purchasePrice: 220.00,
        status: ItemStatus.stored,
        customAttributes: {'Size': 'L', 'Color': 'Matte Black'},
      ));

      _items.clear();
      _items.addAll([macbook, charger, hdmi, ps5, ointment, batteries, jacket]);

      // Create Overdue Loan for ps5 controller
      final loan = await _apiService.lendItem(
        itemId: ps5.id,
        borrowerName: 'Alex Johnson',
        borrowerContact: '+1 (555) 234-5678',
        lentDate: now.subtract(const Duration(days: 14)),
        expectedReturnDate: now.subtract(const Duration(days: 2)), // Overdue 2 days
        notes: 'Lent for weekend game tournament',
      );

      _lendingRecords.clear();
      _lendingRecords.add(loan);

      // Update ps5 status in local item list
      final ps5Idx = _items.indexWhere((i) => i.id == ps5.id);
      if (ps5Idx != -1) {
        _items[ps5Idx] = _items[ps5Idx].copyWith(status: ItemStatus.lent);
      }

      return true;
    } catch (e) {
      debugPrint('seedBackendWithSampleData error: $e');
      if (_boxes.isEmpty) {
        _populateOfflineDemoData();
      }
      return true;
    } finally {
      _isSyncing = false;
      _notify();
    }
  }

  void _populateOfflineDemoData() {
    final now = DateTime.now();

    final f1 = Box(
      id: 'box-f1',
      name: '1st Floor',
      type: StorageType.room,
      label: 'loc_floor_1',
      description: 'Main ground level of the residence',
    );
    final f2 = Box(
      id: 'box-f2',
      name: '2nd Floor',
      type: StorageType.room,
      label: 'loc_floor_2',
      description: 'Upper living and working quarters',
    );
    final living = Box(
      id: 'box-living',
      name: 'Living Room',
      type: StorageType.room,
      parentId: f1.id,
      label: 'loc_living_room',
      description: 'Family entertainment area',
    );
    final office = Box(
      id: 'box-office',
      name: 'Home Office',
      type: StorageType.room,
      parentId: f2.id,
      label: 'loc_home_office',
      description: 'Workspace and study room',
    );
    final kitchen = Box(
      id: 'box-kitchen',
      name: 'Kitchen & Pantry',
      type: StorageType.room,
      parentId: f1.id,
      label: 'loc_kitchen',
      description: 'Cooking and dry food storage',
    );
    final mediaConsole = Box(
      id: 'box-media',
      name: 'TV Media Console',
      type: StorageType.cabinet,
      parentId: living.id,
      label: 'cab_media_01',
      description: 'Cabinet underneath OLED TV',
    );
    final oakBookshelf = Box(
      id: 'box-shelf',
      name: 'Oak Bookshelf',
      type: StorageType.shelf,
      parentId: office.id,
      label: 'shelf_oak_01',
      description: 'Main library and tech shelf',
    );
    final elecBox = Box(
      id: 'box-elec',
      name: 'Electronics & Cables Box',
      type: StorageType.box,
      parentId: oakBookshelf.id,
      label: 'elec_001',
      description: 'High-speed cables, adapters, chargers',
    );
    final gamingDrawer = Box(
      id: 'box-game',
      name: 'Gaming Accessories Drawer',
      type: StorageType.drawer,
      parentId: mediaConsole.id,
      label: 'box_game_01',
      description: 'Controllers, headsets, cartridges',
    );

    _boxes.clear();
    _boxes.addAll([f1, f2, living, office, kitchen, mediaConsole, oakBookshelf, elecBox, gamingDrawer]);

    final item1 = Item(
      id: 'item-usbc',
      name: 'Anker USB-C Thunderbolt 4 Cable',
      boxId: elecBox.id,
      categoryId: 'Electronics',
      quantity: 3,
      unit: 'pcs',
      minQuantity: 1,
      purchasePrice: 450000,
      status: ItemStatus.stored,
      description: 'Braided 40Gbps 100W PD charging cable',
    );
    final item2 = Item(
      id: 'item-charger',
      name: 'Anker Prime 67W GaN Wall Charger',
      boxId: elecBox.id,
      categoryId: 'Electronics',
      quantity: 1,
      unit: 'pcs',
      purchasePrice: 950000,
      status: ItemStatus.stored,
      description: '3-Port compact travel fast charger',
    );
    final item3 = Item(
      id: 'item-dualsense',
      name: 'DualSense Wireless Controller (Midnight Black)',
      boxId: gamingDrawer.id,
      categoryId: 'Gaming',
      quantity: 2,
      unit: 'pcs',
      minQuantity: 1,
      purchasePrice: 1750000,
      status: ItemStatus.stored,
    );
    final item4 = Item(
      id: 'item-ps5',
      name: 'Sony PlayStation 5 Disc Edition',
      boxId: mediaConsole.id,
      categoryId: 'Gaming',
      quantity: 1,
      unit: 'pcs',
      purchasePrice: 14500000,
      status: ItemStatus.lent,
      description: 'Next-gen console with 825GB SSD',
    );
    final item5 = Item(
      id: 'item-med',
      name: 'Paracetamol 500mg Extra Relief',
      boxId: kitchen.id,
      categoryId: 'Medical & Health',
      quantity: 4,
      unit: 'tablets',
      minQuantity: 10,
      purchasePrice: 42000,
      status: ItemStatus.stored,
      isConsumable: true,
      expiryDate: now.add(const Duration(days: 15)),
    );

    _items.clear();
    _items.addAll([item1, item2, item3, item4, item5]);

    final loan = LendingRecord(
      id: 'loan-demo-1',
      itemId: item4.id,
      borrowerName: 'Alex Vance',
      borrowerContact: '+84 901 234 567',
      lentDate: now.subtract(const Duration(days: 10)),
      expectedReturnDate: now.subtract(const Duration(days: 2)),
      notes: 'Borrowed for gaming weekend',
    );

    _lendingRecords.clear();
    _lendingRecords.add(loan);
  }

  Future<void> resetToMockData() async {
    await seedBackendWithSampleData();
  }

  void clearAllData() {
    _boxes.clear();
    _items.clear();
    _lendingRecords.clear();
    _notify();
  }
}
