package repository;

import model.BaseIdBean;

import java.util.Optional;

public interface BaseCrudRepository<T extends BaseIdBean, ID> {

    Optional<T> getOne(ID id);

    Optional<T> getAll();

    Optional<T> save(T bean);

    Optional<T> update(T bean, ID id);

    Optional<Boolean> delete(ID id);
}
