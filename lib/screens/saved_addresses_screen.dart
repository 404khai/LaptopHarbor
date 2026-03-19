import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:country_state_city_picker/country_state_city_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_back_button.dart';

class SavedAddressesScreen extends StatefulWidget {
  final bool selectionMode;
  final String? selectedAddressId;

  const SavedAddressesScreen({
    super.key,
    this.selectionMode = false,
    this.selectedAddressId,
  });

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  String? _uid;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser?.uid;
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (!mounted) return;
      setState(() {
        _uid = user?.uid;
      });
    });
  }

  CollectionReference<Map<String, dynamic>>? _addressesRef() {
    final uid = _uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('addresses');
  }

  Future<void> _deleteAddress(String docId) async {
    final ref = _addressesRef();
    if (ref == null) return;
    await ref.doc(docId).delete();
  }

  Future<void> _saveAddress({
    String? docId,
    required String label,
    required String country,
    required String state,
    required String city,
    required String zipCode,
    required bool isDefault,
  }) async {
    final ref = _addressesRef();
    if (ref == null) return;

    final now = FieldValue.serverTimestamp();
    final data = <String, dynamic>{
      'label': label.trim(),
      'country': country.trim(),
      'state': state.trim(),
      'city': city.trim(),
      'zipCode': zipCode.trim(),
      'isDefault': isDefault,
      'updatedAt': now,
      if (docId == null) 'createdAt': now,
    };

    if (isDefault) {
      final batch = FirebaseFirestore.instance.batch();
      final existing = await ref.get();
      for (final d in existing.docs) {
        if (d.id == docId) continue;
        if ((d.data()['isDefault'] ?? false) == true) {
          batch.update(d.reference, <String, dynamic>{'isDefault': false});
        }
      }
      if (docId == null) {
        final newDoc = ref.doc();
        batch.set(newDoc, data);
      } else {
        batch.set(ref.doc(docId), data, SetOptions(merge: true));
      }
      await batch.commit();
      return;
    }

    if (docId == null) {
      await ref.add(data);
    } else {
      await ref.doc(docId).set(data, SetOptions(merge: true));
    }
  }

  Future<void> _openAddressSheet({Map<String, dynamic>? existing}) async {
    final uid = _uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to manage addresses.')),
      );
      return;
    }

    final labelController = TextEditingController(
      text: (existing?['label'] ?? '').toString(),
    );
    final zipController = TextEditingController(
      text: (existing?['zipCode'] ?? '').toString(),
    );
    String country = (existing?['country'] ?? '').toString();
    String state = (existing?['state'] ?? '').toString();
    String city = (existing?['city'] ?? '').toString();
    bool isDefault = (existing?['isDefault'] ?? false) == true;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.80,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    existing == null ? 'Add Address' : 'Edit Address',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'NAME',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: labelController,
                    decoration: InputDecoration(
                      hintText: 'Home, Work',
                      hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.all(16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'LOCATION',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SelectState(
                      onCountryChanged: (value) {
                        setModalState(() {
                          country = value;
                        });
                      },
                      onStateChanged: (value) {
                        setModalState(() {
                          state = value;
                        });
                      },
                      onCityChanged: (value) {
                        setModalState(() {
                          city = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ZIP CODE',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: zipController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter zip code',
                      hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.all(16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Checkbox(
                        value: isDefault,
                        activeColor: AppColors.primary,
                        onChanged: (value) {
                          setModalState(() {
                            isDefault = value == true;
                          });
                        },
                      ),
                      Text(
                        'Set as default',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.slate900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        final label = labelController.text.trim();
                        final zip = zipController.text.trim();
                        if (label.isEmpty ||
                            country.trim().isEmpty ||
                            state.trim().isEmpty ||
                            city.trim().isEmpty ||
                            zip.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please complete all fields.'),
                            ),
                          );
                          return;
                        }
                        await _saveAddress(
                          docId: existing?['id']?.toString(),
                          label: label,
                          country: country,
                          state: state,
                          city: city,
                          zipCode: zip,
                          isDefault: isDefault,
                        );
                        if (!context.mounted) return;
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        existing == null ? 'Add Address' : 'Save Changes',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatAddress(Map<String, dynamic> data) {
    final label = (data['label'] ?? '').toString();
    final city = (data['city'] ?? '').toString();
    final state = (data['state'] ?? '').toString();
    final country = (data['country'] ?? '').toString();
    final zip = (data['zipCode'] ?? '').toString();
    final line2 = [city, state].where((p) => p.trim().isNotEmpty).join(', ');
    final line3 = [country, zip].where((p) => p.trim().isNotEmpty).join(' ');
    return [label, line2, line3].where((p) => p.trim().isNotEmpty).join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final uid = _uid;
    final ref = _addressesRef();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const Center(child: CustomBackButton()),
        title: Text(
          widget.selectionMode ? 'Select Address' : 'Saved Addresses',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.slate900,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: AppColors.primary),
              onPressed: () {
                _openAddressSheet();
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: uid == null
            ? Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Text(
                    'Please sign in to view saved addresses.',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: ref!.orderBy('createdAt', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink();
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Failed to load addresses.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[500],
                        ),
                      ),
                    );
                  }

                  final docs = snapshot.data?.docs ?? const [];
                  if (docs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'No saved addresses yet.',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.slate900,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Add a new address to use during checkout.',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton(
                              onPressed: () => _openAddressSheet(),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                foregroundColor: Colors.grey[600],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_location_alt_outlined,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Add New Address',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        ...docs.map((doc) {
                          final data = doc.data();
                          final item = <String, dynamic>{...data, 'id': doc.id};
                          final isDefault =
                              (data['isDefault'] ?? false) == true;
                          final isSelected =
                              widget.selectedAddressId != null &&
                              widget.selectedAddressId == doc.id;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: GestureDetector(
                              onTap: widget.selectionMode
                                  ? () => Navigator.pop(context, item)
                                  : null,
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: widget.selectionMode && isSelected
                                        ? AppColors.primary
                                        : Colors.grey[200]!,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.03,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: widget.selectionMode
                                              ? (isSelected
                                                    ? AppColors.primary
                                                    : Colors.grey[300]!)
                                              : (isDefault
                                                    ? AppColors.primary
                                                    : Colors.grey[300]!),
                                          width: 2,
                                        ),
                                      ),
                                      child:
                                          (widget.selectionMode
                                              ? isSelected
                                              : isDefault)
                                          ? const Center(
                                              child: SizedBox(
                                                width: 12,
                                                height: 12,
                                                child: DecoratedBox(
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primary,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            (data['label'] ?? 'Address')
                                                .toString(),
                                            style: GoogleFonts.inter(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.slate900,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            _formatAddress(data),
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                              height: 1.5,
                                            ),
                                          ),
                                          if (!widget.selectionMode &&
                                              isDefault) ...[
                                            const SizedBox(height: 12),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'DEFAULT',
                                                style: GoogleFonts.inter(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    if (widget.selectionMode)
                                      Icon(
                                        Icons.chevron_right,
                                        color: Colors.grey[400],
                                      )
                                    else
                                      Column(
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              Icons.edit,
                                              size: 20,
                                              color: Colors.grey[400],
                                            ),
                                            onPressed: () => _openAddressSheet(
                                              existing: item,
                                            ),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                          const SizedBox(height: 16),
                                          IconButton(
                                            icon: Icon(
                                              Icons.delete_outline,
                                              size: 20,
                                              color: Colors.grey[400],
                                            ),
                                            onPressed: () async {
                                              final ok = await showDialog<bool>(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                      'Delete address',
                                                    ),
                                                    content: const Text(
                                                      'Are you sure you want to delete this address?',
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              context,
                                                              false,
                                                            ),
                                                        child: const Text(
                                                          'Cancel',
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              context,
                                                              true,
                                                            ),
                                                        child: const Text(
                                                          'Delete',
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                              if (ok != true) return;
                                              await _deleteAddress(doc.id);
                                            },
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
                            onPressed: () => _openAddressSheet(),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: Colors.grey[300]!,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              foregroundColor: Colors.grey[600],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_location_alt_outlined,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Add New Address',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
