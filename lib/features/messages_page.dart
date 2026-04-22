// lib/screens/messages_screen.dart
import 'package:flutter/material.dart';
import 'chat_page.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final TextEditingController _searchController = TextEditingController();

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

  final List<Map<String, dynamic>> _activeUsers = [
    {
      'name': 'Eyad',
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAbVmxy0phUBpMQ2WZ4wK9OxLfm0wkrEupS0CDEjc4iv4_oi8pf-urn-DmfYAYc5AyWwJ6oqyXClFuL_37599ua8eHAiRrO7p8zNW4I7V3UbPsVlbvsqpy6JAX0Cey88jgOwt-SWVVpmN9dVcmIlr8HYjXeaQaHb4Gm1DV1zM1-KpY66cpW0PVawlxovtdEdCeFIWnrW6PRb3sPPrvtbzEwYjnkp6EP2vJSpCRmvlKnLYy9Ha0FMv3hO1za8FojE8YT-6on2W3Nd7FT',
    },
    {
      'name': 'Sarah',
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAsmV-7NVNQRhk3HHt_6XzPSmLh8rQqERhBQVtMUqt0l87zybezHwWWE7h8vZYcWgNILlWCNAykoKZW3RYCraYy8YDfWjB_C2cmQzzacgo1kUkqdec5jNMCLoXjsCLfOn7JpLWVoGTm8VeJOn_B8WkO5gAjRPpyBjxC-e6Or8z6yj2YTb8NE8CLaGXGcE8OeEubNSnK1gqeZHxV4C6qmC7ttW4GKLBMBQ5AsZxlyHVQRlNdp7fV0BLJZF-8ZYbTF54qeCPU_Vw2Tu6K',
    },
    {
      'name': 'Zeyad',
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuD007zV6MCbqZ5Gf6EKDBvpAhq456xlYXifl2j8-1HcDQygKP_3OmNjbH7clybkrMCuqclAoyjyPtXrTr1pBoicEb7-gtXsXi-PKCuxQ-e0OxES7GE5UJYv07Goj_88WNyvvYIm0lVWDIa66sG6it1GjbO0gZCEl0QrTDoEDmILh7OdBOChkh70R8mThkmzNW-9nBV3scM_soYTYtM-tn4D9IH6pQ-21haTQO25Q37oCil03RXjIeS4KJOY8c8HvZkqQ11_Rq06lAv3',
    },
    {
      'name': 'Elena',
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuB0i0IOf1dGFcgTjskWy_a_kqXjy8AzkMbZMym7wLoBFXt45c5rA5Wb9TLKSJKefN59ksaGqK1d98ksiE1apUiy3jDW6J_B8mB8R5Iwri68Uuu4CiuASvgz57xKYcbrJrn274BtkhHIXOE2kyoIWlNR1XjyOfBCshet6jVJP0b9fHJkEqWhoJPWTSujDiF_k-L-fPpi-tgrNm4pmv51YKg-huw3q6wvTPt7q139c4-r6oTwjFr2mmOFU--ac7mnKWGfpJoJ_rmqnlZl',
    },
  ];

  final List<Map<String, dynamic>> _conversations = [
    {
      'name': 'Eyad',
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBixo0xDlIsO9EVert7ZCTtbyU23-QEzNI75miIBKLVGbAIjsKjz48LjCohg47q45rz--50G4vNXkW90Ro9bS_SIYEyxyKZ4iEUiRu40NytBx0YvBwIyzpc4BIMEXr9GEUlCscivsZdzJ7sz0o6tKmuIsv-zt4jtfUZ1fcTA021ENEZEvZM09dcsn60CIcCThuOb6jjB_-ZPslrJtOVDXAPpQwB49l93om9Yhmu4nN3MY1rwyXS5oL-c2flQrpgmKCyj5N2pegTp1Js',
      'lastMessage': "Let's review the Python project today!",
      'time': '10:42 AM',
      'unreadCount': 3,
      'isOnline': true,
      'isRead': false,
      'avatarText': null,
    },
    {
      'name': 'Sarah Chen',
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuD_K8CIGZp86frsN5VHm983j6V7ofzwfARJIO0BZJWJV1seOsXBMW_bDqSgvuaMj2wEN9qWWMzvuxcxlRvNyJuo7wyv5mWAZHzzp0qYU5xivnaabMmX5BMMnTPj_Yrs3LuTqCUfJVCbaRwWN28PhmsvCsKe78_fsyMY8YkUFEqy0VHelL6El0Pzl1443eQ63K5J4IKLHe9tnJz-InOt70ui65Wkxmq36wSLvTzQ_QoQJhCB11wcVFMfvUGwg1ngw55sGx1aTho-TBWg',
      'lastMessage': 'Thanks for the feedback on the UI design.',
      'time': 'Yesterday',
      'unreadCount': 0,
      'isOnline': false,
      'isRead': true,
      'readByOther': true,
      'avatarText': null,
    },
    {
      'name': 'Ziad',
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDrDe0Hn51TepkEaq4IBw5SfR9QN_wNCX7GzHOe0rPmmKnsklaFrfNj8ELnJS48IyAkpJX6cQSnJR7oCK1HqgRPXLQ8WPQMFEchfuCf0iG48qvnr2tSEf_8wxyCyoQTCrK7zT3rc-07NvDu43DZSBgMIl5cWWcBDYAJIVKEb_ZfMo-qCyrqxQ8XrxLyhe5ZsrpAWD5-cTojVehuIFoLDX5RKuisSKJZ4sLriGCHJaSOX4fP3zH01lWDh_tiP4MpIHyL_wQYPZD3_Pvj',
      'lastMessage': 'Can you share the Figma link again?',
      'time': 'Monday',
      'unreadCount': 1,
      'isOnline': true,
      'isRead': false,
      'avatarText': null,
    },
    {
      'name': 'Elena Rodriguez',
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCGIin19WAbeTlqSFlDa0CvnQ9n_KtuRs0iX_73UQ6a_wod4o9RSHQ89tOhcn2SOOYxpaqkO2uQrnnNXC6htNAPjH2-JAwTkaY0CiCQLozwPwUuddLje4GkJmcGUgpvseMGww6z3wTYH2ZW4CbQYaQH1XljCKTGAwN3zFJR_bxfB6mpnwAtoeeI_lWUtsFn_uNbBnTcbQk4fs6FqdsM4JxKau2_EV18HBwkYdb-J2vW8TKzFwMuoAqa2Cfe_RGBwzlEMV55ZVLSJCLm',
      'lastMessage': 'The session was extremely helpful, thank you!',
      'time': 'Aug 12',
      'unreadCount': 0,
      'isOnline': false,
      'isRead': true,
      'readByOther': true,
      'avatarText': null,
    },
    {
      'name': 'Marcus Kim',
      'imageUrl': null,
      'lastMessage': "Let me know when you're free to chat.",
      'time': 'Aug 10',
      'unreadCount': 0,
      'isOnline': false,
      'isRead': true,
      'readByOther': false,
      'avatarText': 'MK',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
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
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Messages',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF191C21),
                              letterSpacing: -0.5,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text(
                              'New Chat',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF005DA7),
                              foregroundColor: Colors.white,
                              shape: const StadiumBorder(),
                              elevation: 2,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search conversations...',
                          hintStyle: const TextStyle(color: Color(0xFF717783)),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFF717783),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Colors.grey.withOpacity(0.15),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFF005DA7),
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 100,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            ..._activeUsers.map(
                              (user) => _buildActiveUserItem(user),
                            ),
                            _buildAllUsersItem(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._conversations.map(
                        (conv) => _buildConversationItem(conv),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
            Positioned(
              right: 16,
              bottom: 90,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF005DA7), Color(0xFF2976C7)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0060AC).withOpacity(0.4),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {},
                    child: const Center(
                      child: Icon(
                        Icons.smart_toy,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveUserItem(Map<String, dynamic> user) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF006D36), width: 2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: ClipOval(
                child: Image.network(
                  user['imageUrl'],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const CircleAvatar(
                    backgroundColor: Color(0xFFE1E2E9),
                    child: Icon(Icons.person),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user['name'],
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF414751),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllUsersItem() {
    return Opacity(
      opacity: 0.6,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFC1C7D3), width: 2),
            ),
            child: const Center(
              child: Icon(Icons.add, color: Color(0xFF717783)),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'All',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF414751),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationItem(Map<String, dynamic> conv) {
    final bool isUnread = conv['unreadCount'] > 0;
    final bool hasImage = conv['imageUrl'] != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: isUnread
            ? Colors.white
            : const Color(0xFFF2F3FB).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatPage(
                  name: conv['name'],
                  imageUrl: conv['imageUrl'],
                  avatarText: conv['avatarText'],
                  isOnline: conv['isOnline'] ?? false,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: const Color(0xFFD4E3FF),
                      child: hasImage
                          ? ClipOval(
                              child: Image.network(
                                conv['imageUrl'],
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Text(
                                  conv['avatarText'] ?? conv['name'][0],
                                  style: const TextStyle(
                                    color: Color(0xFF2976C7),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            )
                          : Text(
                              conv['avatarText'] ?? conv['name'][0],
                              style: const TextStyle(
                                color: Color(0xFF2976C7),
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                    ),
                    if (conv['isOnline'] == true)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: const Color(0xFF006D36),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            conv['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Color(0xFF191C21),
                            ),
                          ),
                          Text(
                            conv['time'],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isUnread
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isUnread
                                  ? const Color(0xFF005DA7)
                                  : const Color(0xFF717783),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conv['lastMessage'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isUnread
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isUnread
                                    ? const Color(0xFF191C21)
                                    : const Color(0xFF414751),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isUnread)
                            Container(
                              height: 20,
                              constraints: const BoxConstraints(minWidth: 20),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              decoration: const BoxDecoration(
                                color: Color(0xFFAA2D32),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${conv['unreadCount']}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          else
                            Icon(
                              Icons.done_all,
                              size: 16,
                              color: conv['readByOther'] == true
                                  ? const Color(0xFF005DA7)
                                  : const Color(0xFF717783),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
