# Contributing Guidelines

This document outlines the process for contributing to this project and how
releases are managed.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/your-username/repo-name.git`
3. Create a new branch: `git checkout -b my-feature-branch`
4. Make your changes
5. Push to your fork: `git push origin my-feature-branch`
6. Open a Pull Request

## Code Style

- Write clean, readable code
- Include comments for complex logic
- Add tests for new features
- Update documentation when needed
- Run `make format` to keep codebase consistent
- Use [conventional commits](https://www.conventionalcommits.org/en/v1.0.0/#summary)

## Pull Request Process

1. Ensure your PR addresses a specific issue or feature
2. Update relevant documentation
3. Add appropriate labels (see [labels](https://github.com/cange/specto.nvim/issues/labels))
4. Request review from maintainers
5. Address review feedback

## Release Process

### Creating Releases

1. Go to GitHub Releases
2. Click "Draft a new release"
3. Create a new tag following [semver](https://semver.org/) (e.g. `v1.0.0`)
4. Click "Generate release notes"
5. Review and publish
