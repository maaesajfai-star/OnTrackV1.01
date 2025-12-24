# Contributing to UEMS

Thank you for your interest in contributing to UEMS! This document provides guidelines for contributing to the project.

## Code of Conduct

By participating in this project, you agree to abide by our [Code of Conduct](CODE_OF_CONDUCT.md).

## How to Contribute

### Reporting Bugs

1. Check if the bug has already been reported in Issues
2. Create a new issue with:
   - Clear, descriptive title
   - Steps to reproduce
   - Expected vs actual behavior
   - Environment details (OS, versions, etc.)
   - Screenshots if applicable

### Suggesting Features

1. Check if the feature has been suggested
2. Create a feature request with:
   - Clear description of the feature
   - Use cases and benefits
   - Proposed implementation (optional)

### Pull Requests

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Make your changes following our coding standards
4. Write/update tests
5. Update documentation
6. Commit with clear messages: `git commit -m "Add: feature description"`
7. Push to your fork: `git push origin feature/your-feature-name`
8. Open a Pull Request

## Development Guidelines

### Code Style

- **Backend**: Follow NestJS style guide
- **Frontend**: Follow Next.js and React best practices
- **TypeScript**: Strict mode enabled
- **Formatting**: Use Prettier (run `npm run format`)
- **Linting**: Use ESLint (run `npm run lint`)

### Commit Messages

Follow conventional commits:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Test additions/changes
- `chore`: Maintenance tasks

Example: `feat: add candidate scoring feature`

### Testing

- Write unit tests for new features
- Ensure all tests pass: `npm run test`
- Maintain > 80% code coverage
- Add integration tests for API endpoints

### Documentation

- Update README.md for significant changes
- Add JSDoc comments to functions
- Update API documentation
- Include examples in docs

## Project Structure

```
backend/
├── src/modules/     # Feature modules
├── src/common/      # Shared code
└── test/            # Tests

frontend/
├── src/app/         # Pages
├── src/components/  # UI components
└── src/lib/         # Utilities
```

## Getting Help

- Read the [Developer Guide](docs/DEVELOPER_GUIDE.md)
- Check existing issues and discussions
- Ask questions in GitHub Discussions

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
