# Единая документация по компилятору

Этот файл объединяет ключевую документацию проекта в одном месте.

## Источник 1: docs/README.md

# ReScript to IC10 Compiler Documentation

**Complete documentation for the ReScript → IC10 assembly compiler**

## Quick Links

- 🚀 [Getting Started](#getting-started)
- 📚 [User Guides](#user-guides)
- 🏗️ [Architecture](#architecture)
- 💻 [Implementation Details](#implementation-details)
- 🧪 [Testing](#testing)
- 📦 [Archive](#archive)

---

## 🔥 Recent Updates

### 2025-12-30: Dead Code Elimination Enabled

**Major optimization improvement** - Re-enabled dead code elimination in the IR optimizer:

- ✅ **80% reduction** in register usage (furnace.res: 55 → 11 registers)
- ✅ **Fixed register overflow** - Complex programs now compile successfully
- ✅ **All tests passing** - 168/176 tests (8 skipped for future features)
- ✅ **Improved code quality** - Shorter, more efficient IC10 output

**Impact:** Programs that previously failed with "exceeded 16 registers" now compile successfully.

📖 [Read Full Changelog](CHANGELOG-DEAD-CODE-ELIMINATION.md)

---

## Getting Started

New to the compiler? Start here:

1. **[Compiler Overview](architecture/compiler-overview.md)** - Project structure, architecture, and development workflow
2. **[Language Reference](user-guide/language-reference.md)** - Complete ReScript subset language guide
3. **[IC10 Support](user-guide/ic10-support.md)** - IC10 assembly features and device operations

---

## User Guides

### Language and Usage

| Document                                               | Description                           |
| ------------------------------------------------------ | ------------------------------------- |
| [Language Reference](user-guide/language-reference.md) | Complete language syntax and features |
| [IC10 Support](user-guide/ic10-support.md)             | IC10 assembly language features       |
| [IC10 Bindings](user-guide/ic10-bindings.md)           | ReScript bindings for IC10 operations |
| [IC10 Usage Guide](user-guide/ic10-usage-guide.md)     | Practical IC10 programming guide      |

### Key Features

- ✅ Variables and arithmetic operations
- ✅ Control flow (if/else, while loops)
- ✅ Mutable references
- ✅ Variant types with pattern matching
- ✅ Device I/O operations
- ✅ Raw assembly instructions

---

## Architecture

### Core Design Documents

| Document                                                                 | Description                                                   |
| ------------------------------------------------------------------------ | ------------------------------------------------------------- |
| [Compiler Overview](architecture/compiler-overview.md)                   | High-level architecture and component design                  |
| [Compiler Development Rules](architecture/compiler-development-rules.md) | Project-level engineering rules and compiler invariants       |
| [Stack Layout](architecture/stack-layout.md)                             | IC10 stack operations and variant storage strategy            |
| [IR Design](architecture/ir-design.md)                                   | Intermediate Representation migration plan                    |
| [IR Reference](architecture/ir-reference.md)                             | Complete IR types, instructions, and examples                 |
| [IR Migration Report](architecture/ir-migration-report.md)               | Current migration status and progress                         |
| [Device I/O Operations](architecture/device-io.md)                       | Platform-agnostic device I/O design for multi-backend support |

### Backend Documentation

| Document                         | Description                                 |
| -------------------------------- | ------------------------------------------- |
| [WASM Backend](backends/WASM.md) | WebAssembly backend documentation and usage |

### Compiler Pipeline

```
ReScript Source
      ↓
   Lexer.res         → Tokenization
      ↓
   Parser.res        → AST Generation
      ↓
  Optimizer.res      → AST-level optimizations
      ↓
   ┌────────────────┐
   │ IR Pipeline    │
   ├────────────────┤
   │ IRGen.res      │ → IR generation
   │ IROptimizer    │ → IR optimizations
   └────────────────┘
      ↓
   ┌────────────────┐
   │   Backends     │
   ├────────────────┤
   │ IRToIC10.res   │ → IC10 assembly (default)
   │ IRToWASM.res   │ → WebAssembly text format
   └────────────────┘
      ↓
  Target Output (IC10 or WASM)
```

### Architecture Highlights

- **Hybrid ReScript/TypeScript**: Core compiler in ReScript, VSCode extension in TypeScript
- **16 Registers**: r0-r15 with intelligent register allocation and dead code elimination (70-80% reduction)
- **Fixed Stack Layout**: Variant types use pre-allocated stack regions
- **IR Layer**: Intermediate representation with 7 optimization passes (17% code reduction, 80% register reduction)

---

## Implementation Details

### Feature Implementation Guides

| Document                                                       | Description                                 |
| -------------------------------------------------------------- | ------------------------------------------- |
| [Loops](implementation/loops.md)                               | While loop implementation and optimizations |
| [Switch Statements](implementation/switch-statements.md)       | Pattern matching and variant switches       |
| [Variants](implementation/variants.md)                         | Complete variant type implementation        |
| [Implementation Notes](implementation/implementation-notes.md) | General implementation reference            |

### Key Implementation Patterns

#### Register Allocation

```rescript
// Variable registers: r0-r13 (low to high)
let x = 5         // → r0
let y = 10        // → r1

// Temp registers: r15-r14 (high to low)
switch state {
| Active(n) => n  // n → r15 (freed after case)
}
```

#### Stack Layout for Variants

```
type state = Idle | Active(int)

stack[0] = tag (0=Idle, 1=Active)
stack[1] = Active arg0
```

#### Branch Generation

```rescript
if x < y { ... }
→ blt r0 r1 then_label  // Direct branch (optimized)
```

---

## Testing

| Document                            | Description                |
| ----------------------------------- | -------------------------- |
| [IC10 Tests](testing/ic10-tests.md) | IC10 feature test coverage |

### Test Categories

- **Basic**: Variables, arithmetic, constant folding
- **Comparisons**: All comparison operators with if/else
- **Complex Expressions**: Operator precedence, mixed operations
- **Scoping**: Variable shadowing, nested blocks
- **Control Flow**: If/else, while loops, infinite loops
- **Variants**: Type declarations, pattern matching, switches
- **Error Handling**: Syntax errors, register exhaustion

### Running Tests

```bash
npm test                    # Run all tests
npm test loops              # Run specific test suite
npm run res:build          # Rebuild ReScript compiler
```

---

## Archive

### Changelogs

Detailed change logs for major features and fixes:

| Document                                                    | Date       | Description                                               |
| ----------------------------------------------------------- | ---------- | --------------------------------------------------------- |
| [Dead Code Elimination](CHANGELOG-DEAD-CODE-ELIMINATION.md) | 2025-12-30 | Re-enabled dead code elimination (80% register reduction) |
| [Function Block Ordering](CHANGELOG-FUNCTION-ORDERING.md)   | 2025-11-13 | Fixed function execution order bug                        |
| [IR Name Operand](CHANGELOG-IR-NAME-OPERAND.md)             | 2025-11-12 | Added Name operand support for constants                  |

### Historical Documents

Implementation records and debugging documentation:

| Document                                                        | Description                               |
| --------------------------------------------------------------- | ----------------------------------------- |
| [Implementation Plan](archive/implementation-plan.md)           | Original roadmap and performance analysis |
| [Implementation Complete](archive/implementation-complete.md)   | Completion milestone documentation        |
| [Switch Bug Investigation](archive/switch-bug-investigation.md) | Stack pointer corruption debugging        |
| [Fix Tests](archive/fix-tests.md)                               | Test suite fixes and updates              |

---

## Project Structure

```
rescript-ic10-compiler/
├── src/
│   ├── compiler/           # ReScript compiler core
│   │   ├── Lexer.res      # Tokenization
│   │   ├── Parser.res     # AST generation
│   │   ├── AST.res        # AST definitions
│   │   ├── StmtGen.res    # Statement code generation
│   │   ├── ExprGen.res    # Expression code generation
│   │   ├── BranchGen.res  # Control flow generation
│   │   ├── RegisterAlloc.res # Register management
│   │   ├── Codegen.res    # Main codegen orchestrator
│   │   └── IR/            # Intermediate representation
│   │       ├── IR.res     # IR definitions
│   │       ├── IRGen.res  # AST → IR conversion
│   │       ├── IROptimizer.res # IR-level optimizations
│   │       ├── IRPrint.res # IR pretty printer
│   │       └── IRToIC10.res # IR → IC10 lowering
│   └── extension.ts       # VSCode extension (TypeScript)
├── tests/                 # Jest test suites
├── docs/                  # Documentation (you are here!)
│   ├── user-guide/       # Language and usage guides
│   ├── architecture/     # Design documents
│   ├── implementation/   # Implementation details
│   ├── testing/          # Test documentation
│   └── archive/          # Historical documents
└── testing/              # Test files
    └── test.res         # Sample ReScript code
```

---

## Quick Reference

### Common Tasks

| Task             | Command                                 |
| ---------------- | --------------------------------------- |
| Compile ReScript | `npm run res:build`                     |
| Watch mode       | `npm run res:dev`                       |
| Run tests        | `npm test`                              |
| Test in VSCode   | Press `F5` → "Compile ReScript to IC10" |

### File Naming Conventions

- **User guides**: `lowercase-with-dashes.md`
- **Architecture**: `descriptive-name.md`
- **Implementation**: `feature-name.md`
- **Archive**: `original-purpose.md`

### Documentation Best Practices

- ✅ Use relative links for cross-referencing
- ✅ Include code examples with expected output
- ✅ Explain both "what" and "why"
- ✅ Keep examples simple and focused
- ✅ Update docs when features change

---

## Contributing

When adding new features or fixing bugs:

1. Update relevant documentation
2. Add test cases
3. Update CLAUDE.md if architecture changes
4. Consider adding examples to user guides

---

## Support & Resources

- **Stationeers IC10 Wiki**: [Official IC10 Documentation](https://stationeers-wiki.com/IC10)
- **ReScript Documentation**: [rescript-lang.org](https://rescript-lang.org)
- **VSCode Extension API**: [code.visualstudio.com/api](https://code.visualstudio.com/api)

---

## Document Index

### By Category

**User Guides**

- Language Reference
- IC10 Support
- IC10 Bindings
- IC10 Usage Guide

**Architecture**

- Compiler Overview
- Stack Layout
- IR Design
- Device I/O Operations

**Implementation**

- Loops
- Switch Statements
- Variants
- Implementation Notes

**Testing**

- IC10 Tests

**Archive**

- Implementation Plan
- Implementation Complete
- Switch Bug Investigation
- Fix Tests

---

**Last Updated**: 2025-11-13
**Documentation Version**: 2.0
**Compiler Version**: See package.json

---

## Источник 2: docs/architecture/compiler-development-rules.md

# Правила разработки компилятора (проектные договоренности)

Этот документ фиксирует ключевые инженерные правила, к которым проект пришел в процессе развития IR-пайплайна и backend-ов.

## 1) Единый конвейер компиляции

- Используем только цепочку: `Lexer -> Parser -> Optimizer -> IRGen -> IROptimizer -> Backend`.
- Прямые обходы `AST -> backend` считаются легаси и не должны использоваться для новых фич.
- Выбор backend (`IC10`/`WASM`) происходит только после оптимизации IR.

## 2) IR — центральный и обязательный слой

- IR является границей между frontend-частью языка и целевыми backend-ами.
- Новые языковые возможности сначала выражаются в IR, затем понижаются в backend.
- Любая бизнес-логика, завязанная на конкретную платформу, не должна просачиваться обратно в AST-уровень.

## 3) IR должен оставаться backend-агностичным

- Для device I/O в IR используем абстракции `DeviceLoad`/`DeviceStore` и тип `device`.
- Свойства/режимы (`"Temperature"`, `"Maximum"` и т.д.) передаются как строки на уровне IR.
- Платформо-специфичный выбор конкретной инструкции (`l/lb/lbn/s/sb/sbn`) выполняется только в backend (`IRToIC10`).

## 4) Exhaustive-обработка всех вариантов IR

- При добавлении нового `operand`/`instr` в `IR.res` обязательно обновлять все потребители:
  - `IRGen.res`
  - `IROptimizer.res`
  - `IRToIC10.res`
  - `IRToWASM.res` (если затронуто)
  - `IRPrint.res`
- Pattern-match warning по новому варианту считается блокирующей проблемой, а не "косметикой".

## 5) Регистровая стратегия: virtual first, physical later

- В IR используем неограниченные виртуальные регистры (`vreg`).
- Отображение `vreg -> r0..r15` выполняется только в lowering (`IRToIC10`).
- Ограничение IC10 в 16 физических регистров является жестким: при превышении компиляция должна падать с явной ошибкой.

## 6) Оптимизации до аллокации физических регистров — обязательны

- `IROptimizer` должен выполняться до `IRToIC10`.
- Dead code elimination не отключаем ради совместимости со старыми тест-ожиданиями.
- При изменении оптимизаций обновляем тесты, а не вырезаем оптимизационные проходы.

## 7) Правило генерации ветвлений

- На IR-уровне условная логика строится через `Compare + Bnez`.
- `if` без `else` и `while` используют инвертированное сравнение (jump при FALSE-ветке условия).
- На этапе `IRToIC10` допускается peephole-фьюзинг `Compare + Bnez` в прямые ветки (`blt/bgt/beq/...`).

## 8) Правило порядка функций в выходном коде

- Главный блок программы всегда идет первым.
- Блоки функций размещаются после main-блока.
- Между main и функциями добавляется защитный переход в `__end` (и бесконечный цикл), чтобы исключить fall-through в тело функций.

## 9) Инварианты stack layout для variant/ref

- `sp` инициализируется один раз при выделении памяти и далее не двигается в runtime-операциях с variant-данными.
- Доступ к variant-данным делаем через адресный доступ (`StackGet`/`StackPoke` -> `get db`/`poke`).
- Паттерн с runtime-манипуляцией `sp` для чтения (`move sp ...; peek`) считается ошибочным для нашей модели.
- Слоты под варианты выделяются заранее фиксированным layout.

## 10) Ограничение модели вариантов

- Для одного variant-типа поддерживается только один активный `ref` (ограничение текущей stack-модели).
- Это ограничение должно оставаться явным в диагностике компилятора и в документации.

## 11) Константы и hash-значения

- Для именованных констант используем IR-форму `DefInt`/`DefHash` + `Name`/`Hash` operands.
- Любые оптимизации подстановки констант должны сохранять корректность define-инструкций в финальном выводе.

## 12) Тесты — часть контракта компилятора

- Любое изменение IR/optimizer/backend сопровождается обновлением и прогоном тестов.
- Сравнение кода в тестах допускает "другой, но эквивалентный" вывод только если это осознанный эффект оптимизации и он закреплен в тест-ожиданиях.
- Отдельно контролируем регрессии по:
  - регистровому давлению и overflow,
  - switch/variant поведению,
  - функциям и порядку исполнения,
  - device I/O lowering.

## 13) Документация обновляется вместе с архитектурными изменениями

- При изменении инвариантов или lowering-правил обновляем архитектурные документы и changelog.
- Документация по IR является source of truth для новых доработок.

## Краткий checklist перед merge

1. Фича выражена в IR, а не "вшита" в backend напрямую.
2. Обновлены все pattern-match потребители IR.
3. Пройдены оптимизации до lowering.
4. Не нарушены stack/variant инварианты (`sp`, fixed layout, one-ref-per-type).
5. Обновлены тесты и документация.
