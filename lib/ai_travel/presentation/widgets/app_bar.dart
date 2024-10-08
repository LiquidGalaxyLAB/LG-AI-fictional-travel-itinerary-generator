import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/string/String.dart';
import '../providers/connection_providers.dart';

class CustomAppBar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  final bool isHomePage;
  final bool shouldShowSettingsIcon;
  final bool isSettingsPage;

  const CustomAppBar({
    Key? key,
    this.isHomePage = false,
    this.shouldShowSettingsIcon = true,
    this.isSettingsPage = false,
  }) : super(key: key);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(isSettingsPage ? kToolbarHeight + kTextTabBarHeight : kToolbarHeight);
}

class _CustomAppBarState extends ConsumerState<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    var isConnected = ref.watch(connectedProvider);

    return AppBar(
      elevation: 0,
      title: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
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
                      style: TextStyle(color: isConnected ? Colors.green : Colors.redAccent, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
            //show a circular button having an icon of navigation and text as "Explore city" and border color as white
            if(widget.isHomePage)
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/addCity');
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.explore),
                        color: Colors.white,
                        onPressed: () {},
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Text(
                          "Explore city",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (widget.isHomePage)
              Row(
                children: [
                  const Text(
                    "Made with",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    child: Center(
                      child: Image.asset(
                        'assets/images/lg_logos/line_4/groq_tm.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
      actions: widget.shouldShowSettingsIcon
          ? [
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () {
            Navigator.pushNamed(context, '/settings');
          },
        ),
      ]
          : [],
      bottom: widget.isSettingsPage
          ? const TabBar(
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        tabs: [
          Tab(text: "Connection Settings",),
          Tab(text: "API Settings"),
        ],
      )
          : null,
    );
  }
}
