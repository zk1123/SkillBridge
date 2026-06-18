import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/message_model.dart';
import '../models/session_model.dart';
import 'profile_view_page.dart';
import 'voice_call_page.dart';
import 'report_sheet.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart'; // Required for kIsWeb
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

const _cloudinaryCloudName = 'dbca70ldz';
const _cloudinaryUploadPreset = 'SkillBridgeUploads';

// ═══════════════════════════════════════════════════════════════════
//  COLORS
// ═══════════════════════════════════════════════════════════════════

class _C {
  static const bg = Color(0xFFF8F9FF);
  static const primary = Color(0xFF005DA7);
  static const primaryLight = Color(0xFFD4E3FF);
  static const surface = Colors.white;
  static const textDark = Color(0xFF191C21);
  static const textMid = Color(0xFF64748B);
  static const textLight = Color(0xFF94A3B8);
  static const divider = Color(0xFFF2F3FB);
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);
  static const bannerPending = Color(0xFFFFFBEB);
  static const bannerConfirmed = Color(0xFFEFFFF5);
}

// ═══════════════════════════════════════════════════════════════════
//  CHAT PAGE
// ═══════════════════════════════════════════════════════════════════

class ChatPage extends StatefulWidget {
  final String chatId;
  final String matchId; // ← NEW
  final String otherUid;
  final String name;
  final String profilePicUrl;

