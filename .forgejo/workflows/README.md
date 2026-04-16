# Settings for workflow
`Actions` > `General` > `Workflow permissions`
- Read and write permissions

`Secrets and variables` > `Actions` > `New repository secret`
- DOCKERHUB_TOKEN
- DOCKERHUB_USERNAME
- GITEA_TOKEN (for release creation)

# Notes
- Forgejo Actions uses `gitea.*` context (with `github.*` as alias for compatibility)
- Secrets are accessed via `secrets.*` like GitHub Actions
- Use `forgejo-cli` or curl to Forgejo API for release management
- Gitleaks is installed via CLI instead of GitHub action
