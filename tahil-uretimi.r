# ============================================================
#  En Çok Üretilen 5 Tahıl – Box Plot (2014–2024)
#  Dosya: C:/Users/alper/Desktop/Tahil_ve_diger_miktarlari2014_2024.xlsx
# ============================================================

# ── 0. KÜTÜPHANE YOLU ve TMP (lockPath hatasını önler) ────────
kisa_lib <- "C:/Rlib"
kisa_tmp <- "C:/tmp"
for (d in c(kisa_lib, kisa_tmp)) if (!dir.exists(d)) dir.create(d, recursive = TRUE)
Sys.setenv(TMPDIR = kisa_tmp, TMP = kisa_tmp, TEMP = kisa_tmp)
.libPaths(c(kisa_lib, .libPaths()))
options(repos = c(CRAN = "https://cloud.r-project.org"))

# ── 1. PAKET KURULUMU ──────────────────────────────────────────
pkgs <- c("readxl", "dplyr", "tidyr", "ggplot2", "scales")
for (p in pkgs) {
  if (!requireNamespace(p, quietly = TRUE))
    install.packages(p, lib = kisa_lib)
}
library(readxl); library(dplyr); library(tidyr)
library(ggplot2); library(scales)

# ── 2. VERİYİ OKU ─────────────────────────────────────────────
dosya_yolu <- "C:/Users/alper/Desktop/Tahil_ve_diger_miktarlari2014_2024.xlsx"

# --- TANI: Excel'in ilk 5 ham satırını sütun adı olmadan oku ---
cat("=== HAM İLK 5 SATIR (col_names=FALSE) ===\n")
ham_tani <- read_excel(dosya_yolu, sheet = 1, col_names = FALSE, n_max = 5)
print(ham_tani)

# Yılları ilk satırda ara: satır-1'de 2014..2024 içeren sütun var mı?
yil_satir <- as.numeric(unlist(ham_tani[1, ]))
yil_sutun_idx <- which(!is.na(yil_satir) & yil_satir >= 2014 & yil_satir <= 2024)

if (length(yil_sutun_idx) > 0) {
  skip_n <- 0   # yıllar 1. satırda → başlık olarak oku
} else {
  yil_satir2 <- as.numeric(unlist(ham_tani[2, ]))
  yil_sutun_idx2 <- which(!is.na(yil_satir2) & yil_satir2 >= 2014 & yil_satir2 <= 2024)
  skip_n <- if (length(yil_sutun_idx2) > 0) 1 else 0
}
cat("\n>>> Kullanılacak skip:", skip_n, "<<<\n")

ham_veri <- read_excel(dosya_yolu, sheet = 1, skip = skip_n)
names(ham_veri) <- trimws(as.character(names(ham_veri)))

cat("\n=== Sütun adları ===\n");  print(names(ham_veri))
cat("\n=== İlk 8 satır ===\n"); print(head(ham_veri, 8))

# ── 3. SÜTUN TESPİTİ ──────────────────────────────────────────
tahil_sutun   <- names(ham_veri)[1]                          # 1. sütun = tahıl adı
yil_sayisal   <- suppressWarnings(as.numeric(names(ham_veri)))
yil_mask      <- !is.na(yil_sayisal) & yil_sayisal >= 2014 & yil_sayisal <= 2024
yil_sutunlari <- names(ham_veri)[yil_mask]

cat("\n=== Tespit edilen yıl sütunları ===\n"); print(yil_sutunlari)

if (length(yil_sutunlari) == 0)
  stop(paste("Yıl sütunları bulunamadı! Mevcut sütunlar:",
             paste(names(ham_veri), collapse = " | ")))

# ── 4. TÜM SATIR ADLARINI GÖSTER (teşhis) ─────────────────────
cat("\n=== Excel'deki TÜM tahıl/satır isimleri ===\n")
print(ham_veri[[1]])

# ── 5. UZUN FORMATA ÇEVİR ─────────────────────────────────────
# NOT: Tüm yıl sütunlarını önce character'a çevir (karışık tip hatasını önler)
ham_veri_str <- ham_veri %>%
  mutate(across(all_of(yil_sutunlari), as.character))

uzun_veri <- ham_veri_str %>%
  select(all_of(c(tahil_sutun, yil_sutunlari))) %>%
  rename(Tahil = 1) %>%
  mutate(Tahil = trimws(as.character(Tahil))) %>%
  filter(!is.na(Tahil), Tahil != "", Tahil != "NA") %>%
  # 'Tahıllar' genel toplam satırını ve diğer toplam satırlarını çıkar
  filter(!grepl("^Tah\u0131llar$|toplam|genel|total|subtotal|ara top",
                Tahil, ignore.case = TRUE, perl = TRUE)) %>%
  pivot_longer(
    cols             = all_of(yil_sutunlari),
    names_to         = "Yil",
    values_to        = "Uretim"
  ) %>%
  mutate(
    Yil    = as.integer(Yil),
    Uretim = suppressWarnings(as.numeric(Uretim))
  ) %>%
  filter(!is.na(Uretim), Uretim > 0)

