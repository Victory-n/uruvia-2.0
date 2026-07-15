final Map<String, String> nigerianExpenseMap = {
  // Common items (for category mapping)
  'garri': 'Cassava flakes',
  'indomie': 'Noodles',
  'milo': 'Chocolate malt drink',
  
  // Local vendors
  'mama put': 'Local food vendor',
  'bukka': 'Local restaurant',
};

/// Capitalizes each word in a string (title casing).
String capitalizeWords(String input) {
  if (input.isEmpty) return input;
  return input.split(' ').map((word) {
    if (word.isEmpty) return '';
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}

/// Normalizes Nigerian slang prices (e.g. "5k" -> "5000", "5 thousand" -> "5000") in a text.
String normalizePriceInText(String input) {
  String result = input;
  
  // Remove commas between digits (e.g., 12,000 -> 12000)
  result = result.replaceAllMapped(
    RegExp(r'(\d),(\d)'),
    (match) => '${match.group(1)}${match.group(2)}',
  );

  // Replace "(\d+) k" or "(\d+)k" with "\1000" using replaceAllMapped
  result = result.replaceAllMapped(
    RegExp(r'\b(\d+)\s*k\b', caseSensitive: false),
    (match) => '${match.group(1)}000',
  );

  // Replace "(\d+) thousand" or "(\d+)thousand" with "\1000" using replaceAllMapped
  result = result.replaceAllMapped(
    RegExp(r'\b(\d+)\s*thousand\b', caseSensitive: false),
    (match) => '${match.group(1)}000',
  );

  // Replace "(\d+) million" with "\1000000"
  result = result.replaceAllMapped(
    RegExp(r'\b(\d+)\s*million\b', caseSensitive: false),
    (match) => '${match.group(1)}000000',
  );

  return result;
}

/// Helper to check if a word is in the slang dictionary, but we do NOT replace it in the raw description.
/// Instead, we can use it to normalize or map categories.
String normalizeNigerianText(String input) {
  String result = input;
  
  // First normalize prices
  result = normalizePriceInText(result);

  // Normalize other items
  nigerianExpenseMap.forEach((pattern, replacement) {
    result = result.replaceAll(RegExp(r'\b' + RegExp.escape(pattern) + r'\b', caseSensitive: false), replacement);
  });
  
  return result;
}

/// Parses raw transcribed voice text into structured expense fields.
Map<String, dynamic> parseExpenseFromText(String rawInput) {
  // 1. Normalize prices in the text (keep other slangs like garri/mama put as is)
  String normalized = normalizePriceInText(rawInput);
  
  double? amount;
  String merchant = '';
  String description = '';
  String category = 'Other';

  // 2. Extract Amount
  // Look for currency symbols (₦), "naira", or price indicators like "for", "at", "cost"
  final amountRegexes = [
    RegExp(r'(?:for|at|cost|₦|naira)\s*([\d\.,]+)', caseSensitive: false),
    RegExp(r'([\d\.,]+)\s*(?:naira)', caseSensitive: false),
    RegExp(r'₦\s*([\d\.,]+)', caseSensitive: false),
  ];

  for (final regex in amountRegexes) {
    final match = regex.firstMatch(normalized);
    if (match != null) {
      final numberStr = match.group(1)!.replaceAll(',', '');
      final val = double.tryParse(numberStr);
      if (val != null) {
        amount = val;
        break;
      }
    }
  }

  // If no currency patterns match, fallback to finding any number
  if (amount == null) {
    final allNumbers = RegExp(r'\b\d+[\d\.,]*\b').allMatches(normalized);
    if (allNumbers.isNotEmpty) {
      // Typically, the last number is the price
      final lastMatch = allNumbers.last;
      final numberStr = lastMatch.group(0)!.replaceAll(',', '');
      amount = double.tryParse(numberStr);
    }
  }

  // 3. Extract Merchant and Description from the normalized text
  String cleanedText = normalized;
  
  if (amount != null) {
    final amountInt = amount.toInt();
    // Build a regex to remove the amount and any surrounding currency indicators/prepositions
    final amountPhraseRegex = RegExp(
      '\\b(?:for|at|cost|₦|naira)?\\s*${amountInt}\\s*(?:naira|₦)?\\b',
      caseSensitive: false,
    );
    cleanedText = cleanedText.replaceFirst(amountPhraseRegex, '');
  }

  // Strip starting verbs and connector words (bought, spent, purchased, paid, gave, for, at, on)
  // Run in a loop to remove multiple leading words like "spent on..."
  while (true) {
    final nextText = cleanedText.replaceAll(
      RegExp(r'^\s*(?:bought|spent|purchased|paid|gave|for|at|on|to|in)\s+', caseSensitive: false),
      '',
    );
    if (nextText == cleanedText) break;
    cleanedText = nextText;
  }
  
  cleanedText = cleanedText.replaceAll(RegExp(r'\s+'), ' ').trim();

  // Try to extract merchant if the sentence contains "at <vendor>" or "from <vendor>"
  final vendorRegex = RegExp(r'\b(?:at|from)\s+(.+)$', caseSensitive: false);
  final vendorMatch = vendorRegex.firstMatch(cleanedText);
  if (vendorMatch != null) {
    merchant = vendorMatch.group(1)!.trim();
    description = cleanedText.substring(0, vendorMatch.start).trim();
  } else {
    description = cleanedText;
    
    // Check if we can infer standard merchants from known keywords
    final lowerDesc = description.toLowerCase();
    if (lowerDesc.contains('mama put')) {
      merchant = 'Mama Put';
    } else if (lowerDesc.contains('bukka')) {
      merchant = 'Local Bukka';
    } else if (lowerDesc.contains('uber')) {
      merchant = 'Uber';
    } else if (lowerDesc.contains('bolt')) {
      merchant = 'Bolt';
    } else {
      merchant = '';
    }
  }

  // Title case merchant for proper names
  if (merchant.isNotEmpty) {
    merchant = capitalizeWords(merchant);
  } else {
    merchant = 'Generic Merchant';
  }
  
  // Sentence case description (only capitalize the first letter)
  if (description.isNotEmpty) {
    description = description[0].toUpperCase() + description.substring(1);
  } else {
    description = rawInput; // Fallback if entire string was cleared
  }

  // 4. Classify Category
  final lowerInput = normalized.toLowerCase();
  if (lowerInput.contains('diesel') || lowerInput.contains('fuel') || lowerInput.contains('petrol') || 
      lowerInput.contains('transport') || lowerInput.contains('uber') || lowerInput.contains('bolt') || 
      lowerInput.contains('ride') || lowerInput.contains('cab') || lowerInput.contains('flight') || 
      lowerInput.contains('bus') || lowerInput.contains('fare')) {
    category = 'Travel';
  } else if (lowerInput.contains('garri') || lowerInput.contains('indomie') || lowerInput.contains('milo') || 
             lowerInput.contains('food') || lowerInput.contains('eat') || lowerInput.contains('restaurant') || 
             lowerInput.contains('mama put') || lowerInput.contains('bukka') || lowerInput.contains('meals') || 
             lowerInput.contains('lunch') || lowerInput.contains('dinner') || lowerInput.contains('breakfast') || 
             lowerInput.contains('grocery') || lowerInput.contains('coke') || lowerInput.contains('water')) {
    category = 'Meals';
  } else if (lowerInput.contains('software') || lowerInput.contains('domain') || lowerInput.contains('hosting') || 
             lowerInput.contains('cloud') || lowerInput.contains('saas') || lowerInput.contains('subscription') || 
             lowerInput.contains('api') || lowerInput.contains('github') || lowerInput.contains('figma')) {
    category = 'Software';
  } else if (lowerInput.contains('rent') || lowerInput.contains('office') || lowerInput.contains('space') || 
             lowerInput.contains('lease') || lowerInput.contains('coworking')) {
    category = 'Rent';
  } else if (lowerInput.contains('marketing') || lowerInput.contains('ads') || lowerInput.contains('advert') || 
             lowerInput.contains('facebook') || lowerInput.contains('google ads') || lowerInput.contains('flyer')) {
    category = 'Marketing';
  } else if (lowerInput.contains('paper') || lowerInput.contains('pen') || lowerInput.contains('supplies') || 
             lowerInput.contains('stationery') || lowerInput.contains('printer') || lowerInput.contains('stapler')) {
    category = 'Supplies';
  }

  return {
    'amount': amount,
    'merchant': merchant,
    'description': description,
    'category': category,
  };
}
