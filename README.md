# cloneToCleanGitRepositories version 1.1

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/3e4ce1255ba84133a898d5bd94d6e8f7)](https://app.codacy.com/app/bertrand-benoit/cloneToCleanGitRepositories?utm_source=github.com&utm_medium=referral&utm_content=bertrand-benoit/cloneToCleanGitRepositories&utm_campaign=Badge_Grade_Dashboard)

This is a free tool allowing to clone from a dirty Catchall Git repository to create clean repository for each specified versioned element.

I created initially this tool after having posted a [question on Stackoverflow](https://stackoverflow.com/q/53396677/10524205).

This script uses my [scripts-common](https://github.com/bertrand-benoit/scripts-common) project, you can find on GitHub.

## First time you clone this repository
After the first time you clone this repository, you need to initialize git submodule:
```bash
git submodule init
git submodule update
```

This way, [scripts-common](https://github.com/bertrand-benoit/scripts-common) project will be available and you can use this tool.

## Usage
```bash
Usage: ./cloneToCleanGitRepositories.sh <source repository> <dest root directory> <filter>
<source repository>    path to the existing catchall git repository
<dest root directory>  path to the existing root directory, in which git repositories will be created
<filter>		       the (find) file pattern for which a git repository must be created

N.B.: the source repository won't be altered in any way
```

## Sample
Imagine you have a single Git repository with several scripts in it, and now you would like a dedicated Git repository for each of your script; then this tool is perfect for you.

```bash
./cloneToCleanGitRepositories.sh /path/to/my/catchall/git/repository /tmp/myFirstTest '*.sh'
```

## Contributing
Don't hesitate to [contribute](https://opensource.guide/how-to-contribute/) or to contact me if you want to improve the project.
You can [report issues or request features](https://github.com/bertrand-benoit/cloneToCleanGitRepositories/issues) and propose [pull requests](https://github.com/bertrand-benoit/cloneToCleanGitRepositories/pulls).

## Versioning
The versioning scheme we use is [SemVer](http://semver.org/).

## Authors
[Bertrand BENOIT](mailto:contact@bertrand-benoit.net)

## License
This project is under the GPLv3 License - see the [LICENSE](LICENSE) file for details