cat("\n=== Temizlenmiş veri (ilk 10 satır) ===\n")
print(head(uzun_veri, 10))
cat("Toplam satır:", nrow(uzun_veri), "\n")

# ── 6. EN ÇOK ÜRETİLEN 5 TAHILI BUL ──────────────────────────
top5_tahillar <- uzun_veri %>%
  group_by(Tahil) %>%
  summarise(Toplam = sum(Uretim, na.rm = TRUE), .groups = "drop") %>%
  arrange(desc(Toplam)) %>%
  slice_head(n = 5) %>%
  pull(Tahil)

cat("\n=== En çok üretilen 5 tahıl ===\n"); print(top5_tahillar)

grafik_veri <- uzun_veri %>%
  filter(Tahil %in% top5_tahillar) %>%
  mutate(
    Tahil = factor(Tahil, levels = top5_tahillar),
    Yil   = factor(Yil)
  )

# ── VERİ DOĞRULAMA ────────────────────────────────────────────────────────────
cat("\n")
cat(strrep("=", 70), "\n")
cat("  VERİ DOĞRULAMA: GRAFİKTEKİ DEĞERLER (ton)\n")
cat(strrep("=", 70), "\n")

# Geniş format: satır=Tahıl, sütun=Yıl
dogrulama_genis <- grafik_veri %>%
  mutate(Yil = as.integer(as.character(Yil))) %>%
  arrange(Tahil, Yil) %>%
  pivot_wider(names_from = Yil, values_from = Uretim)

# Binlik ayracı ile yazdır
dogrulama_fmt <- dogrulama_genis %>%
  mutate(across(where(is.numeric),
                ~ formatC(., format = "f", digits = 0, big.mark = ".")))

print(as.data.frame(dogrulama_fmt), row.names = FALSE)

# Toplam ve ortalama özet
cat("\n--- Özet İstatistikler (grafik verisinden) ---\n")
ozet <- grafik_veri %>%
  mutate(Yil = as.integer(as.character(Yil))) %>%
  group_by(Tahil) %>%
  summarise(
    Min_ton     = formatC(min(Uretim),  format="f", digits=0, big.mark="."),
    Medyan_ton  = formatC(median(Uretim), format="f", digits=0, big.mark="."),
    Ort_ton     = formatC(mean(Uretim),  format="f", digits=0, big.mark="."),
    Max_ton     = formatC(max(Uretim),  format="f", digits=0, big.mark="."),
    Toplam_ton  = formatC(sum(Uretim),  format="f", digits=0, big.mark="."),
    .groups = "drop"
  )
print(as.data.frame(ozet), row.names = FALSE)

# Excel ham değerleriyle çapraz kontrol
cat("\n--- Excel Ham Değerleri (ham_veri) ---\n")
ham_kontrol <- ham_veri %>%
  rename(Tahil = 1) %>%
  mutate(Tahil = trimws(as.character(Tahil))) %>%
  filter(Tahil %in% top5_tahillar) %>%
  select(Tahil, all_of(yil_sutunlari))
print(as.data.frame(ham_kontrol), row.names = FALSE)

cat(strrep("=", 70), "\n")
cat("  Yukarıdaki iki tablo aynıysa grafik verileri Excel ile UYUŞUYOR ✓\n")
cat(strrep("=", 70), "\n\n")


# ── 7. BOX PLOT GRAFİĞİ ───────────────────────────────────────
# NOT: Her tahıl için yılda tek bir değer var.
# Box plot'ta her tahılın 11 yıllık değerleri kutu oluşturur.
# X = Tahıl (facet yok), Y = Üretim, renk = Tahıl
# Her kutunun içindeki 11 nokta = 2014-2024 yıllık değerleri
palet <- rep("#64B5F6", 5)

