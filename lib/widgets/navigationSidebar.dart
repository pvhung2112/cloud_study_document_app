import 'package:flutter/material.dart';

class NavigationSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const NavigationSidebar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mainItems = [
      {'icon': Icons.home_rounded, 'label': 'Trang chủ', 'index': 0},
      {'icon': Icons.menu_book_rounded, 'label': 'Tài liệu học tập', 'index': 1},
      {'icon': Icons.school_rounded, 'label': 'Môn học', 'index': 2},
      {'icon': Icons.flag_rounded, 'label': 'Mục tiêu', 'index': 3},
      {'icon': Icons.search_rounded, 'label': 'Tìm kiếm', 'index': 4},
    ];
    final featureItems = [
      {'icon': Icons.map_rounded, 'label': 'Bản đồ Tài liệu', 'index': 5},
      {'icon': Icons.swap_horiz_rounded, 'label': 'Mượn & Chia sẻ', 'index': 6},
      {'icon': Icons.auto_awesome_rounded, 'label': 'Gợi ý cho bạn', 'index': 7},
    ];

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: theme.colorScheme.outlineVariant.withOpacity(0.4),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo & App Name (Cashew Style)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7D8DF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Color(0xFFD81B60),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cashew Study',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Quản lý Tài liệu',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),
          const SizedBox(height: 12),

          // Navigation Items with Cashew Pink Pill Style
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                // Main nav items
                ...mainItems.map((item) => _buildNavItem(item, theme)),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Text(
                    'TÍNH NĂNG MỚI',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6), letterSpacing: 1.2),
                  ),
                ),
                ...featureItems.map((item) => _buildFeatureNavItem(item, theme)),
              ],
            ),
          ),

          // Student Info Footer
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0xFFD81B60),
                    child: Text('H', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Phạm Văn Hưng', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        Text('pvhung2112', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
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

  Widget _buildNavItem(Map<String, Object> item, ThemeData theme) {
    final idx = item['index'] as int;
    final isSelected = selectedIndex == idx;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: () => onDestinationSelected(idx),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFF7D8DF) : Colors.transparent,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                Icon(item['icon'] as IconData, size: 22, color: isSelected ? const Color(0xFFD81B60) : theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 14),
                Text(
                  item['label'] as String,
                  style: TextStyle(fontSize: 14, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? const Color(0xFFD81B60) : theme.colorScheme.onSurface),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureNavItem(Map<String, Object> item, ThemeData theme) {
    final idx = item['index'] as int;
    final isSelected = selectedIndex == idx;
    final Color color = idx == 5 ? Colors.teal : (idx == 6 ? Colors.indigo : const Color(0xFFD81B60));
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: () => onDestinationSelected(idx),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.12) : Colors.transparent,
              borderRadius: BorderRadius.circular(25),
              border: isSelected ? Border.all(color: color.withOpacity(0.3)) : null,
            ),
            child: Row(
              children: [
                Icon(item['icon'] as IconData, size: 20, color: isSelected ? color : theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item['label'] as String,
                    style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? color : theme.colorScheme.onSurface),
                  ),
                ),
                if (idx == 7)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFD81B60), Color(0xFFE91E63)]),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('AI', style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
