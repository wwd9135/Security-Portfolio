# Advanced Calculator GUI using Tkinter.
# Features: Dynamic button generation, improved structure with classes, and basic error handling.
# This is still a simple learning project, not intended for production use.

import tkinter as tk

class CalculatorApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Advanced Calculator")
        self.current_value = ""
        self.previous_value = ""
        self.operator = ""

        # Entry widget
        self.entry = tk.Entry(root, width=35, borderwidth=5, font=("Arial", 14))
        self.entry.grid(row=0, column=0, columnspan=4, padx=10, pady=10)

        # Create buttons dynamically
        self.create_buttons()

    def create_buttons(self):
        buttons = [
            ('7', 1, 0), ('8', 1, 1), ('9', 1, 2), ('/', 1, 3),
            ('4', 2, 0), ('5', 2, 1), ('6', 2, 2), ('*', 2, 3),
            ('1', 3, 0), ('2', 3, 1), ('3', 3, 2), ('-', 3, 3),
            ('0', 4, 0), ('.', 4, 1), ('+', 4, 2), ('=', 4, 3),
            ('Clear', 5, 0), ('Exit', 5, 3)
        ]

        for (text, row, col) in buttons:
            action = lambda x=text: self.on_button_click(x)
            tk.Button(self.root, text=text, width=10, height=2, command=action).grid(row=row, column=col, padx=5, pady=5)

    def on_button_click(self, char):
        if char == "Clear":
            self.current_value = ""
            self.previous_value = ""
            self.operator = ""
            self.entry.delete(0, tk.END)
        elif char == "Exit":
            self.root.quit()
        elif char == "=":
            try:
                if self.operator and self.previous_value:
                    result = self.calculate(float(self.previous_value), float(self.current_value), self.operator)
                    self.entry.delete(0, tk.END)
                    self.entry.insert(0, result)
                    self.current_value = str(result)
                    self.previous_value = ""
                    self.operator = ""
            except Exception:
                self.entry.delete(0, tk.END)
                self.entry.insert(0, "Error")
        elif char in ["+", "-", "*", "/"]:
            self.operator = char
            self.previous_value = self.current_value
            self.current_value = ""
            self.entry.delete(0, tk.END)
        else:
            self.current_value += str(char)
            self.entry.delete(0, tk.END)
            self.entry.insert(0, self.current_value)

    def calculate(self, a, b, op):
        if op == "+":
            return a + b
        elif op == "-":
            return a - b
        elif op == "*":
            return a * b
        elif op == "/":
            return "Error" if b == 0 else a / b

if __name__ == "__main__":
    root = tk.Tk()
    app = CalculatorApp(root)
    root.mainloop()
