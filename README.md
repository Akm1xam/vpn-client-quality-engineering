# Via — Инженерия Качества (Quality Engineering)

Фреймворк обеспечения качества и автоматизации тестирования для VPN-клиента на базе Apple NetworkExtension, Swift 6 и Xray-core.

<p align="left">
  <a href="#матрица-автоматизированных-тестов"><img src="https://img.shields.io/badge/Тесты-16%20Успешно-10b981?style=flat-square&logo=apple&logoColor=white" alt="Тесты" /></a>
  <a href="#матрица-автоматизированных-тестов"><img src="https://img.shields.io/badge/Фреймворк-Swift%20Testing-F05138?style=flat-square&logo=swift&logoColor=white" alt="Swift Testing" /></a>
  <a href="#релизные-критерии-и-гейты-качества"><img src="https://img.shields.io/badge/Бюджет%20Памяти-%3C%2015%20МБ-38bdf8?style=flat-square" alt="Бюджет Памяти" /></a>
  <a href="#безопасность-и-приватность"><img src="https://img.shields.io/badge/Приватность-0%20Утечек%20DNS-8b5cf6?style=flat-square" alt="Ноль Утечек" /></a>
  <a href="#безопасность-и-приватность"><img src="https://img.shields.io/badge/Телеметрия-0%20Трекеров-10b981?style=flat-square" alt="Ноль Телеметрии" /></a>
</p>

---

### Инженерная надежность в нестабильных сетях

Фреймворк **Via Quality Engineering (QE)** спроектирован специально для валидации VPN- и proxy-клиента на базе системного Apple `NetworkExtension`. Работая на стыке пространства пользователя (User Space) и ядра Darwin, фреймворк гарантирует:
- **Полную изоляцию плоскости данных (Data-Plane)**: отсутствие утечек DNS и IPv6 за пределы интерфейса туннеля.
- **Детерминированность автомата состояний**: предотвращение гонок данных (race conditions) при параллельных вызовах внутри Swift 6 акторов.
- **Соблюдение жесткого бюджета памяти**: удержание Packet Tunnel Extension в пределах проектного конверта < 15 МБ.
- **Автоматическое восстановление соединения**: отказоустойчивость при смене сетей (Wi-Fi ↔ LTE/5G) и агрессивной цензуре.

---

## Архитектура тестируемой системы (SUT)

```
Via Application (Основной процесс интерфейса / SwiftUI)
├── Слой представления (DesignSystem / Feature Views)
├── Доменный слой (Server, RoutingProfile, DNSProfile, Source)
├── Слой хранилища (Акторы ServerStore, SourceStore, SettingsStore)
├── Слой конфигурации (UniversalConfigurationParser, SourceUpdater с HWID)
└── Слой оркестрации VPN (Актор ConnectionCoordinator, XrayConfigCompiler, RuntimeSnapshotManager)
        │
        ├── Межпроцессное взаимодействие (IPC) через App Group (`group.com.via.vpn`) & Keychain
        │
Packet Tunnel Extension (NEPacketTunnelProvider / Изолированный процесс)
├── Системные сетевые настройки (NEPacketTunnelNetworkSettings)
├── Привязка к виртуальному интерфейсу (NEPacketTunnelFlow)
├── Низкоуровневый C-мост (XrayBridge C/cgo interface)
└── Прокси-ядро (Xray-core v1.8.24)
        │
Внешние прокси-узлы (VLESS Reality, Hysteria 2, Trojan gRPC, Shadowsocks 2022)
```

---

## Пирамида тестирования и уровни верификации

Вместо хрупких сквозных UI-тестов, архитектура верификации Via опирается на системные границы операционной системы:

```
               [ UI-тесты (XCUITest) ]
              - Критические сценарии пользователя
              - Выбор сервера и переключение туннеля
              - Семантические accessibility identifiers
                         ▲
            [ Лаборатория хаоса и физические устройства ]
           - Переключение Wi-Fi ↔ Мобильная сеть
           - Высокий пинг, джиттер и потеря пакетов (1-50%)
           - Спящий режим, экран блокировки, Captive Portal
                         ▲
         [ Интеграционные тесты (Swift Testing) ]
        - Переходы состояний ConnectionCoordinator
        - Атомарность снапшотов RuntimeSnapshotManager
        - Резервное сохранение Keychain Fallback
                         ▲
           [ Модульные тесты (Swift Testing) ]
          - Логика универсального парсера UniversalConfigurationParser
          - Компилятор конфигураций XrayConfigCompiler
          - Экспоненциальный откат повторных попыток (RetryPolicy)
```

