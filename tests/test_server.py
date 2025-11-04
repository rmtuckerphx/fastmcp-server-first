"""Tests for the FastMCP server."""


def test_server_imports():
    """Test that the server module can be imported."""
    import server
    
    assert hasattr(server, 'mcp')
    assert hasattr(server, 'add_numbers')


def test_add_numbers_function():
    """Test the add_numbers tool function directly."""
    from server import add_numbers
    
    # The decorated function is a FunctionTool, access the original via fn attribute
    assert add_numbers.fn(2, 3) == 5
    assert add_numbers.fn(-1, 1) == 0
    assert add_numbers.fn(0, 0) == 0
    assert add_numbers.fn(100, 200) == 300


def test_mcp_server_name():
    """Test that the MCP server has the correct name."""
    from server import mcp
    
    assert mcp.name == "FastMCP Server First"
