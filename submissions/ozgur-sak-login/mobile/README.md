# Flutter Mobil İstemci (Mobile Client)

Bu dizin, **Login System (2026)** projesinin Flutter ile geliştirilmiş mobil istemcisini (client) içermektedir. Proje; sürdürülebilirlik, ölçeklenebilirlik, modülerlik ve yüksek performans hedeflenerek modern yazılım mimarisi prensipleri doğrultusunda tasarlanmıştır.

---

## 🏗️ Mimari Yaklaşım (Architecture)

Uygulamanın genel mimarisi **temiz kod (clean code)** ve **sorumlulukların ayrılması (separation of concerns)** prensiplerine dayanmaktadır.

### 1. Feature-First (Özellik Öncelikli) Klasör Yapısı

Proje, katman öncelikli (layer-first) yapı yerine **özellik öncelikli (feature-first)** bir yapıyı benimsemektedir. Bu yaklaşımda her işlevsel modül (örn. `auth`, `home`) kendi veri (data), mantık (bloc/cubit) ve arayüz (view) katmanlarını kendi içinde barındırır. Bu durum, büyük takımlarda çakışmaları azaltır ve modüllerin bağımsız olarak geliştirilmesini/test edilmesini sağlar.

```
lib/
├── core/                        # Uygulama genelinde paylaşılan ortak altyapı
│   ├── api/                     # Ağ istemcisi, interceptor'lar ve API sarmalayıcılar
│   ├── navigation/              # Rotalar (auto_route tanımlamaları)
│   └── theme/                   # Renk paleti, metin stilleri ve tema yapılandırması
│
└── features/                    # Uygulama ekranları ve özellikleri
    ├── auth/                    # Kimlik Doğrulama Özelliği
    │   ├── data/                # Kimlik doğrulama servisleri ve lokal depolar
    │   ├── view/                # Login ve Register ekranları, form bileşenleri
    │   └── viewmodel/           # BLoC/Cubit mantığı, doğrulama mixin'leri
    │
    └── home/                    # Giriş Sonrası Ana Ekran Özelliği
        ├── view/                # Ana sayfa ve logout bileşenleri
        └── viewmodel/           # Ev sahibi ekranının iş mantığı
```

### 2. MVVM (Model-View-ViewModel) Tasarım Deseni ve Durum Yönetimi (Cubit)

Projede arayüz ile iş mantığını tamamen ayırmak, test edilebilirliği kolaylaştırmak ve kod kalitesini artırmak için **MVVM (Model-View-ViewModel)** mimari deseni kullanılmıştır:

- **Model (Veri Katmanı):** `data/` klasöründe bulunur. API'den gelen modelleri (OpenAPI modelleri) ve servis katmanını temsil eder.
- **View (Görünüm Katmanı):** `view/` klasöründe bulunur. Sadece arayüz bileşenlerini (ekranlar, butonlar, metin alanları vb.) barındırır. İş mantığından tamamen bağımsızdır ve ViewModel'ın durumlarını dinler.
- **ViewModel (Görünüm Modeli Katmanı):** `viewmodel/` klasöründe bulunur. **Cubit (Flutter BLoC)** kullanılarak geliştirilmiştir. Arayüzün durumunu (UI State) yönetir, kullanıcı etkileşimlerini alır, Model (veri) katmanıyla haberleşir ve arayüze reaktif olarak yeni durumları yayınlar.

**Cubit ile Sağlanan Avantajlar:**

- **Tek Yönlü Veri Akışı:** UI -> Cubit (Metod Çağrısı) -> Cubit State Değişimi -> UI (Yeniden Çizim / Rebuild).
- **Test Edilebilirlik:** ViewModel (Cubit) sınıfları arayüz katmanından bağımsız olduğu için kolayca unit testleri ile test edilebilir.

### 3. Gelişmiş Ağ Katmanı ve Token Yenileme Akışı

Ağ katmanında **Dio** kütüphanesi kullanılmıştır. Uygulamadaki kimlik doğrulama oturumunun sürekliliği için **Refresh Token Rotation (RTR)** mekanizması ağ katmanında tamamen otomatikleştirilmiştir:

- **Lokal Güvenli Depolama:** Başarılı giriş/kayıt işlemlerinden sonra `accessToken` ve `refreshToken` verileri `flutter_secure_storage` kullanılarak şifreli olarak cihazda saklanır.
- **Dio HTTP Interceptor (Token Enjeksiyonu):** Yapılan her API isteğinde interceptor devreye girer, güvenli depodan `accessToken` değerini okur ve isteğin `Authorization: Bearer <token>` başlığına otomatik olarak ekler.
- **Otomatik Token Yenileme (401 Unauthorized Yönetimi):**
  - Gönderilen bir istek `401` hatası aldığında (yani access token süresi dolduğunda), interceptor asıl isteği bekletmeye alır.
  - Arka planda, yeni bir Dio örneği kullanarak `/auth/refresh` endpoint'ine mevcut `refreshToken` ile istek gönderir.
  - **Başarılı Yenileme:** Yeni `accessToken` ve `refreshToken` alınır, lokal güvenli depoya kaydedilir ve bekletilen asıl istek yeni access token ile güncellenerek otomatik olarak yeniden gönderilir. Kullanıcı bu süreci hiç hissetmez.
  - **Başarısız Yenileme (Refresh Token Geçersiz):** Eğer refresh token'ın da süresi dolmuşsa veya geçersiz kılınmışsa, kullanıcının oturumu sonlandırılır, lokal depo temizlenir ve kullanıcı otomatik olarak giriş sayfasına yönlendirilir.

---

