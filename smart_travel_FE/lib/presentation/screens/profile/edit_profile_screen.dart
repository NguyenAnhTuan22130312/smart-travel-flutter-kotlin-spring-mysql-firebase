import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/presentation/blocs/profile/profile_bloc.dart';
import 'package:smart_travel/presentation/blocs/profile/profile_event.dart';
import 'package:smart_travel/presentation/blocs/profile/profile_state.dart';
import 'package:smart_travel/presentation/widgets/common/custom_button.dart';
import 'package:smart_travel/presentation/widgets/common/custom_textfield.dart';
import 'package:smart_travel/presentation/widgets/profile/avatar_picker_widget.dart';
import 'package:smart_travel/presentation/theme/app_colors.dart';
import 'package:smart_travel/core/utils/auth_error_handler_mixin.dart';
import 'package:smart_travel/l10n/app_localizations.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> with AuthErrorHandlerMixin {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();

  String? _avatarUrl;
  String? _selectedGender;
  DateTime? _dateOfBirth;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() {
    final state = context.read<ProfileBloc>().state;
    if (state is ProfileLoaded) {
      final user = state.user;
      _fullNameController.text = user.fullName;
      _phoneController.text = user.phone ?? '';
      _bioController.text = user.bio ?? '';
      _addressController.text = user.address ?? '';
      _cityController.text = user.city ?? '';
      _countryController.text = user.country ?? '';
      _avatarUrl = user.avatarUrl;
      _selectedGender = user.gender;
      _dateOfBirth = user.dateOfBirth;
      setState(() {});
    } else {
      // Load profile if not loaded
      context.read<ProfileBloc>().add(LoadProfile());
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      context.read<ProfileBloc>().add(
        UpdateProfile(
          fullName: _fullNameController.text.trim(),
          phone:
              _phoneController.text.trim().isEmpty
                  ? null
                  : _phoneController.text.trim(),
          bio:
              _bioController.text.trim().isEmpty
                  ? null
                  : _bioController.text.trim(),
          gender: _selectedGender,
          dateOfBirth: _dateOfBirth,
          address:
              _addressController.text.trim().isEmpty
                  ? null
                  : _addressController.text.trim(),
          city:
              _cityController.text.trim().isEmpty
                  ? null
                  : _cityController.text.trim(),
          country:
              _countryController.text.trim().isEmpty
                  ? null
                  : _countryController.text.trim(),
          avatarUrl: _avatarUrl,
        ),
      );
    }
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.editProfileTitle),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.mainGradient),
        ),
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            final snackBar = SnackBar(
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.background,
              content: AwesomeSnackbarContent(
                title: AppLocalizations.of(context)!.success,
                message: state.message,
                contentType: ContentType.success,
              ),
            );
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(snackBar);
            Navigator.pop(context);
          } else if (state is ProfileError) {
            // Check if error is related to token expiration
            if (handleTokenExpiration(state.message)) return;

            final snackBar = SnackBar(
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: AppLocalizations.of(context)!.error,
                message: state.message,
                contentType: ContentType.failure,
              ),
            );
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(snackBar);
          } else if (state is ProfileLoaded) {
            _loadProfileData();
          }
        },
        builder: (context, state) {
          final isLoading = state is ProfileLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar Section with AvatarPickerWidget
                  Center(
                    child: AvatarPickerWidget(
                      currentAvatarUrl: _avatarUrl,
                      isLoading: isLoading,
                      onAvatarChanged: (newAvatarUrl) {
                        setState(() {
                          _avatarUrl = newAvatarUrl;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Full Name
                  CustomTextField(
                    label: AppLocalizations.of(context)!.fullNameLabel,
                    hintText: AppLocalizations.of(context)!.fullNameHint,
                    controller: _fullNameController,
                    prefixIcon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.fullNameRequired;
                      }
                      if (value.length < 2 || value.length > 100) {
                        return AppLocalizations.of(context)!.fullNameLength;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Phone
                  CustomTextField(
                    label: AppLocalizations.of(context)!.phoneLabel,
                    hintText: AppLocalizations.of(context)!.phoneHint,
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                          return AppLocalizations.of(context)!.phoneInvalid;
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Gender
                  Text(
                    AppLocalizations.of(context)!.genderLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedGender,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.wc_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: [
                      DropdownMenuItem(value: 'MALE', child: Text(AppLocalizations.of(context)!.genderMale)),
                      DropdownMenuItem(value: 'FEMALE', child: Text(AppLocalizations.of(context)!.genderFemale)),
                      DropdownMenuItem(value: 'OTHER', child: Text(AppLocalizations.of(context)!.genderOther)),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Date of Birth
                  Text(
                    AppLocalizations.of(context)!.dobLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _selectDateOfBirth,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.calendar_today_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _dateOfBirth != null
                            ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                            : AppLocalizations.of(context)!.dobPlaceholder,
                        style: TextStyle(
                          color:
                              _dateOfBirth != null ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Bio
                  Text(
                    AppLocalizations.of(context)!.bioLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _bioController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.bioHint,
                      prefixIcon: const Icon(Icons.description_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF2563EB),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    validator: (value) {
                      if (value != null && value.length > 1000) {
                        return AppLocalizations.of(context)!.bioMax;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Address
                  CustomTextField(
                    label: AppLocalizations.of(context)!.addressLabel,
                    hintText: AppLocalizations.of(context)!.addressHint,
                    controller: _addressController,
                    prefixIcon: Icons.home_outlined,
                    validator: (value) {
                      if (value != null && value.length > 100) {
                        return AppLocalizations.of(context)!.addressMax;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // City
                  CustomTextField(
                    label: AppLocalizations.of(context)!.cityLabel,
                    hintText: AppLocalizations.of(context)!.cityHint,
                    controller: _cityController,
                    prefixIcon: Icons.location_city_outlined,
                    validator: (value) {
                      if (value != null && value.length > 50) {
                        return AppLocalizations.of(context)!.cityMax;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Country
                  CustomTextField(
                    label: AppLocalizations.of(context)!.countryLabel,
                    hintText: AppLocalizations.of(context)!.countryHint,
                    controller: _countryController,
                    prefixIcon: Icons.flag_outlined,
                    validator: (value) {
                      if (value != null && value.length > 50) {
                        return AppLocalizations.of(context)!.countryMax;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Save Button
                  PrimaryButton(
                    text: isLoading ? AppLocalizations.of(context)!.saving : AppLocalizations.of(context)!.saveChanges,
                    onPressed: isLoading ? () {} : _handleSave,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
