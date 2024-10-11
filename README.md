# URLChecker

## Overview
URLChecker is a Swift command-line application designed to test and validate URLs from a JSON file. The application fetches each URL, measures the response time, and logs the results in a JSON format.

## Features
- Loads a list of URLs from a JSON file.
- Fetches each URL and records the HTTP status code and response time.
- Outputs the results to a JSON file.

## Requirements
- macOS
- Swift 5.x

## Installation
1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd URLChecker
   ```
2. Make sure you have the `urls.json` file in the same directory as `URLChecker.swift`.

## Usage
1. Compile the Swift code:
   ```bash
   swiftc URLChecker.swift -o urlchecker
   ```
2. Run the application:
   ```bash
   ./urlchecker
   ```

## Input JSON Format
The input JSON file (`urls.json`) should be formatted as follows:
```json
{
  "urls": [
    "https://www.example.com",
    "https://www.google.com"
  ]
}
```

## Output JSON Format
The output will be written to a file named `report.json` in the following format:
```json
[
  {
    "url": "https://www.example.com",
    "statusCode": 200,
    "responseTime": 0.123,
    "success": true
  }
]
```

## Contributing
Contributions are welcome! Please open an issue or submit a pull request.
