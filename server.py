"""FastMCP Server - A simple MCP server with HTTP support.

This server provides a single tool for adding two numbers together.
"""

from fastmcp import FastMCP

# Create the FastMCP server instance
mcp = FastMCP("FastMCP Server First")


@mcp.tool()
def add_numbers(a: int, b: int) -> int:
    """Add two numbers together.
    
    Args:
        a: The first number
        b: The second number
        
    Returns:
        The sum of a and b
    """
    return a + b


if __name__ == "__main__":
    # Run the server with HTTP transport
    mcp.run(transport="http", host="0.0.0.0", port=8000, path="/mcp")
