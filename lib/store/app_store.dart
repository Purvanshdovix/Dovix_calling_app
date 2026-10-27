import 'package:flutter/widgets.dart';

import '../data/mock_data.dart';
import '../data/models.dart';

/// In-memory app state. There is no backend yet, so everything lives here and
/// resets on restart. Replace these methods with API calls when a backend exists.
class AppStore extends ChangeNotifier {
  AppStore() {
    leads = initialLeads();
    calls = initialCalls(leads);
    baselineLeadCount = leads.length;
    baselineCallCount = calls.length;
  }

  AppUser user = initialUser();
  bool isLoggedIn = false;
  late final List<Lead> leads;
  late final List<CallLog> calls;
  final List<TaskItem> tasks = initialTasks();
  final List<Campaign> campaigns = initialCampaigns();
  final AppSettings settings = AppSettings();
  late final int baselineLeadCount;
  late final int baselineCallCount;

  int _seq = 0;
  String _id(String prefix) => '$prefix${DateTime.now().microsecondsSinceEpoch}${_seq++}';

  Lead? leadById(String? id) {
    if (id == null) return null;
    for (final l in leads) {
      if (l.id == id) return l;
    }
    return null;
  }

  void login(String identifier) {
    if (identifier.contains('@')) user.email = identifier.trim();
    isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    isLoggedIn = false;
    notifyListeners();
  }

  void updateUser({String? name, String? email, String? phone}) {
    if (name != null) user.name = name;
    if (email != null) user.email = email;
    if (phone != null) user.phone = phone;
    notifyListeners();
  }

  Lead addLead({
    required String name,
    required String phone,
    required String email,
    required String company,
    required LeadSource source,
    required LeadStatus status,
    required String assignedTo,
    required bool hot,
  }) {
    final lead = Lead(
      id: _id('l'),
      name: name,
      company: company,
      phone: phone,
      email: email,
      website: '',
      status: status,
      source: source,
      assignedTo: assignedTo,
      hot: hot,
      isCustomer: false,
      createdAt: DateTime.now(),
    );
    leads.insert(0, lead);
    notifyListeners();
    return lead;
  }

  /// Applies [change] to the lead and notifies listeners.
  void updateLead(String id, void Function(Lead l) change) {
    final l = leadById(id);
    if (l == null) return;
    change(l);
    notifyListeners();
  }

  void addNote(String leadId, String text) {
    updateLead(leadId, (l) => l.notes.insert(0, Note(id: _id('n'), text: text, createdAt: DateTime.now())));
  }

  void logCall({
    required String? leadId,
    required String name,
    required String company,
    required String phone,
    required CallType type,
    required Duration duration,
  }) {
    final now = DateTime.now();
    calls.insert(
      0,
      CallLog(
        id: _id('c'),
        leadId: leadId,
        name: name,
        company: company,
        phone: phone,
        type: type,
        timestamp: now,
        duration: duration,
      ),
    );
    final l = leadById(leadId);
    if (l != null) {
      l.lastContact = now;
      if (l.status == LeadStatus.newLead) l.status = LeadStatus.contacted;
    }
    notifyListeners();
  }

  void toggleTask(String id) {
    final t = tasks.firstWhere((t) => t.id == id);
    t.done = !t.done;
    notifyListeners();
  }

  void addCampaign(String name, int total, CampaignStatus status) {
    const colors = [0xFF1F5EFF, 0xFFF59E0B, 0xFF0D9488, 0xFFEC4899];
    campaigns.insert(
      0,
      Campaign(
        id: _id('cp'),
        name: name,
        done: 0,
        total: total,
        status: status,
        iconCode: 5 + campaigns.length % 3,
        color: colors[campaigns.length % colors.length],
      ),
    );
    notifyListeners();
  }

  void setCampaignStatus(String id, CampaignStatus status) {
    campaigns.firstWhere((c) => c.id == id).status = status;
    notifyListeners();
  }

  void updateSettings(void Function(AppSettings s) change) {
    change(settings);
    notifyListeners();
  }
}

/// Provides the [AppStore] to the widget tree.
class AppScope extends InheritedNotifier<AppStore> {
  const AppScope({super.key, required AppStore store, required super.child}) : super(notifier: store);

  /// Use in build methods: rebuilds when the store changes.
  static AppStore of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  /// Use in callbacks: does not subscribe to changes.
  static AppStore read(BuildContext context) => context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
