import 'package:flutter/material.dart';
void showSnackBar(BuildContext context, String content, bool isError) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Row(
      children: [
        Icon(
          isError ? Icons.block : Icons.check,
          color: Colors.white,
        ),
        const SizedBox(
          width: 16,
        ),
        Expanded(
          child: Text(
            content,
            style: Theme.of(context)
                .textTheme
                .bodyText1
                !.copyWith(color: Colors.white),
          ),
        ),
      ],
      mainAxisSize: MainAxisSize.min,
    ),
    backgroundColor: isError ? Colors.red[700] : Colors.green[500],
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    duration: const Duration(seconds: 2),
  ));
}

