# CI Requirements

## Required Environment Variables

### HYTALE_SERVER_JAR_DOWNLOAD_URL

**Required for:** GitHub Actions and other CI environments

The build process requires `HytaleServer.jar` at compile time as a `compileOnly` dependency. In local development, this is automatically obtained via Docker Compose with OAuth authentication. However, CI environments cannot use Docker Compose and OAuth interactively.

**Solution:** Provide a direct download URL for the server jar via the `HYTALE_SERVER_JAR_DOWNLOAD_URL` environment variable.

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

### Example GitHub Release Approach

> We highly recommend a secure source like Google Drive, OneDrive, S3, etc

```bash
# After running ./gradlew setup locally
cd data/server/Server
gh release create server-jar-v1 HytaleServer.jar --repo your-username/your-repo --notes "Hytale Server JAR for CI"

# Get the download URL
gh release view server-jar-v1 --repo your-username/your-repo --json assets
```

Then set the asset's `browser_download_url` as the `HYTALE_SERVER_JAR_DOWNLOAD_URL` secret.

## Security Considerations

- **Never commit the jar to git** - it's ~3GB and contains proprietary Hytale server code
- Use GitHub Secrets or equivalent for the download URL
- Consider using a private repository or authentication if the jar shouldn't be publicly accessible
- The jar is only needed at compile time for API references, not bundled in the final plugin

## Local Development

Local development does **not** require this environment variable. The build automatically uses Docker Compose with OAuth authentication to obtain the server jar when needed.
