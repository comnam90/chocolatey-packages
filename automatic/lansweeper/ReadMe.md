# <img src="https://27jts3o00yy49vo2y30wem91-wpengine.netdna-ssl.com/wp-content/uploads/2018/08/LsAgent-Scanning-Agent.png" width="48" height="48"/> [lsagent](https://chocolatey.org/packages/lansweeper)

LsAgent is a small, lightweight application that you can install on your Windows, Mac and Linux devices. It gathers the asset data locally and then sends it back to your Lansweeper installation, either by using a direct push or through Lansweeper's cloud-hosted relay service.

## Features

* Automatically collect an inventory from a computer and sends the data back to a Lansweeper installation, either directly or through the lansweeper relay server in the cloud.
* Does not require scanning credentials in Lansweeper.
* Does not require administrative privileges to be able to scan.
* Does not require configuration of your computers' firewalls for scanning. It does require an outbound connection to your Lansweeper installation or cloud relay server.

## Package parameters

The following parameters can be used:

* `/upgrade`: to update a Lansweeper installation.
* `/parts`: to specify which components to install (e.g. /parts ="SCAN,DB,WEB").
* `/dbserver`: SQLLocalDB or SQLServer (e.g. /dbserver="SQLServer").
* `/dbinstance`: to choose the SQL Server instance to connect to (e.g. /dbinstance="localhost\sqlexpress").
* `/dbuser`: to specify the database username that creates the database during installation.
* `/dbpassword`: to specify the database password of the user that creates the database during installation.
* `/dbuserconfig`: optional password for the lansweeperuser database user, useful when installing multiple scanning servers.
* `/allowdboverwrite`: forces the installer to overwrite an existing database found during a new Lansweeper installation.
* `/webserver`: IIS or IISExpress.
* `/httpport`: to specify the web console's HTTP port (e.g. httpport=81).
* `/httpsport`: to specify the web console's HTTPS port (e.g. httpsport=82).
* `/folder`: to specify the Lansweeper installation folder.
* `/credkeyfile`: to specify the encryption key file (Encryption.txt) to be used.
* `/noDCOMReset`: to prevent the Lansweeper installer from making DCOM changes on the Lansweeper server.
* `/ConfigurationFile`: to perform the installation by pointing to a config file that contains the necessary parameters.

Example: `choco install lansweeper --params "/dbserver=sqlserver /dbinstance=localhost\sqlexpress /allowdboverwrite"`

All parameters and values are case-insensitive, except the values provided for /dbuserconfig and /dbpassword.  
If a specific parameter is not provided, a default value is assumed. For instance, if you don't specify which components to install, the assumption is made that you want to install all of them.  
If the installation stops unexpectedly, its log file can be found by typing %temp% in the path of Windows Explorer. The log file is a .txt and will start with "Setup Log...".  
The final installation log file can be also found in Program Files (x86)\Lansweeper\Install on your Lansweeper server once the installation has fully completed.

## Notes

* `upgrade` parameter must be specified when upgrading an existing installation, otherwise it will overwrite the existing installation.
