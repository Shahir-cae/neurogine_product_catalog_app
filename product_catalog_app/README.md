# Product Catalog App

A Flutter app that browses, searches, and views details for products via the DummyJSON API.

## Stack
- Flutter (Dart)
- `http` package for networking

## How to Run
1. Ensure Flutter SDK is installed (`flutter --version` to check)
2. Clone this repo
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` (with an emulator/device connected, or `flutter run -d chrome` for web)

## Architecture
- **Data layer** (`lib/Backend/Products.dart`): `Product` and `Review` models, plus `ProductService` handling all API calls (list, detail, search).
- **Presentation layer** (`lib/Pages/`): screens (`ProductList.dart`, `ProductDetail.dart`) and reusable widgets (`Widget/TopBar.dart`, `Widget/ProductCard.dart`) — no direct API logic here, only calls into the data layer.
- This split keeps networking/parsing logic testable and separate from UI code.

## Search Approach
Chose **server-side search** via `GET /products/search?q=`, debounced 500ms after the user stops typing.
Why: guarantees results are accurate against the full 194-product catalog, not just whatever's been paginated into memory so far. Trade-off: relies on network for every search instead of instant client-side filtering.

## Features Implemented
- Product list with pagination (infinite scroll via `skip`)
- Product detail screen with image carousel, description, price, rating, discount, and reviews
- Debounced search (server-side)
- Loading, error (with retry), empty, and success states

## UI/UX
- **Product card layout**: thumbnail, title, description (truncated), rating, and price laid out in a clean row-based card, with fixed image sizing so long descriptions never overflow or break the layout.
- **Image carousel on detail screen**: product images are shown one at a time (not a cramped horizontal scroll), with tappable `<` / `>` arrows and dot indicators showing position. Arrows automatically hide at the first/last image, and the whole carousel disappears in favor of a single image when there's only one — avoids showing pointless navigation controls.

## Known Limitations / TODOs
- No pull-to-refresh implemented
- No automated unit tests
- No custom image loading placeholder/error handling — `Image.network` falls back to Flutter's default broken-image behavior if a thumbnail/image URL fails to load

## AI Usage Disclosure
Used AI (Claude) for:
- Debugging specific Flutter layout errors (e.g. unbounded width in Row/Image, Column constructor syntax)
- Explaining Flutter/Dart patterns I was unfamiliar with (PageView, Stack/Positioned, debounce via Timer, lifting state up between TopBar and ProductList)
- Reviewing code snippets for bugs (e.g. search returning only one result instead of a list)

All architectural decisions (layer structure, state management approach, search strategy) and final implementation were written and adjusted by me. I can explain each part in the walkthrough video.