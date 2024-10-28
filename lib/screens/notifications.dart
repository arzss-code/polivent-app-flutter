import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.grey),
            onPressed: () {},
          ),
          title: Text(
            'Notifications',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18, // Reduced font size
            ),
          ),
          centerTitle: true,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0), // Padding to push content downwards
        child: ListView(
          children: [
            NotificationItem(
              profilePic: null,
              name: 'REMINDER!!',
              message: 'Your event will start in 2 days! Good Luck :)',
              time: '1hr ago',
            ),
            NotificationItem(
              profilePic: AssetImage('assets/images/david.png'),
              name: 'David Silbia',
              message: 'Invite Jo Malone London’s Mother’s',
              time: 'Just now',
              hasActionButtons: true,
            ),
            NotificationItem(
              profilePic: AssetImage('assets/images/eric.png'),
              name: 'Eric Cantona',
              message: 'Started Following You',
              time: '20 min ago',
            ),
            NotificationItem(
              profilePic: AssetImage('assets/images/jonathan.png'),
              name: 'Jonathan Noel',
              message: 'Join your Event Seminar Nasional Techomfest',
              time: '1hr ago',
            ),
            NotificationItem(
              profilePic: AssetImage('assets/images/clara.png'),
              name: 'Clara Manuela',
              message: 'Invite To Workshop : Training Basic',
              time: 'Tue, 6:20 pm',
              hasActionButtons: true,
            ),
            NotificationItem(
              profilePic: AssetImage('assets/images/billy.png'),
              name: 'Billy Hawkins',
              message: 'Like your events',
              time: 'Wed, 4:40 pm',
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationItem extends StatefulWidget {
  final ImageProvider? profilePic;
  final String name;
  final String message;
  final String time;
  final bool hasActionButtons;

  const NotificationItem({
    Key? key,
    this.profilePic,
    required this.name,
    required this.message,
    required this.time,
    this.hasActionButtons = false,
  }) : super(key: key);

  @override
  _NotificationItemState createState() => _NotificationItemState();
}

class _NotificationItemState extends State<NotificationItem> {
  bool isAccepted = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: Colors.grey[300],
        backgroundImage: widget.profilePic,
        child: widget.profilePic == null
            ? Icon(Icons.notifications, color: Colors.grey[600])
            : null,
      ),
      title: Text(
        widget.name,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.message),
          if (widget.hasActionButtons) SizedBox(height: 8),
          if (widget.hasActionButtons)
            Row(
              children: [
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black,
                  ),
                  child: Text('Reject'),
                ),
                SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    setState(() {
                      isAccepted = true; // Change the state to accepted
                    });
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: isAccepted ? Colors.grey[200] : Colors.blue,
                    foregroundColor: isAccepted ? Colors.black : Colors.white,
                  ),
                  child: Text('Accept'),
                ),
              ],
            ),
        ],
      ),
      trailing: Text(
        widget.time,
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}