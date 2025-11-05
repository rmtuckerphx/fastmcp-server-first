"""FastMCP Server - A simple MCP server with HTTP support.

This server provides a single tool for adding two numbers together.
"""

import logging

from fastmcp import FastMCP
from starlette.responses import JSONResponse

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Create the FastMCP server instance
mcp = FastMCP("FastMCP Server First")

@mcp.custom_route("/health", methods=["GET"])
async def health_check(request):
    logger.info("Health check endpoint accessed")
    return JSONResponse(
        {
            "status": "healthy",
            "service": "mcp-server",
            "version": "0.1.0",
            "endpoints": {"health": "/health", "mcp": "/mcp"},
        }
    )


@mcp.custom_route("/", methods=["GET"])
async def root_handler(request):
    logger.info("Root endpoint accessed")
    return JSONResponse(
        {
            "name": "FastMCP Server First",
            "version": "0.1.0",
            "description": "A FastMCP server with HTTP support",
            "endpoints": {"health": "/health", "mcp": "/mcp"},
        }
    )


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
    logger.info("Starting FastMCP Server...")
    logger.info("Server will be available at: http://0.0.0.0:8000/mcp")
    logger.info("Health check endpoint: http://0.0.0.0:8000/health")
    logger.info("Tools available: add_numbers")

    mcp.run(transport="http", host="0.0.0.0", port=8000, path="/mcp")
