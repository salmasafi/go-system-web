import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:GoSystem/features/admin/popup/cubit/popup_cubit.dart';
import 'package:GoSystem/features/admin/popup/data/repositories/popup_repository.dart';
import 'package:GoSystem/features/admin/popup/model/popup_model.dart';

class MockPopupRepository extends Mock implements PopupRepository {}

void main() {
  late MockPopupRepository mockRepo;

  setUp(() {
    mockRepo = MockPopupRepository();
  });

  PopupModel samplePopup(String id) => PopupModel.fromJson({
        'id': id,
        'title_en': 'Popup $id',
        'title_ar': 'نافذة $id',
        'description_en': 'Description',
        'description_ar': 'وصف',
        'link': 'https://example.com',
        'image': 'popup.jpg',
        'status': true,
        'created_at': '2024-01-01',
      });

  group('PopupCubit', () {
    blocTest<PopupCubit, PopupState>(
      'getAllPopups emits loading then success',
      build: () {
        when(() => mockRepo.getAllPopups()).thenAnswer((_) async => [samplePopup('p1')]);
        return PopupCubit(mockRepo);
      },
      act: (c) => c.getAllPopups(),
      expect: () => [
        isA<GetPopupsLoading>(),
        isA<GetPopupsSuccess>(),
      ],
      verify: (_) {
        verify(() => mockRepo.getAllPopups()).called(1);
      },
    );

    blocTest<PopupCubit, PopupState>(
      'getAllPopups emits loading then error when repository throws',
      build: () {
        when(() => mockRepo.getAllPopups()).thenThrow(Exception('network'));
        return PopupCubit(mockRepo);
      },
      act: (c) => c.getAllPopups(),
      expect: () => [
        isA<GetPopupsLoading>(),
        isA<GetPopupsError>(),
      ],
    );

    blocTest<PopupCubit, PopupState>(
      'addPopup emits loading then success',
      build: () {
        when(() => mockRepo.createPopup(
          titleAr: any(named: 'titleAr'),
          titleEn: any(named: 'titleEn'),
          descriptionAr: any(named: 'descriptionAr'),
          descriptionEn: any(named: 'descriptionEn'),
          link: any(named: 'link'),
          imagePath: any(named: 'imagePath'),
        )).thenAnswer((_) async => {});
        when(() => mockRepo.getAllPopups()).thenAnswer((_) async => [samplePopup('p1')]);
        return PopupCubit(mockRepo);
      },
      act: (c) => c.addPopup(
        titleAr: 'عنوان',
        titleEn: 'Title',
        descriptionAr: 'وصف',
        descriptionEn: 'Description',
        link: 'https://example.com',
        image: null,
      ),
      expect: () => [
        isA<CreatePopupLoading>(),
        isA<CreatePopupSuccess>(),
        isA<GetPopupsLoading>(),
        isA<GetPopupsSuccess>(),
      ],
    );
  });
}
