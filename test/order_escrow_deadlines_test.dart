import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jconnect/features/my_orders/model/order_model.dart';
import 'package:jconnect/features/my_orders/order_details/model/order_details_model.dart';
import 'package:jconnect/features/my_orders/order_details/widgets/order_escrow_deadline_banner.dart';

void main() {
  group('Order Escrow Deadlines Model Tests', () {
    test(
      'OrderModel parses acceptDeadline and proofReviewDeadline correctly',
      () {
        final now = DateTime.now();
        final acceptIso = now
            .add(const Duration(hours: 23, minutes: 50))
            .toIso8601String();
        final proofIso = now
            .add(const Duration(hours: 12, minutes: 30))
            .toIso8601String();

        final pendingJson = {
          'id': 'ord_123',
          'orderCode': 'ORD-123',
          'status': 'PENDING',
          'acceptDeadline': acceptIso,
          'proofReviewDeadline': null,
          'amount': 5000,
        };

        final pendingOrder = OrderModel.fromPaidOrderJson(pendingJson);
        expect(pendingOrder.acceptDeadline, acceptIso);
        expect(pendingOrder.proofReviewDeadline, isNull);
        expect(pendingOrder.isAcceptDeadlineActive, isTrue);
        expect(pendingOrder.isProofReviewDeadlineActive, isFalse);
        expect(pendingOrder.acceptTimeRemaining, isNotNull);
        expect(
          pendingOrder.acceptTimeRemaining!.inHours,
          greaterThanOrEqualTo(23),
        );

        final proofJson = {
          'id': 'ord_456',
          'orderCode': 'ORD-456',
          'status': 'PROOF_SUBMITTED',
          'acceptDeadline': null,
          'proofReviewDeadline': proofIso,
          'amount': 10000,
        };

        final proofOrder = OrderModel.fromPaidOrderJson(proofJson);
        expect(proofOrder.acceptDeadline, isNull);
        expect(proofOrder.proofReviewDeadline, proofIso);
        expect(proofOrder.isAcceptDeadlineActive, isFalse);
        expect(proofOrder.isProofReviewDeadlineActive, isTrue);
        expect(proofOrder.proofReviewTimeRemaining, isNotNull);
        expect(
          proofOrder.proofReviewTimeRemaining!.inHours,
          greaterThanOrEqualTo(12),
        );
      },
    );

    test(
      'OrderDetailsModel parses deadlines, action, and updates timeline titles',
      () {
        final now = DateTime.now();
        final proofIso = now.add(const Duration(hours: 20)).toIso8601String();

        final detailsJson = {
          'id': 'ord_789',
          'orderCode': 'ORD-789',
          'status': 'PROOF_SUBMITTED',
          'proofReviewDeadline': proofIso,
          'action': 'AUTO_RELEASE',
          'isCancelRequested': false,
          'amount': 7500,
        };

        final details = OrderDetailsModel.fromJson(detailsJson);
        expect(details.proofReviewDeadline, proofIso);
        expect(details.isProofReviewDeadlineActive, isTrue);
        expect(details.isAcceptDeadlineActive, isFalse);
        expect(details.action, 'AUTO_RELEASE');

        // Test Auto-release terminal title
        final releasedJson = {
          'id': 'ord_789',
          'orderCode': 'ORD-789',
          'status': 'RELEASED',
          'action': 'AUTO_RELEASE',
        };
        final releasedDetails = OrderDetailsModel.fromJson(releasedJson);
        final lastStep = releasedDetails.timeline.last;
        expect(lastStep.title, 'Completed (Auto-released)');

        // Test Auto-cancel terminal title
        final cancelledJson = {
          'id': 'ord_789',
          'orderCode': 'ORD-789',
          'status': 'CANCELLED',
          'action': 'AUTO_CANCEL_UNACCEPTED',
        };
        final cancelledDetails = OrderDetailsModel.fromJson(cancelledJson);
        final cancelledStep = cancelledDetails.timeline.last;
        expect(cancelledStep.title, 'Auto-cancelled (Acceptance Expired)');
      },
    );

    test('OrderDetailsModel parses deliveryDate and releasedAt keys', () {
      final json = {
        'id': 'ord_del_1',
        'orderCode': 'ORD-DEL-1',
        'status': 'RELEASED',
        'delivery_date': '2026-03-25T14:30:00.000Z',
        'released_at': '2026-03-26T16:00:00.000Z',
      };
      final details = OrderDetailsModel.fromJson(json);
      expect(details.deliveryDate, '2026-03-25T14:30:00.000Z');
      expect(details.releasedAt, '2026-03-26T16:00:00.000Z');
    });

    test('OrderModel statusMessage reflects auto-expiry states', () {
      final autoCancelledOrder = OrderModel(
        title: 'Logo Design',
        platform: 'INSTAGRAM',
        icon: '',
        type: 'Purchased',
        status: 'CANCELLED',
        price: 50.0,
        orderId: '1',
        orderCode: 'ORD-1',
        action: 'AUTO_CANCEL_UNACCEPTED',
      );
      expect(
        autoCancelledOrder.statusMessage,
        'Order cancelled — refund issued',
      );

      final autoReleasedOrder = OrderModel(
        title: 'Song Mix',
        platform: 'SPOTIFY',
        icon: '',
        type: 'Received',
        status: 'RELEASED',
        price: 100.0,
        orderId: '2',
        orderCode: 'ORD-2',
        action: 'AUTO_RELEASE',
      );
      expect(
        autoReleasedOrder.statusMessage,
        'Order auto-released & funds transferred',
      );
    });
  });

  group('OrderEscrowDeadlineBanner Widget Tests', () {
    testWidgets('Renders Seller Acceptance countdown for Buyer', (
      tester,
    ) async {
      final now = DateTime.now();
      final acceptIso = now
          .add(const Duration(hours: 22, minutes: 15))
          .toIso8601String();

      final order = OrderDetailsModel(
        id: 'ord_test_1',
        orderCode: 'ORD-TEST-1',
        platform: 'INSTAGRAM',
        serviceTitle: 'Test Service',
        subServiceTitle: 'Subtitle',
        sellerName: 'Seller Alice',
        sellerEmail: 'seller@test.com',
        sellerUsername: 'seller_alice',
        sellerimageUrl: '',
        sellerId: 'user_seller',
        buyerName: 'Buyer Bob',
        buyerEmail: 'buyer@test.com',
        buyerUsername: 'buyer_bob',
        buyerImageUrl: '',
        rating: 5.0,
        status: 'PENDING',
        orderCreated: now.toIso8601String(),
        deliveryDate: now.add(const Duration(days: 3)).toIso8601String(),
        servicePrice: 5000,
        platformRate: '10',
        platformFee: 500,
        buyerId: 'user_buyer',
        timeline: [],
        proofUrl: [],
        acceptDeadline: acceptIso,
      );

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: OrderEscrowDeadlineBanner(order: order, isBuyer: true),
            ),
          ),
        ),
      );

      expect(find.text('Waiting for Seller Acceptance'), findsOneWidget);
      expect(find.text('ACCEPTANCE WINDOW'), findsOneWidget);
      expect(find.textContaining('Expires in'), findsOneWidget);
    });

    testWidgets('Renders Guarded Paused Banner when dispute is open', (
      tester,
    ) async {
      final now = DateTime.now();
      final proofIso = now.add(const Duration(hours: 18)).toIso8601String();

      final order = OrderDetailsModel(
        id: 'ord_test_2',
        orderCode: 'ORD-TEST-2',
        platform: 'TIKTOK',
        serviceTitle: 'Video Post',
        subServiceTitle: 'Subtitle',
        sellerName: 'Seller Alice',
        sellerEmail: 'seller@test.com',
        sellerUsername: 'seller_alice',
        sellerimageUrl: '',
        sellerId: 'user_seller',
        buyerName: 'Buyer Bob',
        buyerEmail: 'buyer@test.com',
        buyerUsername: 'buyer_bob',
        buyerImageUrl: '',
        rating: 5.0,
        status: 'PROOF_SUBMITTED',
        orderCreated: now.toIso8601String(),
        deliveryDate: now.add(const Duration(days: 3)).toIso8601String(),
        servicePrice: 8000,
        platformRate: '10',
        platformFee: 800,
        buyerId: 'user_buyer',
        timeline: [],
        proofUrl: [],
        proofReviewDeadline: proofIso,
        isCancelRequested: true,
      );

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: OrderEscrowDeadlineBanner(
                order: order,
                isBuyer: true,
                hasOpenDispute: true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Release Paused — Under Review'), findsOneWidget);
      expect(find.text('PAUSED'), findsOneWidget);
      // Ensure it does NOT show the active ticking countdown badge
      expect(find.text('24H REVIEW WINDOW'), findsNothing);
    });
  });
}
