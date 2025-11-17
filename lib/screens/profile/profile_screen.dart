import 'package:descubre_narino/screens/settings/notifications_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart'; // NUEVO: Import del ThemeProvider
import '../../services/event_service.dart';
import '../../models/event_model.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final EventService _eventService = EventService();

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Cambiar Contraseña',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: currentPasswordController,
                  obscureText: obscureCurrent,
                  decoration: InputDecoration(
                    labelText: 'Contraseña actual',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureCurrent
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          obscureCurrent = !obscureCurrent;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: newPasswordController,
                  obscureText: obscureNew,
                  decoration: InputDecoration(
                    labelText: 'Nueva contraseña',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureNew
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          obscureNew = !obscureNew;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo requerido';
                    }
                    if (value.length < 6) {
                      return 'Mínimo 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirm,
                  decoration: InputDecoration(
                    labelText: 'Confirmar contraseña',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirm
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          obscureConfirm = !obscureConfirm;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value != newPasswordController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: GoogleFonts.poppins(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColorsDark.lightText
                      : AppColors.lightText,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    final authProvider = Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    );

                    await authProvider.changePassword(
                      currentPassword: currentPasswordController.text,
                      newPassword: newPasswordController.text,
                    );

                    if (!mounted) return;

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Contraseña actualizada exitosamente',
                          style: GoogleFonts.poppins(),
                        ),
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? AppColorsDark.success
                                : AppColors.success,
                      ),
                    );
                  } catch (e) {
                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          e.toString(),
                          style: GoogleFonts.poppins(),
                        ),
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? AppColorsDark.error
                                : AppColors.error,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? AppColorsDark.primary
                    : AppColors.primary,
                foregroundColor: Theme.of(context).brightness == Brightness.dark
                    ? AppColorsDark.background
                    : AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Cambiar', style: GoogleFonts.poppins()),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Cerrar Sesión',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          '¿Estás seguro que deseas cerrar sesión?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColorsDark.lightText
                    : AppColors.lightText,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              await authProvider.signOut();

              if (!mounted) return;

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColorsDark.error
                  : AppColors.error,
              foregroundColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColorsDark.background
                  : AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Cerrar Sesión', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    // Determinar colores según el tema
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColorsDark.primary : AppColors.primary;
    final backgroundColor =
        isDark ? AppColorsDark.background : AppColors.background;
    final surfaceColor = isDark ? AppColorsDark.surface : AppColors.white;
    final textColor = isDark ? AppColorsDark.darkText : AppColors.darkText;
    final lightTextColor =
        isDark ? AppColorsDark.lightText : AppColors.lightText;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Header con perfil
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: isDark
                    ? AppColorsDark.primaryGradient
                    : AppColors.primaryGradient,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: user.userImg != null
                        ? ClipOval(
                            child: Image.network(
                              user.userImg!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.person,
                                  size: 50,
                                  color: primaryColor,
                                );
                              },
                            ),
                          )
                        : Icon(Icons.person, size: 50, color: primaryColor),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.username,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color:
                          isDark ? AppColorsDark.background : AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: isDark
                          ? AppColorsDark.background.withOpacity(0.9)
                          : AppColors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          (isDark ? AppColorsDark.background : AppColors.white)
                              .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user.role == 'organizer' ? 'Organizador' : 'Usuario',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color:
                            isDark ? AppColorsDark.background : AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Opciones de cuenta
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cuenta',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Botón Cambiar Contraseña
                  _buildOptionCard(
                    icon: Icons.lock_outline,
                    title: 'Cambiar Contraseña',
                    onTap: _showChangePasswordDialog,
                  ),
                  const SizedBox(height: 8),

                  // NUEVO: Botón de Notificaciones
                  _buildOptionCard(
                    icon: Icons.notifications_outlined,
                    title: 'Notificaciones',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const NotificationsSettingsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),

                  // NUEVO: Botón de Cambio de Tema
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, _) {
                      return _buildOptionCard(
                        icon: themeProvider.themeIcon,
                        title: themeProvider.themeLabel,
                        onTap: () async {
                          await themeProvider.toggleTheme();

                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(
                                    themeProvider.themeIcon,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Tema cambiado a: ${themeProvider.themeLabel}',
                                      style: GoogleFonts.poppins(),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 8),

                  // Botón Cerrar Sesión
                  _buildOptionCard(
                    icon: Icons.logout,
                    title: 'Cerrar Sesión',
                    onTap: _showLogoutDialog,
                    isDestructive: true,
                  ),
                ],
              ),
            ),
          ),

          // Mis eventos (solo para organizadores)
          if (user.role == 'organizer') ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Text(
                  'Mis Eventos',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ),
            StreamBuilder<List<EventModel>>(
              stream: _eventService.getUserEvents(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 60,
                              color: lightTextColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No has creado eventos aún',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: lightTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final event = snapshot.data![index];
                      return _buildEventCard(event);
                    }, childCount: snapshot.data!.length),
                  ),
                );
              },
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColorsDark.primary : AppColors.primary;
    final errorColor = isDark ? AppColorsDark.error : AppColors.error;
    final surfaceColor = isDark ? AppColorsDark.surface : AppColors.white;
    final textColor = isDark ? AppColorsDark.darkText : AppColors.darkText;
    final lightTextColor =
        isDark ? AppColorsDark.lightText : AppColors.lightText;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
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
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: isDestructive ? errorColor : textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: lightTextColor),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(EventModel event) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColorsDark.primary : AppColors.primary;
    final surfaceColor = isDark ? AppColorsDark.surface : AppColors.white;
    final textColor = isDark ? AppColorsDark.darkText : AppColors.darkText;
    final lightTextColor =
        isDark ? AppColorsDark.lightText : AppColors.lightText;
    final successColor = isDark ? AppColorsDark.success : AppColors.success;
    final errorColor = isDark ? AppColorsDark.error : AppColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Imagen o placeholder
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  colors: [
                    primaryColor.withOpacity(0.3),
                    (isDark ? AppColorsDark.secondary : AppColors.secondary)
                        .withOpacity(0.3),
                  ],
                ),
              ),
              child: event.img != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        event.img!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.image_outlined,
                            size: 30,
                            color:
                                isDark ? AppColorsDark.white : AppColors.white,
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.image_outlined,
                      size: 30,
                      color: isDark ? AppColorsDark.white : AppColors.white,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: lightTextColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd/MM/yyyy').format(event.date),
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: lightTextColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: event.state == 'active'
                              ? successColor.withOpacity(0.1)
                              : errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          event.state == 'active' ? 'Activo' : 'Inactivo',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: event.state == 'active'
                                ? successColor
                                : errorColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${event.attendeesCount} asistentes',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: lightTextColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton(
              icon: Icon(Icons.more_vert, color: lightTextColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Row(
                    children: [
                      const Icon(Icons.edit, size: 20),
                      const SizedBox(width: 8),
                      Text('Editar', style: GoogleFonts.poppins()),
                    ],
                  ),
                  onTap: () {
                    // TODO: Implementar edición
                  },
                ),
                PopupMenuItem(
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: errorColor),
                      const SizedBox(width: 8),
                      Text(
                        'Eliminar',
                        style: GoogleFonts.poppins(color: errorColor),
                      ),
                    ],
                  ),
                  onTap: () async {
                    await Future.delayed(Duration.zero);
                    _showDeleteDialog(event.id);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(String eventId) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColorsDark.primary : AppColors.primary;
    final errorColor = isDark ? AppColorsDark.error : AppColors.error;
    final lightTextColor =
        isDark ? AppColorsDark.lightText : AppColors.lightText;
    final successColor = isDark ? AppColorsDark.success : AppColors.success;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Eliminar Evento',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          '¿Estás seguro que deseas eliminar este evento?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(color: lightTextColor),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _eventService.deleteEvent(eventId);

                if (!mounted) return;

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Evento eliminado exitosamente',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: successColor,
                  ),
                );
              } catch (e) {
                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Error al eliminar evento',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: errorColor,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: errorColor,
              foregroundColor:
                  isDark ? AppColorsDark.background : AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Eliminar', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }
}
