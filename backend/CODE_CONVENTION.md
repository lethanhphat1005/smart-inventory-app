# BACKEND CONVENTIONS

## 1. File & folder naming

### 1.1. Module file (controller, route, repository, ...)

- Use a kebab-case that combines dot-based suffix.
- General format: `<feature-name>.<layer>.ts`.
- No capital letters and no ordinal numbers in the file name.
- The file must be properly placed in the corresponding layer folder for easy location.

### 1.2. Config/constant file

- Use kebab-case for the entire file name.
- Format: `<entity-use-name>.<config|constants>.ts`.
- The file name should clearly reflect the purpose and scope of use.
- No capital letters and no ordinal numbers.

### 1.3. "index" file

- Always name it "index.ts".
- For re-export purposes only and does not contain business logic or business processing.

### 1.4. Module folder

- The folder name uses lowercase.
- Layers and modules use plurals.
- Avoid vague, confusing names such as helpers, common-stuff.

### 1.5. Document file

- Use the UPPER_SNAKE_CASE format.
- Applies to documentation or legal files at the project level.

---

## 2. Style & formatting

- **Indentation:** Use 2 spaces for each indentation level.
- **Line length:** Avoid lines longer than 80 characters. Prioritize down the line to ensure readability and review code.
- **Wrapping line:** When an expression cannot be written collapsively on a line, the following principles apply:
  - Break the line after the comma.
  - Break the line before the operator.
  - The new line is aligned with the beginning of the same-level expression on the previous line.
- **Blank line:** Use a blank line in the following scenarios:
  - Between import blocks of different groups.
  - Between functions and classes.
  - Between logical blocks in the same function.
  - Between the local variable declaration and the first statement of the function.
  - Before the statement return.
- **Semicolon:** Always use a semicolon (;) at the end of each statement.
- **Quote style:** \* Use a single quote ('') for strings by default.
  - Only use the literal template ('') when interpolation is needed.
  - Do not use double quotes ("") unless required (e.g., Escape or specific requests).
- **Import formatting:** The import order is arranged in groups:
  1. Built-in modules.
  2. Third-party modules.
  3. Internal modules.
  - Each import group is separated from each other by 1 blank line.

---

## 3. Namings

Naming conventions aim to minimize the need to read deep into the implementation to guess the purpose of a variable, function, or class.

| Identifier type         | Rules for naming                                                                                                                                                                                                                                                                                                                                                                |
| :---------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Variables**           | Use `lowerCamelCase`. Variable names are given in the `<noun>` or `<verb + noun>` structure. A noun that clearly expresses the data that is being stored. Adjectives can be used to complement nouns when context is needed. Variable names must describe the meaning correctly, avoiding confusing abbreviations. Avoid generic names that do not have professional semantics. |
| **Boolean variables**   | Always use prefixes that express logical meanings such as: `is`, `has`, `can`, `will`, ... Variable names should be set to positive to avoid double-negatives when reading code. Boolean must answer clearly to a true/false question.                                                                                                                                          |
| **Functions / Methods** | Use `lowerCamelCase`. Function names always start with a verb. Common function name structures: `<verb>`, `<verb + noun>`, `<verb + adjective + noun>`. The name of the function should clearly represent the behavior or impact that the function performs.                                                                                                                    |
| **Constants**           | Use `UPPER_SNAKE_CASE`. The constant name should clearly describe the business or configuration meaning. Only for values that don't change over the lifetime of your app.                                                                                                                                                                                                       |
| **Enums**               | Use `UpperCamelCase`. Enum represents a finite set of values, which have explicit meaning in the domain.                                                                                                                                                                                                                                                                        |
| **Classes**             | Use `UpperCamelCase`. Class names are nouns, representing a specific concept or role. Do not use verbs in class names.                                                                                                                                                                                                                                                          |
| **Interfaces**          | Use `UpperCamelCase`. Prefix I. The interface name reflects the role or data structure it describes.                                                                                                                                                                                                                                                                            |

---

## 4. Comments

Comments are used to aid in reading and maintaining code, not as a substitute for good naming or clear code structure. Incorrect or outdated comments are considered a form of bug and should be treated as seriously as code.

- **General notes:** Comments should always be updated as the code changes. Comments that no longer accurately reflect the current behavior of the code are considered bugs. Avoid vague or overly lengthy comments.
- **Comment language:** All comments in the project are in Vietnamese.
- **Comment placing rules:** Comments should be used in the following cases:
  - Logic is complex, difficult to read, or difficult to reason quickly.
  - The code has special business constraints or depends on the domain context.
- **Comments should not be used in the following cases:**
  - When the code has clearly described itself through variable names, function names, and logical structures.
  - Code has directly demonstrated its own functionality.
