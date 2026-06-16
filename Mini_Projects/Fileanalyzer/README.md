# Overview
This project is a command‑line tool designed as a practical exercise in clean project structure, modular design, and maintainable code. The emphasis is on clarity, reliability, and predictable behaviour across all expected use cases. Each component is organised into logical modules, with robust error handling to ensure the tool responds gracefully to both expected and unexpected user input.
Rather than simply “making it work,” the goal was to build a tool that handles edge cases, validates user actions, and provides consistent, user‑friendly output.

## Usage
Run the tool from the command line:
python main.py -h


## This displays a detailed help message explaining the available arguments and how to use the program.
A typical command looks like:
-python main.py file_name.txt -v 1


## Planned Improvements
Future enhancements will focus on expanding flexibility, improving usability, and supporting more data formats. Planned additions include:
- More comprehensive file validation to prevent incorrect or unsupported inputs.
- User‑selectable analysis options, allowing users to choose which data types or patterns to scan for.
- Custom pattern input, enabling users to define their own regex patterns instead of relying solely on built‑in ones (e.g., email, phone number).
- Improved file selection, potentially using a library that lets users browse their file system rather than manually typing exact filenames.
- Support for additional file types, such as JSON or CSV, with dedicated classes to handle each format cleanly and consistently.
