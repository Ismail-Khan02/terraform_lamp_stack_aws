#!/bin/bash
# 1. Update the system and install necessary packages
# Amazon Linux 2023 uses 'dnf' instead of 'yum'
sudo dnf update -y
sudo dnf install -y httpd wget php-fpm php-mysqli php-json php php-devel mariadb105-server

# 2. Start and Enable Services (Apache & MariaDB)
sudo systemctl start httpd
sudo systemctl enable httpd
sudo systemctl start mariadb
sudo systemctl enable mariadb

# 3. Configure File Permissions
# Add ec2-user to the apache group so you can edit files later if needed
sudo usermod -a -G apache ec2-user
sudo chown -R ec2-user:apache /var/www
sudo chmod 2775 /var/www
find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;

# 4. Secure the Database (Set Root Password)
# This sets the root password to 'mypassword' to match your PHP script
sudo mysqladmin -u root password 'mypassword'

# 5. Create the application file with CSS styling
# Note: Dollar signs are escaped (\$) to prevent Bash from interpreting them
cat <<EOF | sudo tee /var/www/html/my-app.php
<?php
// 1. Configuration
\$servername = "localhost";
\$username   = "root";
\$password   = "mypassword";
\$dbname     = "lamp_test_db";

// 2. Create Connection
\$conn = new mysqli(\$servername, \$username, \$password);

// Check Connection
if (\$conn->connect_error) {
    die("Connection failed: " . \$conn->connect_error);
}

// 3. Setup Database and Table
\$sql = "CREATE DATABASE IF NOT EXISTS \$dbname";
if (!\$conn->query(\$sql)) {
    echo "Error creating database: " . \$conn->error;
}

\$conn->select_db(\$dbname);

\$tableSql = "CREATE TABLE IF NOT EXISTS visitors (
    id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    visit_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)";
if (!\$conn->query(\$tableSql)) {
    echo "Error creating table: " . \$conn->error;
}

// 4. Insert New Data
\$insertSql = "INSERT INTO visitors (visit_time) VALUES (NOW())";
\$conn->query(\$insertSql);

// 5. Retrieve Data
\$result = \$conn->query("SELECT id, visit_time FROM visitors ORDER BY id DESC LIMIT 10");
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
        <strong>Database Name:</strong> <?php echo \$dbname; ?>
    </div>

    <h2>Recent Visitor Log</h2>
    <p>Refresh this page to add a new record to the database.</p>

    <table>
        <tr>
            <th>ID</th>
            <th>Timestamp</th>
        </tr>
        <?php
        if (\$result->num_rows > 0) {
            while(\$row = \$result->fetch_assoc()) {
                echo "<tr><td>" . \$row["id"]. "</td><td>" . \$row["visit_time"]. "</td></tr>";
            }
        } else {
            echo "<tr><td colspan='2'>No results</td></tr>";
        }
        \$conn->close();
        ?>
    </table>
</body>
</html>
EOF

# 6. Restart Apache to ensure all PHP changes are picked up
sudo systemctl restart httpd