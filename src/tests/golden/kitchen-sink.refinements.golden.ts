import { Schema, SchemaGetter } from 'effect'

export const StringOrInt = Schema.Union([Schema.String, Schema.Int])
export type StringOrInt = Schema.Schema.Type<typeof StringOrInt>

export const StringOrArrayBool = Schema.Union([Schema.String, Schema.Array(Schema.Boolean)])
export type StringOrArrayBool = Schema.Schema.Type<typeof StringOrArrayBool>

export const ContainersNested = Schema.Struct({
  deep: Schema.Array(Schema.Record(Schema.String, Schema.String)),
})
export type ContainersNested = Schema.Schema.Type<typeof ContainersNested>

export const InlineEnum = Schema.Literals(['on', 'off'])
export type InlineEnum = Schema.Schema.Type<typeof InlineEnum>

export const LiteralUnion = Schema.Literals(['yes', 'no'])
export type LiteralUnion = Schema.Schema.Type<typeof LiteralUnion>

export const IssueLoopKind = Schema.Literals(['loop_found'])
export type IssueLoopKind = Schema.Schema.Type<typeof IssueLoopKind>

export const IssueBrokenLinkKind = Schema.Literals(['broken_link'])
export type IssueBrokenLinkKind = Schema.Schema.Type<typeof IssueBrokenLinkKind>

export const Order = Schema.Literals(['asc', 'desc'])
export type Order = Schema.Schema.Type<typeof Order>

export const Scalars = Schema.Struct({
  s: Schema.String,
  f: Schema.Number,
  i: Schema.Int,
  b: Schema.Boolean,
  nothing: Schema.Null,
  anything: Schema.Unknown,
  opt: Schema.optionalKey(Schema.NullOr(Schema.String)),
  with_default: Schema.optionalKey(Schema.NullOr(Schema.Int)),
})
export type Scalars = Schema.Schema.Type<typeof Scalars>

export const Refined = Schema.Struct({
  id: Schema.String.check(Schema.isUUID()),
  email: Schema.String,
  site: Schema.String,
  created_at: Schema.String,
  slug: Schema.String.check(Schema.isMinLength(3), Schema.isMaxLength(32), Schema.isPattern(/^[a-z-]+$/)),
  ratio: Schema.Number.check(Schema.isGreaterThanOrEqualTo(0), Schema.isLessThanOrEqualTo(1)),
  count: Schema.Int.check(Schema.isGreaterThan(0), Schema.isMultipleOf(5)),
})
export type Refined = Schema.Schema.Type<typeof Refined>

export const Keywords = Schema.Struct({
  type: Schema.String,
  module: Schema.String,
  and: Schema.Boolean,
  external: Schema.Int,
})
export type Keywords = Schema.Schema.Type<typeof Keywords>

export const Size = Schema.Literals(['small', 'medium', 'large'])
export type Size = Schema.Schema.Type<typeof Size>

export const Phase = Schema.Tuple([Schema.Literals(['Draft', 'Done'])]).pipe(
  Schema.decodeTo(
    Schema.Literals(['Draft', 'Done']),
    {
      decode: SchemaGetter.transform(([s]) => s),
      encode: SchemaGetter.transform((s) => [s] as const),
    },
  ),
)
export type Phase = Schema.Schema.Type<typeof Phase>

export const Measure = Schema.Struct({
  value: Schema.Number,
  unit: Schema.String,
})
export type Measure = Schema.Schema.Type<typeof Measure>

export const Base = Schema.Struct({
  id: Schema.String,
  created_at: Schema.String,
})
export type Base = Schema.Schema.Type<typeof Base>

export const Node = Schema.Struct({
  name: Schema.String,
  children: Schema.Array(Node),
  parent: Schema.NullOr(Node),
})
export type Node = Schema.Schema.Type<typeof Node>

export const EventCreated = Schema.Struct({
  at: Schema.String,
})
export type EventCreated = Schema.Schema.Type<typeof EventCreated>

export const EventDeleted = Schema.Struct({
  reason: Schema.String,
})
export type EventDeleted = Schema.Schema.Type<typeof EventDeleted>

const _MarkShine = Schema.Struct({
  Shine: Schema.Struct({
    target: Schema.String,
  }),
}).pipe(
  Schema.decodeTo(
    Schema.Struct({
      _tag: Schema.Literal('Shine'),
      target: Schema.String,
    }),
    {
      decode: SchemaGetter.transform(({ Shine }) => ({ _tag: 'Shine' as const, ...Shine })),
      encode: SchemaGetter.transform(({ _tag: _t, ...rest }) => ({ Shine: rest })),
    },
  ),
)

