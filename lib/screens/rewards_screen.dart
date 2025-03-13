import 'package:flutter/material.dart';
import 'package:sht/models/reward_model.dart';
import 'package:sht/services/database_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({Key? key}) : super(key: key);

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen>
    with SingleTickerProviderStateMixin {
  final DatabaseService _databaseService = DatabaseService();

  List<Reward> _rewards = [];
  int _userPoints = 0;
  bool _isLoading = true;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load rewards
      final rewards = await _databaseService.getRewards();

      // Load user points
      final userPoints = await _databaseService.getUserPoints();

      setState(() {
        _rewards = rewards;
        _userPoints = userPoints;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading rewards: $e');
      setState(() {
        _isLoading = false;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading rewards: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _redeemReward(Reward reward) async {
    // Check if user has enough points
    if (_userPoints < reward.pointsCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough points to redeem this reward'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Redeem Reward'),
        content: Text(
          'Are you sure you want to redeem "${reward.name}" for ${reward.pointsCost} points?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Redeem'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final updatedReward = await _databaseService.redeemReward(reward.id);

      if (updatedReward != null) {
        // Update local state
        setState(() {
          final index = _rewards.indexWhere((r) => r.id == updatedReward.id);
          if (index != -1) {
            _rewards[index] = updatedReward;
          }

          _userPoints -= reward.pointsCost;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully redeemed "${reward.name}"'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error redeeming reward: $e');

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error redeeming reward: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addReward() {
    // TODO: Navigate to add reward screen
    // For now, show a simple dialog to add a reward
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Reward'),
        content: const Text(
          'This feature is coming soon! You will be able to add custom rewards.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get available and redeemed rewards
    final availableRewards = _rewards.where((r) => !r.isRedeemed).toList();
    final redeemedRewards = _rewards.where((r) => r.isRedeemed).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewards'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Available'),
            Tab(text: 'Redeemed'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Points indicator
                _buildPointsIndicator(),

                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Available rewards tab
                      availableRewards.isEmpty
                          ? _buildEmptyState('No available rewards',
                              'Add rewards to motivate yourself')
                          : _buildRewardsList(availableRewards),

                      // Redeemed rewards tab
                      redeemedRewards.isEmpty
                          ? _buildEmptyState('No redeemed rewards',
                              'Redeem rewards to see them here')
                          : _buildRewardsList(redeemedRewards,
                              isRedeemed: true),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addReward,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPointsIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.star,
            color: Colors.amber,
            size: 28,
          ),
          const SizedBox(width: 8),
          Text(
            '$_userPoints',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'points available',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          const Spacer(),
          if (kIsWeb)
            Text(
              'Web Mode',
              style: TextStyle(
                color: Colors.blue[300],
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.card_giftcard,
            size: 80,
            color: Colors.amber,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addReward,
            icon: const Icon(Icons.add),
            label: const Text('Add Reward'),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsList(List<Reward> rewards, {bool isRedeemed = false}) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: rewards.length,
        itemBuilder: (context, index) {
          final reward = rewards[index];

          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isRedeemed
                              ? Colors.grey.shade300
                              : Colors.amber.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.card_giftcard,
                          color: isRedeemed
                              ? Colors.grey.shade700
                              : Colors.amber.shade800,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reward.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (reward.description != null &&
                                reward.description!.isNotEmpty)
                              Text(
                                reward.description!,
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${reward.pointsCost} points',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      if (isRedeemed)
                        // Show redeemed status
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'Redeemed ${_formatRedeemedDate(reward.redeemedAt)}',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12,
                            ),
                          ),
                        )
                      else
                        // Show redeem button
                        ElevatedButton(
                          onPressed: _userPoints >= reward.pointsCost
                              ? () => _redeemReward(reward)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            _userPoints >= reward.pointsCost
                                ? 'Redeem Now'
                                : 'Need ${reward.pointsCost - _userPoints} more',
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatRedeemedDate(DateTime? date) {
    if (date == null) return '';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'just now';
      }
      return '${difference.inHours} hour${difference.inHours != 1 ? 's' : ''} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays != 1 ? 's' : ''} ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}
