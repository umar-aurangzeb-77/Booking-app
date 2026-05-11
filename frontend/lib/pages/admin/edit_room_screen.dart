import 'package:flutter/material.dart';
import '../../models/room_model.dart';
import '../../services/admin_room_service.dart';
import '../../widgets/admin/facility_selector.dart';

class EditRoomScreen extends StatefulWidget {
  const EditRoomScreen({super.key});

  @override
  State<EditRoomScreen> createState() => _EditRoomScreenState();
}

class _EditRoomScreenState extends State<EditRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _capacityController;
  List<String> _selectedFacilities = [];
  bool _isLoading = false;
  bool _isInit = false;
  late RoomModel _room;

  final AdminRoomService _roomService = AdminRoomService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _room = ModalRoute.of(context)!.settings.arguments as RoomModel;
      _nameController = TextEditingController(text: _room.name);
      _capacityController = TextEditingController(text: _room.capacity.toString());
      _selectedFacilities = List.from(_room.facilities);
      _isInit = true;
    }
  }

  void _toggleFacility(String facility) {
    setState(() {
      if (_selectedFacilities.contains(facility)) {
        _selectedFacilities.remove(facility);
      } else {
        _selectedFacilities.add(facility);
      }
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedFacilities.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one facility')),
        );
        return;
      }

      setState(() => _isLoading = true);

      final updatedRoom = _room.copyWith(
        name: _nameController.text.trim(),
        capacity: int.parse(_capacityController.text.trim()),
        facilities: _selectedFacilities,
      );

      try {
        await _roomService.updateRoom(updatedRoom);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Room updated successfully')),
          );
          Navigator.pop(context, true); // Return true to trigger refresh
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update room: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Room'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Room Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.meeting_room),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Room name cannot be empty';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _capacityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Capacity',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.people),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Capacity cannot be empty';
                        }
                        final capacity = int.tryParse(value);
                        if (capacity == null || capacity <= 0) {
                          return 'Enter a valid positive integer';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Facilities',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    FacilitySelector(
                      selectedFacilities: _selectedFacilities,
                      onToggle: _toggleFacility,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('SAVE CHANGES', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
