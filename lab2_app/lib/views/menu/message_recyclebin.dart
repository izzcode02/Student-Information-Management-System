import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../controller/message_function.dart';

class RecycleBin extends StatefulWidget {
  const RecycleBin({super.key});

  @override
  State<RecycleBin> createState() => _RecycleBinState();
}

class _RecycleBinState extends State<RecycleBin> {
  final MessageFunction _messageFunction = MessageFunction();
  final Set<String> _selectedMessages = {};

  Future<void> _restoreMessage(String documentId) async {
    try {
      await _messageFunction.restoreMessage(documentId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message restored successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error restoring message: $e')),
      );
    }
  }

  Future<void> _permanentDeleteMessage(String documentId) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Permanent Delete'),
          content: const Text(
              'Are you sure you want to permanently delete this message? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await _messageFunction.permanentDeleteMessage(documentId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message permanently deleted')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting message: $e')),
        );
      }
    }
  }

  Future<void> _permanentDeleteSelected() async {
    if (_selectedMessages.isEmpty) return;

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Permanent Delete'),
          content: Text(
              'Are you sure you want to permanently delete ${_selectedMessages.length} selected messages? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        for (String documentId in _selectedMessages) {
          await _messageFunction.permanentDeleteMessage(documentId);
        }
        setState(() {
          _selectedMessages.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Selected messages permanently deleted')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting messages: $e')),
        );
      }
    }
  }

  Future<void> _restoreSelected() async {
    try {
      for (String documentId in _selectedMessages) {
        await _messageFunction.restoreMessage(documentId);
      }
      setState(() {
        _selectedMessages.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected messages restored')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error restoring messages: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recycle Bin'),
        actions: [
          if (_selectedMessages.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.restore),
              onPressed: _restoreSelected,
              tooltip: 'Restore Selected',
            ),
            IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: _permanentDeleteSelected,
              tooltip: 'Permanently Delete Selected',
            ),
          ],
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _messageFunction.getDeletedMessages(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No deleted messages'),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
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
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.restore,
                                  color: Colors.green),
                              onPressed: () => _restoreMessage(doc.id),
                              tooltip: 'Restore',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_forever,
                                  color: Colors.red),
                              onPressed: () => _permanentDeleteMessage(doc.id),
                              tooltip: 'Delete Permanently',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (_selectedMessages.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '${_selectedMessages.length} messages selected',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
