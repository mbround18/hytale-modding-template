# CI Requirements

## Required Environment Variables

### HYTALE_SERVER_JAR_DOWNLOAD_URL

**Required for:** GitHub Actions and other CI environments

The build process requires `HytaleServer.jar` at compile time as a `compileOnly` dependency. In local development, this is automatically obtained via Docker Compose with OAuth authentication. However, CI environments cannot use Docker Compose and OAuth interactively.

**Solution:** Provide a direct download URL for the server jar via the `HYTALE_SERVER_JAR_DOWNLOAD_URL` environment variable.

**⚠️ CRITICAL - IP PROTECTION:** The download URL **MUST** be behind a secure source to prevent unauthorized distribution of proprietary Hytale server code. This is not optional.

**Secure sources include:**

- **Google Drive** with restricted sharing (link-only, no public access)
- **OneDrive** with restricted access policies
- **AWS S3** with signed URLs or dedicated API keys (never use public buckets)
- **Private artifact repositories** (Artifactory, Nexus, etc.) with authentication
- **Other private cloud storage** with access controls

**⚠️ DO NOT use:**

- Public GitHub Releases
- Public file hosting services
- Any publicly accessible URL without authentication

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
   - **Note:** The jar is **not cached** in GitHub Actions to reduce piracy risk and avoid accumulating proprietary code. The jar downloads fresh on each CI run that needs it (usually only when `compose.yml` changes)

## Security Considerations

**PIRACY PREVENTION:**

- **Never make the JAR publicly accessible** - This is proprietary Hytale server code owned by Hypixel Studios
- The download URL must be restricted to authorized users only via authentication or access controls
- Do not commit the URL to public repositories; use GitHub Secrets exclusively
- Regular audit of who has access to the download source

**Best Practices:**

- Use API keys, signed URLs, or authentication tokens for downloads
- Rotate credentials periodically
- Consider using a private repository for additional access tracking
- The jar is only needed at compile time for API references, not bundled in the final plugin
- Never distribute the JAR outside your organization

## Local Development

Local development does **not** require this environment variable. The build automatically uses Docker Compose with OAuth authentication to obtain the server jar when needed.
