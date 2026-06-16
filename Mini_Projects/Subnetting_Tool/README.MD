# Network Subnetting tool## Overview
A subnetting tool for IPv4,
To ensure deterministic behaviour and minimise configuration errors, this tool allocates subnets sequentially within a fixed private IPv4 block. Future versions may support arbitrary base networks.

The output's are logged to a dedicated file: Main.log, ensuring errorsS saved.

## How to use
Request help using __main__.py -h

Input:
__main__.py Marketing: 55 Consultancy: 44 IT: 21 -v 1

## Constraints & Future improvements
### How do I let users enter arbitrary networks?
Short answer: I don’t — at least not yet.
Allowing completely arbitrary network input would explode into an endless parade of edge cases, validation quirks, and subtle bugs. For an early‑stage tool, that’s a recipe for instability rather than usefulness.
A far better approach is to build a focused, reliable core first, then introduce advanced capabilities incrementally. Free‑form network entry simply isn’t a priority for version one. Supporting it safely would require automated testing across every private‑range IP, and that level of complexity doesn’t belong in a month‑one release.

### IPv6 Functionality
IPv6 support should be straightforward to add later, but it isn’t a priority until I’ve taken the time to properly understand IPv6 itself. Implementing it now would mean pulling in additional IPv6‑specific modules, expanding the input surface, or even splitting the tool into separate versions — all of which would overcomplicate what is meant to remain a simple, focused project at this stage.
