<?php
// Connection string for PostgreSQL
$conn = pg_connect("host=localhost dbname=northwind user=pgsqlad password=6XxJzWjDTtPt");

if (!$conn) {
    die("Connection failed: " . pg_last_error());
}

$sql = "SELECT c.categoryid, p.productid, o.orderdetailid 
        FROM Category c 
        JOIN Product p ON c.categoryid = p.categoryid 
        JOIN OrderDetail o ON p.productid = o.productid";

$result = pg_query($conn, $sql);

echo "<h1>Sample Northwind Data</h1>";

if (pg_num_rows($result) > 0) {
    echo "<table><tr><th>CategoryID</th><th>ProductID</th><th>OrderDetailID</th></tr>";
    // Output data of each row
    while ($row = pg_fetch_assoc($result)) {
        echo "<tr><td>" . $row["categoryid"] . "</td><td>" . $row["productid"] . "</td><td>" . $row["orderdetailid"] . "</td></tr>";
    }
    echo "</table>";
} else {
    echo "0 results";
}

pg_free_result($result);
pg_close($conn);
?>