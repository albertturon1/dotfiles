# TypeScript Rules

## Core

Build deep modules.

Small public API.

Hide real complexity.

No useless wrappers.

No pass-through functions.

Bad:

```ts
function parseUser(value: unknown): User {
  return UserSchema.parse(value);
}
```

Good:

```ts
const result = UserSchema.safeParse(value);
```

## Function inputs

When a function needs three or more related input values, accept one named parameter object rather than positional arguments. This keeps call sites legible and makes future changes safe.

```ts
// Bad
scheduleMeal(kitchenId, date, slotId, recipeId);

// Good
scheduleMeal({ kitchenId, date, slotId, recipeId });
```

## No exceptions

Do not use `throw` for expected failures.

No exception-driven control flow.

Use explicit result types.

```ts
type Result<T, E> =
  | { ok: true; value: T }
  | { ok: false; error: E };
```

Bad:

```ts
function loadUser(id: string): User {
  throw new UserNotFoundError(id);
}
```

Good:

```ts
function loadUser(id: UserId): Result<User, LoadUserError> {
  // full operation
}
```

Caller handles error:

```ts
const result = loadUser(userId);

if (!result.ok) {
  return handleLoadUserError(result.error);
}

useUser(result.value);
```

Expected errors include:

* invalid input;
* missing data;
* failed validation;
* not found;
* conflict;
* unauthorized;
* external service failure;
* storage failure.

Return them explicitly.

Use `throw` only for impossible states or programmer bugs.

## Never

* No `any`.
* No fake `unknown`.
* No `as Type`.
* No `as unknown as Type`.
* No `@ts-ignore`.
* No one-off type guards.
* No pass-through wrappers.
* No validation wrappers that only rename schema calls.
* No exceptions for expected failures.
* No swallowed errors.
* No generic `catch` that hides failure.

## Runtime data

Validate external data at module boundary.

Module owns:

* fetching;
* validation;
* normalization;
* error mapping;
* domain conversion.

Caller gets:

```ts
Result<DomainValue, DomainError>
```

Caller must not know:

* transport shape;
* schema library;
* raw API response;
* validation details;
* storage format.

## Validation

Bad:

```ts
function isDifficulty(value: string): value is Difficulty {
  return DIFFICULTY_OPTIONS.some(option => option === value);
}
```

Bad:

```ts
function parseDifficulty(value: unknown): Difficulty {
  return DifficultySchema.parse(value);
}
```

Good:

```ts
type DifficultyError = {
  type: "invalid-difficulty";
  value: unknown;
};

function createDifficulty(
  value: unknown,
): Result<Difficulty, DifficultyError> {
  const result = DifficultySchema.safeParse(value);

  if (!result.success) {
    return {
      ok: false,
      error: {
        type: "invalid-difficulty",
        value,
      },
    };
  }

  return {
    ok: true,
    value: result.data,
  };
}
```

Keep this function only when it is a real module boundary.

Do not create it as useless wrapper.

## Errors

Use typed errors.

```ts
type LoadUserError =
  | { type: "not-found"; userId: UserId }
  | { type: "invalid-response" }
  | { type: "network-failure"; cause: NetworkError };
```

Handle all cases.

```ts
switch (result.error.type) {
  case "not-found":
    return showNotFound();

  case "invalid-response":
    return showInvalidResponse();

  case "network-failure":
    return retryLater(result.error);

  default:
    return assertNever(result.error);
}
```

## Unknown

`unknown` only at real external boundary.

Validate immediately.

Do not pass it deeper.

```text
external data
→ validation
→ Result<domain, error>
→ application
```

## Final check

Search changed code for:

```text
any
unknown
 as
throw
@ts-ignore
@ts-nocheck
is[A-Z]
parse*
validate*
```

Check every match.

Remove useless wrappers.

Replace expected exceptions with result types.

Keep `throw` only for impossible states.
