# CI/CD Automation (GitHub Actions)

This repository heavily leverages GitHub Actions to automate software deployment and data packaging. You can find these workflows in the `.github/workflows/` directory.

## 1. Build and Publish Containers (`build-containers.yml`)

Automatically builds OCI (Docker) containers for all environments and pushes them to the GitHub Container Registry (`ghcr.io`).

* **Trigger:** Runs automatically when a new GitHub Release or Tag is created.
* **Use Case:** Releasing production-ready, locked software environments. Allows users and grid environments (like HTCondor) to simply `docker pull ghcr.io/r-xue/stack-man/casa:latest` without needing to build the stack from source.

## 2. Package CASA Rundata (`package-casarundata.yml`)

Automatically resolves, downloads, and compresses the ~1GB `casarundata` directory (containing critical IERS tables and ephemerides), uploading the tarball as a GitHub Release artifact.

* **Trigger:** Runs on a scheduled cron job (every Monday and Thursday), or manually via the "Run workflow" button in the GitHub UI. It also tests safely in Pull Requests.
* **Use Case:** CASA data updates constantly. Instead of manually downloading 1GB of data to your laptop and copying it to the grid, this workflow handles it in the cloud. It uses GitHub's internal caching to pull delta updates in seconds, generating uniquely versioned `casarundata-YYYYMMDD.tar.gz` payloads perfect for HTCondor OSDF transfers.

## 3. Documentation Deployment (`docs.yml`)

Automatically builds this documentation site using Zensical and deploys it to GitHub Pages.

* **Trigger:** Runs automatically when commits are pushed to the `main` branch that modify the `docs/` folder or `zensical.toml`.
* **Use Case:** Ensuring that the hosted documentation is always perfectly in sync with the repository's `main` branch.

---

## Local Documentation Development

If you want to edit these documents and preview them locally before pushing to GitHub, you can use `uvx` (the `uv` tool runner) to temporarily install and run Zensical without polluting your system environment.

**1. Live Preview Server**  
To spin up a local development server with hot-reloading (automatically refreshes your browser when you save a Markdown file):

```bash
uvx zensical serve
```

**2. Static Build**  
To build the raw HTML files directly to the local `site/` directory (exactly how the CI/CD pipeline does it):

```bash
uvx zensical build
```
