# Configuration Directory

This directory contains configuration files for the AI4R project.

## Files

- `rubocop_initial.json` - Initial Rubocop analysis results
- `local/` - Local configuration overrides (excluded from version control)

## Adding Configuration

When adding new configuration files:
1. Place shared/default configurations in this directory
2. Place local/personal configurations in `config/local/`
3. Update `.gitignore` if necessary to exclude sensitive configurations