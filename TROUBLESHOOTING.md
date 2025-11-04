# Troubleshooting Guide for MCP Server + Copilot Studio

## Common Issues and Solutions

### Issue 1: "notFound" Error in Copilot Studio

**Symptoms:**
```json
{
  "reasonCode": "RequestFailure",
  "errorMessage": "Connector request failed",
  "HttpStatusCode": "notFound"
}
```

**Causes and Solutions:**

1. **Server Not Publicly Accessible**
   - Problem: Your MCP server is running on localhost, but Copilot Studio runs in the cloud
   - Solution: Use a tunneling service like devtunnel, ngrok, or deploy to a cloud service

2. **Incorrect URL Configuration in Copilot Studio**
   - Problem: Wrong endpoint URL configured in Copilot Studio
   - Solution: Ensure you're using the correct public URL + `/mcp` path

3. **CORS Issues**
   - Problem: Cross-origin requests blocked
   - Solution: Ensure CORS is properly configured (done in the updated server.py)

4. **Server Not Running**
   - Problem: MCP server is not actually running
   - Solution: Check if the server process is active

### Issue 2: Server Starts But Can't Connect

**Troubleshooting Steps:**

1. **Test Local Connectivity**
   ```bash
   # Test health endpoint
   curl http://localhost:8000/health
   
   # Test MCP endpoint
   curl http://localhost:8000/mcp
   ```

2. **Check Public Access**
   ```bash
   # If using devtunnel, test the public URL
   curl https://YOUR-TUNNEL-URL/health
   ```

3. **Verify MCP Protocol**
   ```bash
   # Use MCP Inspector to test
   npx @modelcontextprotocol/inspector
   ```

### Issue 3: Authentication/Authorization Issues

**If Copilot Studio requires authentication:**

1. Check if your MCP server needs API keys
2. Verify authentication headers are configured correctly
3. Ensure proper authentication method is selected in Copilot Studio

### Configuration Checklist for Copilot Studio

1. **Connector Type**: Custom Connector or HTTP
2. **Base URL**: Your public tunnel URL (e.g., `https://abc123.devtunnels.ms`)
3. **Endpoint Path**: `/mcp`
4. **HTTP Method**: POST (for MCP protocol)
5. **Headers**: 
   - Content-Type: application/json
   - Accept: application/json

### Testing Your Setup

1. **Start the MCP Server**
   ```bash
   python server.py
   ```

2. **Start the Public Tunnel** (in another terminal)
   ```bash
   .\setup-tunnel.ps1
   ```

3. **Test Endpoints**
   - Health: `https://YOUR-TUNNEL-URL/health`
   - MCP: `https://YOUR-TUNNEL-URL/mcp`
   - Root: `https://YOUR-TUNNEL-URL/`

4. **Configure Copilot Studio**
   - Use the tunnel URL as base URL
   - Add `/mcp` as the endpoint path
   - Test the connection

### Advanced Debugging

1. **Enable Debug Logging**
   - The updated server.py includes logging
   - Monitor the console for incoming requests

2. **Use Network Tools**
   - Browser Developer Tools
   - Postman or similar for API testing
   - Network monitoring tools

3. **Check Firewall Settings**
   - Ensure port 8000 is not blocked
   - Check Windows Defender Firewall if needed

### Getting Help

If issues persist:

1. Check the FastMCP documentation
2. Review Copilot Studio connector documentation
3. Verify your network configuration
4. Consider alternative deployment methods (Azure Functions, etc.)