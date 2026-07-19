# Mobil Tekrar Eden İşler (Mobile Repetitions)

3+ kez yaptığım işleri buraya not ediyorum. Faz sonunda bunlar skill'e dönüşecek.

## 1. Yeni Ekran ve Rota Ekleme 
Her yeni ekran eklediğimde izlediğim adımlar:
1. `features/<feature_name>/view/` altına `<screen_name>_view.dart` oluşturma ve `@RoutePage()` annotasyonunu ekleme.
2. `core/route/app_router.dart` dosyasına yeni rotayı `AutoRoute(page: ScreenRoute.page)` şeklinde tanımlama.
3. Terminalde `flutter pub run build_runner build --delete-conflicting-outputs` komutunu çalıştırarak yönlendirme dosyalarını üretme.
* *Skill adayı:* `create-page` (ekran taslağını oluşturup, router'a ekleyen ve build_runner'ı tetikleyen araç).


