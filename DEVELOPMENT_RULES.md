# Правила разработки osury

Этот файл содержит инварианты проекта — правила, которые нельзя нарушать ни при каких обстоятельствах. Каждое правило проверено практикой и защищает от конкретных классов ошибок.

---

## Правило 1. Единый конвейер

Весь код проходит строгий конвейер:

```
OpenAPI JSON → Schema.parse → SchemaAST → Codegen.generateModule → ReScript code
                                  ↑
                        OpenAPIParser.parseDocument
                        (извлекает schemas из документа)
```

Нельзя генерировать ReScript-код напрямую из JSON. Codegen.res работает только с `Schema.schemaType`, никогда с `JSON.t` или `Dict.t<JSON.t>`.

**Почему:** Если Codegen начнёт парсить JSON, мы потеряем единую точку валидации, и ошибки станут непредсказуемыми.

---

## Правило 2. SchemaAST — единственный источник истины

Тип `Schema.schemaType` определяет всё, что компилятор умеет обрабатывать. Новая OpenAPI-конструкция поддерживается тогда и только тогда, когда она выражена в `schemaType`.

Текущие варианты (17):
```
String | Number | Integer | Boolean | Null
| Optional(schemaType) | Nullable(schemaType)
| Object(array<field>) | Array(schemaType)
| Ref(string) | Enum(array<string>)
| PolyVariant(array<variantCase>)
| Dict(schemaType) | Union(array<schemaType>)
| AllOf(array<schemaType>)
| Unknown
| Refined(schemaType, array<refinement>)
```

`AllOf` — пересечение (`allOf`). Парсер **не** мержит арматы: `$ref`-арм
резолвится только по всему документу, которого `Schema.parse` не видит. Мерж —
отдельный шаг пайплайна (`CodegenTransforms.mergeAllOf`, Правило 6, шаг -3).

`Refined` — прозрачная обёртка: она сужает множество допустимых ЗНАЧЕНИЙ, но не
меняет форму типа. Поэтому подавляющее большинство потребителей обрабатывает её
рекурсией на базовый тип (`| Refined(inner, _) => f(inner)`), а не отдельной
логикой. См. Правило 14.

**При добавлении нового варианта** — обязательно обновить всех потребителей (см. Правило 3).

---

## Правило 3. Exhaustive pattern-match

При добавлении нового варианта в `schemaType` нужно обновить ВСЕ функции, которые делают `switch` по этому типу. Неполный pattern-match — блокирующая ошибка.

### Список потребителей schemaType

**Schema.res** (парсинг):
- Возвращает `schemaType` — нужно добавить парсинг нового варианта

**SampleData.res** (примеры данных):
- `generate` — пример должен удовлетворять собственным ограничениям, иначе
  сгенерированный пример не проходит схему, которую иллюстрирует

**CodegenHelpers.res** (утилиты):
- `isOptionalType` — проверка на Optional/Nullable обёртку
- `isNullableType` — проверка на Nullable
- `getTagForType` — имя тега для poly variant
- `hasUnion` — рекурсивный поиск Union в дереве типов
- `isPrimitiveOnlyUnion` — проверка что union содержит только примитивы

**IRGen.res** (SchemaAST → IR):
- `convertType` — перевод варианта в `IR.irType`
- `generate` — оркестратор пайплайна (Правило 6)

**CodegenTransforms.res** (трансформации AST):
- `extractUnionsFromType` — извлечение Union для выделения в отдельный тип
- `replaceUnionInType` — замена Union на Ref после извлечения
- `getDependencies` — сбор Ref-зависимостей для топологической сортировки
- `typeNamePart` / `getUnionName` — структурное имя для union
- `structuralKey` — каноничный ключ структуры (дедуп извлечённых union-ов)
- `validateRefs`, `mergeAllOf`, `stripRefinementsInType`, `dedupeUnionsInType`
- `collectUnionWarnings` → `findUnions` — поиск union для диагностики

**Backend*.res** (IR → код): `BackendReScript`, `BackendOCaml`, `BackendRust`,
`BackendEffectTS` — печатают `IR.irType`, по schemaType не матчатся.

**Codegen.res** (фасад):
- Реэкспортирует всё из подмодулей, содержит `generateModule` оркестратор

**Errors.res:**
- Может потребовать новый `errorKind` для ошибок парсинга нового варианта

**bin/osury.mjs:**
- CLI обычно не требует изменений (работает через Codegen.generateModule), но проверить вывод

### Wildcard в трансформациях запрещён

