# Code Review Checklist

## Architecture

- Is the implementation consistent with the existing architecture?
- Is logic placed in the correct layer?
- Is there unnecessary coupling?

## Flutter

- Are widgets unnecessarily rebuilding?
- Are lists optimized?
- Are controllers disposed correctly?
- Are async operations handled safely?

## FlutterFlow

- Is the solution compatible with FlutterFlow?
- Are Custom Actions/Functions used appropriately?

## UX

- Is RTL correct?
- Is the UI responsive?
- Are loading/error/empty states handled?

## Data

- Is Quran data handled locally where required?
- Are API calls minimized?
- Is caching appropriate?

## Security

- Are secrets exposed?
- Are unsafe APIs or dependencies introduced?

## Maintainability

- Is there duplicated code?
- Are names clear?
- Is the implementation unnecessarily complex?

## Output

Return only:

CRITICAL
WARNINGS
SUGGESTIONS

Do not modify files unless explicitly requested.