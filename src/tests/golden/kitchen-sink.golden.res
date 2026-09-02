

@genType
@tag("_tag")
@unboxed
@schema
type stringOrInt = String(string) | Int(int)

@genType
@tag("_tag")
@unboxed
@schema
type stringOrArrayBool = String(string) | ArrayBool(array<bool>)

@genType
@schema
type inlineEnum = [#on | #off]

@genType
@schema
type literalUnion = [#yes | #no]

@genType
@schema
type issueLoopKind = [#loop_found]

@genType
@schema
type issueBrokenLinkKind = [#broken_link]

@genType
@schema
type order = [#asc | #desc]

@genType
@schema
type scalars = {
  s: string,
  f: float,
  i: int,
  b: bool,
  nothing: unit,
  anything: @s.matches(S.json) JSON.t,
  opt: option<string>,
  with_default: option<int>
}

@genType
@schema
type refined = {
  id: string,
  email: string,
  site: string,
  created_at: string,
  slug: string,
  ratio: float,
  count: int
}

@genType
@schema
type containers = {
  tags: array<string>,
  matrix: array<array<int>>,
  by_key: Dict.t<float>,
  free_form: Dict.t<@s.matches(S.json) JSON.t>,
  nested: {
  deep: array<Dict.t<string>>
}
}

@genType
@schema
type keywords = {
  @as("type") type_: string,
  @as("module") module_: string,
  @as("and") and_: bool,
  @as("external") external_: int
}

@genType
@schema
type size = [#small | #medium | #large]

@genType
type phase = [#Draft | #Done]

@genType
@schema
type measure = {
  value: float,
  unit: string
}

@genType
@schema
type base = {
  id: string,
  created_at: string
}

@genType
@schema
type rec node = {
  name: string,
  children: array<node>,
  parent: @s.null Nullable.t<node>
}

@genType
@schema
type eventCreated = {
  at: string
}

@genType
@schema
type eventDeleted = {
  reason: string
}

@genType
type mark = Shine({
  target: string
}) | Tint({
  level: int
})

@genType
@schema
type getV1Widgets_widget_idParams = {
  widget_id: string
}

@genType
@schema
type mixedAlias = array<stringOrArrayBool>

@genType
@schema
type issueLoop = {
  kind: issueLoopKind,
  path: array<string>
}

@genType
@schema
type issueBrokenLink = {
  kind: issueBrokenLinkKind,
  from: string,
  @as("to") to_: string
}

@genType
@schema
type getV1WidgetsParams = {
  limit: int,
  cursor: option<string>,
  order: option<order>
}

@genType
@schema
type nullables = {
  maybe_text: @s.null Nullable.t<string>,
  maybe_size: @s.null Nullable.t<size>,
  maybe_list: @s.null Nullable.t<array<string>>,
  only_one: string,
  inline_enum: inlineEnum,
  literal_union: literalUnion
}

@genType
@schema
type widget = {
  id: string,
  created_at: string,
  size: size,
  weight: float
}

@genType
@tag("_tag")
@unboxed
@schema
type measureOrFloat = Measure(measure) | Float(float)

@genType
@tag("_tag")
@schema
type event = EventCreated({
  at: string
}) | EventDeleted({
  reason: string
})

@genType
@tag("kind")
@schema
type issueLoopOrIssueBrokenLink = IssueLoop({
  path: array<string>
}) | IssueBrokenLink({
  from: string,
  @as("to") to_: string
})

@genType
@tag("kind")
@schema
type issue = @as("loop_found") LoopFound({
  path: array<string>
}) | @as("broken_link") BrokenLink({
  from: string,
  @as("to") to_: string
})

@genType
@schema
type widgetAlias = widget

@genType
@schema
type getV1WidgetsResponse = array<widget>

@genType
@schema
type getV1Widgets_widget_idResponse = widget

@genType
@schema
type postV1Widgets_widget_idResponse = widget

@genType
@schema
type shapeDistinct = {
  amount: measureOrFloat,
  mixed_list: array<stringOrInt>
}

@genType
@schema
type envelope = {
  payload: issueLoopOrIssueBrokenLink,
  event: event,
  phase: phase,
  mark: mark
}