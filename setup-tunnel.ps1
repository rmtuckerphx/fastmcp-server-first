# Setup script for exposing MCP server publicly via devtunnel
# This script helps make your local MCP server accessible to Copilot Studio

Write-Host "Setting up public tunnel for MCP Server..." -ForegroundColor Green

# Check if devtunnel is installed
try {
    $devtunnelVersion = devtunnel --version
    Write-Host "Devtunnel is installed: $devtunnelVersion" -ForegroundColor Green
} catch {
    Write-Host "Devtunnel is not installed. Please install it first:" -ForegroundColor Red
    Write-Host "winget install Microsoft.DevTunnels" -ForegroundColor Yellow
    exit 1
}

# Login to devtunnel (if not already logged in)
Write-Host "Logging in to devtunnel..." -ForegroundColor Yellow
devtunnel user login

# Create or update tunnel
Write-Host "Creating tunnel 'fast-mcp-server'..." -ForegroundColor Yellow
try {
    devtunnel create fast-mcp-server -a --host-header unchanged
} catch {
    Write-Host "Tunnel might already exist, continuing..." -ForegroundColor Yellow
}

# Create port mapping
Write-Host "Setting up port forwarding for port 8000..." -ForegroundColor Yellow
devtunnel port create fast-mcp-server -p 8000

# Start hosting (this will show the public URL)
Write-Host "Starting tunnel host..." -ForegroundColor Green
Write-Host "Your MCP server will be publicly accessible!" -ForegroundColor Green
Write-Host "The public URL will be shown below. Use this URL + '/mcp' in Copilot Studio" -ForegroundColor Cyan

devtunnel host fast-mcp-server