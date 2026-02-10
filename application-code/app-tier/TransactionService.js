const dbConfigPromise = require('./DbConfig');
const mysql = require('mysql');

let con;

(async () => {
    try {
        const dbcreds = await dbConfigPromise;
        console.log('DB Config loaded:', { host: dbcreds.DB_HOST, user: dbcreds.DB_USER, database: dbcreds.DB_DATABASE });

        con = mysql.createConnection({
            host: dbcreds.DB_HOST,
            user: dbcreds.DB_USER,
            password: dbcreds.DB_PWD,
            database: dbcreds.DB_DATABASE
        });

        con.connect(err => {
            if (err) {
                console.error("❌ Database connection failed:", err);
                process.exit(1);
            }
            console.log("✅ Connected to database!");
        });
    } catch (err) {
        console.error("❌ Failed to load DB config:", err);
        process.exit(1);
    }
})();

function addTransaction(amount, desc) {
    const query = "INSERT INTO transactions (amount, description) VALUES (?, ?)";
    con.query(query, [amount, desc], function (err, result) {
        if (err) throw err;
        console.log("Transaction added");
    });
    return 200;
}

function getAllTransactions(callback) {
    const query = "SELECT * FROM transactions";
    con.query(query, function (err, result) {
        if (err) throw err;
        return callback(result);
    });
}

function findTransactionById(id, callback) {
    const query = "SELECT * FROM transactions WHERE id = ?";
    con.query(query, [id], function (err, result) {
        if (err) throw err;
        return callback(result);
    });
}

function deleteAllTransactions(callback) {
    const query = "DELETE FROM transactions";
    con.query(query, function (err, result) {
        if (err) throw err;
        return callback(result);
    });
}

function deleteTransactionById(id, callback) {
    const query = "DELETE FROM transactions WHERE id = ?";
    con.query(query, [id], function (err, result) {
        if (err) throw err;
        return callback(result);
    });
}

module.exports = { addTransaction, getAllTransactions, deleteAllTransactions, findTransactionById, deleteTransactionById };