  const ChatPage({
    super.key,
    required this.chatId,
    required this.matchId,
    required this.otherUid,
    required this.name,
    required this.profilePicUrl,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _AppBarBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _AppBarBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
          ),
          child: Icon(icon, color: Colors.white, size: 19),
        ),
      ),
    );
  }
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String _currentUid = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  // ADD THIS LINE:
  bool _isUploadingMedia = false;

  // ── Messaging ────────────────────────────────────────────────────

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();

    final message = MessageModel(
      messageId: '',
      senderId: _currentUid,
      text: text,
      sentAt: Timestamp.now(),
    );

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add(message.toMap());

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .update({
          'lastMessage': text,
          'lastMessageAt': FieldValue.serverTimestamp(),
        });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Displays the option to pick an image or a PDF
  void _showAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _C.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.image_outlined, color: _C.primary),
              title: const Text('Send Image'),
              onTap: () {
                Navigator.pop(context);
                _pickAndSendFile(FileType.image);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.picture_as_pdf_outlined,
                color: _C.danger,
              ),
              title: const Text('Send PDF Document'),
              onTap: () {
                Navigator.pop(context);
                _pickAndSendFile(FileType.custom, allowedExtensions: ['pdf']);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Handles cross-platform picking and dynamic Cloudinary routing (raw vs image)
  Future<void> _pickAndSendFile(
    FileType type, {
    List<String>? allowedExtensions,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: type,
      allowedExtensions: allowedExtensions,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;

    setState(() => _isUploadingMedia = true);

    try {
      final isPdf = file.extension == 'pdf';
      final resourceType = isPdf ? 'raw' : 'image';

      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudinaryCloudName/$resourceType/upload',
      );
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = _cloudinaryUploadPreset;

      if (kIsWeb || file.bytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            file.bytes!,
            filename: file.name,
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath('file', file.path!),
        );
      }

      final response = await request.send();
      if (response.statusCode != 200) throw Exception('Upload failed');

      final body = await response.stream.bytesToString();
      final json = jsonDecode(body);
      final secureUrl = json['secure_url'] as String;

      // 1. Add the new attachment message document
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add({
            'senderId': _currentUid,
            'text': isPdf
                ? 'Sent a document: ${file.name}'
                : 'Sent an image attachment',
            'sentAt': FieldValue.serverTimestamp(),
            'type': isPdf ? 'pdf' : 'image',
            'mediaUrl': secureUrl,
            'fileName': file.name,
          });

      // 2. Update the parent conversation model (Corrected field name to 'lastMessageAt')
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .update({
            'lastMessage': isPdf ? '📄 ${file.name}' : '📷 Photo attachment',
            'lastMessageAt': FieldValue.serverTimestamp(),
          });

      // 3. Force scroll window to animate downwards once the UI updates
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      if (mounted) setState(() => _isUploadingMedia = false);
    }
  }

  // Opens the PDF url in an external tab/app
  Future<void> _openPdfUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ── Session actions ──────────────────────────────────────────────

  Future<void> _acceptSession(SessionModel session) async {
    await FirebaseFirestore.instance
        .collection('sessions')
        .doc(session.sessionId)
        .update({
          'status': 'confirmed',
          'respondedAt': FieldValue.serverTimestamp(),
        });
  }

  Future<void> _declineSession(SessionModel session) async {
    await FirebaseFirestore.instance
        .collection('sessions')
        .doc(session.sessionId)
        .update({
          'status': 'cancelled',
          'respondedAt': FieldValue.serverTimestamp(),
        });
  }

  Future<void> _rescheduleSession(SessionModel session) async {
    // Opens the same bottom sheet but pre-fills existing values
    // and swaps proposer/responder on save
    await _showScheduleSheet(existingSession: session);
  }

  Future<void> _joinCall(SessionModel session) async {
    final roomUrl = Uri.parse(
      'https://meet.jit.si/skillbridge-${session.sessionId}',
    );
    if (await canLaunchUrl(roomUrl)) {
      // Mark call as in_call
      await FirebaseFirestore.instance
          .collection('sessions')
          .doc(session.sessionId)
          .update({'callStatus': 'in_call'});
      await launchUrl(roomUrl, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the call link.')),
      );
    }
  }

  Future<void> _endSession(SessionModel session) async {
    await FirebaseFirestore.instance
        .collection('sessions')
        .doc(session.sessionId)
        .update({'callStatus': 'ended', 'status': 'completed'});
  }

  // ── Schedule bottom sheet ────────────────────────────────────────

  Future<void> _showScheduleSheet({SessionModel? existingSession}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ScheduleSheet(
        currentUid: _currentUid,
        matchId: widget.matchId,
        otherUid: widget.otherUid,
        otherName: widget.name,
        existingSession: existingSession,
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────

  bool _isMyTurn(SessionModel session) => session.responderId == _currentUid;

  bool _canJoin(SessionModel session) {
    if (session.status != 'confirmed') return false;
    final now = DateTime.now();
    final scheduled = session.scheduledAt.toDate();
    // Allow joining 5 min before scheduled time
    return now.isAfter(scheduled.subtract(const Duration(minutes: 5)));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final hasPhoto = widget.profilePicUrl.isNotEmpty;

    return Scaffold(
      backgroundColor: _C.bg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E40AF), Color(0xFF2563EB), Color(0xFF059669)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                children: [
                  // ── Back + Schedule button ────────────────────────
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),

                  // ── Avatar ───────────────────────────────────────
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.all(2.5),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(1.5),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFFEEF2FF),
                        child: hasPhoto
                            ? ClipOval(
                                child: Image.network(
                                  widget.profilePicUrl,
                                  width: 36,
                                  height: 36,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Text(
                                    widget.name[0].toUpperCase(),
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF2563EB),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              )
                            : Text(
                                widget.name[0].toUpperCase(),
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF2563EB),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // ── Name + online hint ────────────────────────────
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ViewProfilePage(uid: widget.otherUid),
                            ),
                          ),
                          child: Text(
                            widget.name,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: Color(0xFF34D399),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'SkillBridge peer',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.75),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ── Schedule session ─────────────────────────────
                  _AppBarBtn(
                    icon: Icons.add_circle_rounded,
                    tooltip: 'Schedule a session',
                    onTap: _showScheduleSheet,
                  ),

                  // ── Voice call ───────────────────────────────────
                  _AppBarBtn(
                    icon: Icons.call_rounded,
                    tooltip: 'Voice call',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VoiceCallPage(
                          personName: widget.name,
                          personImage: widget.profilePicUrl.isNotEmpty
                              ? widget.profilePicUrl
                              : null,
                          avatarText: widget.name.isNotEmpty
                              ? widget.name[0].toUpperCase()
                              : '?',
                        ),
                      ),
                    ),
                  ),

                  // ── Video call ───────────────────────────────────
                  _AppBarBtn(
                    icon: Icons.videocam_rounded,
                    tooltip: 'Schedule a session',
                    onTap: _showScheduleSheet,
                  ),

                  // ── More menu — untouched ────────────────────────
                  IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: Colors.white.withOpacity(0.85),
                      size: 22,
                    ),
                    onPressed: () {
                      showMenu(
                        context: context,
                        position: RelativeRect.fromLTRB(
                          MediaQuery.of(context).size.width,
                          56,
                          0,
                          0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        items: [
                          PopupMenuItem(
                            onTap: () => showReportSheet(
                              context,
                              reportedId: widget.otherUid,
                              targetType: 'user',
                              targetId: widget.otherUid,
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.flag_outlined,
                                  color: Color(0xFFEF4444),
                                  size: 18,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Report user',
                                  style: TextStyle(
                                    color: Color(0xFFEF4444),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Active session banner ──────────────────────────────
          _SessionBanner(
            matchId: widget.matchId,
            currentUid: _currentUid,
            otherName: widget.name,
            isMyTurn: _isMyTurn,
            canJoin: _canJoin,
            onAccept: _acceptSession,
            onDecline: _declineSession,
            onReschedule: _rescheduleSession,
            onJoin: _joinCall,
            onEnd: _endSession,
          ),

          // ── Messages ───────────────────────────────────────────
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('sentAt', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: _C.primary),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.waving_hand_rounded,
                          size: 40,
                          color: Color(0xFFCBD5E1),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Say hi to ${widget.name.split(' ').first}!',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final msg = MessageModel.fromMap(
                      docs[index].data() as Map<String, dynamic>,
                      docs[index].id,
                    );
                    return _buildMessageBubble(msg);
                  },
                );
              },
            ),
          ),

          // ── Input bar ──────────────────────────────────────────
          Container(
            color: _C.surface,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  IconButton(
                    icon: _isUploadingMedia
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _C.primary,
                            ),
                          )
                        : const Icon(Icons.attach_file, color: _C.textMid),
                    onPressed: _isUploadingMedia ? null : _showAttachmentMenu,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: const TextStyle(color: _C.textMid),
                        filled: true,
                        fillColor: _C.divider,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: _C.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
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

  // ── Message bubble (unchanged) ───────────────────────────────────

  // Widget _buildMessageBubble(MessageModel msg) {
  //   final bool isMe = msg.senderId == _currentUid;
  //   final time = msg.sentAt.toDate();
  //   final timeStr =
  //       '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 8),
  //     child: Row(
  //       mainAxisAlignment: isMe
  //           ? MainAxisAlignment.end
  //           : MainAxisAlignment.start,
  //       crossAxisAlignment: CrossAxisAlignment.end,
  //       children: [
  //         if (!isMe) ...[
  //           CircleAvatar(
  //             radius: 14,
  //             backgroundColor: _C.primaryLight,
  //             child: widget.profilePicUrl.isNotEmpty
  //                 ? ClipOval(
  //                     child: Image.network(
  //                       widget.profilePicUrl,
  //                       width: 28,
  //                       height: 28,
  //                       fit: BoxFit.cover,
  //                       errorBuilder: (_, __, ___) => Text(
  //                         widget.name[0].toUpperCase(),
  //                         style: const TextStyle(
  //                           fontSize: 10,
  //                           color: _C.primary,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                       ),
  //                     ),
  //                   )
  //                 : Text(
  //                     widget.name[0].toUpperCase(),
  //                     style: const TextStyle(
  //                       fontSize: 10,
  //                       color: _C.primary,
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //           ),
  //           const SizedBox(width: 6),
  //         ],
  //         Flexible(
  //           child: Container(
  //             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
  //             decoration: BoxDecoration(
  //               color: isMe ? _C.primary : _C.surface,
  //               borderRadius: BorderRadius.only(
  //                 topLeft: const Radius.circular(16),
  //                 topRight: const Radius.circular(16),
  //                 bottomLeft: isMe
  //                     ? const Radius.circular(16)
  //                     : const Radius.circular(4),
  //                 bottomRight: isMe
  //                     ? const Radius.circular(4)
  //                     : const Radius.circular(16),
  //               ),
  //               boxShadow: [
  //                 BoxShadow(
  //                   color: Colors.black.withOpacity(0.05),
  //                   blurRadius: 4,
  //                   offset: const Offset(0, 2),
  //                 ),
  //               ],
  //             ),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.end,
  //               children: [
  //                 Text(
  //                   msg.text,
  //                   style: TextStyle(
  //                     color: isMe ? Colors.white : _C.textDark,
  //                     fontSize: 14,
  //                   ),
  //                 ),
  //                 const SizedBox(height: 4),
  //                 Text(
  //                   timeStr,
  //                   style: TextStyle(
  //                     fontSize: 10,
  //                     color: isMe
  //                         ? Colors.white.withOpacity(0.7)
  //                         : _C.textLight,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildMessageBubble(MessageModel msg) {
    final String senderId = msg.senderId ?? '';
    final String text = msg.text ?? '';
    final String type = msg.type ?? 'text';
    final String? mediaUrl = msg.mediaUrl;
    final String? fileName = msg.fileName;

    final bool isMe = senderId == _currentUid;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          color: isMe
              ? _C.primary
              : (type == 'image' || type == 'pdf' || type == 'file'
                    ? Colors.grey[200]
                    : _C.primaryLight.withOpacity(0.4)),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        // FIXED CHECK: This now checks for 'pdf' OR 'file' type strings natively
        child: type == 'image' && mediaUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(mediaUrl, fit: BoxFit.cover),
              )
            : (type == 'pdf' || type == 'file') && mediaUrl != null
            ? GestureDetector(
                onTap: () => _openPdfUrl(mediaUrl),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.picture_as_pdf,
                      color: Colors.red,
                      size: 32,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fileName ?? 'Document.pdf',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const Text(
                            'Tap to view document',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : Text(
                text,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isMe ? Colors.white : _C.textDark,
                ),
              ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  SESSION BANNER
//  Streams the most recent non-cancelled session for this match
//  and renders the right UI based on status + whose turn it is
// ═══════════════════════════════════════════════════════════════════

class _SessionBanner extends StatelessWidget {
  final String matchId;
  final String currentUid;
  final String otherName;
  final bool Function(SessionModel) isMyTurn;
  final bool Function(SessionModel) canJoin;
  final Future<void> Function(SessionModel) onAccept;
  final Future<void> Function(SessionModel) onDecline;
  final Future<void> Function(SessionModel) onReschedule;
  final Future<void> Function(SessionModel) onJoin;
  final Future<void> Function(SessionModel) onEnd;

  const _SessionBanner({
    required this.matchId,
    required this.currentUid,
    required this.otherName,
    required this.isMyTurn,
    required this.canJoin,
    required this.onAccept,
    required this.onDecline,
    required this.onReschedule,
    required this.onJoin,
    required this.onEnd,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('sessions')
          .where('matchId', isEqualTo: matchId)
          .where('status', whereIn: ['pending_response', 'confirmed'])
          .orderBy('createdAt', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink(); // No active session — hide banner
        }

        final doc = snapshot.data!.docs.first;
        final session = SessionModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );

        return _buildBanner(context, session);
      },
    );
  }

  Widget _buildBanner(BuildContext context, SessionModel session) {
    final myTurn = isMyTurn(session);
    final joinable = canJoin(session);
    final isPending = session.status == 'pending_response';
    final isConfirmed = session.status == 'confirmed';
    final isInCall = session.callStatus == 'in_call';

    final scheduledDate = session.scheduledAt.toDate();
    final dateStr = _formatDate(scheduledDate);
    final timeStr = _formatTime(scheduledDate);

    // Colors based on state
    final bgColor = isPending ? _C.bannerPending : _C.bannerConfirmed;
    final borderColor = isPending
        ? _C.warning.withOpacity(0.3)
        : _C.success.withOpacity(0.3);
    final dotColor = isPending ? _C.warning : _C.success;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header row ──
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _bannerTitle(session, myTurn, isInCall),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isPending
                          ? const Color(0xFF92400E)
                          : const Color(0xFF065F46),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // ── Session details ──
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 12,
                  color: _C.textMid,
                ),
                const SizedBox(width: 4),
                Text(
                  '$dateStr at $timeStr',
                  style: const TextStyle(fontSize: 12, color: _C.textMid),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.timer_outlined, size: 12, color: _C.textMid),
                const SizedBox(width: 4),
                Text(
                  '${session.durationMinutes} min',
                  style: const TextStyle(fontSize: 12, color: _C.textMid),
                ),
              ],
            ),

            if (session.topic.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.school_outlined,
                    size: 12,
                    color: _C.textMid,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      session.topic,
                      style: const TextStyle(fontSize: 12, color: _C.textMid),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 10),

            // ── Action buttons ──
            _buildActions(context, session, myTurn, joinable, isInCall),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(
    BuildContext context,
    SessionModel session,
    bool myTurn,
    bool joinable,
    bool isInCall,
  ) {
    // Case 1: Session is confirmed and joinable (or already in call)
    if (session.status == 'confirmed') {
      if (isInCall) {
        return Row(
          children: [
            Expanded(
              child: _BannerButton(
                label: 'Join Call',
                icon: Icons.videocam_rounded,
                color: _C.success,
                onTap: () => onJoin(session),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _BannerButton(
                label: 'End Session',
                icon: Icons.call_end_rounded,
                color: _C.danger,
                onTap: () => onEnd(session),
              ),
            ),
          ],
        );
      }

      if (joinable) {
        return _BannerButton(
          label: 'Join Call',
          icon: Icons.videocam_rounded,
          color: _C.success,
          onTap: () => onJoin(session),
          fullWidth: true,
        );
      }

      // Confirmed but not yet time
      return const Text(
        'Session confirmed — you\'ll be able to join 5 min before it starts.',
        style: TextStyle(fontSize: 12, color: _C.textMid),
      );
    }

    // Case 2: Pending — it's my turn to respond
    if (myTurn) {
      return Row(
        children: [
          Expanded(
            child: _BannerButton(
              label: 'Accept',
              icon: Icons.check_rounded,
              color: _C.success,
              onTap: () => onAccept(session),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _BannerButton(
              label: 'Reschedule',
              icon: Icons.edit_calendar_outlined,
              color: _C.warning,
              onTap: () => onReschedule(session),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _BannerButton(
              label: 'Decline',
              icon: Icons.close_rounded,
              color: _C.danger,
              onTap: () => onDecline(session),
            ),
          ),
        ],
      );
    }

    // Case 3: Pending — waiting for the other person
    return Text(
      'Waiting for ${otherName.split(' ').first} to respond…',
      style: const TextStyle(fontSize: 12, color: _C.textMid),
    );
  }

  String _bannerTitle(SessionModel session, bool myTurn, bool isInCall) {
    if (isInCall) return 'Session in progress';
    if (session.status == 'confirmed') return 'Upcoming session confirmed ✓';
    if (myTurn) return '${otherName.split(' ').first} proposed a session';
    return 'Session request sent';
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }
}

// ═══════════════════════════════════════════════════════════════════
//  BANNER BUTTON
// ═══════════════════════════════════════════════════════════════════

class _BannerButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool fullWidth;

  const _BannerButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final btn = GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );

    return fullWidth ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}

