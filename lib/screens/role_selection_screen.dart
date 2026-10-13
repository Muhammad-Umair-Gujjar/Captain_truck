import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../customer/constants/app_colors.dart';
import '../app_role.dart';

class RoleSelectionScreen extends StatelessWidget {
  final void Function(AppRole role) onRoleSelected;

  const RoleSelectionScreen({super.key, required this.onRoleSelected});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
          child: Column(
            children: [
              const Spacer(flex: 2),
              SvgPicture.asset(
                'assets/images/logo.svg',
                width: size.width * 0.45,
                height: size.width * 0.45,
              ),
              Transform.translate(
                offset: const Offset(0, -40),
                child: const Text(
                  'Captain Truck',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const Text(
                'Choose how you want to continue',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  color: AppColors.textTertiary,
                ),
              ),
              const Spacer(flex: 2),
              _RoleCard(
                title: 'Customer',
                subtitle: 'Book & track your trips',
                icon: Icons.person_outline_rounded,
                color: AppColors.primary,
                onTap: () => onRoleSelected(AppRole.customer),
              ),
              const SizedBox(height: 16),
              _RoleCard(
                title: 'Driver',
                subtitle: 'Drive & deliver assigned trips',
                icon: Icons.local_shipping_outlined,
                color: const Color(0xFFF4721E),
                onTap: () => onRoleSelected(AppRole.driver),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.25)),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
