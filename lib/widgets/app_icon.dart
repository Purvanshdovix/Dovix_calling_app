import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Dovix AI icon library (assets/icons/*.svg — 24px grid, 2px rounded strokes).
/// Drop replacement SVGs into assets/icons with the same file names to restyle the app.
enum AppIcons {
  activity('activity'),
  add('add'),
  addCall('add_call'),
  aiSparkles('ai_sparkles'),
  arrowRight('arrow_right'),
  autodialer('autodialer'),
  back('back'),
  backspace('backspace'),
  barChart('bar_chart'),
  bot('bot'),
  calendar('calendar'),
  callRecord('call_record'),
  campaign('campaign'),
  check('check'),
  checklist('checklist'),
  chevronDown('chevron_down'),
  chevronRight('chevron_right'),
  clock('clock'),
  close('close'),
  closeCircle('close_circle'),
  company('company'),
  contactCard('contact_card'),
  edit('edit'),
  email('email'),
  export('export'),
  eye('eye'),
  eyeOff('eye_off'),
  facebook('facebook'),
  filter('filter'),
  flame('flame'),
  folder('folder'),
  followup('followup'),
  gift('gift'),
  globe('globe'),
  grid('grid'),
  hash('hash'),
  headset('headset'),
  heart('heart'),
  help('help'),
  home('home'),
  incomingCall('incoming_call'),
  info('info'),
  integrations('integrations'),
  key('key'),
  keypad('keypad'),
  leadStar('lead_star'),
  lineChart('line_chart'),
  location('location'),
  lock('lock'),
  logout('logout'),
  megaphone('megaphone'),
  menu('menu'),
  message('message'),
  microphone('microphone'),
  missedCall('missed_call'),
  more('more'),
  mute('mute'),
  notifications('notifications'),
  outgoingCall('outgoing_call'),
  pause('pause'),
  phone('phone'),
  phoneEnd('phone_end'),
  pieChart('pie_chart'),
  pipeline('pipeline'),
  play('play'),
  profile('profile'),
  qualified('qualified'),
  refresh('refresh'),
  script('script'),
  search('search'),
  settings('settings'),
  sliders('sliders'),
  sort('sort'),
  trendDown('trend_down'),
  trendUp('trend_up'),
  speaker('speaker'),
  trophy('trophy'),
  userPlus('user_plus'),
  users('users'),
  video('video'),
  whatsapp('whatsapp'),
  wifiCall('wifi_call'),
  won('won');

  const AppIcons(this.file);
  final String file;
  String get asset => 'assets/icons/$file.svg';
}

/// Draws an [AppIcons] glyph tinted with [color], falling back to the ambient [IconTheme]
/// so it behaves like [Icon] inside buttons, list tiles and nav bars.
class AppIcon extends StatelessWidget {
  const AppIcon(this.icon, {super.key, this.size, this.color});

  final AppIcons icon;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final s = size ?? theme.size ?? 24;
    // Like Icon: stays centred at its own size when a parent imposes larger minimums
    // (e.g. InputDecoration.prefixIcon's 48px box).
    return SizedBox(
      width: s,
      height: s,
      child: Center(
        child: SvgPicture.asset(
          icon.asset,
          width: s,
          height: s,
          colorFilter: ColorFilter.mode(color ?? theme.color ?? const Color(0xFF0F172A), BlendMode.srcIn),
        ),
      ),
    );
  }
}
