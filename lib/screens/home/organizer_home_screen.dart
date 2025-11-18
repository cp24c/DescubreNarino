import 'package:descubre_narino/screens/chat/chatbot_screen.dart';
import 'package:descubre_narino/screens/map/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../services/event_service.dart';
import '../../models/event_model.dart';
import '../event/create_event_screen.dart';
import '../profile/profile_screen.dart';
import '../../services/cloudinary_service.dart';

class OrganizerHomeScreen extends StatefulWidget {
  const OrganizerHomeScreen({super.key});

  @override
  State<OrganizerHomeScreen> createState() => _OrganizerHomeScreenState();
}

class _OrganizerHomeScreenState extends State<OrganizerHomeScreen> {
  final CloudinaryService _cloudinaryService = CloudinaryService();
  int _currentIndex = 0;
  final EventService _eventService = EventService();

  // CATEGORÍAS ACTUALIZADAS
  final List<String> _categories = [
    'Todos',
    'Cultura',
    'Música',
    'Deportes',
    'Gastronomía',
    'Tecnología',
    'Educación',
    'Otros',
  ];
  String _selectedCategory = 'Todos';

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: _buildCurrentScreen(),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton:
          authProvider.isOrganizer ? _buildFloatingActionButton() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return _buildSavedEvents();
      case 2:
        return _buildDiscoverContent();
      case 3:
        return const ProfileScreen(); // Cambiado de ChatbotScreen a ProfileScreen
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    final authProvider = Provider.of<AuthProvider>(context);
    final username = authProvider.currentUser?.username ?? 'Usuario';

    // Colores dinámicos según el tema
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final backgroundColor = Theme.of(context).colorScheme.background;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final lightTextColor = textColor.withOpacity(0.6);

