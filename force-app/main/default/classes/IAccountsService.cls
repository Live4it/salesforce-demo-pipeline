public interface IAccountsService {
    void syncMailingCountryToContacts(Set<Id> accountIds);
    void updateVipStatus(Set<Id> accountIds);
}