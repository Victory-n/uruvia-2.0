import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/shared/widgets/custom_text.dart';

/// Reusable Region & Currency dropdown picker widget.
class RegionCurrencyPickerWidget extends StatelessWidget {
  final String selectedRegion;
  final String selectedCurrency;
  final ValueChanged<String> onRegionChanged;
  final ValueChanged<String> onCurrencyChanged;

  static const List<String> regions = [
    'Africa',
    'Europe',
    'Asia',
    'America',
    'Australia',
  ];

  static const List<String> currencies = [
    'NGN',
    'USD',
    'EUR',
    'AUD',
  ];

  const RegionCurrencyPickerWidget({
    super.key,
    required this.selectedRegion,
    required this.selectedCurrency,
    required this.onRegionChanged,
    required this.onCurrencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Region Picker
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              googleSansText(
                text: 'Region',
                colors: ConstantColor.headingTextPrimary,
                fontWeight: FontWeight.w600,
                size: 13.0,
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: selectedRegion,
                onChanged: (val) {
                  if (val != null) onRegionChanged(val);
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  prefixIcon: const Icon(
                    Icons.public_rounded,
                    color: ConstantColor.paragraphTextSecondary,
                    size: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: ConstantColor.blueBackground,
                      width: 1.8,
                    ),
                  ),
                ),
                style: const TextStyle(
                  fontFamily: 'googleSans',
                  fontSize: 14.0,
                  color: ConstantColor.paragraphTextPrimary,
                ),
                items: regions.map((region) {
                  return DropdownMenuItem<String>(
                    value: region,
                    child: Text(region),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),

        // Currency Picker
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              googleSansText(
                text: 'Currency',
                colors: ConstantColor.headingTextPrimary,
                fontWeight: FontWeight.w600,
                size: 13.0,
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: selectedCurrency,
                onChanged: (val) {
                  if (val != null) onCurrencyChanged(val);
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  prefixIcon: const Icon(
                    Icons.payments_outlined,
                    color: ConstantColor.paragraphTextSecondary,
                    size: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: ConstantColor.blueBackground,
                      width: 1.8,
                    ),
                  ),
                ),
                style: const TextStyle(
                  fontFamily: 'googleSans',
                  fontSize: 14.0,
                  color: ConstantColor.paragraphTextPrimary,
                ),
                items: currencies.map((currency) {
                  return DropdownMenuItem<String>(
                    value: currency,
                    child: Text(currency),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
