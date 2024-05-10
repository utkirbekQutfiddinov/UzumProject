package repository;

import model.UserBean;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Types;
import java.util.Optional;

public class UserRepository implements BaseCrudRepository<UserBean, Integer> {


    @Override
    public Optional<UserBean> getOne(Integer integer) {
        return Optional.empty();
    }

    @Override
    public Optional<UserBean> getAll() {
        return Optional.empty();
    }

    @Override
    public Optional<UserBean> save(UserBean bean) {
        Connection connection = DBConnection.getConnection();
        try {
            CallableStatement st = connection.prepareCall("{ ? = call register_user(?,?,?,?,?)}");

            st.registerOutParameter(1, Types.VARCHAR);

            st.setString(2, bean.getName());
            st.setString(3, bean.getUsername());
            st.setString(4, bean.getPassword());
            st.setBoolean(5, bean.isGender());
            st.setString(6, bean.getBirthdate().toString());

            st.executeUpdate();

            String beanStr = st.getString(1);


        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return Optional.empty();
    }

    @Override
    public Optional<UserBean> update(UserBean bean, Integer integer) {
        return Optional.empty();
    }

    @Override
    public Optional<Boolean> delete(Integer integer) {
        return Optional.empty();
    }
}
