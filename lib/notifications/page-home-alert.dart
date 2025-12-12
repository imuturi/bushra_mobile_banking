import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/providers/provider-notifications.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});
  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  int _selectedTab = 0;
  List<AlertData> alerts = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationServiceProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Alerts",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
        // actions: [
        //   //if (notificationProvider..any((n) => !n.isRead))
        //     IconButton(
        //       icon: const Icon(Icons.done_all),
        //       tooltip: "Mark All as Read",
        //       onPressed: () async {
        //         //await notificationProvider.markAllAsRead();
        //       },
        //     ),
        // ],
        centerTitle: false,
      ),
      body: LayoutBuilder(
          builder: (context, constraints){

            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;

            return Column(
              children: [
                // Custom Tab Buttons
                Padding(
                  padding: EdgeInsets.all(screenWidth * 0.02),
                  child: Container(
                    height: MediaQuery.of(context).orientation == Orientation.portrait
                        ? screenHeight *  0.06
                        : screenHeight * 0.15,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.indigo.shade900, // Border color
                        width: 1.0, // Border thickness
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTab = 0),
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              color: _selectedTab == 0 ? Colors.indigo.shade900 : Colors.white,
                              child: Text(
                                "Notifications",
                                style: TextStyle(
                                  color: _selectedTab == 0 ? Colors.white : Colors.indigo.shade900,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTab = 1),
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              color: _selectedTab == 1 ? Colors.indigo.shade900 : Colors.white,
                              child: Text(
                                "Request",
                                style: TextStyle(
                                  color: _selectedTab == 1 ? Colors.white : Colors.indigo.shade900,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: _selectedTab == 0 ? _buildNotificationsTab(context) : _buildRequestTab(),
                ),
              ],
            );
          }
      ),
    );
  }

  Widget _buildNotificationsTab(BuildContext context) {
    return Consumer<NotificationServiceProvider>(
      builder: (context, provider, _) {
        final alerts = provider.alerts;
        if (alerts.isEmpty) {
          return const Center(child: Text("No notifications"));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: alerts.length,
          itemBuilder: (context, index) {
            final alert = alerts[index];
            return AlertCard(
              alert: alert,
              onTap: () async {
                await provider.markAlertAsRead(alert.id!);
                // You can still navigate or show details here
                showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with icon + title
                            Row(
                              children: [
                                Icon(Icons.notifications, color: Colors.red.shade900, size: 28),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    alert.title ?? "Alert",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red.shade900,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Message text
                            if (alert.description != null)
                              Text(
                                alert.description!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                  color: Colors.black87,
                                ),
                              ),

                            const SizedBox(height: 16),
                            // Buttons row
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.indigo.shade900,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text("Close", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
                // showDialog(
                //   context: context,
                //   builder: (context) {
                //     return AlertDialog(
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(16),
                //       ),
                //       title: Row(
                //         children: [
                //           Icon(
                //             Icons.notifications,
                //             color: Colors.indigo.shade900,
                //           ),
                //           const SizedBox(width: 8),
                //           Expanded(
                //             child: Text(
                //               alert.title ?? "Alert",
                //               style: const TextStyle(fontWeight: FontWeight.bold),
                //             ),
                //           ),
                //         ],
                //       ),
                //       content: Column(
                //         mainAxisSize: MainAxisSize.min,
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         children: [
                //           if (alert.description != null)
                //             Text(alert.description!,
                //                 style: const TextStyle(fontSize: 15, height: 1.4)),
                //           const SizedBox(height: 12),
                //           if (alert.dateTime != null)
                //             Text(
                //               "Received: ${alert.dateTime}",
                //               style: TextStyle(
                //                 fontSize: 13,
                //                 color: Colors.grey.shade600,
                //               ),
                //             ),
                //         ],
                //       ),
                //       actions: [
                //         TextButton(
                //           onPressed: () => Navigator.of(context).pop(),
                //           child: const Text("Close"),
                //         ),
                //       ],
                //     );
                //   },
                // );
              },
            );
          },
        );

        // return ListView.builder(
        //   padding: const EdgeInsets.all(16),
        //   itemCount: alerts.length,
        //   itemBuilder: (context, index) {
        //     final alert = alerts[index];
        //     return AlertCard(
        //       title: alert.title,
        //       description: alert.description,
        //       dateTime: alert.dateTime,
        //       icon: alert.icon,
        //       iconColor: alert.iconColor,
        //       onTap: () async {
        //         await provider.removeAlert(alert.id!);
        //         ScaffoldMessenger.of(context).showSnackBar(
        //           const SnackBar(content: Text("Notification dismissed")),
        //         );
        //       },
        //     );
        //   },
        // );
      },
    );
  }

  Widget _buildRequestTab() {
    bool isDebugMode = false; // Set to true for debug mode
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ExpansionTile(
          title: const Text("Approve funds requested ",
            style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
          ),
          children: [
            isDebugMode ?
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Approve funds you have been requested to send for amount 1000.00 USD",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.normal),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade900,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    onPressed: () {
                      //TODO
                    },
                    child: const Text("APPROVE", style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            )
            : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "No request for funds at the moment",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.normal),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class AlertCard extends StatelessWidget {
  final AlertData alert;
  final VoidCallback onTap;

  const AlertCard({super.key, required this.alert, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.grey.shade100,
        margin: const EdgeInsets.symmetric(vertical: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: alert.isRead ? Colors.grey.shade400 : Colors.red.shade900,
                child: Icon(Icons.notifications, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.title,
                      style: TextStyle(
                        fontWeight: alert.isRead ? FontWeight.normal : FontWeight.bold,
                        color: alert.isRead ? Colors.grey : Colors.black,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      alert.description,
                      style: TextStyle(
                        color: alert.isRead ? Colors.grey : Colors.black87,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      alert.dateTime,
                      style: TextStyle(
                        color: alert.isRead ? Colors.grey : Colors.black54,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

