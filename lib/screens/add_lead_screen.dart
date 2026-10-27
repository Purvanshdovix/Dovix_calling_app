import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../data/models.dart';
import '../store/app_store.dart';
import '../utils/actions.dart';
import '../widgets/common.dart';
import 'lead_details_screen.dart';

const _codes = ['+91', '+1', '+44', '+971', '+61'];

class AddLeadScreen extends StatefulWidget {
  const AddLeadScreen({super.key, this.phone = ''});

  /// Pre-filled from the dialer's "Add as new lead".
  final String phone;

  @override
  State<AddLeadScreen> createState() => _AddLeadScreenState();
}

class _AddLeadScreenState extends State<AddLeadScreen> {
  final _name = TextEditingController();
  late final _phone = TextEditingController(text: widget.phone);
  final _email = TextEditingController();
  final _company = TextEditingController();
  String _code = '+91';
  LeadSource? _source;
  LeadStatus _status = LeadStatus.newLead;
  String? _assignee;
  Map<String, String> _errors = {};

  @override
  void dispose() {
    for (final c in [_name, _phone, _email, _company]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    final digits = _phone.text.replaceAll(RegExp(r'\D'), '');
    final email = _email.text.trim();
    final e = <String, String>{
      if (_name.text.trim().isEmpty) 'name': 'Full name is required',
      if (digits.isEmpty)
        'phone': 'Phone number is required'
      else if (digits.length < 7 || digits.length > 12)
        'phone': 'Enter a valid phone number',
      if (email.isNotEmpty && !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) 'email': 'Enter a valid email',
    };
    setState(() => _errors = e);
    if (e.isNotEmpty) return;

    final formatted = digits.length == 10 ? '${digits.substring(0, 5)} ${digits.substring(5)}' : digits;
    final lead = AppScope.read(context).addLead(
      name: _name.text.trim(),
      phone: '$_code $formatted',
      email: email,
      company: _company.text.trim().isEmpty ? '—' : _company.text.trim(),
      source: _source ?? LeadSource.others,
      status: _status,
      assignedTo: _assignee ?? '',
      hot: false,
    );
    showToast(context, '${lead.name} added to leads');
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LeadDetailsScreen(leadId: lead.id)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 24),
          children: [
            const PageHeader(title: 'Add New Lead', back: true),
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LabeledField(
                    label: 'Full Name',
                    required: true,
                    controller: _name,
                    hint: 'Enter full name',
                    error: _errors['name'],
                  ),
                  const FieldLabel('Phone Number', required: true),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 96,
                        child: SelectField<String>(
                          value: _code,
                          options: _codes,
                          optionLabel: (c) => c,
                          onChanged: (c) => setState(() => _code = c),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: LabeledField(
                          controller: _phone,
                          hint: 'Enter phone number',
                          keyboardType: TextInputType.phone,
                          error: _errors['phone'],
                        ),
                      ),
                    ],
                  ),
                  LabeledField(
                    label: 'Email Address',
                    controller: _email,
                    hint: 'Enter email address',
                    keyboardType: TextInputType.emailAddress,
                    error: _errors['email'],
                  ),
                  LabeledField(label: 'Company Name', controller: _company, hint: 'Enter company name'),
                  SelectField<LeadSource>(
                    label: 'Source',
                    hint: 'Select source',
                    value: _source,
                    options: LeadSource.values,
                    optionLabel: (s) => s.label,
                    onChanged: (s) => setState(() => _source = s),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: SelectField<LeadStatus>(
                          label: 'Status',
                          value: _status,
                          options: LeadStatus.values,
                          optionLabel: (s) => s.label,
                          onChanged: (s) => setState(() => _status = s),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SelectField<String>(
                          label: 'Assign to',
                          hint: 'Select agent',
                          value: _assignee,
                          options: agents,
                          optionLabel: (a) => a,
                          onChanged: (a) => setState(() => _assignee = a),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: AppButton('Save Lead', onPressed: _save),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
