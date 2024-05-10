package model;

import lombok.Data;

import java.util.Date;


@Data
public class UserBean extends BaseIdBean{
    private String name;
    private String username;
    private String password;
    private Date birthdate;
    private Double balance;
    private boolean gender;

    private Integer created_by;
    private Integer updated_by;
    private Date created_at;
    private Date updated_at;
    private boolean is_deleted;
}
