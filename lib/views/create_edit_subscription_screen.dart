import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:io';
import '../models/subscription.dart';
import '../viewmodels/subscription_view_model.dart';
import '../theme/app_theme.dart';
import 'camera_screen.dart';

class CreateEditSubscriptionScreen extends StatefulWidget {
  final Subscription? existingSubscription;

  const CreateEditSubscriptionScreen({super.key, this.existingSubscription});

  @override
  State<CreateEditSubscriptionScreen> createState() => _CreateEditSubscriptionScreenState();
}

class _CreateEditSubscriptionScreenState extends State<CreateEditSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  
  String _periodicity = 'Monthly';
  DateTime _nextPaymentDate = DateTime.now();
  String _category = 'General';
  String? _logoPath;
  bool _hasReminder = false;
  String _status = 'Active';

  final List<String> _periodicities = ['Daily', 'Weekly', 'Monthly', 'Yearly'];
  final List<String> _categories = ['General', 'Entertainment', 'Work', 'Health', 'Education'];
  final List<String> _statuses = ['Active', 'Paused', 'Archived'];

  @override
  void initState() {
    super.initState();
    final sub = widget.existingSubscription;
    _nameController = TextEditingController(text: sub?.name ?? '');
    _amountController = TextEditingController(text: sub != null ? sub.amount.toString() : '');
    
    if (sub != null) {
      _periodicity = sub.periodicity;
      _nextPaymentDate = sub.nextPaymentDate;
      _category = sub.category;
      _logoPath = sub.logoPath;
      _hasReminder = sub.hasReminder;
      _status = sub.status;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _nextPaymentDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        _nextPaymentDate = date;
      });
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final sub = Subscription(
        id: widget.existingSubscription?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        periodicity: _periodicity,
        nextPaymentDate: _nextPaymentDate,
        category: _category,
        logoPath: _logoPath,
        hasReminder: _hasReminder,
        status: _status,
      );

      final vm = Provider.of<SubscriptionViewModel>(context, listen: false);
      if (widget.existingSubscription != null) {
        vm.updateSubscription(sub);
      } else {
        vm.addSubscription(sub);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title = widget.existingSubscription != null ? 'Edit Subscription' : 'Create Subscription';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              'Save',
              style: TextStyle(
                color: AppTheme.primaryAccent,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          children: [
            const SizedBox(height: 12),
            // Premium Camera / Logo Picker Widget
            Center(
              child: GestureDetector(
                onTap: () async {
                  final path = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CameraScreen()),
                  );
                  if (path != null) {
                    setState(() {
                      _logoPath = path;
                    });
                  }
                },
                child: Stack(
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                          width: 2,
                        ),
                        boxShadow: AppTheme.premiumShadow,
                        image: _logoPath != null
                            ? DecorationImage(image: FileImage(File(_logoPath!)), fit: BoxFit.cover)
                            : null,
                      ),
                      child: _logoPath == null
                          ? Icon(
                              Icons.all_inclusive_rounded, 
                              size: 48, 
                              color: isDark ? Colors.white24 : Colors.grey[300],
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          gradient: AppTheme.premiumGradient,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),

            // Form inputs inside a styled card
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                ),
                boxShadow: AppTheme.premiumShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Subscription Name',
                      hintText: 'e.g. Netflix, Spotify',
                      prefixIcon: Icon(Icons.abc_rounded, size: 24),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Please enter a name';
                      if (val.length < 2 || val.length > 64) return 'Length must be between 2 and 64';
                      if (!RegExp(r'^[a-zA-Z0-9\s\-]+$').hasMatch(val)) return 'Only letters, numbers, spaces, and dashes allowed';
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount (\$)',
                      hintText: '0.00',
                      prefixIcon: Icon(Icons.attach_money_rounded),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Please enter an amount';
                      if (!RegExp(r'^\d{1,6}(\.\d{1,2})?$').hasMatch(val.trim())) return 'Positive numbers only, max 6 digits';
                      final num = double.tryParse(val.trim());
                      if (num == null || num <= 0) return 'Must be a positive number';
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  DropdownButtonFormField<String>(
                    initialValue: _periodicity,
                    decoration: const InputDecoration(
                      labelText: 'Billing Cycle',
                      prefixIcon: Icon(Icons.repeat_rounded),
                    ),
                    items: _periodicities.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _periodicity = val);
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.category_rounded),
                    ),
                    items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _category = val);
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  DropdownButtonFormField<String>(
                    initialValue: _status,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      prefixIcon: Icon(Icons.info_outline_rounded),
                    ),
                    items: _statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _status = val);
                    },
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 16),

            // Date & Switch settings
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                ),
                boxShadow: AppTheme.premiumShadow,
              ),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryAccent.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.calendar_month_rounded, color: AppTheme.secondaryAccent, size: 20),
                    ),
                    title: const Text('Next Payment Date', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    subtitle: Text(
                      '${_nextPaymentDate.day}/${_nextPaymentDate.month}/${_nextPaymentDate.year}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _pickDate,
                  ),
                  const Divider(),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryAccent.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.notifications_active_rounded, color: AppTheme.primaryAccent, size: 20),
                    ),
                    title: const Text('Enable Reminders', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    subtitle: const Text('Notify one day before due date', style: TextStyle(fontSize: 12)),
                    value: _hasReminder,
                    activeThumbColor: AppTheme.primaryAccent,
                    onChanged: (val) {
                      setState(() => _hasReminder = val);
                    },
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 150.ms, duration: 400.ms),

            const SizedBox(height: 32),

            // Large Action Save Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ).copyWith(
                backgroundColor: WidgetStateProperty.resolveWith((states) => Colors.transparent),
              ),
              onPressed: _save,
              child: Ink(
                decoration: BoxDecoration(
                  gradient: AppTheme.premiumGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  height: 54,
                  alignment: Alignment.center,
                  child: const Text(
                    'Save Subscription',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 250.ms, duration: 400.ms),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
