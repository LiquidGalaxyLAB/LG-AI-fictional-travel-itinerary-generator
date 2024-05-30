import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/string/String.dart';
import '../providers/connection_providers.dart';
class CustomAppBar extends ConsumerStatefulWidget implements PreferredSizeWidget{
  const CustomAppBar({super.key});

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends ConsumerState<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    var isConnected = ref.watch(connectedProvider);
    return AppBar(
      elevation: 0,
      title:  Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              Strings.appName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.circle, color: isConnected ? Colors.green : Colors.redAccent, size: 14),
                const SizedBox(width: 8),
                Text(
                  isConnected ? Strings.connected : Strings.disconnected,
                  style: TextStyle(color: isConnected ? Colors.green : Colors.redAccent , fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {
            // Add search functionality here
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () {
            Navigator.pushNamed(context, '/settings');
          },
        ),
      ],
    );
  }
}