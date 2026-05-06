# 📊 Tarımsal Üretim Analizi
### Üretim Miktarı, Ürün Dağılımı ve Zamanla Değişim Analizi (2014–2024)

Bu çalışma, Yönetim Bilişim Sistemleri – Veri Görselleştirme dersi kapsamında hazırlanmıştır.  
Türkiye'nin tarımsal üretim verilerini (meyve, sebze, tahıl ve süs bitkileri) farklı görselleştirme teknikleriyle analiz etmektedir.

> **Hazırlayanlar:** Alperen Topcu · Serdar Bayar

---

## 📁 Grafikler

| Dosya | Grafik Türü | İçerik |
|-------|-------------|--------|
| `meyve_kod.r` | Gruplandırılmış Sütun Grafik | Türkiye'de en çok üretilen 5 meyve (2014–2024) |
| `kod.r` | Yüzey Alan Grafik | Tarım kategorilerinin yıllık üretim payı (Meyve / Sebze / Tahıl) |
| `kesme_kod.r` | Isı Haritası | Kesme çiçekleri üretim yoğunluğu (2014–2024) |
| `sebze.r` | Çizgi Grafik | En çok değişim gösteren 5 sebzenin üretimi (2014–2024) |
| `TAHİL_KOD.r` | Box Plot | En çok üretilen 5 tahılın dağılımı (2014–2024) |
| `kod.r` *(tarım alanı)* | Donut / Pasta Grafik | 2001 vs 2024 tarım alanı karşılaştırması |

---

## 📦 Kullanılan R Paketleri

```r
install.packages(c(
  "ggplot2", "dplyr", "tidyr", "readxl",
  "scales", "forcats", "ggrepel", "patchwork"
))
```

---

## 🗂️ Veri Kaynağı

Tüm veriler **TÜİK (Türkiye İstatistik Kurumu)**'nden alınmıştır.

🔗 [TÜİK – Bitkisel Üretim İstatistikleri](https://www.tuik.gov.tr)

Kullanılan veri setleri:

- `meyve_uretim.xlsx` — Meyve türlerine göre yıllık üretim miktarları
- `Sebze_Uretim_2014_2024.xlsx` — Sebze türlerine göre yıllık üretim miktarları
- `Sus_Bitkileri_uretim_2014_2024.xlsx` — Kesme çiçek ve süs bitkisi üretimi
- `Tahil_ve_diger_miktarlari2014_2024.xlsx` — Tahıl ve diğer tarla ürünleri
- `tarim_alan.xls` — Tarım alanlarının türe göre dağılımı (2001–2024)
