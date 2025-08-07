#!/bin/bash

set -e

# Check if the script is run as root or with sudo
if [ "$EUID" -ne 0 ]; then
  echo "❌ This script must be run as root or with sudo."
  exit 1
fi

echo "🔧 Welcome to the Server Setup Script (Made by Saleh Sadik)"
echo "✅ Running as root. Continuing setup..."

# Run update & upgrade once
echo "📦 Updating and upgrading system packages..."
apt update && apt upgrade -y

# Display interactive menu
echo ""
echo "🌐 Please choose a server software to install:"
PS3="Enter your choice [1-4]: "
options=("Apache2" "Nginx" "Skip this step" "Exit")
select opt in "${options[@]}"
do
  case $opt in
    "Apache2")
      echo "🛠 Installing Apache2..."
      apt install -y apache2
      systemctl start apache2
      systemctl enable apache2
      echo "✅ Apache2 installed and running."
      break
      ;;
    "Nginx")
      echo "🛠 Installing Nginx..."
      apt install -y nginx
      systemctl start nginx
      systemctl enable nginx
      echo "✅ Nginx installed and running."
      break
      ;;
    "Skip this step")
      echo "⏭️ Skipping web server installation."
      break
      ;;
    "Exit")
      echo "👋 Exiting script."
      exit 0
      ;;
    *)
      echo "❌ Invalid option. Please choose again."
      ;;
  esac
done

#Setup Database 
echo ""
echo "🚀 Moving to the next step..."

echo ""
echo "🗃️ Database Setup"
echo "Select one or more databases to install (type numbers separated by space):"
echo "1) MySQL"
echo "2) PostgreSQL"
echo "3) MongoDB"
echo "4) Skip"
echo "5) Exit"

read -p "Enter choices (e.g., 1 3): " db_choices

