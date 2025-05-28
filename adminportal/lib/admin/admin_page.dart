import 'package:flutter/material.dart';
import 'account_management.dart'; // Your dynamic content page

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  Widget currentPage = const Center(
    child: Text(
      'Welcome to the Admin Page!',
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
    ),
  );

  void setPage(Widget page) {
    setState(() {
      currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final darkBlue = Colors.blue[900];

    return Scaffold(
      body: Row(
        children: [
          // Side navigation
          Container(
            width: 250,
            color: darkBlue,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Navigation',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const Divider(color: Colors.white30),
                _NavItem(icon: Icons.dashboard, label: 'Bulletin Board', onTap: () {
                  setPage(const Center(child: Text('Bulletin Board')));
                }),
                _NavItem(icon: Icons.account_circle, label: 'Account Management', onTap: () {
                  setPage(AccountManagementPage());
                }),
                _NavItem(icon: Icons.school, label: 'Student Records', onTap: () {
                  setPage(const Center(child: Text('Student Records')));
                }),
                _NavItem(icon: Icons.people, label: 'Teacher Records', onTap: () {
                  setPage(const Center(child: Text('Teacher Records')));
                }),
                _NavItem(icon: Icons.assignment_turned_in, label: 'Enrollment', onTap: () {
                  setPage(const Center(child: Text('Enrollment')));
                }),
                _NavItem(icon: Icons.book, label: 'Subject Management', onTap: () {
                  setPage(const Center(child: Text('Subject Management')));
                }),
                _NavItem(icon: Icons.schedule, label: 'Schedules & Rooms', onTap: () {
                  setPage(const Center(child: Text('Schedules & Rooms')));
                }),
                _NavItem(icon: Icons.payment, label: 'Payments', onTap: () {
                  setPage(const Center(child: Text('Payments')));
                }),
                _NavItem(icon: Icons.bar_chart, label: 'Reports', onTap: () {
                  setPage(const Center(child: Text('Reports')));
                }),
                _NavItem(icon: Icons.settings, label: 'Settings', onTap: () {
                  setPage(const Center(child: Text('Settings')));
                }),
                const Spacer(),
                const Divider(color: Colors.white30),
                _NavItem(icon: Icons.logout, label: 'Logout', onTap: () {
                  Navigator.pushReplacementNamed(context, '/');
                }),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Content area
          Expanded(
            child: Container(
              color: Colors.grey[100],
              padding: const EdgeInsets.all(16),
              child: currentPage,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: _isHovered ? Colors.white : Colors.transparent,
                width: 4,
              ),
            ),
            color: _isHovered ? Colors.white10 : Colors.transparent,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(widget.icon, color: Colors.white70, size: 22),
              const SizedBox(width: 16),
              Text(
                widget.label,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
