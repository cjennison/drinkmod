import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Detailed view modal for displaying comprehensive drink entry information
class DrinkItemViewModal extends StatelessWidget {
  final Map<String, dynamic> entry;
  final VoidCallback? onEdit;

  const DrinkItemViewModal({
    super.key,
    required this.entry,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final drinkDate = DateTime.parse(entry['drinkDate']);
    final standardDrinks = entry['standardDrinks'] as double;
    final drinkName = entry['drinkName'] as String;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 650, maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, drinkName, drinkDate),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildCoreInfo(standardDrinks, drinkDate),
                    if (_hasInterventionInfo()) ...[
                      const SizedBox(height: 20),
                      _buildInterventionSection(),
                    ],
                    if (_hasContextInfo()) ...[
                      const SizedBox(height: 20),
                      _buildContextSection(),
                    ],
                    if (_hasEmotionalInfo()) ...[
                      const SizedBox(height: 20),
                      _buildEmotionalSection(),
                    ],
                    if (_hasReflectionInfo()) ...[
                      const SizedBox(height: 20),
                      _buildReflectionSection(),
                    ],
                    if (!_hasAnyEnhancedInfo()) ...[
                      const SizedBox(height: 20),
                      _buildNoAdditionalInfoMessage(),
                    ],
                  ],
                ),
              ),
            ),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String drinkName, DateTime drinkDate) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor.withValues(alpha: 0.1),
            Theme.of(context).primaryColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.local_drink,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  drinkName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('EEEE, MMMM d, y').format(drinkDate),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.close, color: Colors.grey.shade600),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoreInfo(double standardDrinks, DateTime drinkDate) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined, 
                   color: Colors.blue.shade600, 
                   size: 20),
              const SizedBox(width: 8),
              Text(
                'Drink Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoTile(
                  'Standard Drinks',
                  standardDrinks.toStringAsFixed(1),
                  Icons.local_drink_outlined,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoTile(
                  'Time',
                  entry['timeOfDay'] ?? DateFormat('h:mm a').format(drinkDate),
                  Icons.access_time_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContextSection() {
    return _buildSection(
      title: 'Context & Setting',
      icon: Icons.place_outlined,
      color: Colors.green.shade600,
      children: [
        if (entry['location'] != null) ...[
          _buildInfoRow('Location', entry['location'], Icons.location_on_outlined),
          const SizedBox(height: 12),
        ],
        if (entry['socialContext'] != null) ...[
          _buildInfoRow('Social Context', entry['socialContext'], Icons.people_outline),
        ],
      ],
    );
  }

  Widget _buildEmotionalSection() {
    return _buildSection(
      title: 'Emotional Check-in',
      icon: Icons.favorite_outline,
      color: Colors.pink.shade600,
      children: [
        if (entry['moodBefore'] != null) ...[
          _buildMoodDisplay(entry['moodBefore']),
          const SizedBox(height: 16),
        ],
        if (entry['triggers'] != null && _hasTriggersContent(entry['triggers'])) ...[
          _buildTriggersDisplay(entry['triggers']),
          const SizedBox(height: 16),
        ],
        if (entry['triggerDescription'] != null) ...[
          _buildInfoRow('Thoughts & Feelings', entry['triggerDescription'], Icons.psychology_outlined),
        ],
      ],
    );
  }

  Widget _buildReflectionSection() {
    return _buildSection(
      title: 'Reflection & Intention',
      icon: Icons.lightbulb_outline,
      color: Colors.orange.shade600,
      children: [
        if (entry['intention'] != null) ...[
          _buildInfoRow('Intention', entry['intention'], Icons.flag_outlined),
          const SizedBox(height: 12),
        ],
        if (entry['urgeIntensity'] != null) ...[
          _buildUrgeIntensityDisplay(entry['urgeIntensity']),
          const SizedBox(height: 12),
        ],
        if (entry['consideredAlternatives'] != null) ...[
          _buildAlternativesDisplay(),
        ],
      ],
    );
  }

  Widget _buildInterventionSection() {
    final interventionData = entry['interventionData'] as Map<String, dynamic>?;
    if (interventionData == null) return const SizedBox.shrink();

    return _buildSection(
      title: 'Intervention Information',
      icon: Icons.warning_amber,
      color: Colors.orange.shade600,
      children: [
        _buildInfoRow(
          'Intervention Type', 
          _getInterventionDescription(interventionData['interventionType'] as String? ?? ''), 
          Icons.category_outlined
        ),
        const SizedBox(height: 12),
        if (interventionData['userMessage'] != null) ...[
          _buildInfoRow(
            'Situation', 
            interventionData['userMessage'] as String, 
            Icons.info_outline
          ),
          const SizedBox(height: 12),
        ],
        if (interventionData['currentMood'] != null) ...[
          _buildMoodDisplay(interventionData['currentMood'] as int),
          const SizedBox(height: 12),
        ],
        if (interventionData['selectedReason'] != null) ...[
          _buildInfoRow(
            'Reason for Proceeding', 
            interventionData['selectedReason'] as String, 
            Icons.psychology_outlined
          ),
          const SizedBox(height: 12),
        ],
        if (interventionData['interventionTimestamp'] != null) ...[
          _buildInfoRow(
            'Check-in Time', 
            DateFormat('h:mm a').format(DateTime.parse(interventionData['interventionTimestamp'] as String)), 
            Icons.access_time_outlined
          ),
        ],
      ],
    );
  }

  String _getInterventionDescription(String interventionType) {
    switch (interventionType) {
      case 'schedule_violation':
        return 'Alcohol-free day intervention';
      case 'limit_exceeded':
        return 'Daily limit intervention';
      case 'approaching_limit':
        return 'Approaching limit intervention';
      case 'tolerance_exceeded':
        return 'Tolerance exceeded intervention';
      default:
        return 'Therapeutic intervention';
    }
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMoodDisplay(int mood) {
    String moodText;
    Color moodColor;
    
    if (mood <= 3) {
      moodText = 'Low ($mood/10)';
      moodColor = Colors.red.shade600;
    } else if (mood <= 6) {
      moodText = 'Moderate ($mood/10)';
      moodColor = Colors.orange.shade600;
    } else {
      moodText = 'Good ($mood/10)';
      moodColor = Colors.green.shade600;
    }
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.mood, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mood at Check-in',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: moodColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: moodColor.withOpacity(0.3)),
                ),
                child: Text(
                  moodText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: moodColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTriggersDisplay(dynamic triggers) {
    List<String> triggerList = [];
    if (triggers is List) {
      triggerList = triggers.map((e) => e.toString()).toList();
    } else if (triggers is String) {
      String cleanString = triggers.replaceAll(RegExp(r'[\[\]]'), '');
      triggerList = cleanString.split(',').map((e) => e.trim()).toList();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.psychology_outlined, size: 18, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Text(
              'Triggers',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: triggerList.map((trigger) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Text(
              trigger,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.blue.shade700,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildUrgeIntensityDisplay(int intensity) {
    return Row(
      children: [
        Icon(Icons.trending_up_outlined, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Urge Intensity',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '$intensity/10',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: Colors.grey.shade300,
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: intensity / 10,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: intensity <= 3 ? Colors.green : intensity <= 6 ? Colors.orange : Colors.red,
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
      ],
    );
  }

  Widget _buildAlternativesDisplay() {
    final considered = entry['consideredAlternatives'] as bool;
    final alternatives = entry['alternatives'] as String?;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.alt_route_outlined, size: 18, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Text(
              'Considered Alternatives',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: considered ? Colors.green.shade50 : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                considered ? Icons.check_circle_outline : Icons.cancel_outlined,
                color: considered ? Colors.green.shade600 : Colors.orange.shade600,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              considered ? 'Yes' : 'No',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: considered ? Colors.green.shade600 : Colors.orange.shade600,
              ),
            ),
          ],
        ),
        if (considered && alternatives != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              alternatives,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNoAdditionalInfoMessage() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.grey.shade400,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            'No Additional Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This drink was logged without additional therapeutic information like mood, triggers, or context.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_outlined),
              label: const Text('Close'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          if (onEdit != null) ...[
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  onEdit?.call();
                },
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Helper methods to check if sections have content
  bool _hasContextInfo() {
    return entry['location'] != null || entry['socialContext'] != null;
  }

  bool _hasEmotionalInfo() {
    return entry['moodBefore'] != null || 
           (entry['triggers'] != null && _hasTriggersContent(entry['triggers'])) ||
           entry['triggerDescription'] != null;
  }

  bool _hasTriggersContent(dynamic triggers) {
    if (triggers == null) return false;
    if (triggers is List) {
      return triggers.isNotEmpty;
    }
    if (triggers is String) {
      String cleanString = triggers.replaceAll(RegExp(r'[\[\]]'), '').trim();
      return cleanString.isNotEmpty;
    }
    return false;
  }

  bool _hasReflectionInfo() {
    return entry['intention'] != null || 
           entry['urgeIntensity'] != null || 
           entry['consideredAlternatives'] != null;
  }

  bool _hasAnyEnhancedInfo() {
    return _hasContextInfo() || _hasEmotionalInfo() || _hasReflectionInfo();
  }

  // Helper method to check if intervention info exists
  bool _hasInterventionInfo() {
    return entry['interventionData'] != null;
  }
}
