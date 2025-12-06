import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/database_service.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../theme/custom_components.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({Key? key}) : super(key: key);

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  final db = DatabaseService();
  late Future<List<User>> _staffFuture;

  bool _showAddForm = false;
  bool _isLoading = false;

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  void _loadStaff() {
    _staffFuture = _getStaffMembers();
    setState(() {});
  }

  Future<List<User>> _getStaffMembers() async {
    try {
      final allUsers = await db.getAllUsers();
      return allUsers.where((u) => u.role == UserRole.staff).toList();
    } catch (e) {
      print('Error loading staff: $e');
      return [];
    }
  }

  void _resetForm() {
    _firstNameCtrl.clear();
    _lastNameCtrl.clear();
    _emailCtrl.clear();
    _passwordCtrl.clear();
    _confirmPasswordCtrl.clear();
    _errorMessage = '';
    setState(() => _showAddForm = false);
  }

  bool _validateForm() {
    _errorMessage = '';

    if (_firstNameCtrl.text.isEmpty) {
      _errorMessage = 'First name is required';
      return false;
    }
    if (_lastNameCtrl.text.isEmpty) {
      _errorMessage = 'Last name is required';
      return false;
    }
    if (_emailCtrl.text.isEmpty) {
      _errorMessage = 'Email is required';
      return false;
    }
    if (!_emailCtrl.text.contains('@')) {
      _errorMessage = 'Invalid email format';
      return false;
    }
    if (_passwordCtrl.text.isEmpty) {
      _errorMessage = 'Password is required';
      return false;
    }
    if (_passwordCtrl.text.length < 8) {
      _errorMessage = 'Password must be at least 8 characters';
      return false;
    }
    if (_passwordCtrl.text != _confirmPasswordCtrl.text) {
      _errorMessage = 'Passwords do not match';
      return false;
    }

    return true;
  }

  Future<void> _addStaff() async {
    if (!_validateForm()) {
      setState(() {});
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Check if email already exists
      final existingUsers = await db.getAllUsers();
      if (existingUsers.any((u) => u.email == _emailCtrl.text.trim())) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Email already exists';
            _isLoading = false;
          });
        }
        return;
      }

      // Create new staff member
      final newStaff = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        role: UserRole.staff,
      );

      // Save to database
      await db.createUser(newStaff);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Staff member added successfully!'),
            backgroundColor: AppTheme.successGreen,
            duration: Duration(seconds: 2),
          ),
        );
        _loadStaff();
        _resetForm();
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _removeStaff(User staff) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        title: const Text(
          'Remove Staff Member?',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          'Are you sure you want to remove ${staff.firstName} ${staff.lastName}? This action cannot be undone.',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Remove',
              style: TextStyle(color: AppTheme.errorRed),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // ✅ DELETE THE STAFF MEMBER FROM DATABASE
        await db.deleteUser(staff.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Staff member removed'),
              backgroundColor: AppTheme.successGreen,
            ),
          );
          _loadStaff();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Management'),
        backgroundColor: AppTheme.surfaceCard,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard.withOpacity(0.5),
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.accentCyan.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Manage Staff Members',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Add, edit, and remove staff members',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () =>
                        setState(() => _showAddForm = !_showAddForm),
                    icon: Icon(_showAddForm ? Icons.close : Icons.add),
                    label: Text(_showAddForm ? 'Cancel' : 'Add Staff'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentCyan,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Add Form
            if (_showAddForm)
              Container(
                padding: const EdgeInsets.all(16),
                color: AppTheme.accentCyan.withOpacity(0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add New Staff Member',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 16),
                    // First Name
                    _buildTextField(
                      controller: _firstNameCtrl,
                      label: 'First Name',
                      hint: 'John',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 12),
                    // Last Name
                    _buildTextField(
                      controller: _lastNameCtrl,
                      label: 'Last Name',
                      hint: 'Doe',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 12),
                    // Email
                    _buildTextField(
                      controller: _emailCtrl,
                      label: 'Email',
                      hint: 'john@example.com',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    // Password
                    _buildTextField(
                      controller: _passwordCtrl,
                      label: 'Password',
                      hint: 'Min 8 characters',
                      icon: Icons.lock_outlined,
                      obscureText: true,
                    ),
                    const SizedBox(height: 12),
                    // Confirm Password
                    _buildTextField(
                      controller: _confirmPasswordCtrl,
                      label: 'Confirm Password',
                      hint: 'Repeat password',
                      icon: Icons.lock_outlined,
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    // Error Message
                    if (_errorMessage.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.errorRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.errorRed.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: AppTheme.errorRed,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage,
                                style: TextStyle(
                                  color: AppTheme.errorRed,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _resetForm,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(
                                color: AppTheme.textSecondary.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              'Reset',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _addStaff,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accentCyan,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                        AppTheme.textPrimary,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Add Staff Member',
                                    style: TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            // Staff List
            Padding(
              padding: const EdgeInsets.all(16),
              child: FutureBuilder<List<User>>(
                future: _staffFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CyberLoader());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 48,
                              color:
                                  AppTheme.accentCyan.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No staff members yet',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add a new staff member to get started',
                              style: TextStyle(
                                color:
                                    AppTheme.textSecondary.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final staff = snapshot.data!;
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: staff.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final member = staff[index];
                      return _StaffMemberCard(
                        staff: member,
                        onRemove: () => _removeStaff(member),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            prefixIcon: Icon(icon, color: AppTheme.accentCyan, size: 18),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            filled: true,
            fillColor: AppTheme.surfaceCard.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppTheme.accentCyan.withOpacity(0.2),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppTheme.accentCyan.withOpacity(0.2),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppTheme.accentCyan,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StaffMemberCard extends StatelessWidget {
  final User staff;
  final VoidCallback onRemove;

  const _StaffMemberCard({
    required this.staff,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.accentCyan.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.cyberGradient,
            ),
            child: Center(
              child: Text(
                staff.firstName.isNotEmpty
                    ? staff.firstName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Staff Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${staff.firstName} ${staff.lastName}',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  staff.email,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Status Badge
          StatusBadge(
            label: 'Active',
            status: 'active',
          ),
          const SizedBox(width: 8),
          // Remove Button
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: AppTheme.errorRed,
            onPressed: onRemove,
            tooltip: 'Remove staff member',
          ),
        ],
      ),
    );
  }
}