# ── 7a. BOX PLOT: X=Tahıl, dağılım=11 yıl ──────────────────
p_box <- ggplot(grafik_veri,
                aes(x    = Tahil,
                    y    = Uretim,
                    fill = Tahil,
                    colour = Tahil)) +
  
  geom_boxplot(
    alpha         = 0.45,
    linewidth     = 0.7,
    outlier.shape = 21,
    outlier.size  = 2.5,
    outlier.stroke = 0.5,
    width         = 0.55
  ) +
  
  # Her yılın değerini jitter ile üste çiz
  geom_jitter(
    aes(label = as.character(Yil)),
    width  = 0.18,
    size   = 2.5,
    alpha  = 0.85,
    shape  = 21,
    colour = "white",
    stroke = 0.4
  ) +
  
  # Ortalama noktası (elmas)
  stat_summary(
    fun    = mean,
    geom   = "point",
    shape  = 23,
    size   = 4,
    colour = "white",
    fill   = "white",
    stroke = 0.8
  ) +
  
  scale_fill_manual(values   = palet, name = "Tahıl") +
  scale_colour_manual(values = palet, name = "Tahıl") +
  
  scale_y_continuous(
    labels = label_number(big.mark = ".", decimal.mark = ",",
                          scale = 1e-6, suffix = " M ton"),
    expand = expansion(mult = c(0.03, 0.08))
  ) +
  
  labs(
    title    = "T\u00fcrkiye'de En \u00c7ok \u00dcretilen 5 Tah\u0131l \u2013 Box Plot (2014\u20132024)",
    subtitle = "Her kutu 11 y\u0131l\u0131n da\u011f\u0131l\u0131m\u0131n\u0131 g\u00f6stermektedir \u2022 Her nokta bir y\u0131l \u2022 \u25c7 ortalama",
    x        = "Tah\u0131l",
    y        = "\u00dcretim Miktar\u0131",
    caption  = "Kaynak: T\u00fcrkiye \u0130statistik Kurumu (TU\u0130K)"
  ) +
  
  theme_minimal(base_size = 13) +
  theme(
    plot.title         = element_text(face = "bold", size = 16,
                                      hjust = 0.5, colour = "#1a1a2e"),
    plot.subtitle      = element_text(size = 10.5, hjust = 0.5, colour = "grey45"),
    plot.caption       = element_text(size = 8,  hjust = 1,   colour = "grey60"),
    plot.background    = element_rect(fill = "#fafafa", colour = NA),
    plot.margin        = margin(14, 18, 14, 18),
    panel.grid.major.x = element_blank(),
    panel.grid.minor   = element_blank(),
    panel.grid.major.y = element_line(colour = "grey88", linetype = "dashed"),
    axis.text.x        = element_text(size = 11, colour = "grey20", face = "bold"),
    axis.text.y        = element_text(size = 10, colour = "grey25"),
    axis.title         = element_text(colour = "grey30", face = "bold"),
    legend.position    = "none"          # renkler zaten x ekseninde belli
  )

# ── 7b. ÇİZGİ GRAFİĞİ: X=Yıl, Y=Üretim, renk=Tahıl ────────
p_cizgi <- ggplot(grafik_veri,
                  aes(x     = as.integer(as.character(Yil)),
                      y     = Uretim,
                      colour = Tahil,
                      group  = Tahil)) +
  
  geom_line(linewidth = 1.1, alpha = 0.85) +
  geom_point(aes(fill = Tahil), shape = 21, size = 3,
             colour = "white", stroke = 0.8) +
  
  scale_colour_manual(values = palet, name = "Tah\u0131l") +
  scale_fill_manual(values   = palet, name = "Tah\u0131l") +
  
  scale_x_continuous(breaks = 2014:2024, labels = 2014:2024) +
  scale_y_continuous(
    labels = label_number(big.mark = ".", decimal.mark = ",",
                          scale = 1e-6, suffix = " M ton"),
    expand = expansion(mult = c(0.03, 0.08))
  ) +
  
  labs(
    title    = "Y\u0131llara G\u00f6re \u00dcretim Trendi (2014\u20132024)",
    subtitle = "Top 5 tah\u0131l\u0131n y\u0131ll\u0131k \u00fcretim de\u011fi\u015fimi",
    x = "Y\u0131l", y = "\u00dcretim Miktar\u0131",
    caption  = "Kaynak: T\u00fcrkiye \u0130statistik Kurumu (TU\u0130K)"
  ) +
  
  theme_minimal(base_size = 13) +
  theme(
    plot.title         = element_text(face = "bold", size = 16,
                                      hjust = 0.5, colour = "#1a1a2e"),
    plot.subtitle      = element_text(size = 10.5, hjust = 0.5, colour = "grey45"),
    plot.caption       = element_text(size = 8, hjust = 1, colour = "grey60"),
    plot.background    = element_rect(fill = "#fafafa", colour = NA),
    plot.margin        = margin(14, 18, 14, 18),
    panel.grid.minor   = element_blank(),
    panel.grid.major   = element_line(colour = "grey88", linetype = "dashed"),
    axis.text.x        = element_text(size = 10, colour = "grey25",
                                      angle = 30, hjust = 1),
    axis.text.y        = element_text(size = 10, colour = "grey25"),
    axis.title         = element_text(colour = "grey30", face = "bold"),
    legend.position    = "bottom",
    legend.title       = element_text(face = "bold", size = 11),
    legend.text        = element_text(size = 10),
    legend.key.size    = unit(0.9, "lines")
  )

print(p_box)
print(p_cizgi)

p <- p_box   # kayıt için ana grafik

print(p)

# ── 8. PDF OLARAK KAYDET ──────────────────────────────────────
ggsave(
  filename = "C:/Users/alper/Desktop/tahil_boxplot.pdf",
  plot     = p,
  width    = 18,
  height   = 10,
  device   = cairo_pdf,
  bg       = "#fafafa"
)

cat("\n✓ Grafik kaydedildi: C:/Users/alper/Desktop/tahil_boxplot.pdf\n")

