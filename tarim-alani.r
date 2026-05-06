# -*- coding: utf-8 -*-
# encoding: UTF-8

library(readxl)
library(ggplot2)
library(dplyr)

# ------ VER??Y?? OKU ------
df <- read_excel("C:/Users/alper/Desktop/tarim_alan.xls", skip = 7)
names(df) <- c("Yil", "Toplam", "Ekilen", "Nadas", "Sebze", "Sus", "Meyve", "Cay")
df <- df[!is.na(df$Yil), ]
df$Yil    <- as.integer(df$Yil)
df$Ekilen <- as.numeric(df$Ekilen)
df$Nadas  <- as.numeric(df$Nadas)
df$Sebze  <- as.numeric(df$Sebze)
df$Meyve  <- as.numeric(df$Meyve)
df$Cay    <- as.numeric(df$Cay)
df <- df[!is.na(df$Yil), ]

# ------ ILK VE SON YIL ------
ilk_yil <- df %>% filter(Yil == min(Yil))
son_yil <- df %>% filter(Yil == max(Yil))

# ------ DONUT VERISI ------
donut_2001 <- data.frame(
  Tur   = c("Tahil", "Nadas", "Sebze Bahcesi", "Meyve Bahcesi", "Cay"),
  Deger = c(ilk_yil$Ekilen, ilk_yil$Nadas, ilk_yil$Sebze, ilk_yil$Meyve, ilk_yil$Cay),
  Yil   = "2001"
)
donut_2024 <- data.frame(
  Tur   = c("Tahil", "Nadas", "Sebze Bahcesi", "Meyve Bahcesi", "Cay"),
  Deger = c(son_yil$Ekilen, son_yil$Nadas, son_yil$Sebze, son_yil$Meyve, son_yil$Cay),
  Yil   = "2024"
)

donut_df <- bind_rows(donut_2001, donut_2024) %>%
  group_by(Yil) %>%
  mutate(Yuzde = Deger / sum(Deger) * 100)

# Gosterim etiketlerini Turkce yap (factor label ile)
donut_df$Tur <- factor(donut_df$Tur,
                       levels = c("Tahil", "Nadas", "Sebze Bahcesi", "Meyve Bahcesi", "Cay"),
                       labels = c(
                         "Tah\u0131l",
                         "Nadas",
                         "Sebze Bah\u00e7esi",
                         "Meyve Bah\u00e7esi",
                         "\u00c7ay"
                       )
)

# ------ GRAFIK ------
p7 <- ggplot(donut_df, aes(x = 2, y = Yuzde, fill = Tur)) +
  geom_col(width = 1, color = "white", linewidth = 0.8) +
  coord_polar(theta = "y") +
  xlim(0.5, 2.5) +
  facet_wrap(~Yil) +
  scale_fill_manual(values = c(
    "Tah\u0131l"         = "#03045E",
    "Nadas"              = "#023E8A",
    "Sebze Bah\u00e7esi" = "#0077B6",
    "Meyve Bah\u00e7esi" = "#00B4D8",
    "\u00c7ay"           = "#90E0EF"
  )) +
  geom_text(
    aes(label = ifelse(Yuzde > 1.5, paste0("%", round(Yuzde, 1)), "")),
    position = position_stack(vjust = 0.5),
    color = "white", fontface = "bold", size = 4
  ) +
  labs(
    title    = "2001 vs 2024: Tar\u0131m Alan\u0131 Kompozisyonu",
    subtitle = "\u0130lk ve Son Y\u0131l Kar\u015f\u0131la\u015ft\u0131rmas\u0131",
    fill     = "Alan T\u00fcr\u00fc",
    caption  = "Kaynak : T\u00fcrkiye \u0130statistik Kurumu (TUIK)"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title    = element_text(face = "bold", size = 15, hjust = 0.5, color = "#1a1a2e"),
    plot.subtitle = element_text(hjust = 0.5, color = "#555", size = 11),
    plot.caption  = element_text(color = "#888", size = 9),
    axis.text     = element_blank(),
    axis.title    = element_blank(),
    panel.grid    = element_blank(),
    strip.text    = element_text(face = "bold", size = 13),
    legend.position = "bottom",
    legend.title  = element_text(face = "bold")
  )

ggsave(
  "C:/Users/alper/Desktop/tarim_07_donut_karsilastirma.pdf",
  plot   = p7,
  width  = 12,
  height = 6,
  device = cairo_pdf,
  bg     = "white"
)

print(p7)

cat("Donut grafik kaydedildi: C:/Users/alper/Desktop/tarim_07_donut_karsilastirma.pdf\n")

