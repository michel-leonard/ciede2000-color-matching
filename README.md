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
Contributions are welcome! Please open an issue or submit a pull request if you have any improvements or suggestions. Also, we aim to extend the compatibility of the `deltaE-2000` function to additional programming languages to meet the diverse needs of the users. Contributions are encouraged!

### Planned Languages
- **Go**: In Progress
  - [ ] Implement the `deltaE-2000` function.
  - [ ] Write usage documentation.
  - [ ] Create unit tests.
  
- **Rust**: In Progress
  - [ ] Implement the `deltaE-2000` function.
  - [ ] Write usage documentation.
  - [ ] Create unit tests.
  
- **Swift**: Planned
  - [ ] Implement the `deltaE-2000` function.
  - [ ] Write usage documentation.
  - [ ] Create unit tests.
  
- **Kotlin**: Planned
  - [ ] Implement the `deltaE-2000` function.
  - [ ] Write usage documentation.
  - [ ] Create unit tests.
  
- **TypeScript**: Planned
  - [ ] Implement the `deltaE-2000` function.
  - [ ] Write usage documentation.
  - [ ] Create unit tests.
  
- **MATLAB**: Planned
  - [ ] Implement the `deltaE-2000` function.
  - [ ] Write usage documentation.
  - [ ] Create unit tests.
  
- **R**: Planned
  - [ ] Implement the `deltaE-2000` function.
  - [ ] Write usage documentation.
  - [ ] Create unit tests.

### How to Contribute
Here’s how you can help:
1. **Choose a Language**: Pick one of the planned languages that interests you.
2. **Implement the Function**: Develop the `deltaE-2000` function in the chosen language, based on implementations.
3. **Write Documentation**: Add a section in the `README.md` for the new language, including usage examples.
4. **Create Tests**: Write unit tests to ensure the function produces consistent results with a tolerance of 1e-10.
5. **Submit a Pull Request**: Once your implementation is complete, submit a pull request for review.

Thank you for your contributions and helping us make this project better!

## License
This project is released into the public domain.
