# 📊 Tarımsal Üretim Analizi
### Üretim Miktarı, Ürün Dağılımı ve Zamanla Değişim Analizi (2014–2024)

Bu çalışma, Yönetim Bilişim Sistemleri – Veri Görselleştirme dersi kapsamında hazırlanmıştır.  
Türkiye'nin tarımsal üretim verilerini (meyve, sebze, tahıl ve süs bitkileri) farklı görselleştirme teknikleriyle analiz etmektedir.

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

## ⚙️ Nasıl Çalıştırılır?

1. **Repoyu klonlayın**
   ```
   git clone https://github.com/AlperenTopcu-1/tarimsal-uretim-analizi.git
   ```

2. **Gerekli paketleri kurun** — R veya RStudio'da bir kez çalıştırın:
   ```r
   install.packages(c("ggplot2", "dplyr", "tidyr", "readxl", "scales", "ggtext", "stringr"))
   ```

3. **Veri dosyalarını proje klasörüne koyun** — Aşağıdaki 5 dosyanın `.R` kodlarıyla **aynı klasörde** olması gerekir:
   - `meyve_uretim.xlsx`
   - `Sebze_Uretim_2014_2024.xlsx`
   - `Sus_Bitkileri_uretim_2014_2024.xlsx`
   - `Tahil_ve_diger_miktarlari2014_2024.xlsx`
   - `tarim_alan.xls`

4. **Her `.R` dosyasında dosya yolunu kendi bilgisayarınıza göre güncelleyin:**
   ```r
   # Örnek: meyve_kod.r içinde bu satırı bulun ve kendi yolunuzu yazın
   ham_veri <- read_excel("C:/KENDI/YOLUNUZ/meyve_uretim.xlsx")
   ```

5. **İlgili `.R` dosyasını RStudio'da açıp çalıştırın** — Grafikler otomatik olarak masaüstüne PDF olarak kaydedilir.

> 💡 **İpucu:** En kolay yöntem, tüm `.R` ve veri dosyalarını aynı klasöre koyup RStudio'da o klasörü **Working Directory** olarak ayarlamaktır: `Session > Set Working Directory > To Source File Location`

---

## 🗂️ Veri Kaynağı

Tüm veriler **TÜİK (Türkiye İstatistik Kurumu)**'nden alınmıştır.

🔗 [TÜİK – Bitkisel Üretim İstatistikleri](https://veriportali.tuik.gov.tr/tr/press/53939)

Kullanılan Excel dosyaları:

- `meyve_uretim.xlsx` — Meyve türlerine göre yıllık üretim miktarları
- `Sebze_Uretim_2014_2024.xlsx` — Sebze türlerine göre yıllık üretim miktarları
- `Sus_Bitkileri_uretim_2014_2024.xlsx` — Kesme çiçek ve süs bitkisi üretimi
- `Tahil_ve_diger_miktarlari2014_2024.xlsx` — Tahıl ve diğer tarla ürünleri
- `tarim_alan.xls` — Tarım alanlarının türe göre dağılımı (2001–2024)
  > 📍 TÜİK → İstatistiksel Temalar → Tarım → Bitkisel Üretim İstatistikleri → Bitkisel Üretim ve Tarım Alanları → Tablolar ve Grafikler → **Tarım ve Orman Alanları**

> **📌 Not:** Bu repodaki Excel dosyaları, TÜİK'te ayrı ayrı yayımlanan tablolar tarafımdan birleştirilerek düzenlenmiştir. Orijinal verilere yukarıdaki bağlantıdan ulaşabilirsiniz.

---

## 👥 Hazırlayanlar

Bu proje, **Aksaray Üniversitesi** Yönetim Bilişim Sistemleri bölümü Veri Görselleştirme dersi kapsamında hazırlanmıştır.

| İsim | 
|------|
| Alperen Topcu |
| Serdar Bayar |