В функциях, которые матчатся по `schemaType` (`CodegenTransforms`, `IRGen`,
`CodegenHelpers`, `SampleData`), ветки `| _ =>` и `| other =>` **запрещены** —
перечисляй варианты явно. Wildcard молча проглатывает новый вариант: warning 8
(рабочий чеклист Правила 3) на него не срабатывает, и трансформация тихо
перестаёт спускаться в новую конструкцию. Именно так `Refined` оказался
необойдённым в шести функциях, а вложенный union — невалидированным.

**Чеклист добавления нового варианта:**
1. [ ] Добавить вариант в `schemaType` (Schema.res)
2. [ ] Реализовать парсинг из JSON (Schema.res)
3. [ ] Добавить перевод в IR (`IRGen.convertType`) и печать в бэкендах
4. [ ] Обновить утилиты: hasUnion, getTagForType, isPrimitiveOnlyUnion (CodegenHelpers.res)
5. [ ] Обновить трансформации: extractUnionsFromType, replaceUnionInType, getDependencies, getUnionName (CodegenTransforms.res)
6. [ ] Добавить тест парсинга + тест генерации кода
7. [ ] Проверить что `npm run res:build` проходит без warnings
8. [ ] Проверить что сгенерированный код компилируется ReScript-ом

---

## Правило 4. Результат вместо исключений

Все функции парсинга возвращают `result<T, Errors.errors>`. Исключения запрещены в логике компилятора.

```rescript
// Правильно:
let parse: JSON.t => result<schemaType, errors>

// Запрещено:
let parse: JSON.t => schemaType  // может бросить исключение
```

Ошибки накапливаются: парсер не останавливается на первой ошибке, а собирает все и возвращает массив.

---

## Правило 5. Структурированные ошибки с location

Каждая ошибка содержит:
- `kind: errorKind` — что именно сломалось (типизированный вариант, не строка)
- `location: { path }` — где сломалось, JSON-путь: `["Order", "items", "anyOf[1]"]`.
  Строк/колонок нет: на входе распарсенный `JSON.t` без позиций
- `hint: option<string>` — как починить (когда возможно)

Все parse-функции `Schema.res` принимают `~path: array<string>` и передают его
дальше: свойство объекта добавляет своё имя, `items`/`additionalProperties` —
своё, арм union'а — `anyOf[i]`/`oneOf[i]`. Ошибка без пути — баг.

**Нельзя** создавать ошибки со строковым сообщением без структуры. Для каждого нового класса ошибки — добавить вариант в `errorKind`.

---

## Правило 6. Трансформации до генерации кода

Пайплайн (IRGen.generate) выполняет трансформации в определённом порядке.
Порядок — **данные**, а не проза: массивы `IRGen.normalizeStages` /
`IRGen.expandStages`, каждый шаг с именем и комментарием «почему здесь». Тест
`Pipeline order` фиксирует последовательность имён — перестановка шагов
становится осознанным действием, а не побочным эффектом правки. Между двумя
половинами собираются warning'и (на нормализованном AST, до промоушена enum'ов).

Этот порядок менять нельзя:

```
-4. validateRefs               — каждый Ref(name) должен резолвиться; иначе
                                 InvalidRef с путём, где $ref написан
-3. mergeAllOf                 — пересечения allOf → один Object; $ref-армы
                                 резолвятся по документу, ошибка InvalidRef /
                                 CircularReference / UnsupportedFeature иначе
-1. stripRefinements           — снятие Refined, когда refinements не запрошены
                                 (Правило 14); при ~refinements=true шаг пропускается
0. collapseLiteralUnions       — нормализация: union из строковых литералов
                                 (enum/const, в т.ч. за $ref) → один merged Enum
1. validateUnionDiscriminators — ошибки для union-ов объектов без дискриминатора
2. collectUnionWarnings        — диагностика проблемных union-паттернов
3. enum promotion              — inline Enum → именованные top-level типы
                                 (collect → guard на коллизии → resolve names → replace)
3.5 extractInlineRecords       — вложенные Object → именованные типы
                                 (Правило 17: inline record легален только
                                 в payload'е варианта)
4. extractUnions               — извлечение inline Union в отдельные именованные типы
5. deduplicate                 — дедупликация по структурному имени
6. replaceUnions               — замена inline Union на Ref(extractedName)
7. buildSchemasDict            — словарь для inline record lookups
8. topologicalSort             — Кahn's algorithm для порядка определений
9. convert to IR → print       — генерация кода (BackendReScript и др.)
```

