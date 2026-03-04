#!/bin/bash

# --- CloudWatch Logging Setup ---
exec > /var/log/user-data.log 2>&1

sudo dnf install -y amazon-cloudwatch-agent

cat <<'CWEOF' | sudo tee /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/user-data.log",
            "log_group_name": "/ec2/lamp/user-data",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  }
}
CWEOF

sudo systemctl start amazon-cloudwatch-agent
sudo systemctl enable amazon-cloudwatch-agent

# 1. Update the system and install necessary packages
sudo dnf update -y
sudo dnf install -y httpd wget php-fpm php-mysqli php-json php php-devel mariadb105-server

# 2. Start Apache and MariaDB early so /var/www/html exists for Composer
sudo systemctl start httpd
sudo systemctl enable httpd
sudo systemctl start php-fpm
sudo systemctl enable php-fpm
sudo systemctl start mariadb
sudo systemctl enable mariadb


# 3. Install Composer
export HOME=/root
curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php
php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer
chmod +x /usr/local/bin/composer

# 4. Install AWS SDK for PHP
mkdir -p /var/www/html
cd /var/www/html && /usr/local/bin/composer require aws/aws-sdk-php --no-interaction

# 5. Fetch DB password from Secrets Manager
DB_PASS=$(aws secretsmanager get-secret-value \
  --secret-id lamp/db_password \
  --region us-east-1 \
  --query SecretString \
  --output text | python3 -c "import sys,json; print(json.load(sys.stdin)['password'])")

# 6. Set root DB password
sudo mysqladmin -u root password "$DB_PASS"

# 7. Write my-app.php BEFORE setting permissions
cat <<'PHPEOF' | sudo tee /var/www/html/my-app.php
<?php
$servername = "localhost";
$username   = "root";
$dbname     = "lamp_test_db";

require '/var/www/html/vendor/autoload.php';
function get_db_password() {
    $client = new Aws\SecretsManager\SecretsManagerClient([
        'region'  => 'us-east-1',
        'version' => 'latest'
    ]);
    $result = $client->getSecretValue(['SecretId' => 'lamp/db_password']);
    $secret = json_decode($result['SecretString'], true);
    return $secret['password'];
}
$password = get_db_password();

$conn = new mysqli($servername, $username, $password);
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$conn->query("CREATE DATABASE IF NOT EXISTS $dbname");
$conn->select_db($dbname);
$conn->query("CREATE TABLE IF NOT EXISTS visitors (
    id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    visit_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)");
$conn->query("INSERT INTO visitors (visit_time) VALUES (NOW())");
$result = $conn->query("SELECT id, visit_time FROM visitors ORDER BY id DESC LIMIT 10");
?>
<!DOCTYPE html>
<html>
<head>
    <title>AWS LAMP Stack Demo</title>
    <style>
        body { font-family: sans-serif; max-width: 800px; margin: 2rem auto; padding: 0 1rem; }
        .status { background: #e0f7fa; padding: 1rem; border-radius: 4px; border-left: 5px solid #006064; }
        table { border-collapse: collapse; width: 100%; margin-top: 20px; }
        th, td { text-align: left; padding: 8px; border-bottom: 1px solid #ddd; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <h1>🚀 LAMP Stack Status</h1>
    <div class="status">
        <strong>Database Connection:</strong> <span style="color: green;">Success</span><br>
        <strong>Connected to:</strong> MariaDB on localhost<br>
        <strong>Database Name:</strong> <?php echo $dbname; ?>
    </div>
    <h2>Recent Visitor Log</h2>
    <p>Refresh this page to add a new record to the database.</p>
    <table>
        <tr><th>ID</th><th>Timestamp</th></tr>
        <?php
        if ($result->num_rows > 0) {
            while($row = $result->fetch_assoc()) {
                echo "<tr><td>" . $row["id"] . "</td><td>" . $row["visit_time"] . "</td></tr>";
            }
        } else {
            echo "<tr><td colspan='2'>No results</td></tr>";
        }
        $conn->close();
        ?>
    </table>
</body>
</html>
PHPEOF

# 8. Set file permissions AFTER all files are written
sudo usermod -a -G apache ec2-user
sudo chown -R ec2-user:apache /var/www
sudo chmod 2775 /var/www
find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;

# 9. Restart Apache to pick up all changes
sudo systemctl restart httpd