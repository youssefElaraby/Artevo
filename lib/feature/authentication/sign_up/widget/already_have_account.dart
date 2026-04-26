import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/route_manager/routes.dart';

class AlreadyHaveAccount extends StatelessWidget {
  const AlreadyHaveAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return // الجزء المهم تحت الزر
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Already have an account? "),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                PageRoutesName.signInRoute,
              );            },
            child: Text(
              "Sign In",
              style: TextStyle(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline, // 🔹 توضيح أنها clickable
              ),
            ),
          )
        ],
      );
  }
}
