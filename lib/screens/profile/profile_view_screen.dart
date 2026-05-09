import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../constants/app_colors.dart';
import '../../widgets/profile_card_widget.dart';

class ProfileViewScreen extends StatefulWidget {
  const ProfileViewScreen({super.key});

  @override
  State<ProfileViewScreen> createState() => _ProfileViewScreenState();
}

class _ProfileViewScreenState extends State<ProfileViewScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();

  Future<void> _shareToWhatsApp() async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/profile_card.png';
    
    await _screenshotController.captureAndSave(
      directory.path,
      fileName: 'profile_card.png',
    );

    await Share.shareXFiles(
      [XFile(imagePath)],
      text: 'Check out my professional profile card!',
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileProvider>(context).profile;

    if (profile == null) {
      return const Scaffold(body: Center(child: Text('No profile found')));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () async {
            await Provider.of<AuthProvider>(context, listen: false).logout();
            Navigator.pushReplacementNamed(context, '/login');
          },
          icon: const Icon(Icons.logout_rounded, color: AppColors.error),
        ),
        title: const Text('Digital Profile Card', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/profile_edit'),
            icon: const Icon(Icons.edit_note_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Screenshot(
              controller: _screenshotController,
              child: ProfileCardWidget(profile: profile),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    label: 'Edit Profile',
                    icon: Icons.edit,
                    color: Colors.white,
                    textColor: AppColors.primary,
                    onTap: () => Navigator.pushNamed(context, '/profile_edit'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    label: 'Share on WhatsApp',
                    icon: Icons.share,
                    color: AppColors.primary,
                    textColor: Colors.white,
                    onTap: _shareToWhatsApp,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: color == Colors.white ? Border.all(color: AppColors.primary.withOpacity(0.1)) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
