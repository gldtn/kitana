# Pagination

## Component Overview

Pagination is a reusable Flux-style page navigation row with chevrons, numbered pages, and ellipses.

## Project Structure and Dependencies

Source file: `Components/Controls/Pagination.qml`.

Qt imports: `import QtQuick`, `import QtQuick.Layouts`.

Project imports: `import "../.."`, `import "../../custom" as Custom`.

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `currentPage` | `int` | `0` | Zero-based current page. |
| `pageCount` | `int` | `1` | Total number of pages. |
| `maxPageButtons` | `int` | `7` | Maximum numbered pages before ellipses are inserted. |
| `wrap` | `bool` | `false` | Wraps previous and next controls at the first and last pages. |

## Signals

#### pageRequested(page)

Emitted with the zero-based page index requested by a page or chevron click.
