import 'dart:convert';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:smart_travel/l10n/app_localizations.dart';
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
    if (settings.languageSettings != null &&
        settings.languageSettings!.isNotEmpty) {
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
    if (settings.notificationSettings != null &&
        settings.notificationSettings!.isNotEmpty) {
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

    context.read<ProfileBloc>().add(UpdateSettings(darkModeEnabled: value));
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
        title: Text(AppLocalizations.of(context)!.settings),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.mainGradient),
        ),
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is SettingsUpdateSuccess) {
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
          } else if (state is ProfileError) {
            // Check if error is related to token expiration
            if (state.message.toLowerCase().contains('unauthorized') ||
                state.message.toLowerCase().contains('401') ||
                state.message.toLowerCase().contains(
                  'phiên đăng nhập hết hạn',
                ) ||
                state.message.toLowerCase().contains('token')) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
              return;
            }

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
          } else if (state is SettingsLoaded) {
            _loadSettingsData(state);
          } else if (state is AccountDeletedSuccess) {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/login', (route) => false);
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading && state is! SettingsLoaded) {
            return Center(
              child: Lottie.asset(
                'assets/lottie/travel_is_fun.json',
                width: 200,
                height: 500,
                repeat: true,
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Language Section
              _buildSection(AppLocalizations.of(context)!.language, [
                _buildLanguageTile(),
              ]),

              const SizedBox(height: 16),

              // Appearance Section
              _buildSection(AppLocalizations.of(context)!.appearance, [
                _buildDarkModeTile(),
              ]),

              const SizedBox(height: 16),

              // Notifications Section
              _buildSection(AppLocalizations.of(context)!.notifications, [
                _buildNotificationTile(
                  title: AppLocalizations.of(context)!.emailNotifications,
                  value: _emailNotifications,
                  onChanged: (value) {
                    setState(() {
                      _emailNotifications = value;
                    });
                    _updateNotifications();
                  },
                ),
                const Divider(height: 1),
                _buildNotificationTile(
                  title: AppLocalizations.of(context)!.pushNotifications,
                  value: _pushNotifications,
                  onChanged: (value) {
                    setState(() {
                      _pushNotifications = value;
                    });
                    _updateNotifications();
                  },
                ),
                const Divider(height: 1),
                _buildNotificationTile(
                  title: AppLocalizations.of(context)!.smsNotifications,
                  value: _smsNotifications,
                  onChanged: (value) {
                    setState(() {
                      _smsNotifications = value;
                    });
                    _updateNotifications();
                  },
                ),
              ]),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLanguageTile() {
    return ListTile(
      leading: const Icon(Icons.language, color: Color(0xFF4A5568)),
      title: Text(
        AppLocalizations.of(context)!.language,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
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
    );
  }

  Widget _buildDarkModeTile() {
    return SwitchListTile(
      secondary: const Icon(Icons.dark_mode, color: Color(0xFF4A5568)),
      title: Text(
        AppLocalizations.of(context)!.darkMode,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(AppLocalizations.of(context)!.systemDefault),
      value: _darkModeEnabled,
      onChanged: _updateDarkMode,
      activeColor: AppColors.primary,
    );
  }

  Widget _buildNotificationTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: const Icon(
        Icons.notifications_outlined,
        color: Color(0xFF4A5568),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }
}
