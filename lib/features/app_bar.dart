import 'package:flutter/material.dart';
import 'bottomnavbar.dart' show appScaffoldKey, SkillBridgeLogo;

class SkillBridgeAppBar extends StatelessWidget {
  final List<Widget> actions;

  const SkillBridgeAppBar({super.key, this.actions = const []});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        border: Border(
          bottom: BorderSide(color: const Color(0xFFE2E8F0).withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          // ── Burger menu ──
          GestureDetector(
            onTap: () => appScaffoldKey.currentState?.openDrawer(),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF2563EB).withOpacity(0.1),
                    const Color(0xFF059669).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: const Color(0xFF2563EB).withOpacity(0.2),
                ),
              ),
              child: const Icon(
                Icons.menu_rounded,
                size: 20,
                color: Color(0xFF2563EB),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const SkillBridgeLogo(fontSize: 22),
          const Spacer(),
          ...actions,
        ],
      ),
    );
  }
}

// ── Reusable icon button used in action lists ──
class AppBarIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary; // true = gradient fill, false = ghost style

  const AppBarIconBtn({
    super.key,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          gradient: isPrimary
              ? const LinearGradient(
                  colors: [
                    Color(0xFF1E40AF),
                    Color(0xFF2563EB),
                    Color(0xFF059669),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [
                    const Color(0xFF2563EB).withOpacity(0.1),
                    const Color(0xFF059669).withOpacity(0.1),
                  ],
                ),
          borderRadius: BorderRadius.circular(13),
          border: isPrimary
              ? null
              : Border.all(color: const Color(0xFF2563EB).withOpacity(0.2)),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Icon(
          icon,
          size: 20,
          color: isPrimary ? Colors.white : const Color(0xFF2563EB),
        ),
      ),
    );
  }
}