### 4 уровня верификации

1. **Уровень 1: Модульные инварианты (50%)** — *Swift Testing (`@Suite`, `@Test`, `#expect`)*
   - Мгновенное выполнение (0.069 сек) без необходимости в сетевых интерфейсах.
   - Проверка разбора пакетных подписок, генерации потоковых настроек Xray и алгоритмов повторных попыток.
   - Защита от гонок жизненного цикла (повторные `connect-while-connecting` и `disconnect-while-disconnecting`).
2. **Уровень 2: Интеграция компонентов (30%)** — *Акторы и тестовые дублеры (Test Doubles)*
   - Проверка взаимодействия между акторами `ConnectionCoordinator`, `ServerStore` и `RuntimeSnapshotManager`.
   - Тестирование атомарной упаковки файла `xray.json` в контейнер App Group.
   - Валидация Dual-Persist стратегии при системных сбоях связки ключей Keychain (ошибка `-34018`).
3. **Уровень 3: Автоматизация интерфейса (10%)** — *Apple XCUITest*
   - Тестирование ключевых путей пользователя с использованием токенов `accessibilityIdentifier`.
   - Проверка состояний кнопки подключения, отображения списка серверов и пунктов политики приватности.
4. **Уровень 4: Лаборатория сетевого хаоса (10%)** — *Физические устройства и инжекция сбоев*
   - Воспроизведение потери пакетов (от 1% до 50%), трансокеанских задержек и флаппинга интерфейсов.
   - Неразрушающие проверочные скрипты и сниффинг трафика через Wireshark для гарантии отсутствия утечек DNS.

---

## Быстрый старт: Запуск тестов

```bash
# 1. Очистка расширенных атрибутов macOS и запуск полного набора тестов
xattr -c -r Sources Tests Targets vpn-client-quality-engineering Package.swift 2>/dev/null
swift test

# 2. Запуск тестов в Xcode для симулятора iOS (iPhone 18 Pro)
xcodebuild test -scheme Via -destination 'platform=iOS Simulator,name=iPhone 18 Pro'

# 3. Безопасная проверка DNS-резолверов
./network-lab/scripts/check_dns_leak.sh

# 4. Замер потребления оперативной памяти процесса
./benchmarks/run_memory_benchmark.sh
```

---

## Матрица автоматизированных тестов

| Идентификатор теста | Категория | Область | Проверяемый инвариант | Инструмент |
| :--- | :--- | :--- | :--- | :--- |
| **`testCleanLifecycleTransitions`** | Автомат состояний | `VPN/State` | Корректный цикл: `.disconnected` ➔ `.connected` ➔ `.disconnected` | Swift Testing |
| **`testConnectWhileConnectingIgnored`**| Конкурентность | `VPN/State` | Идемпотентность: повторный `connect` в процессе подключения игнорируется | Swift Testing |
| **`testDisconnectWhileDisconnectedSafe`**| Конкурентность | `VPN/State` | Повторный вызов `disconnect` безопасен и не вызывает сбоев | Swift Testing |
| **`testRetryPolicyDelayCalculations`** | Надежность | `VPN/State` | Ограниченный экспоненциальный откат: 1с, 2с, 5с, 10с, 30с | Swift Testing |
| **`testRapidToggleStress`** | Нагрузка | `VPN/State` | 10 быстрых циклов переключения под защитой акторов без дедлоков | Swift Testing |
| **`testLogSanitizerMasking`** | Безопасность | `SharedCore` | Regex-маскирование UUID, паролей и ключей Reality в логах | Swift Testing |
| **`testHWIDPersistence`** | Подписки | `SharedCore` | Детерминированный заголовок `x-hwid` по формату `/^[a-zA-Z0-9=-]{10,64}$/` | Swift Testing |
| **`testZeroTelemetryCompliance`** | Приватность | `ViaApp` | Проверка рефлексией: 0 трекинговых SDK слинковано в сборку | Swift Testing |
| **`testServerStoreAddAndRetrieve`** | Интеграция | `Storage` | Акторное сохранение и надежное извлечение серверов и паролей | Swift Testing |
| **`testRuntimeSnapshotAtomicCreation`**| Интеграция | `VPN/Compiler`| Атомарная сборка `xray.json` и профиля сетевых настроек | Swift Testing |
| **`CriticalUserJourneyUITests`** | Сквозной (E2E) | `UITests` | Запуск приложения, рендеринг списка узлов, проверка приватности | XCUITest |

