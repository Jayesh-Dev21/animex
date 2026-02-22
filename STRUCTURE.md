# Animex Project Structure

## Overview

Animex is a professional CLI tool for streaming anime from the terminal with a modern web presence.

## Directory Structure

```
animex/
├── animex              # Main CLI executable
├── animex.1            # Man page documentation
├── LICENSE             # GNU GPL v3.0 license
├── README.md           # Main documentation
├── STRUCTURE.md        # This file
├── .gitignore          # Git ignore rules
├── vercel.json         # Vercel deployment config
├── tests/              # Test suite
│   ├── run-tests.sh            # Main test runner
│   ├── test-smoke.sh           # Smoke tests
│   ├── test-validation.sh      # Validation tests
│   ├── test-mode.sh            # Mode switching tests
│   ├── test-quality.sh         # Quality selection tests
│   ├── test-config-file.sh     # Config file tests
│   ├── test-config.yaml        # Test configuration
│   └── test-results.txt        # Test execution log
├── .github/
│   └── workflows/
│       └── tests.yml           # Automated testing on push
└── web/                        # Next.js website
    ├── app/
    │   ├── page.tsx            # Main landing page
    │   ├── layout.tsx          # Root layout
    │   └── globals.css         # Global styles
    ├── package.json            # Dependencies (Bun)
    ├── next.config.js          # Next.js config (static export)
    └── tsconfig.json           # TypeScript config
```

## Components

### CLI Tool (`animex`)
- Shell script for streaming anime
- Supports multiple platforms (Linux, macOS, Android, Windows, iOS)
- Quality selection (360p - 1080p)
- Download capabilities
- Watch history tracking

### Documentation
- **animex.1**: Man page with full CLI reference
- **README.md**: Quick start guide and basic usage

### Website (`web/`)
- Built with Next.js 14 and TypeScript
- Uses Bun as package manager and runtime
- Deployed to Vercel as static site
- Features modern glassmorphism UI with purple wave animations
- Responsive design for all devices

### Testing (`tests/`)
- Comprehensive test suite for CLI functionality
- Automated via GitHub Actions
- Results logged to `tests/test-results.txt`

### CI/CD (`.github/workflows/`)
- **tests.yml**: Runs test suite on every push to repository
- Automatically updates test results log

## Technology Stack

- **CLI**: POSIX shell script
- **Website**: Next.js 14, React 18, TypeScript
- **Package Manager**: Bun
- **Deployment**: Vercel (static export)
- **Testing**: Bash test scripts

## Links

- **Website**: https://animex.jayeshpuri.me
- **Repository**: https://github.com/Jayesh-Dev21/animex

## Development

### CLI Development
```bash
# Edit the animex script
vim animex

# Run tests
cd tests
./run-tests.sh
```

### Web Development
```bash
cd web
bun install
bun run dev
```

### Deployment
- Website auto-deploys to Vercel on push to main branch
- Vercel configuration in `vercel.json`
