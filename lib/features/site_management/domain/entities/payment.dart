class PaymentIntent {
  const PaymentIntent({
    required this.invoiceId,
    required this.gateway,
    required this.checkoutFormToken,
    required this.redirectUrl,
  });

  final String invoiceId;
  final String gateway;
  final String checkoutFormToken;
  final String redirectUrl;
}
