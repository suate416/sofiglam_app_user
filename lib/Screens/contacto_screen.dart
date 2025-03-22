import 'package:flutter/material.dart';
import '../store/app_colors.dart';

class ContactoScreen extends StatelessWidget {
  const ContactoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Center(
            child: Text(
              'Contáctanos',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildContactCard(
                  icon: Icons.person,
                  title: 'Propietaria',
                  content: 'Sofia Martinez',
                ),
                const SizedBox(height: 20),
                _buildContactCard(
                  icon: Icons.phone,
                  title: 'Teléfono',
                  content: '+504 3226-4646',
                  isPhone: true,
                ),
                const SizedBox(height: 20),
                _buildContactCard(
                  icon: Icons.email,
                  title: 'Correo Electrónico',
                  content: 'sofiglam@gmail.com',
                  isEmail: true,
                ),
                const SizedBox(height: 20),
                _buildContactCard(
                  icon: Icons.location_on,
                  title: 'Ubicación',
                  content: 'La Ceiba, Honduras',
                ),
                const SizedBox(height: 20),
                _buildContactCard(
                  icon: Icons.access_time,
                  title: 'Horario de Atención',
                  content: 'Lunes a Sábado\n9:00 AM - 4:00 PM',
                ),
                const SizedBox(height: 20),
                _buildSocialMediaSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String content,
    bool isPhone = false,
    bool isEmail = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 30, color: AppColors.primary),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.title,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 15,
                    color: isPhone || isEmail
                        ? AppColors.primary
                        : AppColors.subtitle,
                    decoration: isPhone || isEmail
                        ? TextDecoration.underline
                        : TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaSection() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Síguenos en Redes Sociales',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.title,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSocialIcon(Icons.facebook, 'Facebook'),
              _buildSocialIcon(Icons.camera_alt, 'Instagram'),
              _buildSocialIcon(Icons.tiktok, 'TikTok'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 30, color: AppColors.primary),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.subtitle,
          ),
        ),
      ],
    );
  }
}