const _MarkTint = Schema.Struct({
  Tint: Schema.Struct({
    level: Schema.Int,
  }),
}).pipe(
  Schema.decodeTo(
    Schema.Struct({
      _tag: Schema.Literal('Tint'),
      level: Schema.Int,
    }),
    {
      decode: SchemaGetter.transform(({ Tint }) => ({ _tag: 'Tint' as const, ...Tint })),
      encode: SchemaGetter.transform(({ _tag: _t, ...rest }) => ({ Tint: rest })),
    },
  ),
)

export const Mark = Schema.Union([_MarkShine, _MarkTint])
export type Mark = Schema.Schema.Type<typeof Mark>

export const PostV1WidgetsResponse202 = Schema.Struct({
  job_id: Schema.String,
})
export type PostV1WidgetsResponse202 = Schema.Schema.Type<typeof PostV1WidgetsResponse202>

export const GetV1Widgets_widget_idParams = Schema.Struct({
  widget_id: Schema.String.check(Schema.isUUID()),
})
export type GetV1Widgets_widget_idParams = Schema.Schema.Type<typeof GetV1Widgets_widget_idParams>

export const PatchV1Widgets_widget_idRequest = Schema.Struct({
  weight: Schema.optionalKey(Schema.NullOr(Schema.Number)),
})
export type PatchV1Widgets_widget_idRequest = Schema.Schema.Type<typeof PatchV1Widgets_widget_idRequest>

export const MixedAlias = Schema.Array(StringOrArrayBool)
export type MixedAlias = Schema.Schema.Type<typeof MixedAlias>

export const Containers = Schema.Struct({
  tags: Schema.Array(Schema.String),
  matrix: Schema.Array(Schema.Array(Schema.Int)),
  by_key: Schema.Record(Schema.String, Schema.Number),
  free_form: Schema.Record(Schema.String, Schema.Unknown),
  nested: ContainersNested,
})
export type Containers = Schema.Schema.Type<typeof Containers>

export const IssueLoop = Schema.Struct({
  kind: IssueLoopKind,
  path: Schema.Array(Schema.String),
})
export type IssueLoop = Schema.Schema.Type<typeof IssueLoop>

export const IssueBrokenLink = Schema.Struct({
  kind: IssueBrokenLinkKind,
  from: Schema.String,
  to: Schema.String,
})
export type IssueBrokenLink = Schema.Schema.Type<typeof IssueBrokenLink>

export const GetV1WidgetsParams = Schema.Struct({
  limit: Schema.Int.check(Schema.isGreaterThanOrEqualTo(1), Schema.isLessThanOrEqualTo(100)),
  cursor: Schema.optionalKey(Schema.NullOr(Schema.String)),
  order: Schema.optionalKey(Schema.NullOr(Order)),
})
export type GetV1WidgetsParams = Schema.Schema.Type<typeof GetV1WidgetsParams>

export const Nullables = Schema.Struct({
  maybe_text: Schema.NullOr(Schema.String),
  maybe_size: Schema.NullOr(Size),
  maybe_list: Schema.NullOr(Schema.Array(Schema.String)),
  only_one: Schema.String,
  inline_enum: InlineEnum,
  literal_union: LiteralUnion,
})
export type Nullables = Schema.Schema.Type<typeof Nullables>

export const Widget = Schema.Struct({
  id: Schema.String,
  created_at: Schema.String,
  size: Size,
  weight: Schema.Number,
})
export type Widget = Schema.Schema.Type<typeof Widget>

export const MeasureOrFloat = Schema.Union([Measure, Schema.Number])
export type MeasureOrFloat = Schema.Schema.Type<typeof MeasureOrFloat>

const _EventEventCreated = Schema.Struct({
  _tag: Schema.Literal('EventCreated'),
  at: Schema.String,
})

const _EventEventDeleted = Schema.Struct({
  _tag: Schema.Literal('EventDeleted'),
  reason: Schema.String,
})

export const Event = Schema.Union([_EventEventCreated, _EventEventDeleted])
export type Event = Schema.Schema.Type<typeof Event>

