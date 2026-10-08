# Методология Замеров Производительности (Benchmarks)

## 1. Цели и принципы

Набор бенчмарков производительности предназначен для систематического контроля утилизации системных ресурсов, замера профиля оперативной памяти и времени инициализации сессии как для основного приложения iOS, так и для фонового сетевого расширения `NEPacketTunnelProvider`.

> [!IMPORTANT]
> **Недопустимость сфабрикованных цифр**: Все показатели в этом разделе строго описывают методику измерений и формат схемы JSON. Базовые замеры фиксируются исключительно на физических устройствах в лаборатории. До проведения замеров поля помечаются как `Требуется замер базового уровня`.

---

## 2. Ключевые метрики и целевые бюджеты

| Метрика | Целевой процесс | Проектный порог | Статус | Инструмент |
| :--- | :--- | :--- | :--- | :--- |
| **Память расширения (Режим простоя)** | `PacketTunnel` | **< 15.0 МБ** | Требуется замер базового уровня | Xcode Instruments / `vmmap` |
| **Память расширения (Активный трафик 50 Мбит/с)**| `PacketTunnel` | **< 15.0 МБ** | Требуется замер базового уровня | Xcode Instruments / `vmmap` |
| **Память основного приложения (Простой)** | `ViaApp` | **< 60.0 МБ** | Требуется замер базового уровня | Xcode Instruments |
| **Задержка подключения (Handshake RTT)** | Хост ➔ Прокси | **Мин, Медиана, p95, Макс** | Требуется замер базового уровня | Тестовый харнесс |
| **Нагрузка на CPU (В подключенном состоянии)** | Оба процесса | **< 2%** | Требуется замер базового уровня | Xcode Instruments |

---

## 3. Схема сохранения результатов замера памяти (JSON)

При выполнении замеров на реальном оборудовании результаты заносятся в `benchmarks/results/` в соответствии со следующей схемой:

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "ViaMemoryBenchmarkResult",
  "type": "object",
  "properties": {
    "timestamp": { "type": "string", "format": "date-time" },
    "device": { "type": "string" },
    "os_version": { "type": "string" },
    "build_configuration": { "type": "string", "enum": ["Release", "Debug"] },
    "protocol": { "type": "string" },
    "duration_seconds": { "type": "integer" },
    "throughput_mbps": { "type": "number" },
    "extension_memory_mb": {
      "type": "object",
      "properties": {
        "min": { "type": "number" },
        "median": { "type": "number" },
        "p95": { "type": "number" },
        "max": { "type": "number" }
      },
      "required": ["min", "median", "p95", "max"]
    },
    "budget_exceeded": { "type": "boolean" }
  },
  "required": ["timestamp", "device", "os_version", "build_configuration", "protocol", "extension_memory_mb", "budget_exceeded"]
}
```

---

## 4. Скрипт локального замера

Для фиксации объема оперативной памяти процессов во время локального запуска на macOS:

```bash
# Запуск скрипта мониторинга RSS памяти
./benchmarks/run_memory_benchmark.sh
```
