public interface IAccountsSelector extends fflib_ISObjectSelector {
    List<Account> selectByIdWithContacts(Set<Id> accountIds);
    List<Account> selectById(Set<Id> idSet);
}