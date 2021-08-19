# Python code using conditions

import random

if __name__ == "__main__":
    def kelvin_to_celsius(temperature):
        return [k - 273.15 for k in temperature]

    def kelvin_to_fahrenheit(temperature):
        return [k * 9 / 5 - 459.67 for k in temperature]

    temperatures = [300, 170]

    # randomly it is choosen if the temperatures are
    # transformed into celsius or fahrenheit
    if random.random() > 0.5:  # random condition
        A = kelvin_to_celsius(temperatures)
    else:
        A = kelvin_to_fahrenheit(temperatures)
    print(A)