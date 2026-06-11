import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../homescreen.dart';
import '../lessondata.dart';
import '../smartlookup.dart';
import '../account/auth_screen.dart';
import '../account/notif.dart';
import '../progress.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final int _currentIndex = 3;
  User? _currentUser = FirebaseAuth.instance.currentUser;
  bool _isSaving = false;

  // Settings State Trackers
  bool _notificationsEnabled = false;

  final List<String> _avatarOptions = [
    'asset/bear_avatar.png',
    'asset/penguin_avatar.png',
    'asset/dog_avatar.png',
    'asset/seal_avatar.png',
  ];

  String _currentAvatar = 'asset/bear_avatar.png';

  @override
  void initState() {
    super.initState();
    _loadUserAvatar();
  }

  void _loadUserAvatar() {
    if (_currentUser?.photoURL != null && _currentUser!.photoURL!.isNotEmpty) {
      setState(() {
        _currentAvatar = _currentUser!.photoURL!;
      });
    }
  }

  String _getDisplayUsername() {
    if (_currentUser?.displayName != null && _currentUser!.displayName!.isNotEmpty) {
      return _currentUser!.displayName!;
    }
    final email = _currentUser?.email ?? "user@smartsensetutor.internal";
    return email.split('@').first;
  }

  String _getSubtextLabel() {
    return _getDisplayUsername().toLowerCase().replaceAll(' ', '');
  }

  void _handleLogout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
            (route) => false,
      );
    }
  }

  void _openEditProfileSheet() {
    final TextEditingController nameController = TextEditingController(text: _getDisplayUsername());
    String selectedAvatarLocal = _currentAvatar;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Edit Profile",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2C4379)),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Choose an Avatar",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _avatarOptions.length,
                      itemBuilder: (context, index) {
                        final avatarPath = _avatarOptions[index];
                        final isSelected = selectedAvatarLocal == avatarPath;

                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              selectedAvatarLocal = avatarPath;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 14),
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              color: const Color(0xFFCBEFFA),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? const Color(0xFF70D3F4) : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                avatarPath,
                                fit: BoxFit.contain,
                                errorBuilder: (c, e, s) => const Icon(Icons.account_circle, size: 50),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Username",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.transparent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF70D3F4), width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF70D3F4),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isSaving ? null : () async {
                        final updatedName = nameController.text.trim();
                        if (updatedName.isEmpty || _currentUser == null) return;

                        setModalState(() => _isSaving = true);

                        try {
                          await _currentUser!.updateDisplayName(updatedName);
                          await _currentUser!.updatePhotoURL(selectedAvatarLocal);

                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(_currentUser!.uid)
                              .update({
                            'username': updatedName,
                            'searchKey': updatedName.toLowerCase(),
                            'avatarAsset': selectedAvatarLocal,
                          });

                          setState(() {
                            _currentUser = FirebaseAuth.instance.currentUser;
                            _currentAvatar = selectedAvatarLocal;
                          });

                          if (context.mounted) Navigator.pop(context);
                        } catch (e) {
                          print("Error saving profile: $e");
                        } finally {
                          setModalState(() => _isSaving = false);
                        }
                      },
                      child: _isSaving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text("Save Changes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'Profile':
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
        break;
      case 'Settings': break;
      case 'Account Management': break;
      case 'Privacy Policy': break;
    }
  }

  @override
  Widget build(BuildContext context) {
    const lightBlueHeaderColor = Color(0xFF70D3F4);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 160,
            color: lightBlueHeaderColor,
            padding: const EdgeInsets.only(left: 24, bottom: 20),
            alignment: Alignment.bottomLeft,
            child: const Text(
              "Profile",
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Color(0xFF2C4379)),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBEFFA),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          _currentAvatar,
                          fit: BoxFit.contain,
                          errorBuilder: (c, e, s) => const Icon(Icons.account_circle, size: 100, color: Colors.blueGrey),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _openEditProfileSheet,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Edit", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                        SizedBox(width: 4),
                        Icon(Icons.edit, size: 16),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(_getDisplayUsername(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(_getSubtextLabel(), style: const TextStyle(fontSize: 14, color: Colors.black38)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  _buildSettingsDropdown(),
                  _buildDivider(),
                  _buildAccountManagementDropdown(),
                  _buildDivider(),
                  _buildPrivacyPolicyDropdown(),
                  _buildDivider(),

                  const SizedBox(height: 40),
                  InkWell(
                    onTap: _handleLogout,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black12, width: 1),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Logout", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C4379))),
                          Icon(Icons.power_settings_new_rounded, color: Color(0xFF2C4379), size: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex || index == 3) return;
          switch (index) {
            case 0:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
              break;
            case 1:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LessonData()));
              break;
            case 2:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SmartLookup()));
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF2C4379),
        unselectedItemColor: Colors.grey,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          const BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "Lessons"),
          const BottomNavigationBarItem(icon: Icon(Icons.send), label: "Smart Lookup"),
          BottomNavigationBarItem(
            label: "More",
            icon: PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz),
              offset: const Offset(0, -220),
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: _handleMenuSelection,
              itemBuilder: (BuildContext context) {
                return ['Profile', 'Settings', 'Account Management', 'Privacy Policy'].map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2C4379))),
                  );
                }).toList();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsDropdown() {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: const Text(
          "Settings",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2C4379)),
        ),
        trailing: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF2C4379), size: 28),
        childrenPadding: EdgeInsets.zero,
        children: [
          _buildSettingsSubRow(
            "Notifications",
            value: _notificationsEnabled,
            onChanged: (bool newValue) async {
              setState(() {
                _notificationsEnabled = newValue;
              });

              if (newValue) {
                NotificationManager.showAchievement(
                  context: context,
                  title: "Notifications Enabled!",
                  description: "You'll now see alerts when you hit milestones.",
                  badgePath: "asset/gold.png",
                  avatarPath: _currentAvatar,
                );

                final int totalPerfectScores = ProgressService().getUnlockedLevel('General');
                if (totalPerfectScores >= 10) {
                  await Future.delayed(const Duration(milliseconds: 4000));

                  if (mounted) {
                    NotificationManager.showAchievement(
                      context: context,
                      title: "Royal",
                      description: "Re-verified: 10/10 perfect scores achieved!",
                      badgePath: "asset/bronze.png",
                      avatarPath: "asset/perfectscore.png",
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSubRow(String subtitle, {required bool value, required ValueChanged<bool> onChanged}) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 32, right: 24),
      title: Text(
        subtitle,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF70D3F4),
        activeTrackColor: const Color(0xFFCBEFFA),
      ),
    );
  }

  Widget _buildAccountManagementDropdown() {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: const Text(
          "Account Management",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C4379),
          ),
        ),
        trailing: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Color(0xFF2C4379),
          size: 28,
        ),
        children: [
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text("Change Password"),
            onTap: () async {
              final email = FirebaseAuth.instance.currentUser?.email;

              if (email == null) return;

              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Password reset email sent."),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Failed to send reset email."),
                  ),
                );
              }
            },
          ),

          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              "Delete Account",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyPolicyDropdown() {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: const Text(
          "Privacy Policy",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2C4379)),
        ),
        trailing: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF2C4379), size: 28),
        childrenPadding: const EdgeInsets.only(left: 24, right: 24, bottom: 20, top: 8),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPolicyItem(
                title: "Last Updated: June 6, 2026",
                body: "This Privacy Policy explains how we collect and use your information when you use our mobile app. We are committed to protecting your personal data and keeping it secure.",
                isHeaderItem: true,
              ),
              _buildPolicyItem(
                title: "What We Collect and Why",
                body: "We collect your name, username, and email address (such as user@gmail.com) when you sign up. We also collect basic device info and data on how you use the app. We use this information to personalize your lessons, track your progress, and fix any technical bugs to improve your experience.",
              ),
              _buildPolicyItem(
                title: "Data Sharing and Security",
                body: "Your information is stored safely and is never sold, rented, or shared with third parties for marketing. We only share data with essential service providers, like our cloud hosting platform, to keep the app running.",
              ),
              _buildPolicyItem(
                title: "Your Controls and Choices",
                body: "You have full control over your privacy directly in the app. You can turn notifications on or off, change your account privacy settings, or permanently delete your account and all of your data at any time through the settings menu.",
              ),
              _buildPolicyItem(
                title: "Contact Us",
                body: "If you have any questions about your privacy, please email our support team at sstsupport@education.co.",
                isLastItem: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyItem({
    required String title,
    required String body,
    bool isHeaderItem = false,
    bool isLastItem = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          body,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            height: 1.45,
          ),
        ),
        if (!isLastItem) ...[
          const SizedBox(height: 12),
          const Divider(color: Colors.black12, thickness: 0.8, height: 16),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildDivider() {
    return const Divider(color: Colors.black12, thickness: 1, height: 1);
  }

  Widget _buildSubDivider() {
    return const Padding(
      padding: EdgeInsets.only(left: 32.0, right: 16.0),
      child: Divider(color: Color(0xFFE2E8F0), thickness: 0.8, height: 1),
    );
  }
}

class NotificationManager {
  static OverlayEntry? _currentEntry;

  static void showAchievement({
    required BuildContext context,
    required String title,
    required String description,
    required String badgePath,
    required String avatarPath,
  }) {
    _currentEntry?.remove();

    _currentEntry = OverlayEntry(
      builder: (context) => AchievementNotification(
        title: title,
        description: description,
        badgePath: badgePath,
        avatarPath: avatarPath,
        onDismissed: () {
          _currentEntry?.remove();
          _currentEntry = null;
        },
      ),
    );

    Overlay.of(context).insert(_currentEntry!);
  }
}