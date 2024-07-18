import 'package:flutter/material.dart';

class SlideFileCard extends StatelessWidget {
  final String fileName;
  final String fileUrl;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const SlideFileCard({
    super.key,
    required this.fileName,
    required this.fileUrl,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 4.0,
        color: Colors.white,
        child: ListTile(
          contentPadding: const EdgeInsets.all(16.0),
          leading: const Icon(Icons.picture_as_pdf),
          title: Text(
            fileName,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onEdit != null)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: onEdit,
                ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: onDelete,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
