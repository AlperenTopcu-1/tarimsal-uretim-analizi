# ============================================================
# Türkiye Sebze Üretim Miktarları (2014-2024)
# En Çok Değişim Gösteren 5 Sebze - Noktasal Çizgi Grafiği
# Kaynak: Türkiye İstatistik Kurumu (TÜİK)
# ============================================================

# Türkçe karakter sorunu için locale ayarı (Burası eklendi)
Sys.setlocale("LC_ALL", "Turkish")

# Gerekli paketler
library(readxl)
library(ggplot2)
library(tidyr)
library(dplyr)

# -------------------------------------------------------
# 1. VERİYİ DOSYADAN OKU
# -------------------------------------------------------
dosya_yolu <- "C:/Users/alper/Desktop/Sebze_Uretim_2014_2024.xlsx"

ham_veri <- read_excel(dosya_yolu, skip = 1)  # İlk satır "Birim: Ton" → atla

# Sütun adlarını düzenle
yil_sutunlari <- as.numeric(ham_veri[1, -1])   # 2014, 2015, ..., 2024
colnames(ham_veri) <- c("Sebze", as.character(yil_sutunlari))
veri <- ham_veri[-1, ]                          # Yıl satırını çıkar

# Sayısal sütunları dönüştür
yil_cols <- as.character(2014:2024)
veri[yil_cols] <- lapply(veri[yil_cols], as.numeric)

# -------------------------------------------------------
# 2. EN ÇOK DEĞİŞİM GÖSTEREN 5 SEBZEYİ BELİRLE
#    (Domates listede OLMALI)
# -------------------------------------------------------
veri_tam <- veri %>%
  filter(!is.na(`2014`) & !is.na(`2024`)) %>%
  mutate(mutlak_degisim = abs(`2024` - `2014`)) %>%
  arrange(desc(mutlak_degisim))

top5 <- veri_tam %>%
  filter(Sebze == "Domates") %>%
  bind_rows(
    veri_tam %>%
      filter(Sebze != "Domates") %>%
      slice_head(n = 4)
  )

cat("Seçilen 5 sebze:\n")
print(top5 %>% select(Sebze, `2014`, `2024`, mutlak_degisim))

# -------------------------------------------------------
# 3. UZUN FORMATA ÇEVİR
# -------------------------------------------------------
uzun <- top5 %>%
  select(Sebze, all_of(yil_cols)) %>%
  pivot_longer(cols = all_of(yil_cols), names_to = "Yil", values_to = "Miktar") %>%
  mutate(
    Yil   = as.integer(Yil),
    Sebze = factor(Sebze, levels = top5$Sebze)
  )

# -------------------------------------------------------
# 4. RENK PALETİ (Açık Mavi Tonları)
# -------------------------------------------------------
n_sebze   <- nrow(top5)
mavi_renk <- colorRampPalette(c("#0D47A1", "#B3E5FC"))(n_sebze)
names(mavi_renk) <- levels(uzun$Sebze)

# -------------------------------------------------------
# 5. GRAFİK
# -------------------------------------------------------
p <- ggplot(uzun, aes(x = Yil, y = Miktar / 1000,
                      color = Sebze, group = Sebze)) +
  geom_line(linetype = "dashed", linewidth = 0.9, alpha = 0.85) +
  geom_point(size = 4, shape = 21, fill = "white", stroke = 1.8) +
  scale_color_manual(values = mavi_renk) +
  scale_x_continuous(breaks = 2014:2024) +
  scale_y_continuous(
    labels  = function(x) format(x, big.mark = ".", decimal.mark = ",",
                                 scientific = FALSE),
    expand  = expansion(mult = c(0.05, 0.1))
  ) +
  labs(
    title    = "Türkiye'de En Çok Değişim Gösteren 5 Sebzenin Üretimi (2014-2024)",
    subtitle = "Üretim Miktarı (Bin Ton)",
    x        = "Yıl",
    y        = "Üretim Miktarı (Bin Ton)",
    color    = "Sebze",
    caption  = "Kaynak: Türkiye İstatistik Kurumu (TÜİK)"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    # 'sans' veya 'Arial' gibi standart ve Türkçe uyumlu font belirtiyoruz
    text               = element_text(family = "sans"),
    plot.title         = element_text(face = "bold", size = 14, color = "#1A237E",
                                      margin = margin(b = 6)),
    plot.subtitle      = element_text(size = 11, color = "#455A64",
                                      margin = margin(b = 10)),
    plot.caption       = element_text(size = 10, color = "#1A237E", hjust = 1,
                                      face = "bold.italic", margin = margin(t = 12)),
    axis.text.x        = element_text(angle = 45, hjust = 1, size = 10),
    axis.text.y        = element_text(size = 9),
    axis.title         = element_text(size = 11, color = "#37474F"),
    panel.grid.major.x = element_blank(),
    panel.grid.minor   = element_blank(),
    panel.grid.major.y = element_line(color = "#DDEEFF", linewidth = 0.5),
    legend.position    = "right",
    legend.title       = element_text(face = "bold", size = 10),
    legend.text        = element_text(size = 9),
    plot.background    = element_rect(fill = "#EBF5FB", color = NA),
    panel.background   = element_rect(fill = "#F7FBFF", color = NA),
    plot.margin        = margin(15, 20, 15, 15)
  )

# -------------------------------------------------------
# 6. KAYDET
# -------------------------------------------------------
cikti <- "C:/Users/alper/Desktop/sebze_uretim_2014_2024.pdf"
ggsave(
  "C:/Users/alper/Desktop/sebze_uretim_2014_2024.pdf",
  plot   = p,
  width  = 14,
  height = 8,
  device = cairo_pdf,
  bg     = "#EBF5FB"
)
message("Grafik kaydedildi: ", cikti)

print(p)
