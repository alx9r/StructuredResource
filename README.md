# StructuredResource

StructuredResource is a PowerShell module that streamlines the authoring of robust and consistent DSC resources.

## Goals and Strategy

The goal of the StructuredResource project is to reduce the cost of implementing and maintaining DSC resources while increasing their robustness and consistency.  The current strategy to achieve this is the following:

* reduce the total amount of code by moving repetitious code (including test code) into the StructuredResource module where it can be re-used across DSC resources
* establish guidelines that result in consistent interfaces and behaviors across DSC resources
* implement automated tests that support test-driven development (TDD) and support refactoring of DSC resources with confidence  

## Parts

StructuredResource includes three related parts:

* **[Guidelines][]** - a set of written guidelines for authoring robust and consistent DSC resources and the reasons for those guidelines.
* **Tests** - automated tests suitable for test-driven development that check a resource for compliance with the guidelines.
* **Framework** - a few commands that reduces the amount of code repetition across DSC resources.

[Guidelines]: Docs/guidelines.md

## Documentation

You can find the [documentation here][].

[Documentation]: Docs