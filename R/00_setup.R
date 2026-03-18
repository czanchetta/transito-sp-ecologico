# =============================================================================
# 00_setup.R
# Configuração do ambiente — instalação e carregamento de pacotes
#
# Execute este script uma vez para inicializar o renv e instalar dependências.
# Nos demais scripts, basta chamar: source("R/00_setup.R")
# =============================================================================

# -----------------------------------------------------------------------------
# 1. renv — gerenciamento de ambiente reprodutível
# -----------------------------------------------------------------------------
if (!requireNamespace("renv", quietly = TRUE)) {
  install.packages("renv")
}

# Inicializa renv se ainda não foi feito (cria renv.lock e renv/)
if (!file.exists("renv.lock")) {
  renv::init(bare = TRUE)
}

# Restaura pacotes a partir do renv.lock (em ambientes CI ou clones)
# renv::restore()

# -----------------------------------------------------------------------------
# 2. Lista de pacotes do projeto
# -----------------------------------------------------------------------------
packages <- c(
  # --- Manipulação e visualização de dados -----------------------------------
  "tidyverse",    # dplyr, ggplot2, tidyr, readr, purrr, stringr, forcats, tibble
  "janitor",      # limpeza de nomes e tabelas (clean_names, tabyl, adorn_*)
  "lubridate",    # datas e horas (ymd, floor_date, interval, period)

  # --- Dados espaciais -------------------------------------------------------
  "sf",           # Simple Features: leitura, manipulação e exportação vetorial
  "geobr",        # malhas oficiais do Brasil (IBGE/IPEA) via API
  "tmap",         # mapas temáticos estáticos e interativos

  # --- Autocorrelação e econometria espacial ---------------------------------
  "spdep",        # matrizes de vizinhança, Moran I, LISA, modelos SAR/CAR

  # --- Modelos estatísticos --------------------------------------------------
  "MASS",         # regressão binomial negativa (glm.nb), LDA, rlm
  "lme4",         # modelos mistos (lmer, glmer) — efeitos aleatórios municipais
  "betareg",      # regressão beta para proporções (0,1)

  # --- Análise de tendência temporal ----------------------------------------
  "segmented",    # regressão segmentada / joinpoint (pontos de inflexão em séries temporais)

  # --- Tabelas e relatórios --------------------------------------------------
  "gtsummary",    # tabelas de resumo, regressão e comparação formatadas
  "patchwork"     # composição de múltiplos gráficos ggplot2
)

# -----------------------------------------------------------------------------
# 3. Instalação de pacotes ausentes
# -----------------------------------------------------------------------------
installed <- rownames(installed.packages())
to_install <- setdiff(packages, installed)

if (length(to_install) > 0) {
  message("Instalando pacotes ausentes: ", paste(to_install, collapse = ", "))
  install.packages(to_install)
} else {
  message("Todos os pacotes já estão instalados.")
}

# -----------------------------------------------------------------------------
# 4. Carregamento de pacotes
# -----------------------------------------------------------------------------
suppressPackageStartupMessages({
  library(tidyverse)
  library(janitor)
  library(lubridate)
  library(sf)
  library(geobr)
  library(tmap)
  library(spdep)
  library(MASS)
  library(lme4)
  library(betareg)
  library(segmented)
  library(gtsummary)
  library(patchwork)
})

# -----------------------------------------------------------------------------
# 5. Opções globais
# -----------------------------------------------------------------------------
options(
  scipen       = 999,          # desativa notação científica
  digits       = 4,
  OutDec       = ",",          # separador decimal brasileiro
  timeout      = 300,          # timeout de download (segundos)
  dplyr.summarise.inform = FALSE
)

# tmap: modo estático por padrão (trocar para "view" para interativo)
tmap_mode("plot")

# Locale para português (Linux/macOS)
Sys.setlocale("LC_TIME", "pt_BR.UTF-8")

# -----------------------------------------------------------------------------
# 6. Diretórios — garantir existência
# -----------------------------------------------------------------------------
dirs <- c(
  "data/raw/infosiga",
  "data/raw/ibge",
  "data/raw/senatran",
  "data/raw/spatial",
  "data/processed/spatial",
  "output/figures",
  "output/tables",
  "output/maps",
  "docs/analysis"
)

invisible(lapply(dirs, \(d) {
  if (!dir.exists(d)) {
    dir.create(d, recursive = TRUE)
    message("Diretório criado: ", d)
  }
}))

# -----------------------------------------------------------------------------
# 7. Paleta de cores do projeto
# -----------------------------------------------------------------------------
cores_projeto <- list(
  primaria   = "#C0392B",   # vermelho — óbitos
  secundaria = "#E67E22",   # laranja  — feridos graves
  terciaria  = "#F1C40F",   # amarelo  — feridos leves
  neutro     = "#2C3E50",   # cinza-azulado
  mapa_seq   = "YlOrRd",    # escala sequencial para mapas coropléticos
  mapa_div   = "RdBu"       # escala divergente para resíduos/diferenças
)

message("\n=== Ambiente configurado com sucesso ===")
message("R version: ", R.version$major, ".", R.version$minor)
message("Pacotes carregados: ", paste(packages, collapse = ", "))
# Nota: 'joinpoint' foi substituído por 'segmented' (CRAN).
# O NCI Joinpoint Regression Program é software standalone (Windows), não pacote R.
