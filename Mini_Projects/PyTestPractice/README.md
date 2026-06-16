# Pytest Practice

A minimal project for exploring pytest fundamentals — fixtures, test class organisation, and assertion patterns — against a small arithmetic module.

## Project Structure

```
PyTestPractice/
├── src/
│   └── main.py          # Arithmetic module under test
└── test/
    └── MyTest_test.py   # Fixture-based test suite
```

## Running the tests

From the `PyTestPractice/` directory:

```
pytest test/
```

Covers: fixture injection, class-based test grouping, and basic assertion correctness.
