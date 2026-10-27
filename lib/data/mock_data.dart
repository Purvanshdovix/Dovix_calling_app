import 'models.dart';

DateTime _today(int h, int m) {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day, h, m);
}

DateTime _daysAgo(int d, [int h = 0]) => DateTime.now().subtract(Duration(days: d, hours: h));

/// Profile photo for the signed-in user.
const userPhoto = 'assets/images/user_avatar.png';

const agents = ['Amit Kumar', 'Kamlesh Kumar', 'Neha Verma', 'Rahul Singh'];

AppUser initialUser() =>
    AppUser(name: 'Kamlesh Kumar', role: 'Admin', email: 'kamlesh@dovixai.com', phone: '+91 98100 22334');

String _slug(String s) => s.toLowerCase().replaceAll(RegExp('[^a-z]+'), '');

List<Lead> initialLeads() {
  final seeds = <(String, String, String, LeadStatus, LeadSource, bool, bool)>[
    (
      'Rohit Sharma',
      'Tech Solutions Pvt. Ltd.',
      '+91 98765 43210',
      LeadStatus.newLead,
      LeadSource.website,
      true,
      false,
    ),
    ('Priya Khanna', 'Globex Corp', '+91 91234 56789', LeadStatus.contacted, LeadSource.googleAds, false, false),
    ('Amit Jain', 'Jain Traders', '+91 99887 66554', LeadStatus.qualified, LeadSource.referrals, true, false),
    ('Sunita Patel', 'Patel Industries', '+91 88776 55443', LeadStatus.proposal, LeadSource.facebookAds, false, true),
    ('Vikram Singh', 'AutoHaus', '+91 77665 44332', LeadStatus.negotiation, LeadSource.website, true, false),
    ('Meera Das', 'Das Group', '+91 98712 34567', LeadStatus.won, LeadSource.directCall, false, true),
    ('Arjun Rao', 'Rao Enterprises', '+91 76543 21098', LeadStatus.followUp, LeadSource.googleAds, false, false),
    ('Neha Singh', 'Prime Retail', '+91 90011 22334', LeadStatus.newLead, LeadSource.others, false, false),
    ('Karan Mehta', 'Mehta Logistics', '+91 93322 11009', LeadStatus.contacted, LeadSource.website, false, false),
    ('Anjali Verma', 'BrightPath Edu', '+91 95544 33221', LeadStatus.qualified, LeadSource.facebookAds, true, true),
  ];
  final contactTimes = <DateTime?>[
    _today(10, 15),
    _today(9, 45),
    _daysAgo(1),
    _today(11, 20),
    _today(9, 10),
    _today(8, 45),
    _daysAgo(1, 2),
    null,
    _daysAgo(2),
    _daysAgo(3),
  ];

  return [
    for (var i = 0; i < seeds.length; i++)
      () {
        final (name, company, phone, status, source, hot, customer) = seeds[i];
        final domain = _slug(company.split(' ').first);
        return Lead(
          id: 'l${i + 1}',
          name: name,
          company: company,
          phone: phone,
          email: '${name.split(' ').first.toLowerCase()}@$domain.com',
          website: 'www.$domain.com',
          status: status,
          source: source,
          assignedTo: i.isEven ? 'Amit Kumar' : (i % 3 == 0 ? 'Neha Verma' : ''),
          hot: hot,
          isCustomer: customer,
          createdAt: _daysAgo(i + 1),
          lastContact: contactTimes[i],
          nextFollowUp: i == 0 ? _today(15, 0) : (i % 3 == 0 ? DateTime.now().add(Duration(days: i % 4 + 1)) : null),
          notes: i == 0
              ? [
                  Note(
                    id: 'n1',
                    text: 'Interested in the 50-seat plan. Wants a demo with their sales head.',
                    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
                  ),
                ]
              : null,
        );
      }(),
  ];
}

