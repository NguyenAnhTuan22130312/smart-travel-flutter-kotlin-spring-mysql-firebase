import 'dart:convert';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/presentation/blocs/profile/profile_bloc.dart';
import 'package:smart_travel/presentation/blocs/profile/profile_event.dart';
import 'package:smart_travel/presentation/blocs/profile/profile_state.dart';
import 'package:smart_travel/presentation/theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'vi';
  bool _darkModeEnabled = false;
  bool _emailNotifications = true;
  bool _pushNotifications = false;
  bool _smsNotifications = false;

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(LoadSettings());
  }

  void _loadSettingsData(SettingsLoaded state) {
    final settings = state.settings;

    // Parse language settings
    if (settings.languageSettings != null && settings.languageSettings!.isNotEmpty) {
      try {
        final langMap = json.decode(settings.languageSettings!);
        _selectedLanguage = langMap['lang'] ?? 'vi';
      } catch (e) {
        _selectedLanguage = 'vi';
      }
    }

    // Dark mode
    _darkModeEnabled = settings.darkModeEnabled;

    // Parse notification settings
    if (settings.notificationSettings != null && settings.notificationSettings!.isNotEmpty) {
      try {
        final notifMap = json.decode(settings.notificationSettings!);
        _emailNotifications = notifMap['email'] ?? true;
        _pushNotifications = notifMap['push'] ?? false;
        _smsNotifications = notifMap['sms'] ?? false;
      } catch (e) {
        _emailNotifications = true;
        _pushNotifications = false;
        _smsNotifications = false;
      }
    }

    setState(() {});
  }

  void _updateLanguage(String? newLanguage) {
    if (newLanguage != null && newLanguage != _selectedLanguage) {
      setState(() {
        _selectedLanguage = newLanguage;
      });

      final langSettings = json.encode({'lang': newLanguage});
      context.read<ProfileBloc>().add(
            UpdateSettings(languageSettings: langSettings),
          );
    }
  }

  void _updateDarkMode(bool value) {
    setState(() {
      _darkModeEnabled = value;
    });

    context.read<ProfileBloc>().add(
          UpdateSettings(darkModeEnabled: value),
        );
  }

  void _updateNotifications() {
    final notifSettings = json.encode({
      'email': _emailNotifications,
      'push': _pushNotifications,
      'sms': _smsNotifications,
    });

    context.read<ProfileBloc>().add(
          UpdateSettings(notificationSettings: notifSettings),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is SettingsUpdateSuccess) {
            final snackBar = SnackBar(
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: 'Thành công',
                message: state.message,
                contentType: ContentType.success,
              ),
            );
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(snackBar);
          } else if (state is ProfileError) {
            final snackBar = SnackBar(
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: 'Lỗi',
                message: state.message,
                contentType: ContentType.failure,
              ),
            );
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(snackBar);
          } else if (state is SettingsLoaded) {
            _loadSettingsData(state);
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading && state is! SettingsLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: [
              // Language Section
              _buildSectionHeader('Ngôn ngữ'),
              _buildLanguageTile(),
              const Divider(height: 1),

              const SizedBox(height: 16),

              // Appearance Section
              _buildSectionHeader('Giao diện'),
              _buildDarkModeTile(),
              const Divider(height: 1),

              const SizedBox(height: 16),

              // Notifications Section
              _buildSectionHeader('Thông báo'),
              _buildNotificationTile(
                title: 'Thông báo Email',
                value: _emailNotifications,
                onChanged: (value) {
                  setState(() {
                    _emailNotifications = value;
                  });
                  _updateNotifications();
                },
              ),
              const Divider(height: 1, indent: 16),
              _buildNotificationTile(
                title: 'Thông báo Push',
                value: _pushNotifications,
                onChanged: (value) {
                  setState(() {
                    _pushNotifications = value;
                  });
                  _updateNotifications();
                },
              ),
              const Divider(height: 1, indent: 16),
              _buildNotificationTile(
                title: 'Thông báo SMS',
                value: _smsNotifications,
                onChanged: (value) {
                  setState(() {
                    _smsNotifications = value;
                  });
                  _updateNotifications();
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildLanguageTile() {
    return Container(
      color: Theme.of(context).cardColor,
      child: ListTile(
        leading: const Icon(Icons.language, color: Color(0xFF4A5568)),
        title: const Text(
          'Ngôn ngữ',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        trailing: DropdownButton<String>(
          value: _selectedLanguage,
          underline: const SizedBox(),
          items: const [
            DropdownMenuItem(
              value: 'vi',
              child: Row(
                children: [
                  Text('🇻🇳', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 8),
                  Text('Tiếng Việt'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'en',
              child: Row(
                children: [
                  Text('🇬🇧', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 8),
                  Text('English'),
                ],
              ),
            ),
          ],
          onChanged: _updateLanguage,
        ),
      ),
    );
  }

  Widget _buildDarkModeTile() {
    return Container(
      color: Theme.of(context).cardColor,
      child: SwitchListTile(
        secondary: const Icon(Icons.dark_mode, color: Color(0xFF4A5568)),
        title: const Text(
          'Chế độ tối',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        subtitle: const Text('Theo môi trường'),
        value: _darkModeEnabled,
        onChanged: _updateDarkMode,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildNotificationTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      color: Theme.of(context).cardColor,
      child: SwitchListTile(
        secondary: const Icon(Icons.notifications_outlined, color: Color(0xFF4A5568)),
        title: Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }
}
