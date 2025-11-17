import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/colors.dart';
import '../../services/notification_service.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  List<PendingNotificationRequest> _pendingNotifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingNotifications();
  }

  Future<void> _loadPendingNotifications() async {
    setState(() => _isLoading = true);
    final pending = await _notificationService.getPendingNotifications();
    setState(() {
      _pendingNotifications = pending;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final backgroundColor = Theme.of(context).colorScheme.background;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final lightTextColor = textColor.withOpacity(0.6);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Notificaciones',
          style: GoogleFonts.poppins(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con ícono
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? AppColorsDark.primaryGradient
                          : AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (isDark ? Colors.black : Colors.white)
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.notifications_active,
                            color: isDark ? Colors.black : Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Recordatorios Activos',
                                style: GoogleFonts.poppins(
                                  color: isDark ? Colors.black : Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${_pendingNotifications.length} notificaciones programadas',
                                style: GoogleFonts.poppins(
                                  color: (isDark ? Colors.black : Colors.white)
                                      .withOpacity(0.8),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Información sobre notificaciones
                  Text(
                    'Cómo funcionan los recordatorios',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),

                  const SizedBox(height: 12),

                  _buildInfoCard(
                    icon: Icons.calendar_today,
                    iconColor:
                        isDark ? AppColorsDark.primary : AppColors.primary,
                    title: '1 día antes',
                    subtitle: 'A las 9:00 AM del día anterior',
                    isDark: isDark,
                  ),

                  const SizedBox(height: 12),

                  _buildInfoCard(
                    icon: Icons.access_time,
                    iconColor: Colors.orange,
                    title: '2 horas antes',
                    subtitle: 'Recordatorio cercano al evento',
                    isDark: isDark,
                  ),

                  const SizedBox(height: 12),

                  _buildInfoCard(
                    icon: Icons.celebration,
                    iconColor:
                        isDark ? AppColorsDark.success : AppColors.success,
                    title: 'Al momento',
                    subtitle: 'Cuando el evento está comenzando',
                    isDark: isDark,
                  ),

                  const SizedBox(height: 32),

                  // Acciones
                  Text(
                    'Acciones',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Botón: Probar notificaciones
                  _buildActionButton(
                    icon: Icons.notifications_active,
                    title: 'Probar Notificación',
                    subtitle: 'Envía una notificación de prueba',
                    onTap: () async {
                      await _notificationService.showTestNotification();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '¡Notificación enviada!',
                                  style: GoogleFonts.poppins(),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: isDark
                              ? AppColorsDark.success
                              : AppColors.success,
                        ),
                      );
                    },
                    isDark: isDark,
                  ),

                  const SizedBox(height: 12),

                  // Botón: Cancelar todas
                  _buildActionButton(
                    icon: Icons.delete_sweep,
                    title: 'Cancelar Todas',
                    subtitle: 'Elimina todas las notificaciones programadas',
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(
                            '¿Cancelar todas?',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: Text(
                            'Esto eliminará todas las notificaciones programadas de tus eventos guardados.',
                            style: GoogleFonts.poppins(),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(
                                'Cancelar',
                                style: GoogleFonts.poppins(),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark
                                    ? AppColorsDark.error
                                    : AppColors.error,
                              ),
                              child: Text(
                                'Confirmar',
                                style: GoogleFonts.poppins(),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await _notificationService.cancelAllNotifications();
                        await _loadPendingNotifications();
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Todas las notificaciones fueron canceladas',
                              style: GoogleFonts.poppins(),
                            ),
                            backgroundColor: primaryColor,
                          ),
                        );
                      }
                    },
                    isDark: isDark,
                    isDestructive: true,
                  ),

                  const SizedBox(height: 12),

                  // Botón: Actualizar lista
                  _buildActionButton(
                    icon: Icons.refresh,
                    title: 'Actualizar Lista',
                    subtitle: 'Recarga las notificaciones pendientes',
                    onTap: _loadPendingNotifications,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 32),

                  // Lista de notificaciones pendientes
                  if (_pendingNotifications.isNotEmpty) ...[
                    Text(
                      'Notificaciones Programadas',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._pendingNotifications.map((notification) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: lightTextColor.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.notifications,
                              color: primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notification.title ?? 'Sin título',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: textColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (notification.body != null)
                                    Text(
                                      notification.body!,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: lightTextColor,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final lightTextColor = textColor.withOpacity(0.6);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: lightTextColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: lightTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
    bool isDestructive = false,
  }) {
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final lightTextColor = textColor.withOpacity(0.6);
    final primaryColor = Theme.of(context).colorScheme.primary;
    final errorColor = isDark ? AppColorsDark.error : AppColors.error;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: lightTextColor.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (isDestructive ? errorColor : primaryColor).withOpacity(
                  0.1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isDestructive ? errorColor : primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? errorColor : textColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: lightTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: lightTextColor),
          ],
        ),
      ),
    );
  }
}
