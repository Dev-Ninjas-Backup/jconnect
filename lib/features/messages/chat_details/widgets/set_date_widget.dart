// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';

class SetDateWidget extends StatelessWidget {
  const SetDateWidget({super.key});

  Future<void> _pickDate(
    BuildContext context,
    TextEditingController controller,
    void Function(DateTime?) onDateSelected,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme:  ColorScheme.dark(
              primary: Color(0xFFD6002F), // red accent
              surface: Colors.black,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.text = DateFormat('MM/dd/yyyy').format(picked);
      onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    DateTime? selectedDate;

    return Dialog(
      backgroundColor: const Color(0xFF0E0E0E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.white.withOpacity(0.3)),
      ),
      child: StatefulBuilder(
        builder: (context, setState) {
          return Container(
            width: 320,
            padding: const EdgeInsets.all(20),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                /// 🔺 Close Icon (floating top-right)
                Positioned(
                  top: -10,
                  right: -6,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),

                /// 🔽 Main Dialog Content
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Preferred Delivery Date",
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: controller,
                      readOnly: true,
                      onTap: () => _pickDate(context, controller, (picked) {
                        setState(() => selectedDate = picked);
                      }),
                      decoration: InputDecoration(
                        hintText: "mm/dd/yyyy",
                        hintStyle: const TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.calendar_today,
                            color: Colors.white54,
                            size: 20,
                          ),
                          onPressed: () =>
                              _pickDate(context, controller, (picked) {
                                setState(() => selectedDate = picked);
                              }),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF1B1B1B),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 12,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.redColor,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD6002F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: () {
                          if (selectedDate != null) {
                            Navigator.pop(context, selectedDate);
                          }
                        },
                        child: const Text(
                          "Set Delivery Date",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
