<?php
// 1. Configuration
// These match the credentials set in your install_lamp.sh
$servername = "localhost";
$username   = "root";
$password   = "mypassword";
$dbname     = "lamp_test_db";

// 2. Create Connection
$conn = new mysqli($servername, $username, $password);

// Check Connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// 3. Setup Database and Table (Run only if they don't exist)
// Create Database
$sql = "CREATE DATABASE IF NOT EXISTS $dbname";
if (!$conn->query($sql)) {
    echo "Error creating database: " . $conn->error;
}

// Select Database
$conn->select_db($dbname);

// Create Table
$tableSql = "CREATE TABLE IF NOT EXISTS visitors (
    id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    visit_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)";
if (!$conn->query($tableSql)) {
    echo "Error creating table: " . $conn->error;
}

// 4. Insert New Data (Record this visit)
$insertSql = "INSERT INTO visitors (visit_time) VALUES (NOW())";
$conn->query($insertSql);

// 5. Retrieve Data
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
        <tr>
            <th>ID</th>
            <th>Timestamp</th>
        </tr>
        <?php
        if ($result->num_rows > 0) {
            // Output data of each row
            while($row = $result->fetch_assoc()) {
                echo "<tr><td>" . $row["id"]. "</td><td>" . $row["visit_time"]. "</td></tr>";
            }
        } else {
            echo "<tr><td colspan='2'>No results</td></tr>";
        }
        $conn->close();
        ?>
    </table>

</body>
</html>