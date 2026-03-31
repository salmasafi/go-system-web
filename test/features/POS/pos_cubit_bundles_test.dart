// test/features/POS/pos_cubit_bundles_test.dart
//
// Property tests:
//   2.1 — selectTab('bundles') يُصدر PosBundlesLoaded
//   2.2 — فشل API لا يوقف التطبيق

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:systego/features/POS/home/cubit/pos_home_cubit.dart';
import 'package:systego/features/POS/home/cubit/pos_home_state.dart';
import 'package:systego/features/POS/home/model/pos_models.dart';

// ─── Fake Cubits ─────────────────────────────────────────────────────────────
// نستخدم subclass لتجاوز getBundles مباشرة بدون Dio/HTTP

/// Cubit يُرجع bundles ناجحة من API
class _FakeBundlesCubit extends PosCubit {
  final List<BundleModel> fakeBundles;
  _FakeBundlesCubit(this.fakeBundles);

  @override
  Future<void> getBundles() async {
    bundles = fakeBundles;
  }
}

/// Cubit يُحاكي فشل API — يمسك الخطأ داخلياً كما يفعل PosCubit الحقيقي
class _FailingBundlesCubit extends PosCubit {
  _FailingBundlesCubit();

  @override
  Future<void> getBundles() async {
    // نُحاكي نفس سلوك getBundles الحقيقي: catch يمسك الخطأ ويُبقي bundles = []
    try {
      throw Exception('Simulated API failure');
    } catch (_) {
      bundles = [];
    }
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

BundleModel _makeBundle({
  String id = 'b1',
  String name = 'Test Bundle',
  double price = 99.0,
}) =>
    BundleModel(
      id: id,
      name: name,
      images: ['img.png'],
      price: price,
      originalPrice: 120.0,
      savings: 21.0,
      savingsPercentage: 17,
      startDate: '2026-01-01',
      endDate: '2026-12-31',
      products: [],
    );

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  // ══════════════════════════════════════════════════════════════════════════
  // 2.1 — Property: selectTab('bundles') يُصدر PosBundlesLoaded
  // ══════════════════════════════════════════════════════════════════════════

  group('2.1 — selectTab("bundles") يُصدر PosBundlesLoaded', () {
    blocTest<PosCubit, PosState>(
      'عندما تكون bundles فارغة: يستدعي getBundles ويُصدر PosBundlesLoaded',
      build: () => _FakeBundlesCubit([_makeBundle()]),
      act: (cubit) => cubit.selectTab(tab: 'bundles'),
      expect: () => [isA<PosBundlesLoaded>()],
      verify: (cubit) {
        expect(cubit.selectedTab, equals('bundles'));
        expect(cubit.bundles, isNotEmpty);
        expect(cubit.bundles.first, isA<BundleModel>());
      },
    );

    blocTest<PosCubit, PosState>(
      'عندما تكون bundles محملة مسبقاً: لا يستدعي getBundles ويُصدر PosBundlesLoaded مباشرة',
      build: () => PosCubit()..bundles = [_makeBundle(id: 'cached-1')],
      act: (cubit) => cubit.selectTab(tab: 'bundles'),
      expect: () => [isA<PosBundlesLoaded>()],
      verify: (cubit) {
        expect(cubit.bundles.first.id, equals('cached-1'));
      },
    );

    blocTest<PosCubit, PosState>(
      'PosBundlesLoaded يحمل نفس قائمة bundles المُحللة من API',
      build: () => _FakeBundlesCubit([
        _makeBundle(id: 'b1', name: 'Pack A', price: 50.0),
        _makeBundle(id: 'b2', name: 'Pack B', price: 75.0),
      ]),
      act: (cubit) => cubit.selectTab(tab: 'bundles'),
      expect: () => [
        isA<PosBundlesLoaded>().having(
          (s) => s.bundles.length,
          'bundles count',
          equals(2),
        ),
      ],
      verify: (cubit) {
        expect(cubit.bundles[0].id, equals('b1'));
        expect(cubit.bundles[1].id, equals('b2'));
      },
    );

    blocTest<PosCubit, PosState>(
      'selectedTab يُحدَّث إلى "bundles" بعد الاستدعاء',
      build: () => PosCubit()..bundles = [_makeBundle()],
      act: (cubit) => cubit.selectTab(tab: 'bundles'),
      verify: (cubit) => expect(cubit.selectedTab, equals('bundles')),
    );

    blocTest<PosCubit, PosState>(
      'showCategoryFilters و showBrandFilters يُغلقان عند tab == bundles',
      build: () => PosCubit()
        ..showCategoryFilters = true
        ..showBrandFilters = true
        ..bundles = [_makeBundle()],
      act: (cubit) => cubit.selectTab(tab: 'bundles'),
      verify: (cubit) {
        expect(cubit.showCategoryFilters, isFalse);
        expect(cubit.showBrandFilters, isFalse);
      },
    );

    blocTest<PosCubit, PosState>(
      'PosBundlesLoaded.bundles يساوي cubit.bundles بعد التحميل',
      build: () => _FakeBundlesCubit([
        _makeBundle(id: 'x1'),
        _makeBundle(id: 'x2'),
        _makeBundle(id: 'x3'),
      ]),
      act: (cubit) => cubit.selectTab(tab: 'bundles'),
      expect: () => [
        isA<PosBundlesLoaded>().having(
          (s) => s.bundles.map((b) => b.id).toList(),
          'bundle ids',
          equals(['x1', 'x2', 'x3']),
        ),
      ],
    );
  });

  // ══════════════════════════════════════════════════════════════════════════
  // 2.2 — Property: فشل API لا يوقف التطبيق
  // ══════════════════════════════════════════════════════════════════════════

  group('2.2 — فشل API لا يوقف التطبيق', () {
    blocTest<PosCubit, PosState>(
      'فشل الشبكة: يُصدر PosBundlesLoaded بقائمة فارغة ولا يُصدر PosError',
      build: () => _FailingBundlesCubit(),
      act: (cubit) => cubit.selectTab(tab: 'bundles'),
      expect: () => [
        isA<PosBundlesLoaded>().having((s) => s.bundles, 'bundles', isEmpty),
      ],
      verify: (cubit) {
        expect(cubit.bundles, isEmpty);
        expect(cubit.selectedTab, equals('bundles'));
      },
    );

    blocTest<PosCubit, PosState>(
      'خطأ عام: لا يُصدر PosError — التطبيق يستمر',
      build: () => _FailingBundlesCubit(),
      act: (cubit) => cubit.selectTab(tab: 'bundles'),
      // يجب ألا يكون PosError في أي state مُصدَر
      expect: () => [isA<PosBundlesLoaded>()],
    );

    blocTest<PosCubit, PosState>(
      'فشل API لا يؤثر على selectedTab — يبقى "bundles"',
      build: () => _FailingBundlesCubit(),
      act: (cubit) => cubit.selectTab(tab: 'bundles'),
      verify: (cubit) => expect(cubit.selectedTab, equals('bundles')),
    );

    blocTest<PosCubit, PosState>(
      'فشل API لا يُغلق filter panels — showCategoryFilters يبقى false',
      build: () => _FailingBundlesCubit()
        ..showCategoryFilters = false
        ..showBrandFilters = false,
      act: (cubit) => cubit.selectTab(tab: 'bundles'),
      verify: (cubit) {
        expect(cubit.showCategoryFilters, isFalse);
        expect(cubit.showBrandFilters, isFalse);
      },
    );

    blocTest<PosCubit, PosState>(
      'بعد فشل API: selectTab("bundles") مرة ثانية يُعيد المحاولة وينجح',
      build: () {
        // نستخدم cubit مخصص يفشل أول مرة وينجح ثاني مرة
        return _CountingBundlesCubit(
          onCall: (count) async {
            if (count == 1) throw Exception('First call fails');
            return [_makeBundle(id: 'retry-b1')];
          },
        );
      },
      act: (cubit) async {
        await cubit.selectTab(tab: 'bundles'); // فشل — bundles فارغة
        await cubit.selectTab(tab: 'bundles'); // نجاح — bundles محملة
      },
      verify: (cubit) {
        expect(cubit.bundles, isNotEmpty);
        expect(cubit.bundles.first.id, equals('retry-b1'));
      },
    );
  });
}

// ─── Helper Cubit للاختبار الأخير ────────────────────────────────────────────

class _CountingBundlesCubit extends PosCubit {
  final Future<List<BundleModel>> Function(int callCount) onCall;
  int _callCount = 0;

  _CountingBundlesCubit({required this.onCall});

  @override
  Future<void> getBundles() async {
    _callCount++;
    try {
      bundles = await onCall(_callCount);
    } catch (_) {
      bundles = [];
    }
  }
}
