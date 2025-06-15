import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  static Future<void> sendReceiptEmail({
    required String toEmail,
    required String userName,
    required String txnId,
    required List<Map<String, dynamic>> items,
    required double originalCost,
    required double totalCost,
    required String discountLabel,
    required String paymentMethod,
    required String formattedDate,
  }) async {
    final smtpServer = gmail('tseleena200@gmail.com', 'iahfvdtnkcrocvii');

    // 🧾 Generate email body
    final itemList = items.map((item) {
      return "- ${item['productName']} (${item['unitValue']} ${item['unitType']}) x${item['quantity']} = \$${(item['itemFinalPrice']).toStringAsFixed(2)}";
    }).join("\n");

    final body = '''
Hi $userName,

Thank you for your purchase with SmartCart!

🧾 Receipt Details:
Transaction ID: $txnId
Date: $formattedDate

Items:
$itemList

---------------------------
Discount Applied: $discountLabel
Subtotal: \$${originalCost.toStringAsFixed(2)}
Total Paid: \$${totalCost.toStringAsFixed(2)}
Payment Method: $paymentMethod

Thank you for shopping with us! 🛒

SmartCart Team
''';

    final message = Message()
      ..from = Address('tseleena200@gmail.com', 'SmartCart')
      ..recipients.add(toEmail)
      ..subject = 'Your SmartCart Receipt'
      ..text = body;

    try {
      await send(message, smtpServer);
      print('✅ Email sent successfully!');
    } catch (e) {
      print('❌ Failed to send email: $e');
    }
  }
}
