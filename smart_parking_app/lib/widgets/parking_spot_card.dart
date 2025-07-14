import 'package:flutter/material.dart';
import '../models/parking_spot_model.dart';
import '../utils/app_theme.dart';

class ParkingSpotCard extends StatelessWidget {
  final ParkingSpotModel spot;
  final VoidCallback? onTap;
  final bool showDistance;

  const ParkingSpotCard({
    super.key,
    required this.spot,
    this.onTap,
    this.showDistance = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      spot.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusChip(),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Address
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppTheme.textSecondaryColor,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      spot.address,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Availability and Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Availability
                  Row(
                    children: [
                      Icon(
                        Icons.local_parking,
                        size: 16,
                        color: spot.isAvailable 
                            ? AppTheme.successColor 
                            : AppTheme.errorColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${spot.availableSpots}/${spot.totalSpots} available',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: spot.isAvailable 
                              ? AppTheme.successColor 
                              : AppTheme.errorColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  
                  // Price
                  Text(
                    '\$${spot.pricePerHour.toStringAsFixed(2)}/hr',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Features
              if (spot.features.isNotEmpty) ...[
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: spot.features.take(3).map((feature) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        feature,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryColor,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
              ],
              
              // Type and Zone
              Row(
                children: [
                  _buildInfoChip(
                    icon: _getTypeIcon(spot.type),
                    label: _getTypeLabel(spot.type),
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    icon: Icons.place,
                    label: spot.zone,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color color;
    String label;
    
    switch (spot.status) {
      case ParkingSpotStatus.available:
        color = AppTheme.successColor;
        label = 'Available';
        break;
      case ParkingSpotStatus.occupied:
        color = AppTheme.errorColor;
        label = 'Occupied';
        break;
      case ParkingSpotStatus.reserved:
        color = AppTheme.warningColor;
        label = 'Reserved';
        break;
      case ParkingSpotStatus.maintenance:
        color = AppTheme.textSecondaryColor;
        label = 'Maintenance';
        break;
      case ParkingSpotStatus.disabled:
        color = AppTheme.textSecondaryColor;
        label = 'Disabled';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: AppTheme.textSecondaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(ParkingSpotType type) {
    switch (type) {
      case ParkingSpotType.indoor:
        return Icons.home;
      case ParkingSpotType.covered:
        return Icons.roofing;
      case ParkingSpotType.street:
        return Icons.road;
      case ParkingSpotType.garage:
        return Icons.garage;
      case ParkingSpotType.lot:
        return Icons.local_parking;
      default:
        return Icons.local_parking;
    }
  }

  String _getTypeLabel(ParkingSpotType type) {
    switch (type) {
      case ParkingSpotType.indoor:
        return 'Indoor';
      case ParkingSpotType.covered:
        return 'Covered';
      case ParkingSpotType.street:
        return 'Street';
      case ParkingSpotType.garage:
        return 'Garage';
      case ParkingSpotType.lot:
        return 'Lot';
      default:
        return 'Outdoor';
    }
  }
}
