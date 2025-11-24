// mobile-app/lib/src/views/profile_screen.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/offline_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final OfflineService _offlineService = OfflineService();
  User? _currentUser;
  bool _isEditing = false;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _farmSizeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await _offlineService.getUser();
    setState(() {
      _currentUser = user ?? User(
        id: '1',
        name: 'Farmer',
        email: '',
        phone: '',
        joinedAt: DateTime.now(),
      );
    });
    _populateControllers();
  }

  void _populateControllers() {
    _nameController.text = _currentUser?.name ?? '';
    _emailController.text = _currentUser?.email ?? '';
    _phoneController.text = _currentUser?.phone ?? '';
    _farmSizeController.text = (_currentUser?.farmSize ?? 0).toString();
  }

  Future<void> _saveProfile() async {
    final updatedUser = User(
      id: _currentUser!.id,
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      preferredLanguage: _currentUser!.preferredLanguage,
      region: _currentUser!.region,
      farmSize: double.tryParse(_farmSizeController.text) ?? 0.0,
      mainCrops: _currentUser!.mainCrops,
      joinedAt: _currentUser!.joinedAt,
      isPremium: _currentUser!.isPremium,
      totalScans: _currentUser!.totalScans,
      successfulDetections: _currentUser!.successfulDetections,
    );

    await _offlineService.saveUser(updatedUser);
    setState(() {
      _currentUser = updatedUser;
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _populateControllers(); // Reset changes if canceling
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: _toggleEdit,
          ),
        ],
      ),
      body: _currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Header
                  _buildProfileHeader(),
                  const SizedBox(height: 24),
                  
                  // Profile Form
                  _buildProfileForm(),
                  const SizedBox(height: 24),
                  
                  // Statistics
                  _buildStatistics(),
                  const SizedBox(height: 24),
                  
                  // Settings
                  _buildSettingsSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.green[100],
              child: Icon(
                Icons.person,
                size: 40,
                color: Colors.green[700],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _currentUser!.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _currentUser!.region,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Chip(
              label: Text(
                _currentUser!.isPremium ? 'Premium Farmer' : 'Community Farmer',
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: _currentUser!.isPremium 
                  ? Colors.amber[100] 
                  : Colors.green[100],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildEditableField(
              'Full Name',
              _nameController,
              Icons.person,
              _isEditing,
            ),
            const SizedBox(height: 12),
            _buildEditableField(
              'Email',
              _emailController,
              Icons.email,
              _isEditing,
            ),
            const SizedBox(height: 12),
            _buildEditableField(
              'Phone',
              _phoneController,
              Icons.phone,
              _isEditing,
            ),
            const SizedBox(height: 12),
            _buildEditableField(
              'Farm Size (acres)',
              _farmSizeController,
              Icons.agriculture,
              _isEditing,
              textInputType: TextInputType.number,
            ),
            if (_isEditing) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(
    String label,
    TextEditingController controller,
    IconData icon,
    bool enabled, {
    TextInputType textInputType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      keyboardType: textInputType,
    );
  }

  Widget _buildStatistics() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Farming Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildStatItem('Total Scans', _currentUser!.totalScans.toString(), Icons.photo_camera),
                _buildStatItem('Success Rate', _currentUser!.successRatePercentage, Icons.verified),
                _buildStatItem('Farm Size', '${_currentUser!.farmSize} acres', Icons.agriculture),
                _buildStatItem('Main Crops', _currentUser!.mainCrops.length.toString(), Icons.grass),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.green, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'App Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingsItem(
              'Language',
              _currentUser!.languageDisplayName,
              Icons.language,
              () => _showLanguageDialog(),
            ),
            _buildSettingsItem(
              'Offline Mode',
              'Enabled',
              Icons.wifi_off,
              () {},
            ),
            _buildSettingsItem(
              'Voice Feedback',
              'Enabled',
              Icons.volume_up,
              () {},
            ),
            _buildSettingsItem(
              'Clear History',
              'Remove all scan data',
              Icons.delete,
              _clearHistory,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('Kiswahili', 'sw'),
            _buildLanguageOption('English', 'en'),
            _buildLanguageOption('Gikuyu', 'kik'),
            _buildLanguageOption('Dholuo', 'luo'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String language, String code) {
    return ListTile(
      title: Text(language),
      trailing: _currentUser!.preferredLanguage == code
          ? const Icon(Icons.check, color: Colors.green)
          : null,
      onTap: () {
        setState(() {
          _currentUser = User(
            id: _currentUser!.id,
            name: _currentUser!.name,
            email: _currentUser!.email,
            phone: _currentUser!.phone,
            preferredLanguage: code,
            region: _currentUser!.region,
            farmSize: _currentUser!.farmSize,
            mainCrops: _currentUser!.mainCrops,
            joinedAt: _currentUser!.joinedAt,
            isPremium: _currentUser!.isPremium,
            totalScans: _currentUser!.totalScans,
            successfulDetections: _currentUser!.successfulDetections,
          );
        });
        _offlineService.saveUser(_currentUser!);
        Navigator.pop(context);
      },
    );
  }

  void _clearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to delete all scan history? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _offlineService.clearAllData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('History cleared successfully')),
              );
              _loadUserData(); // Reload to refresh UI
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
