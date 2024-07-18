import 'package:flutter/material.dart';

class ProfileMaterial extends StatelessWidget {
  final String title;
  final Widget Page1;
  final Icon? trailing;
  final Future<void> Function()? refreshCallback;

  const ProfileMaterial({
    super.key,
    required this.title,
    required this.Page1,
    this.trailing,
    this.refreshCallback,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18),
        ),
        const Spacer(),
        if (trailing != null) trailing!,
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Page1),
            );
            if (refreshCallback != null) {
              await refreshCallback!();
            }
          },
        ),
      ],
    );
  }
}
