enum LeadStatus {
  newLead('New'),
  contacted('Contacted'),
  qualified('Qualified'),
  proposal('Proposal'),
  negotiation('Negotiation'),
  won('Won'),
  followUp('Follow-up'),
  lost('Lost');

  const LeadStatus(this.label);
  final String label;
}

enum LeadSource {
  website('Website'),
  googleAds('Google Ads'),
  facebookAds('Facebook Ads'),
  referrals('Referrals'),
  directCall('Direct Call'),
  others('Others');

  const LeadSource(this.label);
  final String label;
}

class Note {
  Note({required this.id, required this.text, required this.createdAt});
  final String id;
  final String text;
  final DateTime createdAt;
}

class Lead {
  Lead({
    required this.id,
    required this.name,
    required this.company,
    required this.phone,
    required this.email,
    required this.website,
    required this.status,
    required this.source,
    required this.assignedTo,
    required this.hot,
    required this.isCustomer,
    required this.createdAt,
    this.lastContact,
    this.nextFollowUp,
    List<Note>? notes,
  }) : notes = notes ?? [];

  final String id;
  String name;
  String company;
  String phone;
  String email;
  String website;
  LeadStatus status;
  LeadSource source;
  String assignedTo;
  bool hot;
  bool isCustomer;
  final DateTime createdAt;
  DateTime? lastContact;
  DateTime? nextFollowUp;
  final List<Note> notes;
}

enum CallType { incoming, outgoing, missed }

class CallLog {
  CallLog({
    required this.id,
    required this.leadId,
    required this.name,
    required this.company,
    required this.phone,
    required this.type,
    required this.timestamp,
    required this.duration,
  });

  final String id;
  final String? leadId;
  final String name;
  final String company;
  final String phone;
  final CallType type;
  final DateTime timestamp;
  final Duration duration;
}

enum TaskKind { call, whatsapp, email, meeting }

enum TaskCategory { followUp, callback, other }

class TaskItem {
  TaskItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.kind,
    required this.category,
    required this.due,
    required this.leadId,
    this.done = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final TaskKind kind;
  final TaskCategory category;
  final DateTime due;
  final String? leadId;
  bool done;
}

enum CampaignStatus { active, scheduled, paused, completed }

extension CampaignStatusLabel on CampaignStatus {
  String get label => switch (this) {
    CampaignStatus.active => 'Active',
    CampaignStatus.scheduled => 'Scheduled',
    CampaignStatus.paused => 'Paused',
    CampaignStatus.completed => 'Completed',
  };
}

class Campaign {
  Campaign({
    required this.id,
    required this.name,
    required this.done,
    required this.total,
    required this.status,
    required this.iconCode,
    required this.color,
  });

  final String id;
  final String name;
  final int done;
  final int total;
  CampaignStatus status;

  /// Index into [campaignIcons] (kept as data so mock/back-end data stays UI-free).
  final int iconCode;
  final int color;
}

class AppUser {
  AppUser({required this.name, required this.role, required this.email, required this.phone});
  String name;
  String role;
  String email;
  String phone;
}

class AppSettings {
  bool pushNotifications = true;
  bool missedCallAlerts = true;
  bool followUpReminders = true;
  bool autoRecord = false;
  bool speakerDefault = false;
  bool autoDialNext = false;
  bool darkMode = false;
  bool compactLists = false;
}