for choice in $db_choices; do
  case $choice in
    1)
      echo "🛠 Installing MySQL..."
      apt install -y mysql-server
      echo "✅ MySQL installed."

      read -p "➡️ Enable remote access to MySQL? (yes/no): " enable_mysql_remote
      if [[ "$enable_mysql_remote" == "yes" ]]; then
        sed -i "s/^bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
        systemctl restart mysql
        echo "🌐 Remote access enabled for MySQL."
      fi

      # Create a user
      read -p "👤 Enter new MySQL username: " mysql_user
      read -sp "🔐 Enter password for $mysql_user: " mysql_pass
      echo
      mysql -e "CREATE USER IF NOT EXISTS '$mysql_user'@'%' IDENTIFIED WITH mysql_native_password BY '$mysql_pass';"
      mysql -e "GRANT ALL PRIVILEGES ON *.* TO '$mysql_user'@'%' WITH GRANT OPTION;"
      mysql -e "FLUSH PRIVILEGES;"
      echo "✅ MySQL user '$mysql_user' created with remote access."
      ;;
    2)
      echo "🛠 Installing PostgreSQL..."
      apt install -y postgresql
      echo "✅ PostgreSQL installed."

      read -p "➡️ Enable remote access to PostgreSQL? (yes/no): " enable_pgsql_remote
      if [[ "$enable_pgsql_remote" == "yes" ]]; then
        sed -i "s/^#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/*/main/postgresql.conf
        echo "host all all 0.0.0.0/0 md5" >> /etc/postgresql/*/main/pg_hba.conf
        systemctl restart postgresql
        echo "🌐 Remote access enabled for PostgreSQL."
      fi

      # Create a user
      read -p "👤 Enter new PostgreSQL username: " pgsql_user
      read -sp "🔐 Enter password for $pgsql_user: " pgsql_pass
      echo
      sudo -u postgres psql -c "CREATE ROLE $pgsql_user WITH LOGIN PASSWORD '$pgsql_pass';"
      sudo -u postgres psql -c "ALTER ROLE $pgsql_user CREATEDB;"
      echo "✅ PostgreSQL user '$pgsql_user' created with createdb privileges."
      ;;
    3)
      echo "🛠 Installing MongoDB..."
      apt install -y mongodb
      echo "✅ MongoDB installed."

      read -p "➡️ Enable remote access to MongoDB? (yes/no): " enable_mongo_remote
      if [[ "$enable_mongo_remote" == "yes" ]]; then
        sed -i "s/^  bindIp: 127.0.0.1/  bindIp: 0.0.0.0/" /etc/mongodb.conf
        systemctl restart mongodb
        echo "🌐 Remote access enabled for MongoDB."
      fi

      # Enable authentication and create admin user
      read -p "👤 Enter new MongoDB admin username: " mongo_user
      read -sp "🔐 Enter password for $mongo_user: " mongo_pass
      echo

      mongo <<EOF
use admin
db.createUser({
  user: "$mongo_user",
  pwd: "$mongo_pass",
  roles: [ { role: "root", db: "admin" } ]
})
EOF

      sed -i "s/^#security:/security:\n  authorization: enabled/" /etc/mongodb.conf
      systemctl restart mongodb
      echo "✅ MongoDB admin user '$mongo_user' created with root access."
      ;;
	4)
      echo "⏭️ Skipping database installation."
      ;;
	5)
	echo "👋 Exiting script."
      exit 0
      ;;
    *)
      echo "❌ Invalid choice: $choice"
      ;;
  esac
done

echo ""
echo "📢 Reminder: Make sure port 3306 is open in your firewall or cloud provider for MySQL remote access."
echo "📢 Reminder: Make sure port 5432 is open in your firewall or cloud provider for PostgreSQL remote access."
echo "📢 Reminder: Make sure port 27017 is open in your firewall or cloud provider for MongoDB remote access."

#php and node setup prompt
echo ""
echo "🧰 What would you like to install next?"
echo "You can choose multiple (e.g. 1 2 5), or type 0 to skip or 99 to exit"
echo "  [1] PHP"
echo "  [2] Composer"
echo "  [3] Node.js"
echo "  [4] npm"
echo "  [5] PM2"
echo "  [0] Skip this step"
echo "  [99] Exit setup"
read -p "Enter your choice(s): " -a tools

# Detect installed web server
apache_installed=$(dpkg -l | grep apache2)
nginx_installed=$(dpkg -l | grep nginx)

for tool in "${tools[@]}"; do
    case $tool in
        0)
            echo "⏭️  Skipping this step."
            break
            ;;
        99)
            echo "👋 Exiting setup."
            exit 0
            ;;
        1)
            echo "🛠 Installing PHP..."
            echo "Which PHP version would you like to install? (e.g., 8.3, 8.2, 8.1, 7.4)"
            read -p "Enter version: " php_version

            sudo add-apt-repository -y ppa:ondrej/php
            sudo apt update

            sudo apt install -y php$php_version php$php_version-cli php$php_version-common php$php_version-mysql php$php_version-curl php$php_version-mbstring php$php_version-xml php$php_version-zip

            if [[ $apache_installed ]]; then
                echo "⚙️ Detected Apache. Installing mod-php..."
                sudo apt install -y libapache2-mod-php$php_version
                sudo a2dismod php* >/dev/null 2>&1
                sudo a2enmod php$php_version
                sudo systemctl restart apache2
            elif [[ $nginx_installed ]]; then
                echo "⚙️ Detected Nginx. Installing php-fpm..."
                sudo apt install -y php$php_version-fpm
                sudo systemctl enable php$php_version-fpm
                sudo systemctl start php$php_version-fpm
            else
                echo "⚠️ No web server detected. PHP CLI and FPM installed only."
            fi
            php -v
            ;;
        2)
            echo "🛠 Installing Composer..."
            EXPECTED_SIGNATURE=$(wget -q -O - https://composer.github.io/installer.sig)
            php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
            ACTUAL_SIGNATURE=$(php -r "echo hash_file('sha384', 'composer-setup.php');")

            if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]; then
                >&2 echo 'ERROR: Invalid installer signature'
                rm composer-setup.php
                exit 1
            fi

            php composer-setup.php --install-dir=/usr/local/bin --filename=composer
            rm composer-setup.php
            composer --version
            ;;
        3)
            echo "🛠 Installing Node.js..."
            echo "Which Node.js version would you like to install? (e.g., 20, 18, 16)"
            read -p "Enter version: " node_version

            curl -fsSL https://deb.nodesource.com/setup_$node_version.x | sudo -E bash -
            sudo apt install -y nodejs
            node -v
            ;;
        4)
            echo "📦 Checking for npm..."
            if ! command -v npm &> /dev/null; then
                echo "npm not found. Installing..."
                sudo apt install -y npm
            else
                echo "✅ npm is already installed."
            fi
            npm -v
            ;;
        5)
            echo "🚀 Installing PM2..."
            if ! command -v npm &> /dev/null; then
                echo "❌ npm is required before installing PM2. Skipping PM2 install."
            else
                sudo npm install -g pm2
                pm2 -v
            fi
            ;;
        *)
            echo "❓ Unknown option: $tool"
            ;;
    esac
done

echo ""
echo "📋 Installed Versions Summary"
echo "----------------------------"

# Check and display installed versions
[[ $(command -v apache2) ]] && echo "🌐 Apache: $(apache2 -v | grep version)"
[[ $(command -v nginx) ]] && echo "🌐 Nginx: $(nginx -v 2>&1)"
[[ $(command -v mysql) ]] && echo "🗃️ MySQL: $(mysql --version)"
[[ $(command -v psql) ]] && echo "🗃️ PostgreSQL: $(psql --version)"
[[ $(command -v mongo) ]] && echo "🗃️ MongoDB: $(mongo --version | head -n 1)"
[[ $(command -v php) ]] && echo "🐘 PHP: $(php -v | head -n 1)"
[[ $(command -v composer) ]] && echo "🎼 Composer: $(composer --version)"
[[ $(command -v node) ]] && echo "🟢 Node.js: $(node -v)"
[[ $(command -v npm) ]] && echo "📦 NPM: $(npm -v)"
[[ $(command -v pm2) ]] && echo "⚙️ PM2: $(pm2 -v)"

echo ""
echo "✅ Server setup complete!"

echo "🔚 Thank you for using this script!"
echo "🔗 GitHub: https://github.com/sadik254"
echo "📧 Contact: sadik254@gmail.com"
echo "👋 Bye bye!"
echo "⚠️  Security Tip: Make sure to use strong passwords and limit DB user access to trusted IPs only."
