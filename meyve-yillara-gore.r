# ============================================================
#  Turkiye Meyve Uretim Miktarlari (2014-2024)
#  Gruplandirilmis Sutun Grafigi
# ============================================================

if (!require("readxl"))  install.packages("readxl",  repos = "https://cran.r-project.org")
if (!require("ggplot2")) install.packages("ggplot2", repos = "https://cran.r-project.org")
if (!require("dplyr"))   install.packages("dplyr",   repos = "https://cran.r-project.org")
if (!require("tidyr"))   install.packages("tidyr",   repos = "https://cran.r-project.org")
if (!require("scales"))  install.packages("scales",  repos = "https://cran.r-project.org")

library(readxl); library(ggplot2); library(dplyr); library(tidyr); library(scales)

# 1. VERI OKUMA
ham_veri <- read_excel("C:/Users/alper/Desktop/meyve_uretim.xlsx", col_names = FALSE, skip = 2)
yillar   <- as.character(2014:2024)
colnames(ham_veri) <- c("Urun", yillar)

# 2. FILTRE
# Turkce karakterlerin tamami Unicode kacis dizisi olarak yazildi
uzum      <- "\u00dcz\u00fcm"       # Uzum
elma      <- "Elma"
portakal  <- "Portakal"
zeytin    <- "Zeytin"
mandalina <- "Mandalina"

hedef_meyveler <- c(uzum, elma, portakal, zeytin, mandalina)

df_genis <- ham_veri |>
  filter(Urun %in% hedef_meyveler) |>
  mutate(across(all_of(yillar), as.numeric))

# 3. GENIS -> UZUN FORMAT
df_uzun <- df_genis |>
  pivot_longer(cols = all_of(yillar), names_to = "Yil", values_to = "Uretim_Ton") |>
  mutate(
    Yil  = as.integer(Yil),
    Urun = factor(Urun, levels = hedef_meyveler)
  )

# 4. RENK PALETI (yillara gore mavi tonlari)
yil_renkleri        <- colorRampPalette(c("#cfe2f3", "#08306b"))(11)
names(yil_renkleri) <- as.character(2014:2024)

# 5. GRAFIK
grafik <- ggplot(df_uzun, aes(x = Urun, y = Uretim_Ton, fill = factor(Yil))) +
  geom_bar(
    stat      = "identity",
    position  = position_dodge(width = 0.85),
    width     = 0.8,
    colour    = "white",
    linewidth = 0.15
  ) +
  scale_y_continuous(
    labels = label_number(scale = 1e-6, suffix = " M ton", accuracy = 0.1),
    expand = expansion(mult = c(0, 0.05))
  ) +
  scale_x_discrete(expand = expansion(add = 0.6)) +
  scale_fill_manual(
    values = yil_renkleri,
    name   = "Y\u0131l"
  ) +
  labs(
    title    = "T\u00fcrkiye'de En \u00c7ok \u00dcretilen 5 Meyve (2014\u20132024)",
    subtitle = "Y\u0131ll\u0131k \u00fcretim miktarlar\u0131 \u2013 ton cinsinden",
    x        = NULL,
    y        = "\u00dcretim Miktar\u0131",
    caption  = "Kaynak : T\u00fcrkiye \u0130statistik Kurumu(TUIK)"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title         = element_text(face = "bold", size = 15, hjust = 0, margin = margin(b = 4)),
    plot.subtitle      = element_text(colour = "grey40", size = 11, hjust = 0, margin = margin(b = 10)),
    plot.caption       = element_text(hjust = 1, colour = "grey50", size = 9,
                                      face = "italic", margin = margin(t = 10)),
    axis.text.x        = element_text(size = 12, face = "bold"),
    axis.text.y        = element_text(size = 10),
    axis.title.y       = element_text(size = 11, margin = margin(r = 8)),
    panel.grid.major.x = element_blank(),
    panel.grid.minor   = element_blank(),
    panel.grid.major.y = element_line(colour = "grey88", linewidth = 0.4),
    legend.position    = "right",
    legend.title       = element_text(face = "bold", size = 10),
    legend.text        = element_text(size = 9),
    legend.key.size    = unit(0.45, "cm"),
    plot.margin        = margin(t = 12, r = 16, b = 10, l = 12)
  )

# 6. GRAFIGI KAYDET
ggsave(
  "C:/Users/alper/Desktop/meyve_uretim_grafik.pdf",
  plot   = grafik,
  width  = 16,
  height = 8,
  device = cairo_pdf
)

print(grafik)
