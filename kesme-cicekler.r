# ============================================================
# Kesme Cicekleri Uretim Isi Haritasi (Heat Map) -- 2014-2024
# Veri: Sus_Bitkileri_uretim_2014_2024.xlsx
# ============================================================



# --- Gerekli kütüphaneler ---
if (!require("readxl"))   install.packages("readxl",   repos = "https://cloud.r-project.org")
if (!require("tidyr"))    install.packages("tidyr",    repos = "https://cloud.r-project.org")
if (!require("dplyr"))    install.packages("dplyr",    repos = "https://cloud.r-project.org")
if (!require("ggplot2"))  install.packages("ggplot2",  repos = "https://cloud.r-project.org")
if (!require("scales"))   install.packages("scales",   repos = "https://cloud.r-project.org")
if (!require("stringr"))  install.packages("stringr",  repos = "https://cloud.r-project.org")

library(readxl)
library(tidyr)
library(dplyr)
library(ggplot2)
library(scales)
library(stringr)

# --- Veriyi oku ---
dosya_yolu <- "C:/Users/alper/Desktop/Sus_Bitkileri_uretim_2014_2024.xlsx"
df_raw <- read_excel(dosya_yolu, sheet = 1)

# Sutun adini standartlastir
names(df_raw)[1] <- "Kategori"

# --- Encoding temizligi (Turkce karakterler icin) ---
# Excel'den gelen stringleri gecerli UTF-8'e donustur
df_raw[["Kategori"]] <- iconv(df_raw[["Kategori"]],
                              from = "", to = "UTF-8", sub = "byte")

# --- Sadece belirtilen 18 kesme cicek turunu dahil et ---
# Not: Pattern'lar ASCII-safe; Turkce ozel karakterler yerine kismi esleme kullanildi
#   mbul   → Sümbül
#   ebboy  → Şebboy
#   ris    → İris  (Fresia'da "ris" yok; Lisianthus'ta da yok)
#   G.l    → Gül   (perl regex: G + herhangi bir kar + l)

dahil_pattern <- paste(c(
  "Karanfil",    # Karanfil
  "Gerbera",     # Gerbera
  "G.l",         # Gül (kesme) — perl regex
  "Krizantem",   # Kasimpati (Krizantem)
  "Fresia",      # Fresia
  "Lale",        # Lale
  "Solidago",    # Solidago (Altinbasak)
  "Gypsophilla", # Gypsophilla
  "Nergiz",      # Nergiz
  "Gladiol",     # Glayöl (Gladiol)
  "Lisianthus",  # Lisianthus
  "Lilyum",      # Lilyum (Zambak)
  "mbul",        # Sümbül
  "ebboy",       # Sebboy (Gillyflower)
  "Anemon",      # Anemon (Manisa Lalesi)
  "ris",         # iris / Iris
  "Orkide",      # Orkide
  "Statice"      # Statice
), collapse = "|")

df_cicek <- df_raw %>%
  filter(
    grepl(dahil_pattern, Kategori, ignore.case = TRUE, perl = TRUE),
    !grepl("Toplam", Kategori, ignore.case = TRUE)  # ara toplam satirlarini cikar
  )

# Kategori isimlerini kisalt (uzun olanlari kirp)
df_cicek <- df_cicek %>%
  mutate(
    Kategori = str_trim(Kategori),
    Kategori = ifelse(nchar(Kategori) > 35,
                      paste0(substr(Kategori, 1, 33), "..."),
                      Kategori)
  )

# --- Uzun formata çevir ---
yillar <- as.character(2014:2024)
df_long <- df_cicek %>%
  select(Kategori, all_of(yillar)) %>%
  pivot_longer(cols = all_of(yillar),
               names_to = "Yil",
               values_to = "Uretim") %>%
  mutate(
    Yil    = as.integer(Yil),
    Uretim = as.numeric(Uretim)
  )

