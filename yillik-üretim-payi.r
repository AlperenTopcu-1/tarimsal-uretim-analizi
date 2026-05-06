# ── Paket kurulumu ────────────────────────────────────────────────────────────
pkgs <- c("ggplot2", "dplyr", "tidyr", "readxl", "scales", "ggtext")
for (p in pkgs) if (!require(p, character.only = TRUE))
  install.packages(p, repos = "https://cloud.r-project.org")

library(ggplot2)
library(dplyr)
library(tidyr)
library(readxl)
library(scales)
library(ggtext)

# ── Veri okuma ────────────────────────────────────────────────────────────────
# tahil: row 1 = baslik (Urun, 2014, 2015...), bu yuzden skip=0 + header kullaniliyor
tahil_raw <- read_excel("C:/Users/alper/Desktop/Tahil_ve_diger_miktarlari2014_2024.xlsx",
                        skip = 0, col_names = FALSE)
baslik     <- as.character(tahil_raw[1, ])
baslik[1]  <- "urun"
tahil      <- tahil_raw[-1, ]
colnames(tahil) <- baslik

# meyve & sebze: onceki scriptlerde skip=2 ile calisiyor
meyve <- read_excel("C:/Users/alper/Desktop/meyve_uretim.xlsx",           skip = 2)
sebze <- read_excel("C:/Users/alper/Desktop/Sebze_Uretim_2014_2024.xlsx", skip = 2)
colnames(meyve)[1] <- "urun"
colnames(sebze)[1] <- "urun"

# ── Temizleme fonksiyonu ──────────────────────────────────────────────────────
temizle <- function(df) {
  df <- as.data.frame(df)
  df <- df[!is.na(df$urun) & nchar(trimws(df$urun)) > 0, ]
  df <- df[!grepl("Toplam|Total|TOPLAM", df$urun, ignore.case = TRUE), ]
  yillar <- colnames(df)[grepl("^\\d{4}$", colnames(df))]
  df <- df[, c("urun", yillar)]
  df[yillar] <- lapply(df[yillar], function(x) as.numeric(as.character(x)))
  df$urun <- trimws(df$urun)
  df
}

meyve <- temizle(meyve)
sebze <- temizle(sebze)
tahil <- temizle(tahil)

# ── Sadece gerçek tahıl ürünlerini filtrele (baklagil/yağlı tohum dahil değil) ──
tahil_urunler <- c(
  "Buğday", "Mısır (dane)", "Çeltik", "Arpa", "Çavdar",
  "Yulaf", "Kaplıca", "Darı", "Kuşyemi", "Mahlut", "Tritikale", "Sorgum"
)
tahil <- tahil[trimws(tahil$urun) %in% tahil_urunler, ]

# ── Kategori bazında yıllık toplamları hesapla ────────────────────────────────
yil_toplami <- function(df, kategori_adi) {
  df %>%
    pivot_longer(cols = -urun, names_to = "yil", values_to = "miktar") %>%
    mutate(yil = as.integer(yil), miktar = replace_na(miktar, 0)) %>%
    group_by(yil) %>%
    summarise(toplam = sum(miktar, na.rm = TRUE), .groups = "drop") %>%
    mutate(kategori = kategori_adi)
}

df_meyve <- yil_toplami(meyve, "Meyve")
df_sebze <- yil_toplami(sebze, "Sebze")
df_tahil <- yil_toplami(tahil, "Tahıl")

df_combined <- bind_rows(df_meyve, df_sebze, df_tahil)

# ── Yüzde paylarını hesapla ───────────────────────────────────────────────────
df_pct <- df_combined %>%
  group_by(yil) %>%
  mutate(
    yil_toplam = sum(toplam),
    yuzde      = toplam / yil_toplam * 100
  ) %>%
  ungroup()

