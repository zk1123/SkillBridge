import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/block_provider.dart';

class BlockButton extends StatelessWidget {
  final String targetUserId;
  final String targetUserName;
  final bool asMenuItem;
  final VoidCallback? onBlockSuccess;

  const BlockButton({
    super.key,
    required this.targetUserId,
    required this.targetUserName,
    this.asMenuItem = false,
    this.onBlockSuccess,
  });

  void _showBlockDialog(BuildContext context) {
    final blockProvider = context.read<BlockProvider>();
    final isAlreadyBlocked = blockProvider.isUserBlocked(targetUserId);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isAlreadyBlocked ? 'Unblock User' : 'Block User',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          isAlreadyBlocked
              ? 'Are you sure you want to unblock $targetUserName?\nThey will be able to contact you again.'
              : 'Are you sure you want to block $targetUserName?\nThey will no longer be able to:\n• Send you messages\n• View your profile\n• Appear in your search results',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: isAlreadyBlocked ? Colors.green : Colors.red,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              if (isAlreadyBlocked) {
                await blockProvider.unblockUser(targetUserId);
              } else {
                await blockProvider.blockUser(targetUserId);
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isAlreadyBlocked
                          ? '$targetUserName has been unblocked'
                          : '$targetUserName has been blocked',
                    ),
                    backgroundColor: isAlreadyBlocked
                        ? Colors.green
                        : Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                if (!isAlreadyBlocked) onBlockSuccess?.call();
              }
            },
            child: Text(isAlreadyBlocked ? 'Unblock' : 'Block'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BlockProvider>(
      builder: (context, blockProvider, _) {
        final isBlocked = blockProvider.isUserBlocked(targetUserId);

        if (asMenuItem) {
          return ListTile(
            onTap: () {
              Navigator.pop(context);
              _showBlockDialog(context);
            },
            leading: Icon(
              isBlocked ? Icons.block_flipped : Icons.block,
              color: isBlocked ? Colors.green : Colors.red,
            ),
            title: Text(
              isBlocked ? 'Unblock User' : 'Block User',
              style: TextStyle(
                color: isBlocked ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }

        return OutlinedButton.icon(
          onPressed: () => _showBlockDialog(context),
          icon: Icon(
            isBlocked ? Icons.block_flipped : Icons.block,
            size: 18,
            color: isBlocked ? Colors.green : Colors.red,
          ),
          label: Text(
            isBlocked ? 'Unblock' : 'Block',
            style: TextStyle(color: isBlocked ? Colors.green : Colors.red),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: isBlocked ? Colors.green : Colors.red),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
        );
      },
    );
  }
}
