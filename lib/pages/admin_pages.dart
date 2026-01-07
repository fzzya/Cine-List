import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cine_list/auth_screen.dart';

const Color bgMain = Color(0xFFCEDAD2);
const Color cardBg = Color(0xFFFFFFFF);

const Color primary = Color(0xFF62B4CA);
const Color secondary = Color(0xFFB4D2D0);
const Color accent = Color(0xFF0784A5);

const Color textMain = Color(0xFF001936);
const Color textMuted = Color(0xFF4F6D7A);
const Color danger = Color(0xFFB84A4A);

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgMain,
      appBar: AppBar(
        backgroundColor: bgMain,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'ADMIN CONTROL',
          style: TextStyle(
            color: textMain,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: accent),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const AuthScreen(),
                ),
                (_) => false,
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: accent),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'NO USERS FOUND',
                style: TextStyle(color: textMuted),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: snapshot.data!.docs
                .map((doc) => _UserTile(doc: doc))
                .toList(),
          );
        },
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final QueryDocumentSnapshot doc;

  const _UserTile({required this.doc});

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: secondary),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ListTile(
        leading: const Icon(
          Icons.person_outline,
          color: accent,
        ),
        title: Text(
          data['email'] ?? '-',
          style: const TextStyle(
            color: textMain,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'ROLE • ${(data['role'] ?? 'user').toString().toUpperCase()}',
          style: const TextStyle(
            color: textMuted,
            fontSize: 12,
            letterSpacing: 1,
          ),
        ),
        trailing: PopupMenuButton<_UserAction>(
          icon: const Icon(Icons.more_vert, color: textMuted),
          color: cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: secondary),
          ),
          onSelected: (action) => _handleAction(action),
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: _UserAction.admin,
              child: _MenuItem(
                icon: Icons.security,
                label: 'SET AS ADMIN',
                color: accent,
              ),
            ),
            PopupMenuItem(
              value: _UserAction.user,
              child: _MenuItem(
                icon: Icons.person,
                label: 'SET AS USER',
                color: primary,
              ),
            ),
            PopupMenuItem(
              value: _UserAction.delete,
              child: _MenuItem(
                icon: Icons.delete_outline,
                label: 'DELETE USER',
                color: danger,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAction(_UserAction action) async {
    switch (action) {
      case _UserAction.admin:
        await doc.reference.update({'role': 'admin'});
        break;
      case _UserAction.user:
        await doc.reference.update({'role': 'user'});
        break;
      case _UserAction.delete:
        await doc.reference.delete();
        break;
    }
  }
}

enum _UserAction { admin, user, delete }

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(color: color),
        ),
      ],
    );
  }
}