// ═══════════════════════════════════════════════════════════════════
//  SCHEDULE BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════════

class _ScheduleSheet extends StatefulWidget {
  final String currentUid;
  final String matchId;
  final String otherUid;
  final String otherName;
  final SessionModel? existingSession; // non-null = reschedule flow

  const _ScheduleSheet({
    required this.currentUid,
    required this.matchId,
    required this.otherUid,
    required this.otherName,
    this.existingSession,
  });

  @override
  State<_ScheduleSheet> createState() => _ScheduleSheetState();
}

class _ScheduleSheetState extends State<_ScheduleSheet> {
  final _topicController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _durationMinutes = 60;
  bool _iAmTeacher = true; // true = current user teaches, false = other teaches
  bool _saving = false;

  bool get _isReschedule => widget.existingSession != null;

  @override
  void initState() {
    super.initState();
    if (_isReschedule) {
      final s = widget.existingSession!;
      _topicController.text = s.topic;
      final dt = s.scheduledAt.toDate();
      _selectedDate = dt;
      _selectedTime = TimeOfDay(hour: dt.hour, minute: dt.minute);
      _durationMinutes = s.durationMinutes;
      _iAmTeacher = s.teacherId == widget.currentUid;
    }
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
      builder: (ctx, child) => Theme(
        data: Theme.of(
          ctx,
        ).copyWith(colorScheme: const ColorScheme.light(primary: _C.primary)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 10, minute: 0),
      builder: (ctx, child) => Theme(
        data: Theme.of(
          ctx,
        ).copyWith(colorScheme: const ColorScheme.light(primary: _C.primary)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _save() async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick a date and time.')),
      );
      return;
    }

    final topic = _topicController.text.trim();
    if (topic.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a topic.')));
      return;
    }

    setState(() => _saving = true);

    final scheduledAt = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final teacherId = _iAmTeacher ? widget.currentUid : widget.otherUid;
    final learnerId = _iAmTeacher ? widget.otherUid : widget.currentUid;

    try {
      if (_isReschedule) {
        // Reschedule: swap proposer/responder so it's now the other person's turn
        await FirebaseFirestore.instance
            .collection('sessions')
            .doc(widget.existingSession!.sessionId)
            .update({
              'proposerId': widget.currentUid,
              'responderId': widget.otherUid,
              'topic': topic,
              'scheduledAt': Timestamp.fromDate(scheduledAt),
              'durationMinutes': _durationMinutes,
              'teacherId': teacherId,
              'learnerId': learnerId,
              'status': 'pending_response',
              'callStatus': 'idle',
            });
      } else {
        // New session proposal
        final session = SessionModel(
          sessionId: '',
          matchId: widget.matchId,
          proposerId: widget.currentUid,
          responderId: widget.otherUid,
          teacherId: teacherId,
          learnerId: learnerId,
          topic: topic,
          durationMinutes: _durationMinutes,
          scheduledAt: Timestamp.fromDate(scheduledAt),
          status: 'pending_response',
          callStatus: 'idle',
          createdAt: Timestamp.now(),
        );
        await FirebaseFirestore.instance
            .collection('sessions')
            .add(session.toMap());
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title
          Text(
            _isReschedule ? 'Reschedule Session' : 'Schedule a Session',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _C.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _isReschedule
                ? 'Propose a new time to ${widget.otherName.split(' ').first}'
                : 'Propose a learning session with ${widget.otherName.split(' ').first}',
            style: const TextStyle(fontSize: 13, color: _C.textMid),
          ),

          const SizedBox(height: 24),

          // Topic field
          _SheetLabel('Topic'),
          const SizedBox(height: 8),
          TextField(
            controller: _topicController,
            decoration: _inputDecoration('e.g. Intro to Flutter widgets'),
            textCapitalization: TextCapitalization.sentences,
          ),

          const SizedBox(height: 16),

          // Date & Time row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SheetLabel('Date'),
                    const SizedBox(height: 8),
                    _PickerTile(
                      icon: Icons.calendar_today_outlined,
                      label: _selectedDate == null
                          ? 'Pick date'
                          : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                      onTap: _pickDate,
                      filled: _selectedDate != null,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SheetLabel('Time'),
                    const SizedBox(height: 8),
                    _PickerTile(
                      icon: Icons.access_time_outlined,
                      label: _selectedTime == null
                          ? 'Pick time'
                          : _selectedTime!.format(context),
                      onTap: _pickTime,
                      filled: _selectedTime != null,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Duration
          _SheetLabel('Duration'),
          const SizedBox(height: 8),
          Row(
            children: [30, 60, 90].map((d) {
              final selected = _durationMinutes == d;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _durationMinutes = d),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? _C.primary : _C.divider,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${d}m',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: selected ? Colors.white : _C.textMid,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Who teaches who
          _SheetLabel('I will…'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _iAmTeacher = true),
                  child: _RoleChip(
                    label: 'Teach',
                    sublabel: widget.otherName.split(' ').first,
                    icon: Icons.emoji_objects_outlined,
                    selected: _iAmTeacher,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _iAmTeacher = false),
                  child: _RoleChip(
                    label: 'Learn from',
                    sublabel: widget.otherName.split(' ').first,
                    icon: Icons.school_outlined,
                    selected: !_iAmTeacher,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _isReschedule ? 'Send New Proposal' : 'Send Proposal',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  SHEET HELPERS
// ═══════════════════════════════════════════════════════════════════

class _SheetLabel extends StatelessWidget {
  final String text;
  const _SheetLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: _C.textDark,
      ),
    );
  }
}

InputDecoration _inputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: _C.textLight, fontSize: 14),
    filled: true,
    fillColor: const Color(0xFFF8F9FF),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: _C.primary, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );
}

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  const _PickerTile({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: filled ? const Color(0xFFEFF6FF) : const Color(0xFFF8F9FF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: filled
                ? _C.primary.withOpacity(0.4)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: filled ? _C.primary : _C.textLight),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: filled ? FontWeight.w600 : FontWeight.w400,
                  color: filled ? _C.primary : _C.textLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String label;
  final String sublabel;
  final IconData icon;
  final bool selected;

  const _RoleChip({
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFEFF6FF) : const Color(0xFFF8F9FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? _C.primary : const Color(0xFFE2E8F0),
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: selected ? _C.primary : _C.textLight),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: selected ? _C.primary : _C.textMid,
                  ),
                ),
                Text(
                  sublabel,
                  style: const TextStyle(fontSize: 11, color: _C.textLight),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
