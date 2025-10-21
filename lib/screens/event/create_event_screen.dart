import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../services/event_service.dart';
import '../../services/cloudinary_service.dart'; // NUEVO IMPORT
import '../../models/event_model.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _placeController = TextEditingController();
  final _priceController = TextEditingController();
  final _hourController = TextEditingController();

  final EventService _eventService = EventService();
  final CloudinaryService _cloudinaryService = CloudinaryService(); // NUEVO

  DateTime? _selectedDate;
  String _selectedType = 'Cultura';
  String _selectedMunicipality = 'Pasto';
  String _selectedPrivacity = 'public';
  File? _selectedImage;
  String? _uploadedImageUrl;
  bool _isLoading = false;
  bool _isFree = true;

  // CATEGORÍAS ACTUALIZADAS
  final List<String> _eventTypes = [
    'Cultura',
    'Música',
    'Deportes',
    'Gastronomía',
    'Tecnología',
    'Educación',
    'Otros',
  ];

  // MUNICIPIOS DE NARIÑO
  final List<String> _municipalities = [
    'Pasto',
    'Tumaco',
    'Ipiales',
    'Túquerres',
    'Samaniego',
    'La Unión',
    'El Charco',
    'Barbacoas',
    'Cumbal',
    'Ricaurte',
    'Guaitarilla',
    'Sandoná',
    'La Cruz',
    'San Lorenzo',
    'Aldana',
    'Ancuyá',
    'Arboleda',
    'Belén',
    'Buesaco',
    'Colón',
    'Consacá',
    'Contadero',
    'Córdoba',
    'Cuaspud',
    'Cumbitara',
    'El Peñol',
    'El Rosario',
    'El Tablón',
    'El Tambo',
    'Francisco Pizarro',
    'Funes',
    'Guachucal',
    'Iles',
    'Imués',
    'La Florida',
    'La Llanada',
    'La Tola',
    'Leiva',
    'Linares',
    'Los Andes',
    'Magüí',
    'Mallama',
    'Mosquera',
    'Nariño',
    'Olaya Herrera',
    'Ospina',
    'Policarpa',
    'Potosí',
    'Providencia',
    'Puerres',
    'Pupiales',
    'Roberto Payán',
    'Santa Bárbara',
    'Santacruz',
    'Sapuyes',
    'Taminango',
    'Tangua',
    'Yacuanquer',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _placeController.dispose();
    _priceController.dispose();
    _hourController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al seleccionar imagen: $e',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // MÉTODO ACTUALIZADO PARA CLOUDINARY
  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return null;

    try {
      // Subir imagen a Cloudinary en la carpeta 'events'
      final imageUrl = await _cloudinaryService.uploadImage(
        file: _selectedImage!,
        folder: 'events',
      );

      return imageUrl;
    } catch (e) {
      throw 'Error al subir imagen: $e';
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              onSurface: AppColors.darkText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              onSurface: AppColors.darkText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _hourController.text = picked.format(context);
      });
    }
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor selecciona una fecha',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_hourController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor selecciona una hora',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;

      if (user == null) {
        throw 'Usuario no autenticado';
      }

      // Subir imagen si existe - AHORA USA CLOUDINARY
      if (_selectedImage != null) {
        _uploadedImageUrl = await _uploadImage();
      }

      // Crear lugar completo: "Lugar específico, Municipio, Nariño"
      final String fullPlace =
          '${_placeController.text.trim()}, $_selectedMunicipality, Nariño';

      // Crear evento
      final EventModel newEvent = EventModel(
        id: '',
        userId: user.uid,
        img: _uploadedImageUrl,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        date: _selectedDate!,
        hour: _hourController.text.trim(),
        place: fullPlace,
        price: _isFree ? 0.0 : double.parse(_priceController.text),
        type: _selectedType,
        privacity: _selectedPrivacity,
        state: 'active',
        organizer: user.username,
        createdAt: DateTime.now(),
        attendeesCount: 0,
      );

      await _eventService.createEvent(newEvent);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // Mostrar diálogo de éxito
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '¡Evento Creado!',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Tu evento ha sido creado exitosamente y ahora es visible para todos los usuarios.',
            style: GoogleFonts.poppins(fontSize: 15),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar diálogo
                Navigator.pop(context); // Volver a home
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Aceptar',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Crear Evento',
          style: GoogleFonts.poppins(
            color: AppColors.darkText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Selector de imagen
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 50,
                                color: AppColors.lightText,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Agregar imagen del evento',
                                style: GoogleFonts.poppins(
                                  color: AppColors.lightText,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // Título
                TextFormField(
                  controller: _titleController,
                  style: GoogleFonts.poppins(),
                  decoration: InputDecoration(
                    labelText: 'Título del evento',
                    labelStyle: GoogleFonts.poppins(),
                    prefixIcon: const Icon(Icons.event),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa el título del evento';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Descripción
                TextFormField(
                  controller: _descriptionController,
                  style: GoogleFonts.poppins(),
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Descripción',
                    labelStyle: GoogleFonts.poppins(),
                    prefixIcon: const Icon(Icons.description),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa una descripción';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Fecha y Hora - CORREGIDO
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _selectDate,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.calendar_today,
                                  color: AppColors.primary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Fecha',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: AppColors.lightText,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _selectedDate != null
                                          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                          : 'Seleccionar',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: _selectTime,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.access_time,
                                  color: AppColors.primary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Hora',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: AppColors.lightText,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _hourController.text.isEmpty
                                          ? 'Seleccionar'
                                          : _hourController.text,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // DROPDOWN DE MUNICIPIOS
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: DropdownButtonFormField<String>(
                    value: _selectedMunicipality,
                    decoration: InputDecoration(
                      labelText: 'Municipio',
                      labelStyle: GoogleFonts.poppins(),
                      prefixIcon: const Icon(Icons.location_city),
                      border: InputBorder.none,
                    ),
                    style: GoogleFonts.poppins(
                      color: AppColors.darkText,
                      fontSize: 14,
                    ),
                    isExpanded: true,
                    items: _municipalities.map((municipality) {
                      return DropdownMenuItem(
                        value: municipality,
                        child: Text(municipality),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedMunicipality = value!;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Lugar específico
                TextFormField(
                  controller: _placeController,
                  style: GoogleFonts.poppins(),
                  decoration: InputDecoration(
                    labelText: 'Lugar específico (ej: Parque Central)',
                    labelStyle: GoogleFonts.poppins(),
                    prefixIcon: const Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa el lugar específico del evento';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Tipo de evento
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedType,
                    decoration: InputDecoration(
                      labelText: 'Categoría',
                      labelStyle: GoogleFonts.poppins(),
                      prefixIcon: const Icon(Icons.category),
                      border: InputBorder.none,
                    ),
                    style: GoogleFonts.poppins(
                      color: AppColors.darkText,
                      fontSize: 14,
                    ),
                    items: _eventTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Precio
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.attach_money,
                              color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Precio',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.lightText,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: _isFree,
                            activeColor: AppColors.primary,
                            onChanged: (value) {
                              setState(() {
                                _isFree = value!;
                                if (_isFree) {
                                  _priceController.clear();
                                }
                              });
                            },
                          ),
                          Text(
                            'Evento gratuito',
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        ],
                      ),
                      if (!_isFree)
                        TextFormField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.poppins(),
                          decoration: InputDecoration(
                            labelText: 'Precio en pesos',
                            labelStyle: GoogleFonts.poppins(),
                            prefixText: '\$ ',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (!_isFree && (value == null || value.isEmpty)) {
                              return 'Ingresa el precio';
                            }
                            return null;
                          },
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Privacidad
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Privacidad',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.lightText,
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text(
                                'Público',
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                              value: 'public',
                              groupValue: _selectedPrivacity,
                              activeColor: AppColors.primary,
                              contentPadding: EdgeInsets.zero,
                              onChanged: (value) {
                                setState(() {
                                  _selectedPrivacity = value!;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text(
                                'Privado',
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                              value: 'private',
                              groupValue: _selectedPrivacity,
                              activeColor: AppColors.primary,
                              contentPadding: EdgeInsets.zero,
                              onChanged: (value) {
                                setState(() {
                                  _selectedPrivacity = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Botón de crear
                Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createEvent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: AppColors.white,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.white,
                              ),
                            ),
                          )
                        : Text(
                            'Crear Evento',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
