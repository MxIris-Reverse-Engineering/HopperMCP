# HopperMCP

## Overview
A [Model Context Protocol](https://modelcontextprotocol.io/introduction) server for `Hopper Disassembler` interaction and automation. This server provides tools to read and write `Hopper Disassembler` files via Large Language Models.

Please note that `HopperMCP` is currently in early development. The functionality and available tools are subject to change and expansion as we continue to develop and improve the server.

## Note

Due to Hopper's closed environment, it doesn't allow plugins to link to any third-party libraries, only permitting the use of basic dependencies like `Foundation` and `AppKit`. Therefore, we need to inject code into Hopper to enable loading of any type of plugin.

Hopper's SDK is also very rudimentary, with no public interfaces to obtain disassembled or decompiled code. We've reverse-engineered Hopper and call its private interfaces to access this essential information. These basic interfaces are generally stable, but there's no guarantee that the author won't modify them in future versions.

Since code injection is required, you must disable **SIP** (System Integrity Protection) to use `HopperMCP`.

## Usage

1. Move `HopperMCP.app` to your Applications folder

2. Install the Helper program (option 1 in the `HopperMCPApp` main interface, requires password)

3. Install the plugin to the specified directory (option 2 in the `HopperMCPApp` main interface)

The application needs to run in the background. You should launch `HopperMCP` before starting `Hopper` (when `HopperMCP` detects Hopper starting, it will automatically inject code)

About 3 seconds after Hopper launches, you'll see a `Tool Plugin` menu appear in the menu bar. `HopperMCP` provides 4 menu options:

- `Start MCP Plugin`
  - Starts the MCP plugin service
- `Stop MCP Plugin`
  - Stops the MCP plugin service
- `Reload Plugins`
  - Reloads all tool plugins
- `Notify Document Loaded`
  - Since plugins can't detect when Hopper has finished loading, you need to manually notify the plugin when the document has loaded completely. This will initiate some caching operations. Because Hopper doesn't provide an interface to find addresses by name, we need to handle this ourselves.

4. Start the `HopperMCP` plugin service

5. Copy the `Hopper MCP Server` JSON (option 3 in the `HopperMCPApp` main interface) and enter this JSON of your MCP client

Now you can use `HopperMCP`!

## Available Tools

- Get current assembly/pseudocode
- Get assembly/pseudocode by name
- Get assembly/pseudocode by address
- Add comment
- Add inline comment