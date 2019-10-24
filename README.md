# DevSecOps Example Heroku

This repository shows exemplary how to set up a DevSecOps build chain which detects vulnerabilities in an application upon a commit / deployment.

**DO NOT DEPLOY THE APPLICATION IN THIS REPOSITORY IF YOU DO NOT EXACTLY KNOW WHAT YOU ARE DOING**

The enclosed application contains:
- Only an index page with a reflected XSS vulnerability
- A framework which contains vulnerabilities

## Vulnerable Application

This is a simple web application written with Django. It implements a single view which will return everything the user inputs. The templating engine disables the automatic XSS protection feature which sanitizes the input. In addition, the XSSDisableMiddleware disables the XSS protection feature implemented in modern web browser.

## Tutorial

This application contains a build file for [CircleCI](https://circleci.com/) to deploy the vulnerable application to [Heroku](https://heroku.com). There are build jobs defined to do a dependency check for the python application using [safety](https://pypi.org/project/safety/) and a dynamic application security test using the [Crashtest Security Suite](https://crashtest-security.com).

This application is used within workshops hold by [Crashtest Security](https://crashtest-security.com/janosch). This tutorial contains the steps to follow the workshop. In case you want to attend one of those workshops, let us know via [e-mail](mailto:info@crashtest-security.com).

### Create Accounts

- [GitHub](https://github.com): Create an account to get access to the source code of this example project
- [CircleCI](https://circleci.com/signup/): Login using GitHub to grant CircleCI access to your GitHub projects
- [Heroku](https://heroku.com): Create an account to deploy the example application there
- [Crashtest Security](https://crashtest.cloud): Create an account to conduct a dynamic vulnerability scan

### Fork the Repository

To get access to the repository code, fork this repository by clicking the "Fork" button on the top right: https://github.com/crashtest-security/devsecops-example-heroku

![Fork Repository](/res/01_github.png)

This will create your own copy of the code repository and redirect you to the repository page.

### Configure Heroku to be used with this project

- Create a new application within Heroku: https://dashboard.heroku.com/new-app. You may choose any name and region you like. Just remember the name of your new Heroku app. We will refer to the name of your Heroku app as `HEROKU_APP_NAME`. For this tutorial, I have named the application `sigs-devsecops-example`
- Go to the app settings, click on "Reveal Config Vars" and add a new environment variable `DISABLE_COLLECTSTATIC = 1`. This is needed for the Django application to run properly on heroku. If you miss to set this environment variable you will later see an error message during the corresponding build step.
- When you click on "Open App", you should see a default page from Heroku that states that you have no application running yet.

![Heroku Environment Variable](/res/02_heroku.png)

- Retrieve your Heroku API key here: https://dashboard.heroku.com/account (At the bottom of the page). You need this API key to grant CircleCI access to deploy your application. We will refer to this variable as `HEROKU_API_KEY`.


### Link GitHub Repository with CircleCI Workflow

- Open the CircleCI dashboard: https://circleci.com/dashboard. When you get asked for login credentials, log in using your GitHub account. This grants CircleCI access permissions to get the code from your repository.
- Add your GitHub Repository to CircleCI by clicking "Add Projects" in the left menu bar and then on "Set Up Project"
- Choose "Workflows" in the left menu bar and then click on the little gear symbol next to your project
- Configure the following two environment variables:

    - `HEROKU_APP_NAME` - Enter the name that you previously chose
    - `HEROKU_API_KEY` - Enter the API Key as provided by Heroku

![Circle CI Environment Variables](/res/03_circleci.png)

### Commit a Change to the Repository

- To start a fresh build in CircleCI, we need to trigger a change in the repository. Therefore we add a submit button to the form in the application.
- In your GitHub repository navigate to `devsecops-example-heroku/vulnerable/templates/index.html` and click the pencil icon to edit the file.
- Add a button to the form by adding the following code before the form closing tag (line 11).

```html
<input type="submit" value="Send!" />
```

![Add Submit Button to Application](/res/04_github.png)

- When the file is saved, the change is commited to the repository and a new build is triggered in CircleCI automatically.

![Successful Build in CircleCI](/res/05_circleci.png)

- The build deploys the application and you can now access it from Heroku by clicking the "Open App" button.

![Running Application](/res/06_application.png)

- You can see that the application contains a Cross-Site-Scripting vulnerability by typing the following as your name within the application. This will make the browser show an alert box as it is interpreting your provided JavaScript:

```html
<script>alert("XSS")</script>
```

### Enable Python Safety (SAST) Build Step

- To enable the dependency check of all python dependencies in the build, add the following lines at the end of the file `devsecops-example-heroku/vulnerable/.circleci/config.yml` (make sure that the indentation matches).

```yaml
      - sast
```

![Add DAST Scan](/res/07_github.png)

- The new build step must fail, as there are known vulnerabilities in the Django version used.

![Failed Build](/res/08_circleci.png)

- To fix the build, figure out what the latest Django version is and update it in the file `devsecops-example-heroku/requirements.txt`. You can find the latest Django version here: https://www.djangoproject.com/download/

### Enable Crashtest Security (DAST) Build Step

- To integrate a dynamic vulnerability scan using the Crashtest Security Suite, log in on https://crashtest.cloud and create a new project with the following settings:

    - Project Type: Multi Page Application
    - Title: Choose a title you like
    - Protocol: https
    - URL: The URL that your application is running (Copy from your browser address bar after clicking on "Open App" in Heroku).

- Click on Verify Project to download the verification file. You need this file to allow the Crashtest Security Suite to scan your application.

![Download Verification File](/res/09_crashtest.png)

- In GitHub within the root directory of your project click on "Create new file". Name the file similar to the downloaded verification file and fill it with the same content.

![Add Verification File](/res/10_github.png)

- Generate a Webhook within the Crashtest Security Suite. Go to the project preferences and click on "Generate" in the Webhook section

![Generate Crashtest Security Suite Webhook](/res/11_crashtest.png)

- Add a new environment variable in the project settings in CircleCI:

    - `CRASHTEST_WEBHOOK` - Enter the ID of the webhook that you just generated (without the URL path). 

![Configure Webhook in CircleCI](/res/12_circleci.png)

- Now enable the dynamic vulnerability scan for your application by adding the following lines at the end of the file `devsecops-example-heroku/vulnerable/.circleci/config.yml` (make sure that the indentation matches, the line "requires" has 4 additional whitespaces of indentation compared to the line before).

```yaml
      # Start Crashtest Security Suite
      - dast:
          requires:
            - deploy

```

![Add DAST Scan](/res/13_github.png)

- Now the build fails because of several more detected vulnerabilities such as the Cross-Site-Scripting Vulnerability

![Failed Build in CircleCI](/res/14_circleci.png)

### Resolve Vulnerabilities

- To resolve the Cross-Site-Scripting vulnerability open the file `devsecops-example-heroku/vulnerable/templates/index.html` and remove the pipe `| safe` in line 4.
- Now you should get a successful build again and have a much more secure application than before.
