# 🧸 qute _(q unit tests)_
**qute** is a minimal and lightweight unit-testing harness for q/kdb+, inspired by [k4unit](https://github.com/simongarland/k4unit).

It is designed to be simple and extensible. The framework manages test discovery, execution order, result collection, and performance validation.

## ✨ Features
- **Data-Driven Testing**: Define tests in simple `dsv` files
- **Performance Monitoring**: Track execution time and memory usage
- **Flexible Test Organization**: Support for setup/teardown at multiple levels
- **Comprehensive Results**: Detailed execution logs with timestamps
- **Version Compatibility**: Minimum version checking for tests
- **Configurable Output**: Customizable result saving and verbosity
- **Error Handling**: Robust error capture and reporting

## 🚀 Usage
### 🔧 Setup
```q
/ Loads the qute library
.lib.require`qute

/ Load tests from a directory/file
.qute.loadTests`:test/dir

/ Run tests
.qute.runTests[]

/ Saving tests to .qute.cfg.saveFile
.qute.saveTestResults[]

/ Reloading tests from .qute.cfg.saveFile
// WARN: This overrides qutr
.qute.loadTestResults[]
```
- [Inspecting Test Results](#-inspecting-test-results)

### ⚙️ Configuration
**qute** provides several configuration options:
```q
/ Delimiter for dsv file
.qute.cfg.delim:"|";

/ Enable fail on error for debugging
.qute.cfg.failOnError:1b;

/ File to save/load result
.qute.cfg.saveFile:`:qutr.dsv;

/ Save method affects how repeated (`beforeeach`aftereach action) code run results are saved: `all/`last
.qute.cfg.saveMethod:`all;
```

## 🧪 Test Formats
### ✍🏻 Test File Format
Test files must be named with the pattern `qute.*.dsv` and contain the following columns:
| Column    | Type   | Required | Description                                                       |
| -         | -      | -        | -                                                                 |
| `action`  | Symbol | Yes      | [Test Actions](#-test-actions)                                    |
| `minver`  | Float  | No       | Minimum version of kdb+ (.z.K) (default: 0)                       |
| `code`    | Symbol | Yes      | Code to be executed                                               |
| `repeat`  | Int    | No       | Number of repetitions (default: 1)                                |
| `ms`      | Int    | No       | Maximum milliseconds it should take to run (default: 0 -> ignore) |
| `bytes`   | Long   | No       | Maximum bytes it should take to run (default: 0 -> ignore)        |
| `comment` | Symbol | No       | Description of the test                                           |

Additional columns are added when the test files are loaded:
| Column | Type   | Description                               |
| -      | -      | -                                         |
| `file` | Symbol | Relative file path to test file           |
| `line` | Int    | Absolute line number of test in test file |

Test definitions are stored in the `qut` table when the test files are loaded.

#### 🎬 Test Actions
**qute** supports the following test actions executed in a specific order:
- **`beforeany`**: Run code once **before any tests**
  - **`beforeeach`**: Run code once **before** any tests in **each file**
    - **`before`**: Run code once **before** any tests in **this file** only
    - **`run`**: Run code
    - **`true`**: Run code: expects result to return **true** (1b)
    - **`fail`**: Run code: expects result to **fail** (2+`two)
    - **`after`**: Run code once **after** all tests in **this file** only
  - **`aftereach`**: Run code once **after** all tests in **each file**
- **`afterall`**: Run code once **after all tests**

Example Test File:
```dsv
action    | minver | code                              | repeat | ms  | bytes | comment
beforeany |        | .test.data:([]a:1 2 3;b:10 20 30) |        |     |       | Setup test data
before    |        | .test.temp:1                      |        |     |       | Initialize temp variable
true      |        | 6~sum .test.data.a                |        |     |       | Expected sum
true      |        | 20~avg .test.data.b               |        |     |       | Expected average
run       |        | update c:a*b from`.test.data      | 1      | 100 |       | Aggregate test data
true      |        | 36000~prd .test.data.c            |        |     |       | Expected product
fail      |        | .test.temp+`two                   |        |     |       | Expected failure
after     |        | delete from`.test                 |        |     |       | Cleanup test namespace
```

### 📊 Test Results
Test results are stored in the `qutr` table with comprehensive metrics.

The `qutr` table shares the same columns as the `qut` table with the following additional columns:
| Column      | Description                                                                                               |
| -           | -                                                                                                         |
| `msx`       | Milliseconds taken to eXecute code                                                                        |
| `bytesx`    | Bytes used to eXecute code                                                                                |
| `okms`      | True if msx is not greater than ms (performance is ok)                                                    |
| `okbytes`   | True if bytesx is not greater than bytes (memory usage is ok)                                             |
| `ok`        | True if the test completes correctly (note: result is ok if `fail action fails)                           |
| `valid`     | True if the code is valid (does not throw an error, note: `fail action should return valid:0b, and ok:1b) |
| `error`     | Error message if test failed                                                                              |
| `timestamp` | When the test was executed                                                                                |
| `result`    | Actual result of code execution                                                                           |

#### Test Summary functions
```q
/ Shows tests that passed all (okms, bytesms, ok) checks
quts.oks[]
/ Shows tests that failed any (okms, bytesms, ok) checks
quts.notOks[]
/ Shows tests that passed logic (ok) check
quts.ok[]
/ Shows tests that failed logic (ok) check
quts.notOk[]
/ Shows tests that failed performance (okms) check
quts.slow[]
/ Shows tests that failed memory (okbytes) check
quts.big[]
/ Shows tests that failed code execution
quts.invalid[]
```
