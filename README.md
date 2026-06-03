# neno

App Flutter para acompanhamento de gestação — registre movimentos do bebê, visualize análises e receba conselhos personalizados.

## Funcionalidades

- **Movimentos** — Registre cada movimento do bebê com data, hora, intensidade e observações. Tudo salvo localmente.
- **Análises** — Visualize gráficos de movimentos por dia, distribuição por horário, média diária, intervalo médio e sequência de dias.
- **Conselhos** — Assistente inteligente que gera conselhos personalizados baseados na sua semana de gestação e nos movimentos registrados.
- **Perfil** — Cadastre a DPP (Data Provável do Parto) ou DUM (Data da Última Menstruação) e acompanhe automaticamente a semana e o trimestre.

## Stack

- **Flutter** 3.35.4 (gerenciado via FVM)
- **State management:** `flutter_bloc`
- **Storage local:** `hive_ce`
- **Gráficos:** `fl_chart`
- **DI:** `get_it`
- **Datas:** `intl`

## Arquitetura

Clean Architecture baseada em features:

```
lib/
├── app/           # Tema, app root
├── core/di/       # Service Locator (get_it)
├── data/
│   ├── models/    # Movement, PregnancyProfile (com Hive adapters)
│   ├── datasources/  # LocalStorage, AiService
│   └── repositories/ # Movement, Profile, AI
└── features/
    ├── movements/    # Bloc + View + Widgets
    ├── analytics/    # Bloc + View + Charts
    ├── ai/           # Bloc + View + Chat UI
    ├── profile/      # Bloc + View + Edit page
    └── home/         # Bottom navigation
```

## Setup

Pré-requisitos: [FVM](https://fvm.app) instalado.

```bash
fvm install stable
fvm use stable
fvm flutter pub get
```

## Rodar no iOS

```bash
open -a Simulator
fvm flutter run -d <device_id>
```

## Testes

```bash
fvm flutter test
```

Os testes cobrem os Blocs com `bloc_test` + `mocktail`.

## Aviso

Os conselhos gerados pelo app são informativos e **não substituem orientação médica profissional**.
