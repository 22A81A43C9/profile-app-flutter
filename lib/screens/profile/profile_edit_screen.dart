import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../constants/app_colors.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  
  late TextEditingController _degreeController;
  late TextEditingController _institutionController;
  late TextEditingController _yearController;
  
  late TextEditingController _jobTitleController;
  late TextEditingController _companyController;
  late TextEditingController _experienceController;
  late TextEditingController _skillsController;
  late TextEditingController _bioController;

  File? _imageFile;
  String? _existingPhotoUrl;
  bool _isInitial = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _degreeController = TextEditingController();
    _institutionController = TextEditingController();
    _yearController = TextEditingController();
    _jobTitleController = TextEditingController();
    _companyController = TextEditingController();
    _experienceController = TextEditingController();
    _skillsController = TextEditingController();
    _bioController = TextEditingController();
  }

  void _loadExistingData() {
    final profile = Provider.of<ProfileProvider>(context, listen: false).profile;
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    
    if (profile != null) {
      _nameController.text = profile.name;
      _emailController.text = profile.email;
      _phoneController.text = profile.phoneNumber;
      _existingPhotoUrl = profile.photoUrl;
      
      _degreeController.text = profile.education.degree;
      _institutionController.text = profile.education.institution;
      _yearController.text = profile.education.yearOfPassing;
      
      _jobTitleController.text = profile.professional.jobTitle;
      _companyController.text = profile.professional.company;
      _experienceController.text = profile.professional.experience;
      _skillsController.text = profile.professional.skills.join(', ');
      _bioController.text = profile.professional.bio;
    } else {
      _phoneController.text = user?.phoneNumber ?? '';
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    
    // Check if phone number changed
    if (profileProvider.profile != null && _phoneController.text != profileProvider.profile!.phoneNumber) {
      // Trigger OTP re-verification
      _triggerPhoneReverification();
      return;
    }

    final profile = UserProfile(
      id: authProvider.user!.uid,
      name: _nameController.text,
      email: _emailController.text,
      phoneNumber: _phoneController.text,
      photoUrl: _existingPhotoUrl,
      education: Education(
        degree: _degreeController.text,
        institution: _institutionController.text,
        yearOfPassing: _yearController.text,
      ),
      professional: ProfessionalDetails(
        jobTitle: _jobTitleController.text,
        company: _companyController.text,
        experience: _experienceController.text,
        skills: _skillsController.text.split(',').map((e) => e.trim()).toList(),
        bio: _bioController.text,
      ),
    );

    await profileProvider.saveProfile(profile, _imageFile);
    Navigator.pushReplacementNamed(context, '/profile_view');
  }

  void _triggerPhoneReverification() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.sendOtp(
      _phoneController.text,
      (verificationId) {
        // Here we'd usually go to a special OTP screen that updates the profile after success
        // For simplicity in this task, I'll assume standard flow
        Navigator.pushNamed(context, '/otp');
      },
      (error) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error))),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitial) {
      _loadExistingData();
      _isInitial = false;
    }

    final isLoading = Provider.of<ProfileProvider>(context).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Configure Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
            )
          else
            IconButton(onPressed: _onSave, icon: const Icon(Icons.check, color: AppColors.primary)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImagePicker(),
              const SizedBox(height: 32),
              _buildSectionTitle('Basic Information'),
              _buildCard([
                _buildTextField('Full Name', _nameController, Icons.person),
                _buildTextField('Email', _emailController, Icons.email, keyboardType: TextInputType.emailAddress),
                _buildTextField('Phone Number', _phoneController, Icons.phone, keyboardType: TextInputType.phone),
              ]),
              const SizedBox(height: 24),
              _buildSectionTitle('Education'),
              _buildCard([
                _buildTextField('Degree', _degreeController, Icons.school),
                _buildTextField('Institution', _institutionController, Icons.business),
                _buildTextField('Year of Passing', _yearController, Icons.calendar_today, keyboardType: TextInputType.number),
              ]),
              const SizedBox(height: 24),
              _buildSectionTitle('Professional Details'),
              _buildCard([
                _buildTextField('Job Title', _jobTitleController, Icons.work),
                _buildTextField('Company', _companyController, Icons.apartment),
                _buildTextField('Experience (Years)', _experienceController, Icons.history, keyboardType: TextInputType.number),
                _buildTextField('Skills (comma separated)', _skillsController, Icons.bolt),
                _buildTextField('Short Bio', _bioController, Icons.description, maxLines: 3),
              ]),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Save & Preview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Stack(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white,
              backgroundImage: _imageFile != null
                  ? FileImage(_imageFile!)
                  : (_existingPhotoUrl != null ? NetworkImage(_existingPhotoUrl!) : null) as ImageProvider?,
              child: _imageFile == null && _existingPhotoUrl == null
                  ? const Icon(Icons.camera_alt, size: 40, color: AppColors.textSecondary)
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.edit, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {TextInputType? keyboardType, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }
}
