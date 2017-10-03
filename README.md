[![Build status](https://ci.appveyor.com/api/projects/status/c4o1e8ci9p6vqj0k?svg=true&passingText=master%20-%20OK)](https://ci.appveyor.com/project/alx9r/structuredresource/branch/master)

# StructuredResource

StructuredResource is a PowerShell module that streamlines the development and maintenance of robust and consistent DSC resources.

## Goals and Strategy

The goal of the StructuredResource project is to reduce the cost of developing and maintaining DSC resources while increasing their robustness and consistency.  The current strategy to achieve this is as follows:

* reduce the amount of code in DSC resources by doing the following:
	* move repetitious code (including test code) into the StructuredResource module where it can be re-used across resources
	* write only the minimum amount of code for each resource to pass the automated tests
* reduce the number of edge cases by establishing guidelines for consistent interfaces and behaviors across DSC resources
* speed the development of new DSC resources by way of automated tests that support test-driven development (TDD)
* reduce the risk of maintenance of DSC resources by way of automated regression tests 

## Parts

StructuredResource includes three related parts:

* **[Guidelines][]** - a set of written guidelines for authoring robust and consistent DSC resources and the reasons for each guideline.
* **Tests** - automated tests suitable for test-driven development that check a resource for compliance with the guidelines.
* **Framework** - a few commands that reduces the amount of code repetition across DSC resources.

[Guidelines]: Docs/guidelines.md

## Documentation

You can find the [documentation here][].

[documentation here]: Docs