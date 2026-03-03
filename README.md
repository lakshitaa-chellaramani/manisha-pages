# Manisha Art Jewellers

This project contains the source for the static marketing site.  It is intended to be kept in a **private** GitHub repository while the built/compiled files are published to a separate **public** repository that is served via GitHub Pages.

Below are the steps to get both repositories set up.  The examples use the GitHub CLI (`gh`), which is convenient but not required; if you don’t have it installed you can create the repos via the GitHub website and simply copy the URLs in the commands.

> **Tip:** on Windows you can install the CLI with `winget install --id GitHub.cli` or download from https://cli.github.com/.  After installing run `gh auth login` to connect to your account.

You can adapt the commands to other tools if you prefer.

---

## 1. Create the private source repository

```powershell
cd C:\Users\Admin\Documents\sidequests\manisha
# initialise local repo if not already
git init
git add .
git commit -m "initial commit of site source"

# create a private repo on GitHub (requires gh CLI configured)
gh repo create manisha-source --private --description "Source for Manisha Art Jewellers website"

# push the current branch (e.g. main)
git branch -M main
git remote add origin git@github.com:<YOUR_USER>/manisha-source.git
git push -u origin main
```

*If you don't use `gh`, log into GitHub, create a private repo named `manisha-source`, and add the remote URL manually.*


## 2. Create the public Pages repository

```powershell
# make a second repo that will host the compiled site
gh repo create manisha-pages --public --description "Published site for Manisha Art Jewellers" --enable-pages

# the repository will be empty; you will push the built files to it
```

The Pages repository will serve whatever is on its `main` branch (or `gh-pages` if you choose) as a static site.  You can configure a custom domain in its settings later.


## 3. Deployment script

Add the following PowerShell script to the source repo to simplify publishing.  It clones the public repo into a temporary folder, copies over the current contents of `manisha`, commits, and pushes.

```powershell
# deploy.ps1
param(
    [string]$PublicRepo = 'https://github.com/lakshitaa-chellaramani/manisha-pages.git',
    [string]$TempDir = (New-TemporaryFile).DirectoryName
)

Write-Host "Cloning public repo into $TempDir"

git clone $PublicRepo $TempDir

Write-Host "Copying files..."
# remove .git so commit history comes from the public repo
Remove-Item -Recurse -Force "$TempDir\*"

Copy-Item -Recurse -Force "*" $TempDir

Set-Location $TempDir

git add --all
try {
    git commit -m "Publish site $(Get-Date -Format g)" | Out-Null
} catch {
    Write-Host "Nothing to commit"
}

git push origin main
Write-Host "Deployment complete."
```

Invoke it from within the source repo directory:

```powershell
.\\deploy.ps1
```

You can also add this command as a npm `script` or a GitHub Action later.

> **Note:** the default repository URL in the script now uses **HTTPS**.  If you prefer SSH, make sure your SSH key is configured in GitHub or update the `$PublicRepo` variable accordingly.


## 4. Custom domain (optional)

When you have a domain name, go to the settings of the **manisha-pages** repo → Pages and add a custom domain.  GitHub will show the DNS records you need to create (typically an `A`/`ALIAS` record and a `CNAME` or `txt` for verification).  Once DNS propagates the site will respond on your own URL with a valid TLS certificate.


### Notes

* Keep the private repo `manisha-source` as the working copy; do your edits there.
* The public repo only contains the final static HTML/CSS/JS (there is no build step at the moment because it's already static).  It may be fine to simply mirror the whole directory, but you can exclude development files if you like.
* You can automate the publish step with GitHub Actions by having a workflow triggered on pushes to `main` of the source repo; the action would checkout the public repo (using a personal access token) and copy files over.  The `deploy.ps1` script is a simpler manual alternative.

---

That’s all you need to host from a private source and publish a compiled public copy without exposing your working repository.  Let me know if you want help writing the GitHub Action or adjusting the script for your environment.