**Почему:** Мерж allOf идёт первым — все последующие шаги считают, что типы уже
плоские объекты. Collapse должен быть до валидации — литеральный union не имеет свойства для дискриминатора и после схлопывания в нём не нуждается. Enum promotion должен быть до union extraction, чтобы последующие проходы видели Ref вместо сырых Enum внутри Union/PolyVariant. Union extraction должен быть до topological sort, иначе зависимости от извлечённых типов не будут учтены. Генерация должна быть последней, потому что она только печатает — не трансформирует.

---

## Правило 7. @schema совместимость

Аннотация `@schema` (sury-ppx) генерируется для типа, только если тип совместим с sury-ppx:
- Inline Union-ы **несовместимы** с @schema → поэтому они извлекаются в отдельные типы (Правило 6)
- Извлечённые Union-типы получают `@tag("_tag")` + `@schema`
- Union-ы, чьи ветки различимы по **runtime-форме**, дополнительно получают
  `@unboxed` и НЕ требуют дискриминатора: ReScript и sury выбирают ветку по
  форме значения. Это и примитивные (`String | Number`), и смешанные
  (`Object | Number`, `Object | Array`) — см. `CodegenHelpers.runtimeShapeOf`.

**Дискриминатор обязателен только когда ветки неразличимы** — два объектных
`$ref`, `int | float` (обе JS-number), вложенный union. Требовать тег там, где
формы различны, — вредно: тег заставляет ожидать на проводе `_tag`, которого
бэкенд не шлёт, и такой тип не парсит НИ ОДНУ реальную форму данных.

**Нельзя** ставить `@schema` на тип, пока не проверена совместимость с sury-ppx.

Отсутствие sury-схемы **транзитивно**: если у типа нет `<name>Schema`, его не
может быть и у всех, кто на него ссылается. Любая новая причина «схемы нет»
регистрируется в `CodegenTransforms.buildSkipSchemaSet` (там каскад по
зависимостям), а не решается точечно в `IRGen` — иначе потребитель сохраняет
`@schema` и ppx ссылается на несуществующее значение.

---

## Правило 8. Аннотации генерируемого кода

Каждый сгенерированный тип обязательно получает:
- `@genType` — для генерации TypeScript-типов
- `@schema` — для генерации Sury-схем (если совместим, см. Правило 7)

Variant-типы дополнительно получают:
- `@tag("_tag")` — дискриминант по умолчанию в стиле Effect TS (не стандартный `TAG`)
- Если OpenAPI указывает `discriminator: { propertyName: "type" }`, используется `@tag("type")` — дискриминант **должен** совпадать с тем, что API реально присылает в JSON, иначе sury-парсинг упадёт в рантайме

**По умолчанию** `_tag`, но `discriminator.propertyName` из OpenAPI spec перекрывает дефолт.

---

## Правило 9. Порядок типов в выходном файле

Типы определяются в порядке топологической сортировки: тип X должен быть определён ДО типов, которые на него ссылаются через `Ref(X)`.

Для циклических зависимостей (circular refs) — типы добавляются в конец. На данный момент circular refs не поддерживаются полноценно и должны давать явную диагностику, а не молча ломаться.

---

## Правило 10. Reserved keywords

Если имя поля JSON совпадает с ключевым словом ReScript (type, let, module и т.д.), генератор обязан:
1. Использовать `@as("originalName")` атрибут
2. Добавить суффикс `_` к имени поля: `type_` вместо `type`

Список ключевых слов определён в `Codegen.reservedKeywords` и должен обновляться при обновлении версии ReScript.

---

## Правило 11. Тесты — часть контракта

Каждый поддерживаемый OpenAPI-конструкт покрыт минимум двумя тестами:
1. **Тест парсинга:** JSON → SchemaAST (проверяет структуру AST)
2. **Тест генерации:** SchemaAST → ReScript code (проверяет строку выхода)

Для сложных паттернов (union extraction, deduplication, topological sort) — отдельные тесты трансформаций.

**TDD-правило:** один тест за раз. Написать тест → красный → реализовать → зелёный → commit.

---

## Правило 12. _tag фильтрация

Поле `_tag` в JSON Schema **всегда** пропускается при парсинге properties объекта. Оно обрабатывается через `@tag("_tag")` аннотацию на уровне variant-типа, а не как обычное поле записи.

Это относится к:
- `parseObjectType` в Schema.res (фильтрация `_tag` из properties)
- `parseOneOf` в Schema.res (извлечение `_tag.const` как дискриминатора, остальные properties как payload)

---

## Правило 13. Shim-файлы генерируются вместе с основным кодом

