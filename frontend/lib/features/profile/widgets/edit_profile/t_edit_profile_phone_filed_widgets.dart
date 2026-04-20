import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

class TPhoneFormFieldWidget extends StatefulWidget {
  const TPhoneFormFieldWidget({
    super.key,
    required this.label,
    required this.controller,
    required this.onChanged,
    this.isRequired = false,
    this.enabled = true,
  });

  final String label;
  final TextEditingController controller;
  final Function(String) onChanged;
  final bool isRequired;
  final bool enabled;

  @override
  State<TPhoneFormFieldWidget> createState() => _TPhoneFormFieldWidgetState();
}

class _TPhoneFormFieldWidgetState extends State<TPhoneFormFieldWidget> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasText = widget.controller.text.isNotEmpty;
    final bool isValid = widget.controller.text.length == 10;

    final Color textColor =
        widget.enabled ? AppColors.primaryText : AppColors.subText;

    Color borderColor;
    if (!widget.enabled) {
      borderColor = Colors.transparent;
    } else if (_focusNode.hasFocus) {
      borderColor = isValid ? Colors.green : AppColors.primary;
    } else {
      borderColor = Colors.grey.shade300;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// LABEL
        RichText(
          text: TextSpan(
            text: widget.label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: AppSizes.p12,
              fontWeight: FontWeight.w500,
              color: AppColors.subText,
            ),
            children: [
              if (widget.isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: AppColors.alertText,
                    fontWeight: FontWeight.bold,
                    fontSize: AppSizes.p13,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.p8),

        /// INPUT CONTAINER
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radius8),
            border: Border.all(
              color: borderColor,
              width: widget.enabled ? 1 : 0,
            ),
            color:
                widget.enabled ? Colors.white : Colors.grey.withOpacity(0.05),
          ),
          child: IntlPhoneField(
            enabled: widget.enabled,
            focusNode: _focusNode,
            controller: widget.controller,
            initialCountryCode: 'VN',
            showDropdownIcon: widget.enabled,
            dropdownIcon: Icon(
              Icons.arrow_drop_down,
              color: widget.enabled ? AppColors.softGrey : AppColors.subText,
            ),
            disableLengthCheck: true,
            autovalidateMode: AutovalidateMode.disabled,
            cursorColor: AppColors.primary,
            flagsButtonPadding:
                const EdgeInsets.only(left: AppSizes.p10, right: AppSizes.p10),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            keyboardType: TextInputType.phone,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: AppSizes.p14,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
            dropdownTextStyle: TextStyle(
              fontFamily: 'Poppins',
              fontSize: AppSizes.p14,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
            decoration: InputDecoration(
              hintText: TTexts.editPhoneNumberHint.tr,
              hintStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: AppSizes.p14,
                fontWeight: FontWeight.w400,
                color: AppColors.softGrey,
              ),
              counterText: "",
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              filled: false,
              isDense: true,
              contentPadding: const EdgeInsets.only(
                left: AppSizes.p12,
                right: AppSizes.p12,
                top: AppSizes.p16,
                bottom: AppSizes.p16,
              ),
              suffixIcon: (hasText && widget.enabled)
                  ? IconButton(
                      icon: const Icon(
                        Icons.cancel,
                        size: AppSizes.p20,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        widget.controller.clear();
                        widget.onChanged("");
                        setState(() {});
                        _focusNode.requestFocus();
                      },
                      splashColor: Colors.transparent,
                    )
                  : null,
            ),
            onChanged: (phone) {
              if (!widget.enabled) return;
              setState(() {
                widget.onChanged(phone.number);
              });
            },
          ),
        ),

        /// THÔNG BÁO LỖI
        if (widget.enabled && _focusNode.hasFocus && hasText && !isValid)
          Padding(
            padding: const EdgeInsets.only(top: AppSizes.p8, left: AppSizes.p4),
            child: Text(
              TTexts.editPhoneNumberInvalid.tr,
              style: const TextStyle(
                color: Colors.red,
                fontSize: AppSizes.p12,
                fontFamily: 'Poppins',
              ),
            ),
          ),
      ],
    );
  }
}