# --- Toplam üretime göre türleri sırala (yüksekten düşüğe) ---
siralama <- df_long %>%
  group_by(Kategori) %>%
  summarise(Toplam = sum(Uretim, na.rm = TRUE), .groups = "drop") %>%
  arrange(Toplam)   # ggplot y-ekseni aşağıdan yukarı okur

df_long$Kategori <- factor(df_long$Kategori,
                           levels = siralama$Kategori)

# --- Z-score normalleştirme (satır bazlı — her tür kendi içinde) ---
df_long <- df_long %>%
  group_by(Kategori) %>%
  mutate(Uretim_scaled = scale(Uretim)[, 1]) %>%
  ungroup()

# --- Milyon biriminde etiket için ham değer ---
df_long <- df_long %>%
  mutate(Etiket = ifelse(Uretim >= 1e6,
                         paste0(round(Uretim / 1e6, 1), "M"),
                         ifelse(Uretim >= 1e3,
                                paste0(round(Uretim / 1e3, 0), "B"),
                                as.character(round(Uretim, 0)))))

# ============================================================
# HEAT MAP — Normalleştirilmiş (satır bazlı z-score)
# ============================================================
p <- ggplot(df_long, aes(x = factor(Yil), y = Kategori, fill = Uretim_scaled)) +

  geom_tile(color = "white", linewidth = 0.5) +

  # Hücre içi değer etiketi (Açık renklerde siyah, koyu renklerde beyaz metin)
  geom_text(aes(label = Etiket, color = Uretim_scaled > 0.5),
            size = 2.6, fontface = "bold", show.legend = FALSE) +

  scale_color_manual(values = c("TRUE" = "white", "FALSE" = "#111111")) +

  # Renk paleti: Mavi ve tonları
  scale_fill_gradient(
    low      = "#e3f2fd",   # açık mavi  → düşük
    high     = "#011f4b",   # koyu mavi  → yüksek
    name     = "Z-Skor\n(Tur Ici\nNormalize)",
    guide    = guide_colorbar(
      barheight = 10,
      barwidth  = 0.8,
      title.position = "top"
    )
  ) +

  scale_x_discrete(expand = c(0, 0)) +
  scale_y_discrete(expand = c(0, 0)) +

  labs(
    title    = "Kesme Cicekleri Uretim Isi Haritasi (2014-2024)",
    subtitle = "Turkiye | 2014-2024  (Hucreler: gercek uretim miktari; M=milyon, B=bin adet/dal)",
    caption  = "Kaynak: Turkiye Istatistik Kurumu (TUIK)",
    x        = "Yil",
    y        = NULL
  ) +

  theme_minimal(base_size = 11) +
  theme(
    plot.title        = element_text(face = "bold", size = 15, hjust = 0,
                                     color = "#1a1a2e", margin = margin(b = 4)),
    plot.subtitle     = element_text(size = 8.5, color = "#444", margin = margin(b = 10)),
    plot.caption      = element_text(size = 7, color = "#888", hjust = 0),
    plot.background   = element_rect(fill = "#f8f9fa", color = NA),
    panel.background  = element_rect(fill = "#f8f9fa", color = NA),
    panel.grid        = element_blank(),
    axis.text.x       = element_text(face = "bold", size = 9, color = "#333"),
    axis.text.y       = element_text(size = 8.5, color = "#222"),
    axis.ticks        = element_blank(),
    legend.title      = element_text(size = 8, face = "bold"),
    legend.text       = element_text(size = 7.5),
    plot.margin       = margin(15, 15, 10, 15)
  )

# --- Kaydet ---
ggsave(
  filename = "C:/Users/alper/Desktop/kesme_cicek_heatmap.pdf",
  plot     = p,
  width    = 14,
  height   = 8,
  device   = cairo_pdf,
  bg       = "#f8f9fa"
)

message("✅ Heat map kaydedildi: C:/Users/alper/Desktop/kesme_cicek_heatmap.pdf")

# Ayrıca ekranda göster
print(p)