CLI (`bin/osury.mjs`) генерирует не только основной `.res` файл, но и обязательные shim-ы:
- `Dict.gen.ts` — TypeScript-тип для `Dict.t<T>`
- `Nullable.res` — ReScript-модуль для `Nullable.t<'a> = option<'a>`
- `Nullable.shim.ts` — TypeScript-маппинг `t<T> = T | null`

**Нельзя** генерировать `.res` файл без shim-ов, если в схеме используются Dict или Nullable типы.

---

## Правило 14. Refinements опциональны на выходе, обязательны в AST

`Refined` появляется в AST **всегда**, когда спека содержит validation keywords
(`format`, `minLength`, `maximum`, `pattern`, ...). AST описывает спеку, а не
запрос пользователя.

Но печать этих проверок меняет то, что сгенерированный код **принимает в
рантайме**: данные, раньше проходившие парсинг, начнут падать. Поэтому вывод
opt-in: `IRGen.generate(schemas, ~refinements=true, ())` (CLI: `--refinements`).
Без флага `CodegenTransforms.stripRefinements` снимает обёртки первым шагом
пайплайна, и выход байт-в-байт совпадает с выходом без поддержки refinements.

**Нельзя** делать печать refinements поведением по умолчанию без явного решения
владельца контракта — это молчаливое ужесточение проверок у всех потребителей.

Печатают refinements **все** бэкенды, каждый — тем, что его цель умеет:

| Проверка | ReScript/sury | Effect TS | OCaml | Rust |
|---|---|---|---|---|
| minLength/maxLength, minimum/maximum, exclusive*, multipleOf | да | `.check(Schema.is*)` | guard в декодере (`Oj.check_`) | `#[serde(deserialize_with)]` |
| pattern | да | `Schema.isPattern` | нет (нужен regex-модуль) | нет (нужен crate) |
| format | да (`S.uuid`, `S.email`, ...) | только `uuid` | нет | нет |

Чего цель не умеет — **не молчит**: `Backend*.droppedRefinements` возвращает
warning на каждую (тип, проверка), и они попадают в вывод CLI. Своих регулярок
для email/uri осознанно не пишем: они разошлись бы с тем, что реально проверяет
sury, и одна спека начала бы значить разное на разных целях.

Соответствие sury:
- `format` → `@s.matches(S.uuid)` — **заменяет** базовую схему (не оборачивает)
- остальные → `@s.with(S.minLength(_, 3))` — оборачивают, применяются по порядку
- границы для `Integer` печатаются int-литералом, для `Number` — float-литералом
  (`S.gte: (t<'value>, 'value)` требует значение того же типа)

---

## Правило 15. `Null` матчится явно при обходе `JSON.t`

В любом `switch` по `JSON.t`, где есть ветка `Object(dict)`, ветка `Null`
пишется **явно** — нельзя складывать её в `| _ =>`.

Причина в кодогенерации ReScript, а не в семантике: для такой формы матча
компилятор строит диспетчер `switch (typeof json) { case "object": ... }`, и
`Null` попадает в него вместе с объектами, потому что в JS
`typeof null === "object"`. Проверки `!== null` в этой ветке не появляется, и
первое же чтение поля падает с `Cannot read properties of null`.

```rescript
// НЕПРАВИЛЬНО — null уходит в ветку Object и падает в рантайме
switch json {
| Object(dict) => dict->Dict.get("anyOf")->...
| Array(items) => items->Array.forEach(walk)
| _ => ()
}

// ПРАВИЛЬНО
switch json {
| Null => ()
| Object(dict) => dict->Dict.get("anyOf")->...
| Array(items) => items->Array.forEach(walk)
| _ => ()
}
```

Особенно опасны рекурсивные обходы документа (`extractFieldDiscriminators`,
`extractAllDiscriminatorMappings`): они спускаются в **каждое** значение, а
`null` в спеке — норма (`default: null`, `example: null`). Один такой узел
роняет весь запуск.

Проверка: после `npm run res:build` в `.mjs` перед `case "object"` должен стоять
`if (x === null) return;`.

---

## Правило 16. Из paths типизируется весь JSON-контракт

Для каждой операции извлекаются:
- `requestBody.content.application/json.schema` → `{Method}{Path}Request`
- каждый 2xx-ответ с JSON-телом → `{Method}{Path}Response` (200, иначе 201,
  иначе первый по документу) и `{Method}{Path}Response{код}` для остальных
- `parameters` (query + path, без headers) → `{Method}{Path}Params`

Ответы без тела (204) и не-JSON media types типов не дают.

**4xx/5xx не типизируются — решено 2026-09-02, вопрос закрыт.**