    return CustomScrollView(
      slivers: [
        // App Bar personalizado
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¡Hola, $username!',
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            authProvider.isOrganizer
                                ? 'Gestiona tus eventos'
                                : 'Descubre eventos increíbles',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: lightTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon:
                          Icon(Icons.notifications_outlined, color: textColor),
                      iconSize: 28,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Notificaciones próximamente',
                              style: GoogleFonts.poppins(),
                            ),
                            backgroundColor: primaryColor,
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.smart_toy_outlined, color: primaryColor),
                      iconSize: 28,
                      tooltip: 'Chat con NariñoBot',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ChatbotScreen()),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                const SizedBox(height: 20),

                // Barra de búsqueda
                Container(
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
                  child: TextField(
                    style: GoogleFonts.poppins(color: textColor),
                    decoration: InputDecoration(
                      hintText: 'Buscar eventos...',
                      hintStyle: GoogleFonts.poppins(color: lightTextColor),
                      prefixIcon: Icon(Icons.search, color: lightTextColor),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.tune, color: primaryColor),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Filtros próximamente',
                                style: GoogleFonts.poppins(),
                              ),
                              backgroundColor: primaryColor,
                            ),
                          );
                        },
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                    onSubmitted: (query) {
                      // TODO: Implementar búsqueda
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        // Categorías
        SliverToBoxAdapter(
          child: SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                final isDark = Theme.of(context).brightness == Brightness.dark;
                final primaryColor = Theme.of(context).colorScheme.primary;
                final surfaceColor = Theme.of(context).colorScheme.surface;
                final textColor = Theme.of(context).colorScheme.onSurface;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? (isDark
                              ? AppColorsDark.primaryGradient
                              : AppColors.primaryGradient)
                          : null,
                      color: isSelected ? null : surfaceColor,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? primaryColor.withOpacity(0.3)
                              : Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      category,
                      style: GoogleFonts.poppins(
                        color: isSelected
                            ? (isDark ? Colors.black : Colors.white)
                            : textColor,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 20)),

        // Título de eventos destacados
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Eventos Destacados',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Ver todos próximamente',
                          style: GoogleFonts.poppins(),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    );
                  },
                  child: Text(
                    'Ver todos',
                    style: GoogleFonts.poppins(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Lista de eventos
        StreamBuilder<List<EventModel>>(
          stream: _eventService.getEventsByCategory(_selectedCategory),
          builder: (context, snapshot) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final surfaceColor = Theme.of(context).colorScheme.surface;
            final textColor = Theme.of(context).colorScheme.onSurface;
            final lightTextColor = textColor.withOpacity(0.6);
            final errorColor = isDark ? AppColorsDark.error : AppColors.error;
            final primaryColor = Theme.of(context).colorScheme.primary;

            if (snapshot.connectionState == ConnectionState.waiting) {
              return SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: CircularProgressIndicator(color: primaryColor),
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
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
                        Icon(Icons.error_outline, size: 60, color: errorColor),
                        const SizedBox(height: 16),
                        Text(
                          'Error al cargar eventos',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: errorColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: lightTextColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
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
                        Icon(Icons.event_busy, size: 60, color: lightTextColor),
                        const SizedBox(height: 16),
                        Text(
                          'No hay eventos disponibles',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: lightTextColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (authProvider.isOrganizer)
                          Text(
                            'Toca el botón + para crear uno',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: primaryColor,
                              fontWeight: FontWeight.w500,
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
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final event = snapshot.data![index];
                    return _buildEventCard(event);
                  },
                  childCount: snapshot.data!.length,
                ),
              ),
            );
          },
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildSavedEvents() {
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.currentUser?.uid;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final lightTextColor = textColor.withOpacity(0.6);

    if (userId == null) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Eventos Guardados',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ),
        StreamBuilder<List<EventModel>>(
          stream: _eventService.getFavoriteEvents(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
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
                        Icon(Icons.bookmark_border,
                            size: 60, color: lightTextColor),
                        const SizedBox(height: 16),
                        Text(
                          'No tienes eventos guardados',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: lightTextColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Guarda eventos tocando el ícono de marcador',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: lightTextColor,
                          ),
                          textAlign: TextAlign.center,
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
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final event = snapshot.data![index];
                    return _buildEventCard(event);
                  },
                  childCount: snapshot.data!.length,
                ),
              ),
            );
          },
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildDiscoverContent() {
    return const MapScreen();
  }

  Widget _buildEventCard(EventModel event) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.uid;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final lightTextColor = textColor.withOpacity(0.6);
    final successColor = isDark ? AppColorsDark.success : AppColors.success;

    final optimizedImageUrl = event.img != null
        ? _cloudinaryService.getOptimizedUrl(
            imageUrl: event.img!,
            width: 800,
            height: 400,
            quality: 'auto',
          )
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen del evento
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: optimizedImageUrl != null
                    ? Image.network(
                        optimizedImageUrl,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 160,
                            width: double.infinity,
                            color: isDark
                                ? AppColorsDark.surfaceVariant
                                : Colors.grey.shade200,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(primaryColor),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 160,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  primaryColor.withOpacity(0.3),
                                  (isDark
                                          ? AppColorsDark.secondary
                                          : AppColors.secondary)
                                      .withOpacity(0.3),
                                ],
                              ),
                            ),
                            child: Icon(
                              Icons.image_outlined,
                              size: 60,
                              color: isDark
                                  ? AppColorsDark.white
                                  : AppColors.white,
                            ),
                          );
                        },
                      )
                    : Container(
                        height: 160,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primaryColor.withOpacity(0.3),
                              (isDark
                                      ? AppColorsDark.secondary
                                      : AppColors.secondary)
                                  .withOpacity(0.3),
                            ],
                          ),
                        ),
                        child: Icon(
                          Icons.image_outlined,
                          size: 60,
                          color: isDark ? AppColorsDark.white : AppColors.white,
                        ),
                      ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    event.type,
                    style: GoogleFonts.poppins(
                      color: isDark ? Colors.black : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (userId != null)
                Positioned(
                  top: 12,
                  right: 12,
                  child: StreamBuilder<bool>(
                    stream: _eventService.isEventFavorite(userId, event.id),
                    builder: (context, snapshot) {
                      final isFavorite = snapshot.data ?? false;
                      return Container(
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            isFavorite ? Icons.bookmark : Icons.bookmark_border,
                          ),
                          color: primaryColor,
                          onPressed: () async {
                            try {
                              if (isFavorite) {
                                await _eventService.removeFromFavorites(
                                    userId, event.id);
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Evento eliminado de favoritos',
                                      style: GoogleFonts.poppins(),
                                    ),
                                    backgroundColor: successColor,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              } else {
                                await _eventService.addToFavorites(
                                    userId, event.id);
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Evento guardado en favoritos',
                                      style: GoogleFonts.poppins(),
                                    ),
                                    backgroundColor: successColor,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Error al actualizar favoritos',
                                    style: GoogleFonts.poppins(),
                                  ),
                                  backgroundColor: isDark
                                      ? AppColorsDark.error
                                      : AppColors.error,
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),

          // Información del evento
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 16, color: lightTextColor),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('dd MMM, yyyy', 'es').format(event.date),
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: lightTextColor),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.access_time, size: 16, color: lightTextColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        event.hour,
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: lightTextColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        event.formattedPrice,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: successColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 16, color: lightTextColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        event.place,
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: lightTextColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final lightTextColor = textColor.withOpacity(0.6);

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: primaryColor,
        unselectedItemColor: lightTextColor,
        selectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            activeIcon: Icon(Icons.bookmark),
            label: 'Guardados',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Descubrir',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      height: 65,
      width: 65,
      decoration: BoxDecoration(
        gradient:
            isDark ? AppColorsDark.primaryGradient : AppColors.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateEventScreen(),
            ),
          ).then((_) {
            setState(() {});
          });
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Icon(
          Icons.add,
          size: 32,
          color: isDark ? Colors.black : Colors.white,
        ),
      ),
    );
  }
}
