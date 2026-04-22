import 'package:flutter/material.dart';

class SessionsPage extends StatelessWidget {
  const SessionsPage({super.key});

  // Colors
  static const Color bgMain = Color(0xFFF7F8FC);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color bgInput = Color(0xFFF1F2F6);
  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textPlaceholder = Color(0xFF9CA3AF);
  static const Color success = Color(0xFF22C55E);
  static const Color danger = Color(0xFFEF4444);
  static const Color primary = Color(0xFF5B6CFF);
  static const Color border = Color(0xFFE5E7EB);
  static const Color tagBlue = Color(0xFFE0F2FE);
  static const Color tagGreen = Color(0xFFDCFCE7);
  static const Color tagPurple = Color(0xFFEDE9FE);
  static const Color logoBlue = Color(0xFF3953E8);
  static const Color logoTeal = Color(0xFF3AAFA9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgMain,
      appBar: AppBar(
        backgroundColor: bgCard,
        elevation: 0,
        leading: const Icon(Icons.menu, color: textPrimary),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [logoBlue, logoTeal],
          ).createShader(bounds),
          child: const Text(
            'SkillBridge',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        actions: const [
          Icon(Icons.search, color: textPrimary),
          SizedBox(width: 12),
          Icon(Icons.person_outline, color: textPrimary),
          SizedBox(width: 12),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            color: bgCard,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: const Text(
              'My Sessions',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
          ),

          // Tabs
          Container(
            color: bgCard,
            child: Row(children: [_tab('Upcoming', true), _tab('Past', false)]),
          ),

          // Subtitle
          Container(
            color: bgCard,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: const Text(
              'Manage your upcoming peer-to-peer learning exchanges.',
              style: TextStyle(color: textSecondary, fontSize: 13),
            ),
          ),

          const SizedBox(height: 8),

          // Sessions List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // Session 1 - Confirmed
                _sessionCard(
                  name: 'Elena Rodriguez',
                  status: 'CONFIRMED',
                  statusColor: success,
                  statusBg: tagGreen,
                  type: 'LEARNING',
                  typeBg: tagBlue,
                  tags: ['UI', 'Motion', 'Design'],
                  date: 'Oct 24, 2023 | 10:00 AM – 11:30 AM',
                  actions: [
                    _actionBtn('Message', primary, Colors.white),
                    _actionBtn('Reschedule', bgInput, textPrimary),
                    _actionBtn('Cancel', danger, Colors.white),
                  ],
                ),

                const SizedBox(height: 12),

                // Session 2 - Pending
                _sessionCard(
                  name: 'Marcus Chen',
                  status: 'PENDING',
                  statusColor: const Color(0xFFD97706),
                  statusBg: const Color(0xFFFEF3C7),
                  type: 'TEACHING',
                  typeBg: tagPurple,
                  tags: ['Advanced', 'React', 'Patterns'],
                  date: 'Oct 26, 2023 | 4:00 PM – 5:00 PM',
                  actions: [
                    _actionBtn('Accept', success, Colors.white),
                    _actionBtn('Message', bgInput, textPrimary),
                  ],
                ),

                const SizedBox(height: 20),

                // Looking for more banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF7A59), Color(0xFFFFB36B)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Looking for more?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'You have 3 open slots this week. Match with a peer to fill them.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Find New Match',
                          style: TextStyle(
                            color: Color(0xFFFF7A59),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab(String label, bool isActive) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isActive ? primary : textSecondary,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 2,
            width: 60,
            color: isActive ? primary : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _sessionCard({
    required String name,
    required String status,
    required Color statusColor,
    required Color statusBg,
    required String type,
    required Color typeBg,
    required List<String> tags,
    required String date,
    required List<Widget> actions,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFFD1D5DB),
                    child: Icon(Icons.person, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Type + Tags
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: typeBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  type,
                  style: const TextStyle(
                    color: primary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ...tags.map(
                (tag) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Text(
                    tag,
                    style: const TextStyle(color: textSecondary, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Date
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 13, color: textSecondary),
              const SizedBox(width: 6),
              Text(
                date,
                style: const TextStyle(color: textSecondary, fontSize: 12),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Action Buttons
          Row(
            children: actions
                .map(
                  (btn) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: btn,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(String label, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
