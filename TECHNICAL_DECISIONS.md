# OpenAPI → ReScript Type Generator

## Обзор

Кодогенератор для преобразования OpenAPI спецификаций в ReScript типы с поддержкой Effect TS совместимости.

**Pipeline:** `OpenAPI JSON` → `Schema AST` → `ReScript Code` → `TypeScript Types` + `Sury Schemas`

## Ключевые технические решения

### 1. `@genType` для генерации TypeScript типов

**Решение:** Использовать `@genType` аннотацию для автоматической генерации `.gen.tsx` файлов.

**Причина:**
- Автоматическая синхронизация ReScript и TypeScript типов
- Нет ручного дублирования типов
- Поддержка discriminated unions

**Результат:**
```rescript
@genType
type user = { id: int, name: string }
```
↓
```typescript
export type user = { readonly id: number; readonly name: string };
```

### 2. `@tag("_tag")` для Effect TS совместимости

**Решение:** Использовать `@tag("_tag")` вместо стандартного `TAG`.

**Причина:**
- Effect TS использует `_tag` как стандартный дискриминант
- RTK Query и другие библиотеки ожидают `_tag`
- Совместимость с существующей экосистемой

**Результат:**
```rescript
@genType
@tag("_tag")
type response =
  | Success({data: string})
  | Error({message: string})
```
↓
```typescript
export type response =
    { _tag: "Success"; readonly data: string }
  | { _tag: "Error"; readonly message: string };
```

### 3. `@schema` (sury-ppx) для автоматической генерации схем

**Решение:** Использовать `@schema` аннотацию из sury-ppx для автоматической генерации Sury схем.

**Причина:**
- Автоматическая валидация данных в рантайме
- Нет ручного написания схем
- Схемы синхронизированы с типами

**Результат:**
```rescript
@genType
@tag("_tag")
@schema
type response =
  | Success({data: string})
  | Error({message: string})
```
↓
```javascript
let responseSchema = S.union([
  S.schema(s => ({ _tag: "Success", data: s.m(S.string) })),
  S.schema(s => ({ _tag: "Error", message: s.m(S.string) }))
]);
```

### 4. Сохранение `_0` для payload полей

**Решение:** Оставить стандартное имя `_0` для payload вместо кастомного `data`.

**Причина:**
- Избежание путаницы: откуда поле `data` - ReScript? RTK Query? API?
- Упрощение кодогенератора
- `_0` явно указывает на ReScript происхождение

**Альтернатива (отклонена):** Использовать inline records `Optional({data: schemaType})` для кастомизации имени поля. Отклонено из-за усложнения.

### 5. ReScript 12 + sury + sury-ppx

**Решение:** Обновиться до ReScript 12 для использования sury и sury-ppx.

**Причина:**
- sury требует ReScript 12.x
- sury-ppx генерирует схемы с правильным `_tag` дискриминантом
- Современный toolchain

**Конфигурация (rescript.json):**
```json
{
  "dependencies": ["@rescript/core", "sury"],
  "ppx-flags": ["sury-ppx/bin"],
  "gentypeconfig": { "language": "typescript" }
}
```

### 6. Переименование OpenAPI.res → OpenAPIParser.res

**Решение:** Переименовать модуль во избежание конфликта имён.

**Причина:** sury содержит свой `src/OpenAPI.res`, что вызывает конфликт модулей.

## Архитектура

```
src/
├── Schema.res          # AST типы схемы + парсер JSON → AST
├── OpenAPIParser.res   # Парсер OpenAPI документов
├── Codegen.res         # Генератор ReScript кода
├── Errors.res          # Типы ошибок
├── test_ppx.res        # Тест комбинации @genType + @tag + @schema
└── tests/
    └── schema.test.js  # 24 теста
```

## Генерируемые файлы

| Исходник | Генерируется | Описание |
|----------|--------------|----------|
| `*.res` | `*.res.js` | JavaScript модуль |
| `*.res` с `@genType` | `*.gen.tsx` | TypeScript типы |
| `*.res` с `@schema` | схемы в `*.res.js` | Sury валидационные схемы |

## Поддерживаемые OpenAPI конструкции

| OpenAPI | ReScript | TypeScript |
|---------|----------|------------|
| `type: string` | `String` | `"String"` |
| `type: number` | `Number` | `"Number"` |
| `type: integer` | `Integer` | `"Integer"` |
| `type: boolean` | `Boolean` | `"Boolean"` |
| `type: null` | `Null` | `"Null"` |
| `type: array` | `Array(itemType)` | `{ _tag: "Array"; _0: T }` |
| `type: object` | `Object(fields)` | `{ _tag: "Object"; _0: field[] }` |
| `$ref` | `Ref(name)` | `{ _tag: "Ref"; _0: string }` |
| `enum` | `Enum(values)` | `{ _tag: "Enum"; _0: string[] }` |
| `oneOf` | `PolyVariant(cases)` | `{ _tag: "PolyVariant"; _0: variantCase[] }` |
| `anyOf: [T, null]` | `Optional(T)` | `{ _tag: "Optional"; _0: T }` |
| `additionalProperties` | `Dict(valueType)` | `{ _tag: "Dict"; _0: T }` |

## Тесты

24 теста покрывают:
- Парсинг примитивных типов
- Парсинг nullable (anyOf с null)
- Парсинг объектов и массивов
- Парсинг $ref ссылок
- Парсинг enum
- Парсинг allOf (merge объектов)
- Парсинг oneOf (poly variants)
- Парсинг additionalProperties (Dict)
- Генерация ReScript кода для всех типов
- End-to-end: OpenAPI doc → ReScript module

## Ограничения

1. **sury-ppx на ARM64:** PPX бинарник только для x86-64. На ARM64 (Apple Silicon, некоторые Linux) нужен Rosetta или x86 окружение.

2. **Не поддерживается:**
   - `allOf` с не-объектными типами
   - Circular references (рекурсивные типы)
   - `discriminator` (OpenAPI 3.x)

## Использование

```bash
# Сборка
npx rescript build

# Запуск кодогена
node -e "
const OpenAPIParser = require('./src/OpenAPIParser.res.mjs');
const Codegen = require('./src/Codegen.res.mjs');
const fs = require('fs');

const doc = JSON.parse(fs.readFileSync('./openapi.json', 'utf8'));
const result = OpenAPIParser.parseDocument(doc);

if (result._tag === 'Ok') {
  fs.writeFileSync('./Generated.res', Codegen.generateModule(result._0));
}
"

# Тесты
npx jest src/tests/
```

## Будущие улучшения

- [ ] CLI инструмент для кодогенерации
- [ ] Watch mode для автоматической перегенерации
- [ ] Поддержка circular references
- [ ] Генерация API клиента (fetch functions)
- [ ] Интеграция с RTK Query codegen