---

## Релизные критерии и гейты качества

Каждый Pull Request и релизный билд проходит многоуровневый автоматический контроль:

```
[ Гейт 1: Статический анализ ] ──► Swift 6 strict concurrency (0 предупреждений)
                                     └── Сканер телеметрии (0 внешних трекеров)
[ Гейт 2: Автоматические тесты ] ──► 100% успешное прохождение Unit и Integration наборов
[ Гейт 3: Бюджет памяти ]       ──► PacketTunnelExtension resident memory < 15.0 МБ
[ Гейт 4: Безопасность ]        ──► 0 открытых паролей в логах; 0 утечек DNS
```

- **Дефекты P0 (Блокирующие)**: **Строго 0.** Блокируют релиз немедленно.
- **Дефекты P1 (Критические)**: **0 без подписанного обоснования.**
- **Проектный бюджет памяти**: Потребление оперативной памяти расширения туннеля строго **< 15 МБ** в ходе 60-минутного стресс-теста.

---

## Границы автоматизации: CI против физических устройств

Поскольку фреймворк Apple `NetworkExtension` взаимодействует напрямую с ядром Darwin и требует привилегий операционной системы, проверки строго разделены:

| Возможность | Автоматизировано в CI (GitHub Runner) | Физическая лаборатория (Device Lab) |
| :--- | :---: | :---: |
| **Swift 6 конкурентность и инварианты состояний** | ✅ Да (`swift test`) | — |
| **Парсинг многонодовых подписок (FlozVPN)** | ✅ Да (`swift test`) | — |
| **Санитизация логов в памяти и маскирование** | ✅ Да (`swift test`) | — |
| **Статический аудит отсутствия телеметрии** | ✅ Да (`qa-quality-gates.yml`) | — |
| **Симуляция переходов VPN-сессии** | ✅ Да (`ViaTests`) | — |
| **Привязка к системному ядру `NEPacketTunnelProvider`** | ❌ Недоступно в виртуальной среде | ✅ Физический iPhone 17/18 |
| **Бесшовный переход Wi-Fi ↔ 5G/LTE** | ❌ Недоступно в виртуальной среде | ✅ Физический iPhone + SIM-карта |
| **Сниффинг пакетов на уровне роутера (утечки DNS)** | ❌ Недоступно в виртуальной среде | ✅ Точка доступа Wi-Fi + Wireshark |
| **Профилирование памяти через Instruments (60 мин)** | ❌ Недоступно в виртуальной среде | ✅ Подключение к реальному процессу |
| **Восстановление после сна/блокировки устройства** | ❌ Недоступно в виртуальной среде | ✅ Ручная валидация в лаборатории |

---

## Структура репозитория

```
vpn-client-quality-engineering/
├── .github/workflows/                 # Описания CI-пайплайнов и гейтов качества
├── README.md                          # Главная документация и обзор архитектуры QE
├── automation/
│   ├── IntegrationTests/              # Интеграционные тесты компонентов (IPC, снапшоты)
│   ├── TestDoubles/                   # Тестовые дублеры (MockTunnelManager, FakeAppGroupStorage)
│   ├── UITests/                       # XCUITest автоматизация сценариев пользователя
│   └── UnitTests/                     # Swift Testing тесты инвариантов и безопасности
├── benchmarks/                        # Методология замеров памяти и JSON-схемы
├── docs/
│   ├── release-criteria.md            # Измеримые критерии релиза и пороги дефектов
│   ├── risk-assessment.md             # Матрица рисков RPN и модель угроз
│   ├── test-matrix.md                 # Матрица трассируемости рисков к тестам
│   ├── test-plan.md                   # План тестирования (Smoke, Regression, Chaos)
│   └── test-strategy.md               # Стратегия и цели обеспечения качества
├── network-lab/
│   ├── scenarios/                     # Сценарии симуляции сбоев (потери, задержки)
│   └── scripts/                       # Безопасные скрипты проверки сети и DNS
├── reports/
│   ├── sanitized-samples/             # Обезличенные примеры отчетов об ошибках
│   └── templates/                     # Шаблоны баг-репортов и отчетов
└── test-cases/                        # Функциональные, сетевые, нагрузочные и security кейсы
```

---

## Лицензия и условия использования

- Входит в состав проекта **Via**, распространяется под лицензией [Mozilla Public License 2.0 (MPL-2.0)](../LICENSE).
- Ядро прокси-туннеля работает на базе [Xray-core](https://github.com/XTLS/Xray-core) (MPL-2.0).
