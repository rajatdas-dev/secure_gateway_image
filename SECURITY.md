# Security Policy

Please do not report security vulnerabilities through public GitHub issues.

Report security issues privately through the repository's configured security contact.

## Scope

secure_gateway_image does not:

- store credentials
- perform authentication
- persist network responses
- manage HTTP sessions
- manage application cache storage

It only renders image sources supplied by the host application.