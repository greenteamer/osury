module S = Sury

@genType
@schema
type status = [#pending | #active | #blocked]

@genType
@schema
type admin = {
  permissions: option<array<string>>,
  level: int
}

@genType
@schema
type errorDetails = {
  code: string,
  message: string,
  details: option<Dict.t<string>>
}

@genType
@tag("_tag")
@schema
type adminOrGuest = Admin({
  permissions: option<array<string>>,
  level: int
}) | Guest({
  expiresAt: @s.null Nullable.t<string>,
  invitedBy: option<user>
})

@genType
@schema
type user = {
  id: int,
  email: string,
  name: @s.null Nullable.t<string>,
  status: option<status>,
  role: option<adminOrGuest>,
  tags: option<array<string>>,
  metadata: option<Dict.t<string>>
}

@genType
@schema
type guest = {
  expiresAt: @s.null Nullable.t<string>,
  invitedBy: option<user>
}

@genType
@schema
type apiResponse = {
  success: bool,
  data: @s.null Nullable.t<user>,
  error: @s.null Nullable.t<errorDetails>
}

@genType
@schema
type getUsersResponse = array<user>