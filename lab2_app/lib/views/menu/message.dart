// message_box_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lab2_app/widget/customButton.dart';
import '../../controller/message_function.dart';

class MessageBoxPage extends StatefulWidget {
  const MessageBoxPage({
    super.key,
  });

  @override
  MessageBoxPageState createState() => MessageBoxPageState();
}

class MessageBoxPageState extends State<MessageBoxPage> {
  final TextEditingController _messageController = TextEditingController();
  final MessageFunction _messageFunction = MessageFunction();
  final Set<String> _selectedMessages = {}; // Store selected message IDs

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _addMessage() async {
    if (_messageController.text.isNotEmpty) {
      try {
        await _messageFunction.addMessage(
          message: _messageController.text,
        );
        _messageController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding message: $e')),
        );
      }
    }
  }

  Future<void> _clearMessages() async {
    try {
      await _messageFunction.clearMessages();
      _selectedMessages.clear(); // Clear selections after deleting
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error clearing messages: $e')),
      );
    }
  }

  Future<void> _deleteMessage(String documentId) async {
    try {
      await _messageFunction.deleteMessage(documentId);
      setState(() {
        _selectedMessages
            .remove(documentId); // Remove from selections if deleted
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting message: $e')),
      );
    }
  }

  Future<void> _deleteSelectedMessages() async {
    try {
      for (String documentId in _selectedMessages) {
        await _messageFunction.deleteMessage(documentId);
      }
      setState(() {
        _selectedMessages.clear(); // Clear selections after deleting
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting selected messages: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Message Box'),
        actions: [
          if (_selectedMessages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteSelectedMessages,
              tooltip: 'Delete Selected',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Enter a message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addMessage,
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _messageFunction.getMessages(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('No messages yet. Add one above!'),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var doc = snapshot.data!.docs[index];
                      bool isSelected = _selectedMessages.contains(doc.id);

                      return Card(
                        child: ListTile(
                          leading: Checkbox(
                            value: isSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _selectedMessages.add(doc.id);
                                } else {
                                  _selectedMessages.remove(doc.id);
                                }
                              });
                            },
                          ),
                          title: Text(doc['message']),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteMessage(doc.id),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            if (_selectedMessages.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Center(
                  child: Text(
                    '${_selectedMessages.length} messages selected',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            Center(
              child: SubmitButton(
                onPressed: _clearMessages,
                text: 'Delete All Message'.toUpperCase(),
                color: Colors.red,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Center(
              child: NextButton(
                valueColor: 0xFFFFFF,
                routeName: '/users/message/recyclebin',
                nameButton: 'Recycle Bin',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
