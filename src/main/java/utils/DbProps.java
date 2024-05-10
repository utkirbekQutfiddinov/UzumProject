package utils;

import java.io.FileInputStream;
import java.io.IOException;
import java.util.Properties;

public class DbProps {

    public static String get(String key){
        Properties props=new Properties();
        try {
            props.load(new FileInputStream("db.properties"));
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        return props.getProperty(key);
    }
}