Причина не в лени, а в замере: в обеих продовых спеках (Math 140 операций,
Core 83) **все 153 тела ошибок — `$ref` на компонент**, инлайновых нет, ключа
`default` нет, не-JSON тел нет. Значит типы ошибок (`HTTPValidationError`,
`ProductReportErrorResponse`, `OAuthDetailError`) уже сгенерированы как обычные
компоненты, и ничего не теряется.

Симметричное правило (`{Method}{Path}Response422`) дало бы в Math 140 алиасов
вида `type getXResponse422 = httpValidationError` — +25% к размеру выхода при
нуле новой информации. Это ровно тот шум, которого правило «генерируем, только
когда добавляем информацию» (см. 204 и не-JSON тела) и должно избегать.

Что осталось незакрытым и когда к этому вернуться:
- **Inline-тело ошибки** сегодня не даёт типа. В текущих спеках таких нет, но
  это свойство FastAPI/DRF, а не гарантия. Если появится — генерировать
  `{Method}{Path}Error{Code}` только для inline-схем.
- **Отображение «операция → код → тип»** в выходе отсутствует. Оно станет
  нужным, когда osury начнёт генерировать не только типы, но и клиентские
  функции; тогда — per-operation union `{Method}{Path}Error` с `@as` на кодах,
  под флагом.
- Фильтровать в обоих случаях надо не «4xx», а «не-2xx с JSON-телом» плюс
  `default`: в Core ошибки приходят как 502.

---

## Правило 17. Inline record — только в конструкторе варианта

ReScript принимает анонимную запись `{ a: string }` лишь как payload
конструктора варианта. В поле записи, элементе массива, значении словаря или
под `option`/`Nullable` она — синтаксическая ошибка с крайне неинформативным
сообщением «The module or file <field> can't be found».

Поэтому шаг `extractInlineRecords` (Правило 6) поднимает каждый вложенный
`Object` в отдельный именованный тип (`holder.rows` → `holderRows`), оставляя
inline-записи только там, где они легальны: в армах union'а и payload'ах
вариантов.

Проверка: тест `Generated ReScript compiles` реально компилирует выход
синтетической спеки с sury-ppx — это единственный способ поймать такие ошибки
до потребителя.

---

## Правило 18. Нижняя граница sury — `>=11.0.0-rc.2`

`sury 11.0.0-rc.1` неверно компилирует union, одна из веток которого содержит
optional/nullable поле: ветка на позиции ≥ 2 перестаёт матчиться **и ломает все
последующие**. На rc.1 это ровно та форма, которую osury печатает чаще всего —
`@tag(...)` вариант из oneOf. В контракте Nyle Math 35 из 39 вариантов с ≥3
ветками несут `option`/`Nullable`.

Воспроизводится на голом sury и на сгенерированном модуле; на rc.2 всё зелёное.
Поэтому `peerDependencies` требуют `>=11.0.0-rc.2` — с rc.1 генерируемый код
компилируется, но молча не парсит данные.

**Вывод шире одной версии:** компиляции выхода недостаточно. Тест
`Generated ReScript parses real data` (`src/tests/rescript-compiles.test.mjs`)
собирает модуль и **исполняет** его схему на настоящих данных — как это давно
делают OCaml/Rust/Effect-TS бэкенды. Баг такого класса ловится только так.

---

## Checklist перед merge

Проверяется при каждом изменении:

1. [ ] **Конвейер:** Новая функциональность выражена через SchemaAST, Codegen не парсит JSON напрямую
2. [ ] **Pattern-match:** Все потребители `schemaType` обновлены (см. список в Правиле 3)
3. [ ] **Тесты:** Добавлен тест парсинга И тест генерации для нового конструкта
4. [ ] **Сборка:** `npm run res:build` проходит без warnings
5. [ ] **Тесты зелёные:** `npm test` проходит полностью
6. [ ] **Выход компилируется:** покрыто тестом `Generated ReScript compiles` (синтетическая спека + sury-ppx); на реальной спеке — `npm run codegen` и сборка
7. [ ] **Shim-ы актуальны:** Если добавлены новые TypeScript-шимы, они включены в `package.json` files
8. [ ] **Ошибки информативны:** Новые ошибочные пути дают структурированную диагностику (kind + location + hint)
9. [ ] **`Null` явно:** Новые обходы `JSON.t` матчат `Null` отдельной веткой (Правило 15)
10. [ ] **Выход исполняется:** схема сгенерированного модуля парсит реальные данные, а не только компилируется (Правило 18)
