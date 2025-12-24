class PaymentMethodModel {
  final String? cardBrand;
  final String? last4;
  final int? expMonth;
  final int? expYear;

  PaymentMethodModel({
    this.cardBrand,
    this.last4,
    this.expMonth,
    this.expYear,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      cardBrand: json['cardBrand'],
      last4: json['last4'],
      expMonth: json['expMonth'],
      expYear: json['expYear'],
    );
  }
}
