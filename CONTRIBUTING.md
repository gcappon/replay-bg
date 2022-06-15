# Contributing to ReplayBG: A step-by-step guide

This guide is intended to describe the steps to follow to contribute to ReplayBG.

## Step 1. It all starts from an issue
If you want to contribute to ReplayBG you can:

* Open a new issue to request a *new feature* or to *report a bug* using the available issue templates  

![Issue templates](https://i.postimg.cc/sXgG4mZW/issues-template.png)

* Try to solve an open issue choosing between one of the available issues. <br>

::: tip
If you are new to the concept of contributing to an open source repository, try to start from the issues labeled as ![good first issue](https://i.postimg.cc/hvxmXjdZ/good-first-issue.png).
:::

## Step 2: Fork, branch & code

If you decided to solve an opened issue (thank you m8) just comment the issue saying that you will get into solving the issue, and finally propose a due date.

The next step is to fork ReplayBG. So, from the ReplayBG repository homepage click the ![fork](https://i.postimg.cc/rFjmQxMC/fork.png) button in the upper right corner.

Then, clone the forked repository in your local machine using: 

```BASH
git clone https://github.com/<YOUR_USERNAME>/replay-bg.git
```

and create a new branch from `master` using a proper name possibly "connected" the the issue you are solving (e.g., `fix-plot-bug`, or `new-fancy-features`), for example

```BASH
git checkout -b new-fancy-feature
```

It is now time to code. Solve the issue and commit your changes in your local branch once you have done using a proper commit message. In particular, it is a good practice to start the commit message with the branch name, between square brackets, and including the issue number at some point in the message. For example, if the issue you are solving is the #3 and the branch you are using to solve the issue is called `new-fancy-feature` a good commit could be:

```BASH
git commit -a -m "[new-fancy-feature] solves #3."
```
## Step 3: Push and make a pull request

Push the committed changes to your forked online repository remembering to define the upstream of your new branch `new-fancy-feature`

```BASH
git push --set-upstream origin new-fancy-feature
```

Finally, make a pull request to ReplayBG by clicking the ![pull request](https://i.postimg.cc/52Qh6W7Y/pull-request.png) button (can be found in the homepage of your forked repository in Github) and following the instructions. 







