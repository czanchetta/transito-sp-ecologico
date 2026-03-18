# Fontes de Dados

Este projeto utiliza dados de quatro fontes principais. Os arquivos brutos devem ser
colocados em `data/raw/<fonte>/` e **não são versionados** (ver `.gitignore`).
Os dados processados e derivados ficam em `data/processed/`.

---

## 1. InfoSiga — Sistema de Informações Gerenciais de Acidentes de Trânsito

| Campo           | Detalhe |
|-----------------|---------|
| **Responsável** | Secretaria de Segurança Pública do Estado de São Paulo (SSP-SP) |
| **URL**         | <https://www.infosiga.sp.gov.br> |
| **Acesso**      | Portal público; download por município e período |
| **Granularidade** | Ocorrência individual (data, hora, tipo, vítimas) |
| **Cobertura**   | Municípios do Estado de SP, 2010–atual |
| **Variáveis chave** | `municipio`, `data_ocorrencia`, `tipo_acidente`, `obitos`, `feridos_graves`, `feridos_leves`, `logradouro`, `latitude`, `longitude` |
| **Diretório local** | `data/raw/infosiga/` |
| **Formato**     | `.xlsx` / `.csv` por ano e município |
| **Citação sugerida** | SSP-SP. *InfoSiga — Sistema de Informações Gerenciais de Acidentes de Trânsito*. São Paulo, 2024. Disponível em: https://www.infosiga.sp.gov.br |

### Notas de uso
- Filtrar registros com `tipo_ocorrencia == "ACIDENTE DE TRÂNSITO"`.
- Georreferenciar endereços ausentes com o pacote `tidygeocoder`.
- Atenção a mudanças de codificação de municípios entre 2010 e 2018.

---

## 2. IBGE — Instituto Brasileiro de Geografia e Estatística

| Campo           | Detalhe |
|-----------------|---------|
| **Responsável** | IBGE |
| **URL**         | <https://www.ibge.gov.br> / API: <https://servicodados.ibge.gov.br> |
| **Acesso**      | Download direto; API REST sem autenticação |
| **Granularidade** | Municipal, setorial (Censo) |
| **Cobertura**   | Brasil; Censos 2000, 2010, 2022; estimativas intercensitárias anuais |
| **Variáveis chave** | `cod_municipio` (7 dígitos), `populacao`, `area_km2`, `pib_per_capita`, `gini`, `idh`, `densidade_demografica` |
| **Diretório local** | `data/raw/ibge/` |
| **Formato**     | `.csv`, `.xlsx`, Shapefile, GeoPackage |
| **Citação sugerida** | IBGE. *Censo Demográfico 2022*. Rio de Janeiro: IBGE, 2023. |

### Fontes específicas utilizadas
- **Censo Demográfico 2022** — população residente por município.
- **Estimativas populacionais** — anos intercensitários (TCU).
- **PIB dos Municípios** — renda e produto per capita.
- **Malha municipal** — polígonos vetoriais (baixados via `geobr::read_municipality()`).

---

## 3. SENATRAN / SENATRAN-DENATRAN — Frota de Veículos

| Campo           | Detalhe |
|-----------------|---------|
| **Responsável** | Secretaria Nacional de Trânsito (SENATRAN) / DENATRAN (anterior a 2021) |
| **URL**         | <https://portalservicos.senatran.serpro.gov.br> · <https://www.gov.br/transportes/> |
| **Acesso**      | Download de planilhas mensais via portal GOV.BR |
| **Granularidade** | Municipal × tipo de veículo × mês |
| **Cobertura**   | Brasil, 2001–atual |
| **Variáveis chave** | `cod_municipio`, `ano`, `mes`, `tipo_veiculo`, `total_frota` |
| **Diretório local** | `data/raw/senatran/` |
| **Formato**     | `.xlsx` por mês/ano |
| **Citação sugerida** | SENATRAN. *Frota de Veículos por Município*. Brasília: SENATRAN/SERPRO, 2024. Disponível em: https://portalservicos.senatran.serpro.gov.br |

### Notas de uso
- Agregar por `ano` para obter frota anual média (média dos 12 meses).
- Considerar apenas veículos registrados no Estado de SP.
- Indicadores derivados: `frota_per_capita`, `frota_por_km2`, `taxa_motorização`.

---

## 4. geobr — Malhas Geoespaciais do Brasil

| Campo           | Detalhe |
|-----------------|---------|
| **Responsável** | IPEA — Instituto de Pesquisa Econômica Aplicada |
| **URL**         | <https://github.com/ipeaGIT/geobr> · CRAN: `install.packages("geobr")` |
| **Acesso**      | Pacote R; dados baixados automaticamente das APIs do IBGE/IPEA |
| **Granularidade** | Município, mesorregião, estado, país, setor censitário |
| **Cobertura**   | Brasil, anos de referência 2000–2022 |
| **Variáveis chave** | `code_muni`, `name_muni`, `code_state`, `abbrev_state`, `geom` (MULTIPOLYGON) |
| **Diretório local** | Cache automático do pacote; exportações em `data/processed/spatial/` |
| **Formato**     | `sf` (Simple Features); exportável como GeoPackage / Shapefile |
| **Citação sugerida** | Pereira, R.H.M. et al. *geobr: Loads Shapefiles of Official Spatial Data Sets of Brazil*. R package version 1.8.2. GitHub: ipeaGIT/geobr, 2023. |

### Funções principais utilizadas
```r
geobr::read_municipality(code_muni = 35, year = 2022)   # municípios SP
geobr::read_state(code_state = "SP", year = 2022)        # estado SP
geobr::read_metro_area(year = 2020)                      # regiões metropolitanas
geobr::read_census_tract(code_tract = 35, year = 2022)   # setores censitários
```

---

## Estrutura de arquivos esperada

```
data/
├── raw/
│   ├── infosiga/          # arquivos .xlsx/.csv do InfoSiga
│   ├── ibge/              # censo, estimativas, PIB
│   ├── senatran/          # frota mensal
│   └── spatial/           # shapefiles auxiliares (se baixados manualmente)
└── processed/
    ├── acidentes_sp.rds   # base consolidada de acidentes
    ├── municipios_sp.rds  # painel municipal com todas as covariáveis
    └── spatial/           # geometrias processadas (.gpkg)
```

---

## Reprodutibilidade

Os scripts em `R/` baixam, limpam e integram estas fontes de forma automatizada.
Execute na ordem numérica:

```r
source("R/00_setup.R")
source("R/01_download_data.R")
source("R/02_clean_infosiga.R")
source("R/03_clean_covariates.R")
source("R/04_spatial_join.R")
```
