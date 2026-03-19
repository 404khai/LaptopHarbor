import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_intl_phone_field/flutter_intl_phone_field.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_back_button.dart';
import '../services/cloudinary_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _initialized = false;
  bool _isUploadingPhoto = false;
  String _phoneInitialCountryCode = 'US';
  String _phoneInitialNumber = '';
  String _phoneNational = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
  }

  String _nameFromEmail(String email) {
    final trimmed = email.trim();
    final atIndex = trimmed.indexOf('@');
    final localPart = (atIndex > 0) ? trimmed.substring(0, atIndex) : trimmed;
    if (localPart.isEmpty) return 'User';
    return localPart;
  }

  String _effectiveDisplayName({
    required Map<String, dynamic>? profile,
    required String? authDisplayName,
    required String? authEmail,
  }) {
    final profileDisplayName = (profile?['displayName'] as String?)?.trim();
    if (profileDisplayName != null && profileDisplayName.isNotEmpty) {
      return profileDisplayName;
    }

    final normalizedAuthDisplayName = authDisplayName?.trim();
    if (normalizedAuthDisplayName != null &&
        normalizedAuthDisplayName.isNotEmpty) {
      return normalizedAuthDisplayName;
    }

    final firstName = (profile?['firstName'] as String?)?.trim();
    final lastName = (profile?['lastName'] as String?)?.trim();
    final combined = [firstName, lastName]
        .whereType<String>()
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .join(' ')
        .trim();
    if (combined.isNotEmpty) return combined;

    final email = (profile?['email'] as String?)?.trim() ?? authEmail?.trim();
    if (email != null && email.isNotEmpty) return _nameFromEmail(email);

    return 'User';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;
    final profile = authProvider.userProfile;

    _nameController.text = _effectiveDisplayName(
      profile: profile,
      authDisplayName: user?.displayName,
      authEmail: user?.email,
    );
    _emailController.text = user?.email ?? (profile?['email'] as String?) ?? '';
    _phoneController.text = (profile?['phone'] as String?) ?? '';
    final phoneIso = (profile?['phoneIso'] as String?)?.trim();
    final phoneNational = (profile?['phoneNational'] as String?)?.trim();
    if (phoneIso != null &&
        phoneIso.isNotEmpty &&
        phoneNational != null &&
        phoneNational.isNotEmpty) {
      _phoneInitialCountryCode = phoneIso;
      _phoneInitialNumber = phoneNational;
      _phoneNational = phoneNational;
    } else {
      _syncPhoneInitialFromStored(_phoneController.text);
    }

    _initialized = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadPhoto() async {
    if (_isUploadingPhoto) return;
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;
    if (user == null) return;

    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;

    setState(() {
      _isUploadingPhoto = true;
    });

    try {
      final bytes = await file.readAsBytes();
      final url = await CloudinaryService.uploadImageBytes(
        bytes: bytes,
        filename: file.name.isNotEmpty ? file.name : 'profile.jpg',
      );

      final error = await authProvider.updateProfile(
        displayName: _nameController.text,
        phone: _phoneController.text,
        photoUrl: url,
        phoneIso: _phoneInitialCountryCode,
        phoneNational: _phoneNational,
      );

      if (!mounted) return;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profile photo updated')));
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to upload profile photo'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingPhoto = false;
        });
      }
    }
  }

  void _syncPhoneInitialFromStored(String stored) {
    final trimmed = stored.trim();
    if (trimmed.isEmpty) {
      _phoneInitialCountryCode = 'US';
      _phoneInitialNumber = '';
      _phoneNational = '';
      return;
    }

    if (trimmed.startsWith('+')) {
      final parsed = _tryParseE164(trimmed);
      _phoneInitialCountryCode = parsed.$1;
      _phoneInitialNumber = parsed.$2;
      _phoneNational = parsed.$2;
      return;
    }

    _phoneInitialCountryCode = 'US';
    _phoneInitialNumber = trimmed;
    _phoneNational = trimmed;
  }

  (String, String) _tryParseE164(String value) {
    final digits = value.trim().replaceAll(RegExp(r'[^0-9+]'), '');
    if (!digits.startsWith('+')) return ('US', digits);
    final raw = digits.substring(1);

    const dialToIso = <String, String>{
      '1': 'US',
      '44': 'GB',
      '233': 'GH',
      '234': 'NG',
      '254': 'KE',
      '255': 'TZ',
      '256': 'UG',
      '27': 'ZA',
      '91': 'IN',
    };
    final keys = dialToIso.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    for (final k in keys) {
      if (raw.startsWith(k)) {
        final iso = dialToIso[k] ?? 'US';
        final national = raw.substring(k.length);
        return (iso, national);
      }
    }

    return ('US', raw);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final profile = authProvider.userProfile;
    final photoUrl =
        (profile?['photoUrl'] as String?)?.trim() ?? user?.photoURL?.trim();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Center(child: CustomBackButton()),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.slate900,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: user == null
            ? Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Text(
                    'Please sign in to edit your profile.',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Center(
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey[200],
                                        border: Border.all(
                                          color: Colors.grey[100]!,
                                          width: 2,
                                        ),
                                      ),
                                      child:
                                          (photoUrl != null &&
                                              photoUrl.isNotEmpty)
                                          ? ClipOval(
                                              child: Image.network(
                                                photoUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return const Center(
                                                        child: Icon(
                                                          Icons.person,
                                                          size: 56,
                                                          color: AppColors
                                                              .slate900,
                                                        ),
                                                      );
                                                    },
                                              ),
                                            )
                                          : const Icon(
                                              Icons.person,
                                              size: 56,
                                              color: AppColors.slate900,
                                            ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: _pickAndUploadPhoto,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 4,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(
                                                  alpha: 0.1,
                                                ),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: _isUploadingPhoto
                                              ? const SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color:
                                                            AppColors.slate900,
                                                      ),
                                                )
                                              : const Icon(
                                                  Icons.camera_alt,
                                                  color: AppColors.slate900,
                                                  size: 20,
                                                ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                GestureDetector(
                                  onTap: _pickAndUploadPhoto,
                                  child: Text(
                                    'Change Photo',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildTextField(
                            label: 'Full Name',
                            controller: _nameController,
                            hint: 'Enter your name',
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            label: 'Email Address',
                            controller: _emailController,
                            hint: 'Enter your email',
                            keyboardType: TextInputType.emailAddress,
                            readOnly: true,
                          ),
                          const SizedBox(height: 20),
                          _buildPhoneField(label: 'Phone Number'),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: Colors.grey[100]!)),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: authProvider.isLoading
                            ? null
                            : () async {
                                final error = await context
                                    .read<AuthProvider>()
                                    .updateProfile(
                                      displayName: _nameController.text,
                                      phone: _phoneController.text,
                                      phoneIso: _phoneInitialCountryCode,
                                      phoneNational: _phoneNational,
                                    );

                                if (!context.mounted) return;

                                if (error == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Profile updated'),
                                    ),
                                  );
                                  Navigator.pop(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(error),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.slate900,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          authProvider.isLoading ? 'Saving...' : 'Save Changes',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.slate900,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          readOnly: readOnly,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.slate900,
          ),
          decoration: InputDecoration(
            hintText: hint,
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
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField({required String label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.slate900,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        IntlPhoneField(
          decoration: InputDecoration(
            hintText: 'Enter phone number',
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
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          initialCountryCode: _phoneInitialCountryCode,
          initialValue: _phoneInitialNumber,
          onChanged: (phone) {
            _phoneController.text = phone.completeNumber;
            _phoneInitialCountryCode = phone.countryISOCode;
            _phoneInitialNumber = phone.number;
            _phoneNational = phone.number;
          },
        ),
      ],
    );
  }
}