const _IssueLoopOrIssueBrokenLinkIssueLoop = Schema.Struct({
  kind: Schema.Literal('IssueLoop'),
  path: Schema.Array(Schema.String),
}).pipe(
  Schema.decodeTo(
    Schema.Struct({
      _tag: Schema.Literal('IssueLoop'),
      path: Schema.Array(Schema.String),
    }),
    {
      decode: SchemaGetter.transform(({ kind: _k, ...rest }) => ({ _tag: 'IssueLoop' as const, ...rest })),
      encode: SchemaGetter.transform(({ _tag: _t, ...rest }) => ({ kind: 'IssueLoop' as const, ...rest })),
    },
  ),
)

const _IssueLoopOrIssueBrokenLinkIssueBrokenLink = Schema.Struct({
  kind: Schema.Literal('IssueBrokenLink'),
  from: Schema.String,
  to: Schema.String,
}).pipe(
  Schema.decodeTo(
    Schema.Struct({
      _tag: Schema.Literal('IssueBrokenLink'),
      from: Schema.String,
      to: Schema.String,
    }),
    {
      decode: SchemaGetter.transform(({ kind: _k, ...rest }) => ({ _tag: 'IssueBrokenLink' as const, ...rest })),
      encode: SchemaGetter.transform(({ _tag: _t, ...rest }) => ({ kind: 'IssueBrokenLink' as const, ...rest })),
    },
  ),
)

export const IssueLoopOrIssueBrokenLink = Schema.Union([_IssueLoopOrIssueBrokenLinkIssueLoop, _IssueLoopOrIssueBrokenLinkIssueBrokenLink])
export type IssueLoopOrIssueBrokenLink = Schema.Schema.Type<typeof IssueLoopOrIssueBrokenLink>

const _IssueLoopFound = Schema.Struct({
  kind: Schema.Literal('loop_found'),
  path: Schema.Array(Schema.String),
}).pipe(
  Schema.decodeTo(
    Schema.Struct({
      _tag: Schema.Literal('LoopFound'),
      path: Schema.Array(Schema.String),
    }),
    {
      decode: SchemaGetter.transform(({ kind: _k, ...rest }) => ({ _tag: 'LoopFound' as const, ...rest })),
      encode: SchemaGetter.transform(({ _tag: _t, ...rest }) => ({ kind: 'loop_found' as const, ...rest })),
    },
  ),
)

const _IssueBrokenLink = Schema.Struct({
  kind: Schema.Literal('broken_link'),
  from: Schema.String,
  to: Schema.String,
}).pipe(
  Schema.decodeTo(
    Schema.Struct({
      _tag: Schema.Literal('BrokenLink'),
      from: Schema.String,
      to: Schema.String,
    }),
    {
      decode: SchemaGetter.transform(({ kind: _k, ...rest }) => ({ _tag: 'BrokenLink' as const, ...rest })),
      encode: SchemaGetter.transform(({ _tag: _t, ...rest }) => ({ kind: 'broken_link' as const, ...rest })),
    },
  ),
)

export const Issue = Schema.Union([_IssueLoopFound, _IssueBrokenLink])
export type Issue = Schema.Schema.Type<typeof Issue>

export const WidgetAlias = Widget
export type WidgetAlias = Schema.Schema.Type<typeof WidgetAlias>

export const GetV1WidgetsResponse = Schema.Array(Widget)
export type GetV1WidgetsResponse = Schema.Schema.Type<typeof GetV1WidgetsResponse>

export const PostV1WidgetsResponse = Widget
export type PostV1WidgetsResponse = Schema.Schema.Type<typeof PostV1WidgetsResponse>

export const GetV1Widgets_widget_idResponse = Widget
export type GetV1Widgets_widget_idResponse = Schema.Schema.Type<typeof GetV1Widgets_widget_idResponse>

export const PostV1Widgets_widget_idResponse = Widget
export type PostV1Widgets_widget_idResponse = Schema.Schema.Type<typeof PostV1Widgets_widget_idResponse>

export const PatchV1Widgets_widget_idResponse = Widget
export type PatchV1Widgets_widget_idResponse = Schema.Schema.Type<typeof PatchV1Widgets_widget_idResponse>

export const PostV1WidgetsRequest = Widget
export type PostV1WidgetsRequest = Schema.Schema.Type<typeof PostV1WidgetsRequest>

export const ShapeDistinct = Schema.Struct({
  amount: MeasureOrFloat,
  mixed_list: Schema.Array(StringOrInt),
})
export type ShapeDistinct = Schema.Schema.Type<typeof ShapeDistinct>

export const Envelope = Schema.Struct({
  payload: IssueLoopOrIssueBrokenLink,
  event: Event,
  phase: Phase,
  mark: Mark,
})
export type Envelope = Schema.Schema.Type<typeof Envelope>
