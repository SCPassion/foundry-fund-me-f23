README.md:
# Useful commands

```
git status  : Check what files are pushed to github

git add . : Add all files to the git status except the files in .gitignore

git log : Show the version history

git commit -m 'Our first commit!' : Commit to git. This commit history is stored locally, we need to push the code to github.

git remote add origin https://github.com/SCPassion/foundry-fund-me-f23.git
remote keyword refers to a website like github. 
add keyword stands for adding our remote place for us to push our code.
origin keyword is a shortened name for the giant URL, and the URL is the actual place where we want to push our code to.

git remote -v: see where to push and pull our code from. (fetch is pull, push is push)

git push -u origin main : Push all of our codes to the URL asssociated with origin and on the main branch.
```
# My way to do it
Create a new repository on github
Copy the link of following information from github new repository page
```
Quick setup — if you’ve done this kind of thing before
or	
https://github.com/SCPassion/foundry-fund-me-f23.git
Get started by creating a new file or uploading an existing file. We recommend every repository include a README, LICENSE, and .gitignore.
```

# Push an update to github, (your need to have a repository created on github)
```
// If there is a origin existed
git remote remove origin // If you would like to change a new repository
git remote add origin https://github.com/SCPassion/foundry-fund-me-f23.git
git branch -M main // Change the default branch from "master" to "main" locally, you will need to push the changes
git add .
git status
git commit -m 'My first Commit'
git push -u origin main
```

# To Clone a repository from github
```
cd // back to main directory
mkdir patrick-fund-me-f23 // Make a new folder for upcoming clone project
git clone https://github.com/Cyfrin/foundry-fund-me-f23 patrick-fund-me-f23 // Clone the project from github to local folder
code patrick-fund-me-f23/ // Open the project in VS Code
```