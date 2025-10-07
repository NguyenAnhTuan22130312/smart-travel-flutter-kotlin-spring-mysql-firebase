import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget{
  final  Widget icon;
  final String label;
  final VoidCallback? onPressed;

  const SocialButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,


});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
   return OutlinedButton.icon(
     onPressed: onPressed,
       icon: icon,
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF374151),
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: const BorderSide(color: Color(0xFFE5E7EB), width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }}