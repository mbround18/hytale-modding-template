# CI Requirements

## Required Environment Variables

### HYTALE_SERVER_JAR_DOWNLOAD_URL

**Required for:** GitHub Actions and other CI environments

The build process requires `HytaleServer.jar` at compile time as a `compileOnly` dependency. In local development, this is automatically obtained via Docker Compose with OAuth authentication. However, CI environments cannot use Docker Compose and OAuth interactively.

**Solution:** Provide a direct download URL for the server jar via the `HYTALE_SERVER_JAR_DOWNLOAD_URL` environment variable.

**⚠️ IMPORTANT:** The URL must be a **direct download link** that returns the JAR file directly, not an HTML page. For services like Google Drive or Dropbox, ensure you use the direct download URL format (not the sharing page URL). The download uses `curl -L` to follow redirects, but the final response must be the actual JAR file.

### Setting Up in GitHub Actions

1. **Obtain the Server JAR:**
   - Run `./gradlew setup` locally (requires OAuth login)
   - The jar will be placed at `data/server/Server/HytaleServer.jar`

2. **Upload to Accessible Location:**
   - Option A: Upload to a file hosting service (Dropbox, Google Drive with public link, etc.)
   - Option B: Upload to GitHub Releases in your fork/repo
   - Option C: Use a private artifact repository with authentication

3. **Add Secret to Repository:**
   - Go to repository Settings → Secrets and variables → Actions
   - Click "New repository secret"
   - Name: `HYTALE_SERVER_JAR_DOWNLOAD_URL`
   - Value: The direct download URL for your hosted jar file

4. **Update Workflow:**
   - The CI workflow will automatically use this variable when available
   - If not set, builds will fail with a clear error message
   - The jar is cached between runs (keyed on `compose.yml` hash), so it only downloads once per server version

## Security Considerations

- **Never commit the jar to git** - Contains proprietary Hytale server code
- Use GitHub Secrets or equivalent for the download URL
- Consider using a private repository or authentication if the jar shouldn't be publicly accessible
- The jar is only needed at compile time for API references, not bundled in the final plugin

## Local Development

Local development does **not** require this environment variable. The build automatically uses Docker Compose with OAuth authentication to obtain the server jar when needed.