- **Implementation comment formats:** The project uses 4 types of implementation comments:
  1. **Single-line comments:** Used for short, simple explanations that do not occupy more than 1 line. Should be placed after a blank-line and preceded by the relevant line of code. If a comment cannot be written on a single line, it should be in the block-comment format.
  2. **Block comments:** Used to describe complex files, classes, functions, algorithmic logic, and operations. Need to be placed after a blank-line to distinguish it from the rest of the code, before classes/functions, or inside a function to explain complex logic.
  3. **Trailing comments:** Short comments are placed with the line of code they describe, trailing comments are only used when it is necessary to clarify the meaning of a variable or context specific to that line.
  4. **Note comments:** Comments with prefixes are stipulated to be temporary notes or notes for the reader:
     - `TODO:` Mark the work that needs to be done in the future.
     - `FIXME:` Mark errors, risks, or improper behaviors that need to be corrected.
     - `NOTE:` Provides important note to code readers.

---

## 5. Statements

- **Return Statement:** `return` is always placed on a separate line. Do not write any additional statements after returns in the same code block.
- **if-else statement:** Do not write `if` on a single line. Always use brackets (`{}`) for all `if`, `else if`, `else`, even if the block has only one line.
- **switch-case statement:** A switch-case statement always has a `default` to handle unexpected cases. Each case must end with a `break`, unless there is an obvious reason. If a case deliberately does not have a break, it is necessary to add a comment `/* falls through */` at the usual position of the break to show intentionality.
- **Loop (for, while, do-while) statement:** A loop statement should always use brackets `{}` and the entire loop block should not be written on a single line.

---

## 6. Declarations

- **Type rules:** With Typescript, it is recommended to use `unknown` instead of `any` when the data type is not clearly defined, and only use `any` in mandatory cases or temporary code.
  - When using `any` for temporary code, it must be accompanied by a `TODO` comment to indicate that it will be refactored later.
  - For other cases where it is necessary to use `any`, it is necessary to have a comment explaining the reason for use.
- **Number per line:** It is recommended that each line declares only one variable or one constant.
- **Function declarations:** Using arrow functions for standalone functions and callbacks, this style avoids the problems associated with this and keeps the style consistent. Limit the function to more than 2 levels because it will reduce the ability to read, debug and test.
- **Class declarations:** The order of declarations in the class should be kept consistent so that it is easy to read:
  1. Properties.
  2. Constructor.
  3. Public methods.
  4. Protected methods.
  5. Private methods.
- **Interface declarations:** The interface is only used to describe the shape of the data, and does not contain processing logic.

---

## 7. Error handlings & Loggings

### 7.1. Error handlings

- Use `try-catch` to handle sync errors.
- For asynchronous code, always use `async/await` in combination with `try-catch`.
- Error messages need to have a clear meaning, describe the context in which the error occurred, and avoid generic messages.

### 7.2. Log levels

Always use the correct log level according to the severity of the event:

- **Debug:** Used for debug server information. Log intermediate variables, internal states, processing flows. Enable only in a dev or staging environment.
- **Info:** Used for important events in the system flow. Mark a notable start/end process or business event.
- **Warn:** Used for abnormal behaviors but the system still works. Applies when the data is invalid but has a fallback mechanism.
- **Error:** Used for errors that cause a request or job to fail. Exceptions need to be handled, logged, and alerted.
- The message log must clearly describe what happened and in what context, avoiding vague logs such as error occurred, something went wrong.

---

## 8. API contract

- **Success response structure:** All API responses (successes) must follow a uniform format:
  - `success`: boolean — required.
  - `data`: main data (object | array | null).
  - `meta`: add-on information (pagination, total, page, limit, ...) — optional.
  - `message`: Additional debug description — optional.
- **Error response structure:** All API responses (errors) must follow the format:
  - `success`: boolean — required, always `false`.
  - `status`: HTTP status code (400, 401, 403, 404, 409, 500, ...) — required.
  - `message`: a clear, easy-to-understand error description message — required.
- **HTTP status code usage:** Always use the correct HTTP status code in all cases.
- **Pagination:** \* Query format: `?page=x&limit=y` (x, y are natural numbers).
  - Response format: The pagination information is placed in the `meta` field.
- **Sort & filter:** Parameters for sort/filter endpoints use `lowerCamelCase`, which is not abbreviated and explicit.
- **Query string naming:** The parameters for endpoint queries use `lowerCamelCase`, which is abbreviated and explicit.
- **Request body field naming:** The fields in the body request use `lowerCamelCase`.

---

## 9. Security & secret storages

### 9.1. Environment variables

- Absolutely do not hardcode the environment variable in the source code.
- All configurations by environment must be derived from environment variables.
- Do not commit the `.env` file or similar files, use `.env.example` instead to describe the list of necessary variables.

### 9.2. Secret & sensitive datas

Secret/sensitive data includes (but is not limited to): API keys, jwt secrets, database credentials, passwords (including hashed passwords), emails, phones,...

Secrets **MUST NOT** appear anywhere in:

- Source code.
- Git history.
- Log.
- Error message.
- API response returns to the client.