# ── Etiketler için: orta noktayı hesapla (label pozisyonu) ───────────────────
df_pct <- df_pct %>%
  arrange(yil, desc(kategori)) %>%
  group_by(yil) %>%
  mutate(
    kumulatif    = cumsum(yuzde),
    label_y      = kumulatif - yuzde / 2,
    label_text   = ifelse(yuzde >= 3.5, paste0(round(yuzde, 1), "%"), "")
  ) %>%
  ungroup()

# ── Kategori sıralaması ───────────────────────────────────────────────────────
df_pct$kategori <- factor(df_pct$kategori, levels = c("Meyve", "Sebze", "Tahıl"))

# ── Renk paleti ───────────────────────────────────────────────────────────────
renk_paleti <- c(
  "Tahıl" = "#9ECAE1",   # Açık mavi
  "Sebze" = "#4292C6",   # Orta mavi
  "Meyve" = "#084594"    # Koyu mavi
)

# ── Grafik ───────────────────────────────────────────────────────────────────
p <- ggplot(df_pct, aes(x = factor(yil), y = yuzde, fill = kategori)) +
  
  geom_bar(
    stat     = "identity",
    position = "stack",
    width    = 0.72,
    colour   = "#FFFFFF",
    linewidth = 0.5
  ) +
  
  # Yüzde etiketleri
  geom_text(
    aes(y = label_y, label = label_text),
    color    = "#FFFFFF",
    fontface = "bold",
    size     = 3.8
  ) +
  
  scale_fill_manual(
    values = renk_paleti,
    name   = "Tarım Kategorisi",
    guide  = guide_legend(
      reverse   = FALSE,
      keywidth  = unit(1.1, "cm"),
      keyheight = unit(0.65, "cm")
    )
  ) +
  
  scale_y_continuous(
    labels = function(x) paste0(x, "%"),
    breaks = seq(0, 100, 10),
    expand = c(0, 0),
    limits = c(0, 101)
  ) +
  
  labs(
    title    = "Tarım Kategorilerinin Yıllık Üretim Payı (2014–2024)",
    subtitle = "Meyve · Sebze · Tahıl — Yüzde dağılımı (ton bazında)",
    x        = NULL,
    y        = "Üretim Payı (%)",
    caption  = "Kaynak: T\u00fcrkiye \u0130statistik Kurumu (T\u00dc\u0130K)"
  ) +
  
  theme_minimal(base_size = 13) +
  theme(
    # Arka plan
    plot.background  = element_rect(fill = "#FFFFFF", color = NA),
    panel.background = element_rect(fill = "#FFFFFF", color = NA),
    
    # Başlık & Alt yazı
    plot.title    = element_text(color = "#0D1B2A", size = 17, face = "bold",
                                 margin = margin(b = 6)),
    plot.subtitle = element_text(color = "#2C3E50", size = 11,
                                 margin = margin(b = 16)),
    plot.caption  = element_text(color = "#2C3E50", size = 8.5, hjust = 1,
                                 margin = margin(t = 10)),
    
    # Eksen
    axis.text.x  = element_text(color = "#2C3E50", size = 11, face = "bold"),
    axis.text.y  = element_text(color = "#2C3E50", size = 10),
    axis.title.y = element_text(color = "#2C3E50", size = 10),
    
    # Grid
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_line(color = "#E2E8F0", linewidth = 0.4),
    panel.grid.minor   = element_blank(),
    
    # Lejant
    legend.position   = "top",
    legend.background = element_rect(fill = "#FFFFFF", color = NA),
    legend.text       = element_text(color = "#2C3E50", size = 11),
    legend.title      = element_text(color = "#2C3E50", size = 10),
    legend.key        = element_rect(fill = NA, color = NA),
    legend.margin     = margin(b = 6),
    
    plot.margin = margin(16, 20, 12, 16)
  )

print(p)

ggsave(
  "C:/Users/alper/Desktop/stacked_100_bar.pdf",
  plot   = p,
  width  = 13,
  height = 7.5,
  device = cairo_pdf,
  bg     = "#FFFFFF"
)

cat("✓ Grafik kaydedildi: C:/Users/alper/Desktop/stacked_100_bar.png\n")
