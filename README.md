# Hesap Makinesi / Calculator

15 dilde çalışan, Flutter ile yazılmış çok amaçlı hesap makinesi.

## Özellikler

- **Hesap makinesi:** Basit ve bilimsel mod (sin/cos/tan ve tersleri, ln, log, √, ∛, xʸ, x!, π, e), DEG/RAD seçimi, canlı sonuç önizleme, `9+5% = 9,45` tarzı yüzde hesabı, işlem geçmişi. Sonuca uzun basınca kopyalanır.
- **Birim dönüştürücü:** Uzunluk, alan, hacim, ağırlık, sıcaklık, hız, zaman, veri (döviz kuru bilerek yok).
- **Yüzde:** X'in %Y'si, X Y'nin yüzde kaçı, yüzde değişim.
- **İndirim:** İndirim + isteğe bağlı vergi.
- **Bahşiş ve bölüşme:** Kişi başı toplam ve bahşiş.
- **Kredi:** Eşit taksit ve eşit anapara, aylık ödeme planı tablosu.
- **Tarih:** İki tarih arası fark (yıl/ay/gün), tarihe gün ekleme/çıkarma.
- **Vücut kitle indeksi:** Metrik ve İngiliz ölçü birimi.
- **Ayarlar:** Dil, tema (sistem/açık/koyu), geçmişi temizleme.

## Diller

İngilizce, Çince (basitleştirilmiş), Hintçe, İspanyolca, Arapça, Fransızca, Bengalce, Portekizce, Rusça, Urduca, Endonezce, Almanca, Japonca, Türkçe, Korece.

- Uygulama telefonun dilini kullanır. Telefonun dili bu 15 dilden biri değilse **İngilizce** açılır.
- Dil, ana ekrandaki 🌐 düğmesinden veya Ayarlar'dan değiştirilebilir. Seçim kaydedilir. "Sistem varsayılanı" seçilirse tekrar telefonun diline döner.
- Android 13 ve üzeri sürümlerde dil, telefonun *Ayarlar → Uygulamalar → Dil* menüsünden de seçilebilir.
- Uygulamanın ana ekrandaki adı da dile göre değişir: Hesap Makinesi, Calculator, Rechner, 電卓 vb.
- Arapça ve Urducada arayüz sağdan sola akar. Tuş takımı ve matematik ifadeleri her dilde soldan sağa kalır.
- Sayılar her dilin kendi ayırıcılarıyla gösterilir (`1.234,5` / `1,234.5` / Hintçede `12,34,567`). Rakamlar her dilde 0–9'dur.

## APK / AAB oluşturma

Gereken: [Flutter SDK](https://docs.flutter.dev/get-started/install) ve Android Studio (Android SDK için).

```bash
flutter pub get
flutter test                   # testleri çalıştır
flutter run                    # bağlı telefonda/emülatörde çalıştır
flutter build apk --release    # build/app/outputs/flutter-apk/app-release.apk
flutter build appbundle        # Play Store için: build/app/outputs/bundle/release/app-release.aab
```

### Play Store'a yüklemeden önce

1. **Paket adı:** `com.alberlevi.hesap_makinesi`. Değiştirmek istersen `android/app/build.gradle.kts` dosyasındaki `applicationId` ve `namespace` değerlerini, ayrıca `MainActivity.kt` dosyasının bulunduğu klasörü güncelle. Paket adı Play Store'a ilk yüklemeden sonra değiştirilemez.
2. **İmzalama:** Şu an release derlemesi debug anahtarıyla imzalanıyor. Kendi anahtarını oluşturup `build.gradle.kts` içine ekle: <https://docs.flutter.dev/deployment/android#sign-the-app>
3. **Sürüm:** `pubspec.yaml` içindeki `version: 1.0.0+1` değerini artır. Uygulama içinde gösterilen sürüm `lib/screens/settings_screen.dart` dosyasındaki `appVersion` sabitidir.
4. **Çeviriler:** Yayından önce her dilin anadili konuşan biri tarafından kontrol edilmesi önerilir, özellikle Bengalce, Urduca ve Hintçe.
5. **iOS:** Uygulama adı her dilde "Calculator" olarak görünür. iOS'ta da dile göre değişen ad için Xcode'da `InfoPlist.strings` eklenmelidir.

## Çevirileri düzenleme

Metinler `tool/l10n/<dil>.py` dosyalarında. Bir metni değiştirdikten sonra şunları çalıştır:

```bash
python3 tool/gen_l10n.py   # ARB dosyalarını ve Android uygulama adlarını üretir, eksik anahtar varsa hata verir
flutter gen-l10n
```

Yeni bir dil eklemek için `tool/l10n/` klasörüne dosya ekle, sonra `tool/gen_l10n.py` içindeki `LANGS` listesini ve `lib/app_languages.dart` dosyasını güncelle.

## Proje yapısı

```
lib/
  core/        hesaplama mantığı (ifade çözücü, kredi, birimler, tarih, sayı biçimi)
  screens/     ekranlar
  widgets/     ortak bileşenler, yan menü, dil seçici
  l10n/        üretilmiş çeviri dosyaları (elle düzenleme)
tool/          çeviri kaynakları ve üretici betik
test/          birim testleri + 15 dilde tüm ekranların taşma testi
```
