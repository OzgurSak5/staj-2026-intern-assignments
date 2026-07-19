## Mobil (Flutter) Mimari Kararlar

## Mimari: MVVM (Model-View-ViewModel) + Cubit

Uygulamayı presentation ve business logic olarak ayırmak için MVVM desenini tercih ettim.

- **Model (DTOs):** OpenAPI generator ile üretilen tipler veriyi temsil eder.
- **View (Screens/Widgets):** Sadece arayüzü çizer ve kullanıcı etkileşimlerini alır.
- **ViewModel (Cubit):** Bloc kütüphanesine kıyasla daha hafif, event tanımlama gerektirmeyen ve sadece metot tetiklemeleriyle state yayan Cubit yapısı iş mantığını yönetir.

## Navigasyon: auto_route

Flutter'ın varsayılan Navigator 1.0/2.0 yapısı yerine auto_route paketi seçildi.

- **Tip Güvenliği (Type-safety):** Sayfalar arası geçişlerde argüman gönderimi statik tiplerle güvenceye alınır.
- **Declarative Routing:** Guards (AuthGuard) yapısı sayesinde giriş yapmamış kullanıcıların korumalı sayfalara (Dashboard) erişmesi deklaratif olarak engellenir.
- **Kod Üretimi:** Rotalar build_runner ile otomatik üretilerek insan hatası sıfıra indirilir.

## Eyalet Yönetimi: Equatable

Bloc/Cubit durum değişikliklerini (State transitions) yönetirken Equatable paketi entegre edildi.

- **Nesne Karşılaştırma (Value Equality):** Dart'taki referans bazlı nesne karşılaştırmasını değer bazlıya dönüştürür.
- **Gereksiz Arayüz Çizimini Önleme (Performance):** Aynı veriye sahip durumlar yayıldığında UI'ın tekrar tetiklenmesini (`rebuild`) engeller, performansı artırır.
- **Temiz copyWith Yapısı:** State sınıflarının tekil bir sınıfta birleştirilerek `copyWith` ile kopyalanmasını ve yönetilmesini kolaylaştırır.

## Veri Katmanı Mimarisi: Repository Pattern
Clean Architecture prensipleri doğrultusunda Business Logic (Cubit) ile Veri Kaynağı (Service/Storage) katmanları arasına bir Repository katmanı ekledim.
- **Sorumlulukların Ayrılması (Separation of Concerns):** Cubit'lerin token saklama, silme gibi yerel disk işlemlerini doğrudan bilmesinin önüne geçildi. Cubit sadece "giriş yap", "çıkış yap" gibi soyut komutları Repository'ye iletir.
- **Tek Noktadan Veri Yönetimi:** `AuthRepositoryImpl` sınıfı, `AuthService` (uzak sunucu) ve `SecureStorageManager` (yerel disk) bileşenlerini birleştirerek verinin akışını ve yerel hafızaya kaydedilmesini tek bir noktada koordine eder.
- **Gevşek Bağlılık (Loose Coupling):** Cubit'ler doğrudan somut sınıflarla değil, `AuthRepository` arayüzü (interface) üzerinden konuşur. Bu sayede test yazarken (Mocking) repository kolaylıkla taklit edilebilir.
