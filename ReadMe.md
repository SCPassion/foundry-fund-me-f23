README.md:
1 Proper README
2 Integration tests
3 Programatic verification
4 Push to github

1.git status  
Check what files are pushed to github

2. git add .
Add all files to the git status except the files in .gitignore

3. git log
Show the version history

4. Commit to git.
git commit -m 'Our first commit!'

5. You will see this with git log
```
commit faa7560339aad5e195cc316be9b961db93464f8c
Author: Bernard <bernard.bmehk@gmail.com>
Date:   Fri Aug 18 18:42:03 2023 +0000

Our first commit!
```
This commit history is stored locally, we need to push the code to github.

6. Create a new repository on github

7. Copy the link of following information from github new repository page
```
Quick setup — if you’ve done this kind of thing before
or	
https://github.com/SCPassion/foundry-fund-me-f23.git
Get started by creating a new file or uploading an existing file. We recommend every repository include a README, LICENSE, and .gitignore.
```

8. git remote add origin https://github.com/SCPassion/foundry-fund-me-f23.git
remote keyword refers to a website like github. 
add keyword stands for adding our remote place for us to push our code.
origin keyword is a shortened name for the giant URL, and the URL is the actual place where we want to push our code to.

8.5. git remote -v: see where to push and pull our code from. (fetch is pull, push is push)

9. git push -u origin main
Push all of our codes to the URL asssociated with origin and on the main branch.

# My way to do it
```
// If there is a origin existed
git remote remove origin
git remote add origin https://github.com/SCPassion/foundry-fund-me-f23.git
git branch -M main
git add .
git status
git commit -m 'My first Commit'
git push -u origin main
```