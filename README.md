[![Latest Version](https://img.shields.io/github/v/release/sadik254/ubuntu-server-setup?style=flat-square)](https://github.com/sadik254/ubuntu-server-setup/releases)  
[![License](https://img.shields.io/github/license/sadik254/ubuntu-server-setup?style=flat-square)](LICENSE) 

# Ubuntu Server Setup Script

A fully interactive Bash script for setting up and configuring your Ubuntu server with popular tools like Apache, Nginx, MySQL, PostgreSQL, MongoDB, PHP, Node.js, Composer, PM2, and more.

---

## ✨ Features

-  **Sudo check** to ensure the script runs with root privileges
-  **Interactive installation menu** for:
  - Web servers: Apache2 / Nginx
  - Databases: MySQL / PostgreSQL / MongoDB (multi-select)
  - Runtimes: PHP (choose version), Node.js (choose version)
  - Package managers: Composer, NPM
  - Process manager: PM2
- ⚙️ Auto-start services after installation
- 🔓 Remote database access toggle
- 🔐 Reminders for opening firewall ports
- 📊 Final summary of installed tools and versions
- 🙌 Skip options and safe exit
- 📧 Support info included

---

## 🖥️ Requirements

- OS: Ubuntu 20.04 / 22.04 / 24.04 (tested)
- Root access (`sudo`)
- Internet connection

---

## 🚀How to Use

1. Clone the repository:
   ```bash
   git clone https://github.com/sadik254/ubuntu-server-setup.git
   cd ubuntu-server-setup
   ```
2. Make the Script Executable:
    ```bash
    chmod +x setup.sh
    ```
3. Run the script with sudo:
    ```bash
    sudo ./setup.sh
    ```

## 📸Preview (Example)
    ```
    Choose a web server to install:
    1) Apache
    2) Nginx
    3) Skip this step
    > 1

    Installing Apache...
    Starting apache2 service...

    Choose databases to install (comma separated):
    1) MySQL
    2) PostgreSQL
    3) MongoDB
    4) Skip
    > 1,3
    ...
    ```

## 📦Installed Tools (based on selection)
    | Tool         | Installed Version    |
    | ------------ | -------------------- |
    | Apache/Nginx | ✅ if selected        |
    | MySQL        | ✅ with remote toggle |
    | PostgreSQL   | ✅ with remote toggle |
    | MongoDB      | ✅ with remote toggle |
    | PHP          | Multiple versions    |
    | Node.js      | Multiple versions    |
    | Composer     | ✅ if selected        |
    | PM2          | ✅ if selected        |

## 🔐 Security Note
Remember to manually configure your firewall to open ports for any database services you want to access remotely (e.g., port 3306 for MySQL, 5432 for PostgreSQL, 27017 for MongoDB).
    ```bash
    # Example for UFW
    sudo ufw allow 3306/tcp
    sudo ufw allow 5432/tcp
    sudo ufw allow 27017/tcp
    ```
## 🙋 About the Author
Developed with ❤️ by Md. Saleh Sadik
 - [🔗 GitHub:](https://github.com/sadik254)
 - 📧 Email: sadik254@gmail.com

## 📄 License
[This Project is Licensed under the MIT License](LICENSE)

## ⭐️ Contribute
Feel free to fork this project and submit PRs or suggestions!

## 👋 Final Message
Thanks for using this script to set up your server!
Feel free to share it or improve it — contributions are welcome.

Bye bye! 👋

