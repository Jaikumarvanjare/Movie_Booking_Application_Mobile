import 'dart:async';

import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'payment_gateway.dart';

class RazorpayPaymentGateway implements PaymentGateway {
  RazorpayPaymentGateway() : _razorpay = Razorpay() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  final Razorpay _razorpay;
  Completer<PaymentGatewaySuccess>? _activeCompleter;

  @override
  Future<PaymentGatewaySuccess> openCheckout(PaymentGatewayRequest request) {
    if (_activeCompleter != null && !_activeCompleter!.isCompleted) {
      throw const PaymentGatewayException(
        'A Razorpay checkout is already in progress.',
      );
    }

    final completer = Completer<PaymentGatewaySuccess>();
    _activeCompleter = completer;

    _razorpay.open({
      'key': request.keyId,
      'order_id': request.orderId,
      'amount': request.amount.round(),
      'currency': request.currency,
      'name': 'CineBook',
      'description': request.description,
      'prefill': {'name': request.userName, 'email': request.userEmail},
      'theme': {'color': '#E11D48'},
    });

    return completer.future;
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    final completer = _activeCompleter;
    _activeCompleter = null;

    if (completer == null || completer.isCompleted) {
      return;
    }

    final orderId = response.orderId;
    final paymentId = response.paymentId;
    final signature = response.signature;
    if (orderId == null || paymentId == null || signature == null) {
      completer.completeError(
        const PaymentGatewayException(
          'Razorpay did not return complete payment details.',
        ),
      );
      return;
    }

    completer.complete(
      PaymentGatewaySuccess(
        razorpayOrderId: orderId,
        razorpayPaymentId: paymentId,
        razorpaySignature: signature,
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    final completer = _activeCompleter;
    _activeCompleter = null;
    if (completer == null || completer.isCompleted) {
      return;
    }

    completer.completeError(
      PaymentGatewayException(
        response.message ?? 'Payment was cancelled or failed.',
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    final completer = _activeCompleter;
    _activeCompleter = null;
    if (completer == null || completer.isCompleted) {
      return;
    }

    completer.completeError(
      PaymentGatewayException(
        '${response.walletName ?? 'External wallet'} checkout is not supported in this flow.',
      ),
    );
  }
}
