# CIEDE2000 Color-Difference

This software is not affiliated with the CIE (International Commission on Illumination), has not been validated by it, and is released into the **public domain**. It is provided "as is" without any warranty.

## Languages
The implementation of the **CIEDE2000 color difference formula** is proposed with consistent results in 6 programming languages:
- JavaScript
- C/C++
- Python
- PHP
- Java
- Ruby

## Cross-Language Consistency
The functions provided in this repository have been rigorously tested to ensure that they produce consistent results across all supported languages. The results are consistent with a tolerance of 1e-10 for any input parameters. This means that for any given set of input values, the difference in results between any two implementations will not exceed 1e-10.

## Live Example
You can see a live example of the CIEDE2000 color difference calculation at the following link:
- [Live Example](https://michel-leonard.github.io/delta-e-2000)

## Testing and Validation
Extensive tests have been conducted to verify the accuracy and consistency of the implementations across different programming languages. Below are some details of the testing process:

- **Test Cases**: A comprehensive set of test cases was used to validate the implementations.
- **Tolerance**: The results are validated to be within a tolerance of 1e-10.
- **Cross-Language**: The same test cases were executed in all supported programming languages, ensuring that the results are consistent regardless of the language used.

## Usage
To use the CIEDE2000 color difference formula in your project, follow the instructions specific to your programming language of choice.

### JavaScript
```javascript
// Example usage in JavaScript
const deltaE = ciede2000(l1, a1, b1, l2, a2, b2);
console.log(deltaE);
```

### C/C++
```c
// Example usage in C
double deltaE = ciede_2000(l1, a1, b1, l2, a2, b2);
printf("%f\n", deltaE);
```

### Python
```python
# Example usage in Python
delta_e = ciede_2000(l1, a1, b1, l2, a2, b2)
print(delta_e)
```

### PHP
```php
// Example usage in PHP
$deltaE = ciede2000($l1, $a1, $b1, $l2, $a2, $b2);
echo $deltaE;
```

### Java
```java
// Example usage in Java
double deltaE = ciede2000(l1, a1, b1, l2, a2, b2);
System.out.println(deltaE);
```

### Ruby
```ruby
# Example usage in Ruby
delta_e = ciede_2000(l1, a1, b1, l2, a2, b2)
puts delta_e
```

## Contributing
Contributions are welcome! Please open an issue or submit a pull request if you have any improvements or suggestions.

## License
This project is released into the public domain.