## 🛠️ Kullanılan Paketler ve Kütüphaneler

Uygulamada kullanılan kütüphaneler ve projeye katkıları şöyledir:

| Paket İsmi                   | Kategorisi                | Kullanım Amacı                                                                                                                                             |
| :--------------------------- | :------------------------ | :--------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **`flutter_bloc`**           | Durum Yönetimi            | Uygulama durumlarının (loading, success, error) Cubit'ler vasıtasıyla yönetilmesi ve arayüzün reaktif olarak güncellenmesi.                                |
| **`auto_route`**             | Yönlendirme               | Ekranlar arası geçişlerin tip güvenli (type-safe) yapılması, nested-routing (iç içe rotalar) ve derin bağlantıların (deep link) kolay yönetimi.            |
| **`dio`**                    | Ağ İletişimi              | Gelişmiş HTTP istek yönetimi, interceptor desteği, dosya indirme/yükleme yetenekleri ve hata yönetimi.                                                     |
| **`flutter_secure_storage`** | Güvenlik / Lokal Depolama | Android Keystore ve iOS Keychain entegrasyonu ile JWT token'larının cihaz üzerinde donanımsal olarak şifrelenip saklanması.                                |
| **`openapi`** _(Yerel)_      | API Entegrasyonu          | Swagger şemasından üretilen modeller ve API metotları. API istek/cevaplarındaki veri tiplerinin frontend ile backend arasında %100 uyumlu olmasını sağlar. |
| **`equatable`**              | Yardımcı Kütüphane        | State nesnelerinin değer bazlı karşılaştırılmasına olanak tanır. Gereksiz arayüz çizimlerini (rebuild) engeller.                                           |
| **`cupertino_icons`**        | Tasarım                   | iOS tarzı ikon setlerinin arayüzde kullanılması için.                                                                                                      |

---

## ✨ Temel Özellikler

1. **Cam Efekti Tasarım (Glassmorphism UI):**
   - Koyu yeşil temayla harmanlanmış modern, yarı saydam cam efekti içeren kartlar.
   - İnce gölge efektleri ve yuvarlatılmış köşelerle premium tasarım hissiyatı.
2. **Kullanıcı Bilgisi Koruma (Session Persistence):**
   - Uygulama yeniden başlatıldığında kullanıcının giriş durumunu korur.
3. **Form Doğrulama Mixin'leri:**
   - E-posta format doğrulaması (RegExp), minimum şifre uzunluğu ve şifre tekrarı kontrollerinin yapıldığı genişletilebilir Mixin yapısı (`AuthValidationMixin`).
4. **Hata Yönetimi ve Kullanıcı Bildirimleri:**
   - API'den dönen tüm sunucu hataları (örn. `409 Conflict`, `401 Unauthorized`) yakalanarak kullanıcıya kullanıcı dostu uyarı mesajları olarak gösterilir.

---

## 🚀 Kurulum ve Çalıştırma

### Gereksinimler

- **Flutter SDK:** `3.10.8` veya üzeri.
- **Platformlar:** Android (API 21+) veya iOS (12.0+).
- **Çalışan Backend API:** `http://localhost:5075` adresinde API servislerinin açık olması gerekir.

### Adımlar

1. **Bağımlılıkları Kurun:**

   ```bash
   flutter pub get
   ```

2. **Kod Üretimini Başlatın (Build Runner):**
   Rotalar ve kod modellerinin derlenmesi için build_runner'ı çalıştırın:

   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

3. **Uygulamayı Başlatın:**
   Cihazınız veya emülatörünüz bağlıyken uygulamayı çalıştırın:
   ```bash
   flutter run
   ```

---

## 🧪 Testler

### 1. Widget & Birim Testleri

Uygulama arayüz bileşenlerinin ve Cubit mantığının doğru çalışıp çalışmadığını test etmek için Flutter'ın dahili test kütüphanesi kullanılır.

- **Çalıştırma Komutu:**
  ```bash
  flutter test
  ```

### 2. Maestro Uçtan Uca (E2E) UI Testleri

Cihaz üzerinde gerçek bir kullanıcı gibi tıklama, metin yazma ve ekran doğrulama işlemlerini otomatize etmek için **Maestro** test çatısı kullanılmaktadır.

- **Test Dosyaları:**
  - `maestro/login_flow.yaml`: Hatalı giriş kontrolleri, form alanlarının boş bırakılması senaryolarını test eder.
  - `maestro/register_flow.yaml`: Kayıt ekranına geçiş, alan doğrulamaları ve tekrar giriş sayfasına dönüş senaryolarını test eder.

#### Maestro Testlerini Çalıştırma Adımları:

1. **Maestro CLI Kurulumu (Git Bash / CMD):**
   ```bash
   curl -FsSL https://get.maestro.mobile.dev | bash
   ```
2. **Çevresel Değişken Tanımlama (Windows):**
   Kurulum bittikten sonra `.maestro/bin` klasör yolunu Windows Sistem/Kullanıcı PATH değişkenlerine ekleyin. (Örn: `C:\Users\<KullanıcıAdı>\.maestro\bin`)
3. **Uygulamayı Emülatöre Yükleyin:**
   Maestro çalıştırılmadan önce uygulamanın emülatörde yüklü olması gerekir. Debug APK'yı derleyip kurun:
   ```bash
   flutter build apk --debug
   adb install build/app/outputs/flutter-apk/app-debug.apk
   ```
4. **Testleri Tetikleyin:**

   ```bash
   # Giriş Akışı Testi
   maestro test maestro/login_flow.yaml

   # Kayıt Akışı Testi
   maestro test maestro/register_flow.yaml
   ```
