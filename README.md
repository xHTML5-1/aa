# Site & Aidat Yönetimi Mobil Uygulaması

Bu repo, Flutter + Clean Architecture yaklaşımıyla geliştirilen çok kiracılı (multi-tenant) **Site & Aidat Yönetimi** uygulamasını ve beraberindeki mock API'yi içerir. Uygulama; dönem bazlı masraf dağıtımı, fatura üretimi, çevrimdışı senkronizasyon, rol yönetimi, FCM bildirimleri, PDF çıktısı ve pazar yeri ödeme altyapılarına entegrasyon için gerekli soyutlamaları örnekler.

## Mimarinin Özeti

- **Sunum Katmanı (Presentation)**: Riverpod tabanlı durumsal yönetim (`SiteController`) ve Material 3 arayüz bileşenleri.
- **Domain Katmanı**: Entity, repository sözleşmeleri ve use-case'ler (`GetSite`, `RunPeriod`, `PublishPeriod`, `CreatePaymentIntent`, vb.).
- **Veri Katmanı**: `SiteRepositoryImpl` ile mock API'den veri alma, çevrimdışı önbellek (`OfflineCache`) ve idempotent senkron kuyruğu.
- **Çekirdek**: JWT yönetimi, HTTP istemcisi, PDF üretimi (Türkçe karakter desteği için TrueType font), bildirim servisi (FCM), hata modelleri.
- **Mock API**: FastAPI ile yazılmış çok kiracılı uç noktalar, masraf dağıtım seçeneklerinin (arsa payı, m², sabit, sayaç) tamamını destekler.

## Özellikler

- Dönem -> çalışma -> yayınlama -> fatura üretim akışı.
- Kalem bazlı masraf dağıtım tipleri: arsa payı, metrekare, sabit tutar, sayaç okuması.
- Faturalar için UUID tabanlı tekillik (`invoice_id`).
- İyzico / PayTR benzeri pazar yeri ödeme entegrasyonuna hazırlık yapan `PaymentIntent` modellemesi ve platform komisyonu ayrımı için altyapı.
- Firebase Messaging ile FCM bildirimleri, Firebase Core başlatma.
- Çevrimdışı cache + idempotent senkron kuyruğu (`OfflineCache`).
- Roller: `superadmin`, `site_yoneticisi`, `muhasebe`, `personel`, `sakin`.
- Türkçe karakter uyumlu PDF çıktısı (`InvoicePdfGenerator`).
- JWT saklama ve yenileme kontrolü (`JwtTokenManager`).
- Mock testler (`flutter_test`, `mocktail`).

## Kurulum

### 1. Flutter ortamı

```bash
flutter pub get
```

Varsayılan olarak `lib/main.dart` Firebase'i başlatır; test veya geliştirme ortamında `firebase_options.dart` gereksinimini kaldırmak için `Firebase.initializeApp()` çağrısını koşullu hale getirebilirsiniz.

### 2. Mock API'yi çalıştırma

Mock API, `mock_api/server.py` içinde FastAPI ile sağlanır.

```bash
cd mock_api
python -m venv .venv
source .venv/bin/activate
pip install fastapi uvicorn
uvicorn server:app --reload --host 0.0.0.0 --port 8000
```

### 3. Uygulamayı başlatma

```bash
flutter run -d ios    # veya
flutter run -d android
```

Uygulama açıldığında Riverpod provider zinciri `demo-site` kiracısını yükler ve dönem/masraf örneklerini listeler.

## Testler

```bash
flutter test
```

## Çevrimdışı Senkron ve Idempotency

- Her başarısız ağ isteği `ApiClient` içinde SharedPreferences tabanlı kuyruğa yazılır.
- `OfflineCache` birincil anahtar üretimini UUID ile sağlar, tekrar eden istekler idempotent şekilde saklanır.
- `SiteLocalDataSource` kuyruğu dışarı aktarır; gerçek projede arka plan senkron servisi ile işlenebilir.

## Bildirimler

`NotificationService`, Firebase Cloud Messaging izinlerini ister ve `site-updates` konusuna abone olur. Use-case çağrıları başarıyla tamamlandığında log tabanlı bildirim tetiklenir; gerçek uygulamada `flutter_local_notifications` ile görsel bildirim gösterilebilir.

## PDF

`core/utils/pdf_generator.dart` dosyası Syncfusion PDF paketini kullanarak Türkçe karakter desteği sağlayan TrueType font ile fatura PDF'i üretir. `assets/fonts/Roboto-Regular.ttf` gibi bir font dosyasını `pubspec.yaml`'a eklemeyi unutmayın.

## Güvenlik

`JwtTokenManager`, SharedPreferences üzerinde JWT saklarken `exp` alanını kontrol eder; süresi dolan token'ı temizler. API çağrıları otomatik olarak `Authorization: Bearer` başlığı ile yapılır.

## Lisans

MIT
