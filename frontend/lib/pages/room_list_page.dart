import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../widgets/room_card.dart';
import '../providers/room_provider.dart';
import '../models/room_model.dart';

class RoomListPage extends StatefulWidget {
  const RoomListPage({super.key});

  @override
  State<RoomListPage> createState() => _RoomListPageState();
}

class _RoomListPageState extends State<RoomListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoomProvider>().loadRooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    final roomProvider = context.watch<RoomProvider>();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Explore Rooms', style: AppTextStyles.heading2),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/filter');
              },
              icon: Icon(Icons.filter_list_rounded, color: Theme.of(context).primaryColor),
            ),
            const SizedBox(width: AppSpacing.medium),
          ],
          bottom: TabBar(
            indicatorColor: Theme.of(context).primaryColor,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: AppColors.secondaryText,
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Available'),
              Tab(text: 'Booked'),
            ],
          ),
        ),
        body: roomProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : roomProvider.error != null
                ? Center(child: Text('Error: ${roomProvider.error}'))
                : TabBarView(
                    children: [
                      _buildRoomList(roomProvider, roomProvider.rooms),
                      _buildRoomList(roomProvider, roomProvider.rooms.where((r) => !roomProvider.isRoomBooked(r.id)).toList()),
                      _buildRoomList(roomProvider, roomProvider.rooms.where((r) => roomProvider.isRoomBooked(r.id)).toList()),
                    ],
                  ),
      ),
    );
  }

  Widget _buildRoomList(RoomProvider roomProvider, List<RoomModel> rooms) {
    if (rooms.isEmpty) {
      return const Center(child: Text('No rooms found in this category.'));
    }

    return RefreshIndicator(
      onRefresh: () => roomProvider.loadRooms(),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.medium),
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          final room = rooms[index];
          final isBooked = roomProvider.isRoomBooked(room.id);
          
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.medium),
            child: RoomCard(
              roomName: room.name,
              capacity: room.capacity,
              isAvailable: !isBooked,
              onReserve: () {
                Navigator.pushNamed(
                  context,
                  '/room-view',
                  arguments: room,
                ).then((_) => roomProvider.loadRooms());
              },
            ),
          );
        },
      ),
    );
  }
}