List<CallLog> initialCalls(List<Lead> leads) {
  CallLog log(String id, String leadId, CallType type, DateTime ts, int secs) {
    final l = leads.firstWhere((l) => l.id == leadId);
    return CallLog(
      id: id,
      leadId: leadId,
      name: l.name,
      company: l.company,
      phone: l.phone,
      type: type,
      timestamp: ts,
      duration: Duration(seconds: secs),
    );
  }

  final y = const Duration(days: 1);
  return [
    log('c1', 'l1', CallType.outgoing, _today(10, 15), 138),
    log('c2', 'l2', CallType.incoming, _today(9, 30), 102),
    log('c3', 'l3', CallType.missed, _today(9, 12), 0),
    log('c4', 'l4', CallType.outgoing, _today(8, 45), 201),
    log('c5', 'l5', CallType.incoming, _today(8, 20), 65),
    log('c6', 'l6', CallType.outgoing, _today(17, 30).subtract(y), 168),
    log('c7', 'l7', CallType.missed, _today(16, 15).subtract(y), 0),
    log('c8', 'l8', CallType.incoming, _today(15, 10).subtract(y), 119),
    log('c9', 'l9', CallType.outgoing, _today(12, 5).subtract(y * 2), 74),
  ];
}

List<TaskItem> initialTasks() => [
  TaskItem(
    id: 't1',
    title: 'Call Rohit Sharma',
    subtitle: 'Tech Solutions',
    kind: TaskKind.call,
    category: TaskCategory.callback,
    due: _today(11, 0),
    leadId: 'l1',
  ),
  TaskItem(
    id: 't2',
    title: 'Follow-up with Priya',
    subtitle: 'Globex Corp',
    kind: TaskKind.whatsapp,
    category: TaskCategory.followUp,
    due: _today(12, 30),
    leadId: 'l2',
  ),
  TaskItem(
    id: 't3',
    title: 'Send proposal to Amit Jain',
    subtitle: 'Jain Traders',
    kind: TaskKind.email,
    category: TaskCategory.other,
    due: _today(14, 0),
    leadId: 'l3',
  ),
  TaskItem(
    id: 't4',
    title: 'Demo call with Sunita Patel',
    subtitle: 'Patel Industries',
    kind: TaskKind.meeting,
    category: TaskCategory.other,
    due: _today(15, 30),
    leadId: 'l4',
  ),
  TaskItem(
    id: 't5',
    title: 'Follow-up with Vikram',
    subtitle: 'AutoHaus',
    kind: TaskKind.call,
    category: TaskCategory.followUp,
    due: _today(17, 0),
    leadId: 'l5',
  ),
  TaskItem(
    id: 't6',
    title: 'Call back Arjun Rao',
    subtitle: 'Rao Enterprises',
    kind: TaskKind.call,
    category: TaskCategory.callback,
    due: _today(17, 45),
    leadId: 'l7',
  ),
  TaskItem(
    id: 't7',
    title: 'Share pricing with Neha',
    subtitle: 'Prime Retail',
    kind: TaskKind.whatsapp,
    category: TaskCategory.followUp,
    due: _today(18, 15),
    leadId: 'l8',
    done: true,
  ),
];

List<Campaign> initialCampaigns() => [
  Campaign(
    id: 'cp1',
    name: 'Product Demo',
    done: 1240,
    total: 2000,
    status: CampaignStatus.active,
    iconCode: 0,
    color: 0xFF8B5CF6,
  ),
  Campaign(
    id: 'cp2',
    name: 'New Year Offer',
    done: 980,
    total: 1500,
    status: CampaignStatus.active,
    iconCode: 1,
    color: 0xFFEF4444,
  ),
  Campaign(
    id: 'cp3',
    name: 'Enterprise Plan',
    done: 680,
    total: 1000,
    status: CampaignStatus.scheduled,
    iconCode: 2,
    color: 0xFF6366F1,
  ),
  Campaign(
    id: 'cp4',
    name: 'Re-Engagement',
    done: 450,
    total: 800,
    status: CampaignStatus.active,
    iconCode: 3,
    color: 0xFF16A34A,
  ),
  Campaign(
    id: 'cp5',
    name: 'Follow-up Campaign',
    done: 320,
    total: 600,
    status: CampaignStatus.completed,
    iconCode: 4,
    color: 0xFFA855F7,
  ),
];

