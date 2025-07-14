import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reservation_provider.dart';
import '../utils/app_theme.dart';

class ReservationSummaryCard extends StatelessWidget {
  const ReservationSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReservationProvider>(
      builder: (context, reservationProvider, child) {
        final stats = reservationProvider.statistics;
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reservation Summary',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        context,
                        icon: Icons.event_available,
                        label: 'Active',
                        value: '${stats['activeReservations']}',
                        color: AppTheme.successColor,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        context,
                        icon: Icons.schedule,
                        label: 'Upcoming',
                        value: '${stats['upcomingReservations']}',
                        color: AppTheme.warningColor,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        context,
                        icon: Icons.history,
                        label: 'Total',
                        value: '${stats['totalReservations']}',
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        context,
                        icon: Icons.attach_money,
                        label: 'Total Spent',
                        value: '\$${(stats['totalSpent'] as double).toStringAsFixed(0)}',
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        context,
                        icon: Icons.trending_up,
                        label: 'Completion',
                        value: '${((stats['completionRate'] as double) * 100).toInt()}%',
                        color: AppTheme.successColor,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        context,
                        icon: Icons.access_time,
                        label: 'Avg Duration',
                        value: _formatDuration(stats['averageDuration'] as Duration),
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }
}
