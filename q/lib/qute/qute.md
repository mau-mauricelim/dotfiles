# 🧸 qute _(q unit tests)_
A comprehensive unit testing framework for q/kdb+ inspired by [k4unit](https://github.com/simongarland/k4unit).
qute provides a robust testing infrastructure with performance monitoring, flexible test organization, and comprehensive result tracking.

## 📝 Overview
qute is a data-driven testing framework that loads test definitions from `dsv` (delimiter-separated values) files and
executes them with comprehensive performance and correctness monitoring.

Tests are organized into structured workflows with setup, execution, validation, and teardown phases.

## ✨ Features
- **Data-Driven Testing**: Define tests in simple `dsv` files
- **Performance Monitoring**: Track execution time and memory usage
- **Flexible Test Organization**: Support for setup/teardown at multiple levels
- **Comprehensive Results**: Detailed execution logs with timestamps
- **Version Compatibility**: Minimum version checking for tests
- **Configurable Output**: Customizable result saving and verbosity
- **Error Handling**: Robust error capture and reporting

## 🚀 Usage
### ⚙️ Configuration
qute provides several configuration options:
```q
/ Delimiter for DSV files (default: "|")
.qute.delim:"|";

/ Enable verbose output (default: 0b)
.qute.verbose:1b;

/ Enable debug mode (default: 0b)
.qute.debug:1b;

/ File to save results (default: `:QUTR.dsv)
.qute.saveFile:`:myresults.dsv;

/ Save method: `all (default) or `last
.qute.saveMethod:`last;
```

### ✍🏻 Test File Format
Test files must be named with the pattern `qute.*.dsv` and contain the following columns:
| Column    | Type   | Required | Description                                                           |
| -         | -      | -        | -                                                                     |
| `action`  | Symbol | Yes      | Type of test action (see [Test Actions](#-test-actions))              |
| `minver`  | Float  | No       | Minimum version of kdb+ (.z.K) (default: 0)                           |
| `code`    | Symbol | Yes      | Code to be executed                                                   |
| `repeat`  | Int    | No       | Number of repetitions (default: 1)                                    |
| `ms`      | Int    | No       | Maximum allowed execution time in milliseconds (default: 0 -> ignore) |
| `bytes`   | Long   | No       | Maximum allowed memory usage in bytes (default: 0 -> ignore)          |
| `comment` | Symbol | No       | Description of the test                                               |

#### 🎬 Test Actions
qute supports nine different test actions executed in a specific order:
- **`beforeany`**: Run code once BEFORE ANY TESTS
  - **`beforeeach`**: Run code once BEFORE any tests in EACH FILE
    - **`before`**: Run code once BEFORE any tests in THIS FILE only
    - **`run`**: Run code
    - **`true`**: Run code: expects result to return true (1b)
    - **`fail`**: Run code: expects result to fail (2+`two)
    - **`after`**: Run code once AFTER all tests in THIS FILE only
  - **`aftereach`**: Run code once AFTER all tests in EACH FILE
- **`afterall`**: Run code once AFTER ALL TESTS

Example Test File:
```dsv
TODO
```
### 🔧 Setup
```q
/ Loads the qute library
.lib.require`qute

/ Load tests from a directory
.qute.loadTests`:test/dir
/ Load tests from a file
.qute.loadTest`:qute.test.dsv

/ Run tests
.qute.runTests[]

/ Inspect results
select from QUTR where not ok
```
