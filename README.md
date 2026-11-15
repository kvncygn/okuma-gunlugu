# Okuma Günlüğü (Flutter + Firebase)

`Okuma_Günlüğü___Mockup2.html` etkileşimli mockup'ının Flutter, Riverpod, GoRouter, Freezed ve Firebase (Auth + Cloud Firestore Offline Persistence) ile geliştirilmiş iOS/Android/Web uygulaması.

---

## 🚀 GitHub'dan ZIP İndirenler İçin Hızlı Başlangıç

Projeyi GitHub'dan **Download ZIP** diyerek indiren veya `git clone` ile çeken herkes, herhangi bir API anahtarına ihtiyaç duymadan **2 komutla** hemen çalıştırabilir:

1. ZIP dosyasını klasöre çıkarın ve klasörün içinde terminal (PowerShell / CMD / VS Code Terminal) açın.
2. Şu iki komutu çalıştırın:
   ```bash
   flutter pub get
   flutter run -d chrome
   ```
   *(Android emülatör veya telefon bağlıysa doğrudan `flutter run` yazabilirsiniz).*

> **Not:** `env.json` dosyası olmasa bile uygulama otomatik olarak **Yerel Test Modunda** (örnek kitaplar, kronometre, haftalık grafik, alıntılar ve canlı Google Books aramasıyla) tam etkileşimli açılır.

---

## 🧪 Birim Testlerini Çalıştırma

Mockup formüllerinin (yüzde hesabı, kalan gün tahmini, 30 günlük ortalama, ağırlıklı okuma hızı, seri ve öneri skorlama) testlerini çalıştırmak için:

```bash
flutter test
```

---

## 🔥 Ortak Firebase Veritabanına Bağlanma (İsteğe Bağlı)

Uygulamayı gerçek Cloud Firestore veritabanıyla çalıştırmak için:

1. Proje kök dizinindeki `env.example.json` dosyasını **`env.json`** adıyla kopyalayın (veya ekip arkadaşınızdan `env.json` dosyasını alıp proje ana klasörüne bırakın).
2. Uygulamayı şu komutla başlatın:
   ```bash
   flutter run -d chrome --dart-define-from-file=env.json
   ```
   *(Mobil cihazda: `flutter run --dart-define-from-file=env.json`)*

### Firestore Güvenlik Kurallarını Yayınlama
```bash
firebase deploy --only firestore:rules,firestore:indexes
```
