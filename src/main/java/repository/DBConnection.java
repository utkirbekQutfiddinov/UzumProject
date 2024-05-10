package repository;

import utils.DbProps;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    private static Connection connection;


    public static Connection getConnection() {
        if (connection == null) {
            try {
                connection = DriverManager.getConnection("jdbc:"
                                + DbProps.get("db.driverName") +
                                "://" + DbProps.get("db.url") + "/" + DbProps.get("db.name"),
                        DbProps.get("db.username"), DbProps.get("db.password"));
            } catch (SQLException e) {
                throw new RuntimeException(e);
            }
        }
        return connection;
    }
}
