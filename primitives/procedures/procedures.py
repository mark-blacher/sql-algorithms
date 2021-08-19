# Python code using procedures

if __name__ == "__main__":
    def kelvin_to_celsius(temperature):
        return [k - 273.15 for k in temperature]

    def kelvin_to_fahrenheit(temperature):
        return [k * 9 / 5 - 459.67 for k in temperature]

    temperature = [300, 170]
    print(kelvin_to_fahrenheit(temperature))