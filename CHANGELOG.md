# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

* increase lambda timeout to 60s

## 0.3.0 (May 14, 2024)

* adding repo policy ([#5])

[#5]: https://github.com/tradeparadigm/terraform-aws-ecr-repo-lambda/pull/5

## 0.2.0 (April 2, 2024)

Switching runtime to python3.12, and other random fixes

* fixing a typo in README
* updating AWS Lambda runtime from `python3.9` to `python3.12`
* updating pre-commit hooks repo versions
* removing duplicate `content` key in TF Docs config
* fixing default value of `var.repo_lifecycle_policy`
* making `var.repo_lifecycle_policy` nullable
* adding error log message when JSON parsing fails
* corrected module source in the example
* removed `CODEOWNERS` and `CONTRIBUTING.md` from the root of the repo

## 0.1.0 (August 15, 2022)

* Initial release
