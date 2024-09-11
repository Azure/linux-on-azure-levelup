<?php
// Database connection settings
$host = '172.17.61.127'; // Replace with your remote host
$port = '5432'; // Default PostgreSQL port
$dbname = 'northwind'; // Replace with your database name
$user = 'postgres'; // Replace with your PostgreSQL username
$password = 'yourpassword'; // Replace with your PostgreSQL password

// Connection string
$conn_string = "host=$host port=$port dbname=$dbname user=$user password=$password";

// Try to connect to PostgreSQL
$conn = pg_connect($conn_string);

// Check if the connection was successful
if (!$conn) {
    echo "Error: Unable to connect to the database.\n";
    echo pg_last_error();
} else {
    echo "Successfully connected to the PostgreSQL database on remote host: $host\n";
    echo "Database name: $dbname\n";
    echo "User: $user\n";
    echo "Port: $port\n";

    // Optionally, get some additional connection information
    $version = pg_version($conn);
    echo "PostgreSQL version: " . $version['client'] . "\n";

    // Close the connection
    pg_close($conn);
}
?>
