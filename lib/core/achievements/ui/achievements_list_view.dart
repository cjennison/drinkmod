import 'package:flutter/material.dart';
import '../models/achievement_model.dart';
import '../achievement_manager.dart';
import '../achievement_registry.dart';

/// Full list view of all achievements
class AchievementsListView extends StatefulWidget {
  const AchievementsListView({super.key});

  @override
  State<AchievementsListView> createState() => _AchievementsListViewState();
}

class _AchievementsListViewState extends State<AchievementsListView> {
  final AchievementManager _manager = AchievementManager.instance;
  List<GrantedAchievement> _grantedAchievements = [];
  List<Achievement> _allAchievements = [];
  Set<String> _grantedIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    try {
      // Load all achievements from registry
      final allAchievements = AchievementRegistry.getAllAchievements();
      
      // Load granted achievements
      final grantedAchievements = await _manager.getGrantedAchievements();
      
      // Create set of granted IDs for quick lookup
      final grantedIds = grantedAchievements.map((ga) => ga.achievement.id).toSet();
      
      if (mounted) {
        setState(() {
          _allAchievements = allAchievements;
          _grantedAchievements = grantedAchievements;
          _grantedIds = grantedIds;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final grantedCount = _grantedAchievements.length;
    final totalCount = _allAchievements.length;
    
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Achievements'),
            if (!_isLoading && totalCount > 0)
              Text(
                '$grantedCount of $totalCount unlocked',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _allAchievements.isEmpty
              ? _buildEmptyState()
              : _buildAchievementsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No achievements available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new achievements!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsList() {
    // Separate granted and ungranted achievements
    final grantedAchievements = _grantedAchievements;
    final ungrantedAchievements = _allAchievements
        .where((achievement) => !_grantedIds.contains(achievement.id))
        .toList();

    // Sort ungranted by category and chain position
    ungrantedAchievements.sort((a, b) {
      // First sort by category
      final categoryCompare = a.category.index.compareTo(b.category.index);
      if (categoryCompare != 0) return categoryCompare;
      
      // Then by chain position (if exists)
      if (a.chainPosition != null && b.chainPosition != null) {
        return a.chainPosition!.compareTo(b.chainPosition!);
      }
      
      // Finally by name
      return a.name.compareTo(b.name);
    });

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Granted achievements section
        if (grantedAchievements.isNotEmpty) ...[
          Text(
            'Unlocked (${grantedAchievements.length})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.green[700],
            ),
          ),
          const SizedBox(height: 8),
          ...grantedAchievements.map((granted) => _buildGrantedAchievementCard(granted)),
          const SizedBox(height: 24),
        ],
        
        // Ungranted achievements section
        if (ungrantedAchievements.isNotEmpty) ...[
          Text(
            'Work Towards (${ungrantedAchievements.length})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          ...ungrantedAchievements.map((achievement) => _buildUngrantedAchievementCard(achievement)),
        ],
      ],
    );
  }

  Widget _buildGrantedAchievementCard(GrantedAchievement granted) {
    final achievement = granted.achievement;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: achievement.color,
            shape: BoxShape.circle,
          ),
          child: Icon(
            achievement.icon,
            size: 20,
            color: Colors.white,
          ),
        ),
        title: Text(
          achievement.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          achievement.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green[600],
              size: 16,
            ),
            const SizedBox(height: 2),
            Text(
              _formatDate(granted.grantedAt),
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUngrantedAchievementCard(Achievement achievement) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.grey[50],
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Icon(
            achievement.icon,
            size: 20,
            color: Colors.grey[600],
          ),
        ),
        title: Text(
          achievement.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        subtitle: Text(
          achievement.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Locked',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '${difference}d ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}
