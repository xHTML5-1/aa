import '../../domain/entities/payment.dart';

class PaymentIntentModel extends PaymentIntent {
  const PaymentIntentModel({
    required super.invoiceId,
    required super.gateway,
    required super.checkoutFormToken,
    required super.redirectUrl,
  });

  factory PaymentIntentModel.fromJson(Map<String, dynamic> json) {
    return PaymentIntentModel(
      invoiceId: json['invoice_id'] as String,
      gateway: json['gateway'] as String,
      checkoutFormToken: json['checkout_form_token'] as String,
      redirectUrl: json['redirect_url'] as String,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'invoice_id': invoiceId,
        'gateway': gateway,
        'checkout_form_token': checkoutFormToken,
        'redirect_url': redirectUrl,
      };
}
