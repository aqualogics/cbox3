# Pre-requisites

Please ensure you meet the following pre-requisites prior to starting the course.
You may use your preferred environment such as Windows, Mac or Linux although the course
video presentations will be delivered from a Mac.

## [IDE]()

Use your favorite code editor. However if you do not have one, we recommend VSCode (Visual Studio). 
You can install a CFML syntax plug-in within the IDE.

* https://code.visualstudio.com/download
* https://www.sublimetext.com/download


## [Java](https://www.java.com/en/) (Version 8)

This can be downloaded bundled with CommandBox if needed
* https://www.java.com/en/
* https://www.ortussolutions.com/products/commandbox


## **Optional** [Git](https://git-scm.com)

* https://git-scm.com

## **Optional** [GitUI]()


## [CommandBox CLI](https://www.ortussolutions.com/products/commandbox#download) (Version 4.\*)

On a Mac, Commandbox installation is done using Homebrew. However, if you do not have the required Java JDK already installed, homebrew will prompt you to install it first, prior to the actual commandbox installation.

** Optional ** If you already have Homebrew installed on your Mac, but an old version, we recommend that you upgrade it as follows:

```
brew upgrade
```

Then, if you do not have Commandbox already installed:

```
brew install commandbox
```

Then run the `box` command within the bin directory at the above location. This is a one time process that will configure commandbox. On Mac, the `box`command will be made automatically available system-wide in any terminal window. If it does not, place the `box` binary in your `/usr/bin` directory. 

Commandbox binaries will be installed at /usr/local/cellar/commandbox/version

Otherwise, if you already have an older version of Commandbox installed, we suggest you upgrade to the current version as of this writing (September 2021) - version 5.4.x:

```
brew upgrade commandbox
```

Otherwise, for other platforms, follow download and installation instructions here:

* https://www.ortussolutions.com/products/commandbox#download
* https://commandbox.ortusbooks.com/content/setup/installation

## MySQL Server

You need to have a running MySQL Server locally.

**Important** : We still give preference to version 5.7 and not 5.8.  The JDBC drivers in Lucee and Adobe CF used to have conflicting issues with MySQL version 5.8. These issues may have been resolved by now, but we have not tested them.

To download MySQL 5.7, you may have to run Homebrew to install it on Mac, as it is no longer available for download on the MySQL site herein-below. 

If you had rather go with MySQL 5.8, you can get started with a download of 
[MySQL](https://dev.mysql.com/downloads/mysql/) for your operating system.

## MySQL Client

You'll need a SQL client to inspect and interact with your database. Whatever your favourite MySQL client, **you must be allowed to run an SQL script**, meaning loading an SQL file into an import utility and run it. You can use any client you would like. Here are a few we like ourselves:

* [Sequel Pro](https://sequelpro.com) (Mac, Free)
* [Heidi SQL](https://www.heidisql.com) (Windows, Free)
* [Data Grip](https://www.jetbrains.com/datagrip/) (Cross Platform, Commercial / Free Trial)
* [phpMyAdmin](https://www.phpmyadmin.net/downloads/)

On Mac, we recommend Sequel Pro, since phpMyAdmin requires PHP and that since Big Sur (11.5+), MacOS no longer comes with PHP installed by default.

### Launch your MySQL Client
 
You need privileges such as CREATE,ALTER,DROP to install a database. In doubt, login to MySQL as “root” in order to avoid problems during the installation.

```sh
Create a new database called `merapi` with collation `utf8_general_ci`.
```

### Create a MySQL user with limited privileges to access your database

You need a least privileged user to access MySQL from your application. This user can then be used to access your database programmatically. **Remember the credentials of that user** as you are going to need them later, during the course, when configuring the CFML engine connection to your `merapi` database.

```sh
- Assign credentials to that user (e.g: webuser/webpass)
- Deny at least: ALTER, GRANT and DROP privileges from this user
```

## Useful Resources

* ColdBox Api Docs: https://apidocs.ortussolutions.com/coldbox/6.5.2/index.html
* ColdBox Docs: https://coldbox.ortusbooks.com
* WireBox Docs: https://wirebox.ortusbooks.com
* TestBox Docs: https://testbox.ortusbooks.com
* TestBox Api Docs: https://apidocs.ortussolutions.com/testbox/4.4.0/index.html
