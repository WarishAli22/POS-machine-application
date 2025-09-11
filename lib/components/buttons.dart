import 'package:flutter/material.dart';

class SquareIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const SquareIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 38,
        width: 38,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon),
      ),
    );
  }
}

class DecreaseButton extends StatelessWidget{

  final Function()? onTap;
  const DecreaseButton({required this.onTap});

  Widget build(BuildContext context){
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red, // Background color
        foregroundColor: Colors.white, // Text/icon color
        minimumSize: const Size(48, 48), // Button size
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), // Fully rounded corners
        ),
        padding: EdgeInsets.zero, // Remove default padding
      ),
      child: const Icon(
        Icons.remove, // Minus icon
        size: 24,
      ),
    );
  }
}

class IncreaseButton extends StatelessWidget{

  final Function()? onTap;
  const IncreaseButton({required this.onTap});

  Widget build(BuildContext context){
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red, // Background color
        foregroundColor: Colors.white, // Text/icon color
        minimumSize: const Size(48, 48), // Button size
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), // Fully rounded corners
        ),
        padding: EdgeInsets.zero, // Remove default padding
      ),
      child: const Icon(
        Icons.add, // Minus icon
        size: 24,
      ),
    );
  }
}