# fastmcp-server-first

A FastMCP server with HTTP support, providing a simple MCP (Model Context Protocol) server that can be accessed over HTTP.

## Features

- Single tool: `add_numbers` - Adds two numbers together
- HTTP transport support
- Devcontainer configuration for easy development

## Prerequisites

- Python 3.10 or higher
- pip for package installation

## Installation

Install the package and its dependencies:

```bash
pip install -e .
```

## Usage

### Running the Server

Start the FastMCP server:

```bash
python server.py
```

The server will start on `http://0.0.0.0:8000/mcp` and be accessible via HTTP.

### Using with MCP Clients

The server exposes one tool:

- `add_numbers(a: int, b: int) -> int`: Adds two integers and returns the result

Any MCP-compatible client (like Claude Desktop, Cursor, VSCode with MCP extension, Amazon Q Developer) can connect to the server at `http://localhost:8000/mcp`.

## Development

### Using Devcontainer

This project includes a devcontainer configuration for VS Code:

1. Open the project in VS Code
2. Click "Reopen in Container" when prompted (or use Command Palette > "Dev Containers: Reopen in Container")
3. The container will automatically install dependencies
4. Port 8000 will be forwarded automatically

### Manual Setup

If not using devcontainer:

```bash
# Install dependencies
pip install -e .

# Run the server
python server.py
```

## License

See LICENSE file for details.
