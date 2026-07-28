public interface IAccountsSelector extends fflib_ISObjectSelector {
    List<Account> selectByIdWithContacts(Set<Id> accountIds);
}
