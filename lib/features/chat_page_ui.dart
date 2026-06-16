import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'block_controller.dart';
import 'voice_call_page.dart';
import 'live_session_page.dart';
import 'profile_page_ui.dart';

// ── Local color shortcuts ──
const _primary = Color(0xFF2563EB);
const _green = Color(0xFF059669);
const _textDark = Color(0xFF0F172A);
const _textMid = Color(0xFF475569);
const _textLight = Color(0xFF94A3B8);
const _divider = Color(0xFFE2E8F0);
const _success = Color(0xFF10B981);
const _tag = Color(0xFFEFF6FF);
const _danger = Color(0xFFEF4444);

const _grad = LinearGradient(
  colors: [Color(0xFF1E40AF), Color(0xFF2563EB), Color(0xFF059669)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// ═══════════════════════════════════════════════════════════════════
//  CHAT PAGE
// ═══════════════════════════════════════════════════════════════════

class ChatPage extends StatefulWidget {
  final String userId;
  final String name;
  final String? imageUrl;
  final String? avatarText;
  final bool isOnline;

  const ChatPage({
    super.key,
    this.userId = '',
    this.name = '',
    this.imageUrl = '',
    this.avatarText = '',
    this.isOnline = false,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  // Use userId if provided, fall back to name
  String get _userId => widget.userId.isNotEmpty ? widget.userId : widget.name;

  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Hey! Are you available for a session today?',
      'isMe': false,
      'time': '10:30 AM',
    },
    {'text': 'Yes! What time works for you?', 'isMe': true, 'time': '10:32 AM'},
    {
      'text': 'How about 3 PM? We can review the Python project.',
      'isMe': false,
      'time': '10:35 AM',
    },
    {
      'text': "Perfect! I'll prepare some questions.",
      'isMe': true,
      'time': '10:36 AM',
    },
    {
      "text": "Let's review the Python project today!",
      'isMe': false,
      'time': '10:42 AM',
    },
  ];

  @override
  void initState() {
    super.initState();
    BlockController.instance.addListener(_refresh);
  }

  @override
  void dispose() {
    BlockController.instance.removeListener(_refresh);
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _send() {
    if (_msgCtrl.text.trim().isEmpty) return;
    setState(
      () => _messages.add({
        'text': _msgCtrl.text.trim(),
        'isMe': true,
        'time': TimeOfDay.now().format(context),
      }),
    );
    _msgCtrl.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _toast(String msg, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.inter()),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: color ?? _textDark,
      ),
    );
  }

  // ── Voice call ──
  void _startVoiceCall() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VoiceCallPage(
          personName: widget.name,
          personImage: widget.imageUrl,
          avatarText: widget.avatarText,
        ),
      ),
    );
  }

  // ── Video call ──
  void _startVideoCall() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LiveSessionPage(
          sessionId: 'quick_${DateTime.now().millisecondsSinceEpoch}',
          personId: _userId, // 🆕 so the review saves under this user
          personName: widget.name,
          personImage: widget.imageUrl,
          avatarText: widget.avatarText,
          topic: 'Video Call',
          durationMinutes: 0,
        ),
      ),
    );
  }

  // 🆕 View the person's profile
  void _viewProfile() {
    // Match by name/userId to known profiles. Falls back to Marwan.
    ProfileData profile;
    final id = _userId.toLowerCase();
    final name = widget.name.toLowerCase();

    if (id.contains('mohamed') ||
        name.contains('mohamed') ||
        name.contains('nukbassy')) {
      profile = ProfileData.mohamed();
    } else if (id.contains('marwan') || name.contains('marwan')) {
      profile = ProfileData.marwan();
    } else {
      // Default fallback profile for anyone else (uses chat data)
      profile = ProfileData(
        userId: _userId,
        name: widget.name,
        title: 'SkillBridge Member',
        location: 'Egypt',
        about: 'A SkillBridge community member.',
        imageUrl: widget.imageUrl ?? '',
        skills: const ['SkillBridge'],
        experience: [],
        email: '',
        phone: '',
        website: '',
        github: '',
        linkedin: '',
        portfolio: '',
        followers: 0,
        yearsExperience: 0,
      );
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfilePage(profile: profile, isOwnProfile: false),
      ),
    );
  }

  // ── 3-dots options menu ──
  void _showOptions() {
    final isBlocked = BlockController.instance.isBlocked(_userId);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: _divider,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              _menuItem(
                Icons.person_outline_rounded,
                _primary,
                'View Profile',
                onTap: () {
                  Navigator.pop(context);
                  _viewProfile();
                },
              ),
              _menuItem(
                Icons.notifications_off_outlined,
                _textMid,
                'Mute Notifications',
                onTap: () => Navigator.pop(context),
              ),
              _menuItem(
                Icons.report_outlined,
                const Color(0xFFF59E0B),
                'Report',
                onTap: () => Navigator.pop(context),
              ),
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: _divider,
              ),
              _menuItem(
                isBlocked ? Icons.lock_open_rounded : Icons.block_rounded,
                _danger,
                isBlocked ? 'Unblock ${widget.name}' : 'Block ${widget.name}',
                isDanger: true,
                onTap: () {
                  Navigator.pop(context);
                  if (isBlocked) {
                    BlockController.instance.unblock(_userId);
                    _toast('✅ ${widget.name} unblocked', color: _success);
                  } else {
                    _confirmBlock();
                  }
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuItem(
    IconData icon,
    Color color,
    String label, {
    VoidCallback? onTap,
    bool isDanger = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDanger ? _danger : _textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmBlock() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _danger.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.block_rounded,
                  color: _danger,
                  size: 28,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Block ${widget.name}?',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "They won't be able to message you or book sessions. You can unblock anytime from Settings.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: _textMid,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _divider),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.inter(
                              color: _textMid,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _danger,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Block',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (ok == true) {
      BlockController.instance.block(
        userId: _userId,
        name: widget.name,
        imageUrl: widget.imageUrl,
        avatarText: widget.avatarText,
      );
      _toast('🚫 ${widget.name} has been blocked', color: _danger);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBlocked = BlockController.instance.isBlocked(_userId);
    return Scaffold(
      backgroundColor: const Color(0xFFEEF2FF),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          if (isBlocked) _blockedBanner(),
          Expanded(child: _buildMessages()),
          if (!isBlocked) _buildInput() else _blockedInputPlaceholder(),
        ],
      ),
    );
  }

  // ── Blocked banner ──
  Widget _blockedBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _danger.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _danger.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _danger.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.block_rounded, color: _danger, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You blocked ${widget.name}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _danger,
                  ),
                ),
                Text(
                  'Messages and calls are disabled',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: _danger.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _blockedInputPlaceholder() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _divider.withOpacity(0.5))),
      ),
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: () {
            BlockController.instance.unblock(_userId);
            _toast('✅ ${widget.name} unblocked', color: _success);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: _success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _success.withOpacity(0.3)),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lock_open_rounded,
                    color: _success,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tap to unblock ${widget.name}',
                    style: GoogleFonts.inter(
                      color: _success,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── AppBar ──
  PreferredSizeWidget _buildAppBar() {
    final isBlocked = BlockController.instance.isBlocked(_userId);
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _tag,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 16,
            color: _primary,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: widget.imageUrl == null || widget.imageUrl!.isEmpty
                      ? _grad
                      : null,
                  border: Border.all(color: _divider, width: 1.5),
                ),
                child: ClipOval(
                  child: widget.imageUrl != null && widget.imageUrl!.isNotEmpty
                      ? Image.network(
                          widget.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _avatarFallback(),
                        )
                      : _avatarFallback(),
                ),
              ),
              if (widget.isOnline)
                Positioned(
                  bottom: 1,
                  right: 1,
                  child: Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: _success,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.name,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: widget.isOnline ? _success : _textLight,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    widget.isOnline ? 'Online' : 'Offline',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: widget.isOnline ? _success : _textLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Video call
        Container(
          margin: const EdgeInsets.only(right: 6),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_primary.withOpacity(0.1), _green.withOpacity(0.1)],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _primary.withOpacity(0.2)),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.videocam_outlined,
              color: _primary,
              size: 18,
            ),
            onPressed: isBlocked ? null : _startVideoCall,
          ),
        ),
        // Phone call
        Container(
          margin: const EdgeInsets.only(right: 6),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: _grad,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: _primary.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.call_outlined,
              color: Colors.white,
              size: 18,
            ),
            onPressed: isBlocked ? null : _startVoiceCall,
          ),
        ),
        // 🆕 Options (3 dots) - here's the Block button!
        Container(
          margin: const EdgeInsets.only(right: 12),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _tag,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _primary.withOpacity(0.15)),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.more_vert_rounded,
              color: _primary,
              size: 20,
            ),
            onPressed: _showOptions,
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _divider.withOpacity(0.5)),
      ),
    );
  }

  Widget _avatarFallback() {
    return Container(
      color: _tag,
      child: Center(
        child: Text(
          widget.avatarText?.isNotEmpty == true
              ? widget.avatarText!
              : (widget.name.isNotEmpty ? widget.name[0] : '?'),
          style: const TextStyle(
            color: _primary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // ── Messages list ──
  Widget _buildMessages() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEEF2FF), Color(0xFFDBEAFE), Color(0xFFD1FAE5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: ListView.builder(
        controller: _scrollCtrl,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: _messages.length,
        itemBuilder: (_, i) => _buildBubble(_messages[i]),
      ),
    );
  }

  Widget _buildBubble(Map<String, dynamic> msg) {
    final bool isMe = msg['isMe'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _divider),
              ),
              child: ClipOval(
                child: widget.imageUrl != null && widget.imageUrl!.isNotEmpty
                    ? Image.network(
                        widget.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _avatarFallback(),
                      )
                    : _avatarFallback(),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: isMe ? _grad : null,
                color: isMe ? null : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: isMe
                      ? const Radius.circular(18)
                      : const Radius.circular(4),
                  bottomRight: isMe
                      ? const Radius.circular(4)
                      : const Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isMe
                        ? _primary.withOpacity(0.25)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: isMe ? 10 : 4,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    msg['text'],
                    style: GoogleFonts.inter(
                      color: isMe ? Colors.white : _textDark,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    msg['time'],
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: isMe ? Colors.white.withOpacity(0.7) : _textLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Input bar ──
  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _divider.withOpacity(0.5))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _tag,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _primary.withOpacity(0.15)),
              ),
              child: const Icon(
                Icons.attach_file_rounded,
                size: 18,
                color: _primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _divider),
                ),
                child: TextField(
                  controller: _msgCtrl,
                  onSubmitted: (_) => _send(),
                  style: GoogleFonts.inter(fontSize: 14, color: _textDark),
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: GoogleFonts.inter(
                      color: _textLight,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _send,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: _grad,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _primary.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