/// Dashboard activity: per slot [connected, notAnswered, busy].
/// Dashboard activity: per slot [connected, notAnswered, busy].
const hourlyActivity = <String, (List<String>, List<List<int>>)>{
  'Today': (
    ['9AM', '11AM', '12PM', '1PM', '3PM', '5PM', '7PM'],
    [
      [70, 30, 8],
      [110, 40, 10],
      [160, 55, 14],
      [170, 60, 15],
      [150, 50, 13],
      [120, 40, 10],
      [112, 37, 10],
    ],
  ),
  'Week': (
    ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    [
      [820, 290, 74],
      [880, 305, 79],
      [930, 320, 85],
      [892, 312, 80],
      [910, 300, 82],
      [450, 160, 40],
      [210, 80, 20],
    ],
  ),
};

class ReportData {
  const ReportData({
    required this.totalCalls,
    required this.callsDelta,
    required this.connected,
    required this.connectedDelta,
    required this.conversion,
    required this.conversionDelta,
    required this.avgTalkSecs,
    required this.avgTalkDelta,
    required this.trendLabels,
    required this.trendValues,
  });

  final int totalCalls;
  final double callsDelta;
  final int connected;
  final double connectedDelta;
  final double conversion;
  final double conversionDelta;
  final int avgTalkSecs;
  final double avgTalkDelta;
  final List<String> trendLabels;
  final List<int> trendValues;
}

const reportPeriods = <String, ReportData>{
  'This Month': ReportData(
    totalCalls: 12480,
    callsDelta: 18.6,
    connected: 892,
    connectedDelta: 8.2,
    conversion: 24.8,
    conversionDelta: 3.5,
    avgTalkSecs: 168,
    avgTalkDelta: 12.4,
    trendLabels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
    trendValues: [620, 760, 700, 980, 1050, 1284],
  ),
  'Last Month': ReportData(
    totalCalls: 10520,
    callsDelta: 9.1,
    connected: 824,
    connectedDelta: 4.6,
    conversion: 21.3,
    conversionDelta: 1.2,
    avgTalkSecs: 149,
    avgTalkDelta: 6.8,
    trendLabels: ['Dec', 'Jan', 'Feb', 'Mar', 'Apr', 'May'],
    trendValues: [540, 620, 760, 700, 980, 1050],
  ),
  'This Year': ReportData(
    totalCalls: 98340,
    callsDelta: 27.4,
    connected: 7310,
    connectedDelta: 15.2,
    conversion: 22.9,
    conversionDelta: 4.1,
    avgTalkSecs: 157,
    avgTalkDelta: 9.7,
    trendLabels: ['Q1', 'Q2', 'Q3', 'Q4'],
    trendValues: [18200, 23400, 26900, 29840],
  ),
};

const leadSourceBreakdown = <(String, int, int)>[
  ('Website', 3240, 0xFF1F5EFF),
  ('Google Ads', 2480, 0xFF22C55E),
  ('Facebook Ads', 1960, 0xFF8B5CF6),
  ('Referrals', 1520, 0xFFF59E0B),
  ('Direct Call', 1280, 0xFFEC4899),
  ('Others', 2000, 0xFFB8C4D9),
];

/// Phone keypad: (digit, letters).
const dialKeys = <(String, String)>[
  ('1', ''),
  ('2', 'ABC'),
  ('3', 'DEF'),
  ('4', 'GHI'),
  ('5', 'JKL'),
  ('6', 'MNO'),
  ('7', 'PQRS'),
  ('8', 'TUV'),
  ('9', 'WXYZ'),
  ('*', ''),
  ('0', '+'),
  ('#', ''),
];
