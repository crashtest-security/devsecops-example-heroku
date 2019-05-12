# DevSecOps Example Heroku

This repository shows exemplary how to set up a DevSecOps build chain which detects vulnerabilities in an application upon a commit / deployment.

**DO NOT DEPLOY THE APPLICATION IN THIS REPOSITORY IF YOU DO NOT EXACTLY KNOW WHAT YOU ARE DOING**

The enclosed application contains:
- Only an index page with a reflected XSS vulnerability
- A framework which contains vulnerabilities

## Vulnerable Application

This is a simple web application written with Django. It implements a single view which will return everything the user inputs. The templating engine disables the automatic XSS protection feature which sanitizes the input. In addition, the XSSDisableMiddleware disables the XSS protection feature implemented in modern web browser.

## Deployment

This application contains a build file for [circleci](https://circleci.com/) to deploy the vulnerable application to [Heroku](https://heroku.com). There are build jobs defined to do a dependency check for the python application using [safety](https://pypi.org/project/safety/) and a dynamic application security test using the [Crashtest Security Suite](https://crashtest-security.com).

To run these jobs, they need to be added to the defined workflow.