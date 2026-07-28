public class AccountsServiceImpl implements IAccountsService {
    
    public void syncMailingCountryToContacts(Set<Id> accountIds) {
        if (accountIds == null || accountIds.isEmpty()) {
            return;
        }

        // 1. Initialiseer de Unit of Work via de Application fabriek
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(
            new List<SObjectType> { Contact.SObjectType }
        );

        // 2. Haal de accounts op via de Selector
        List<Account> accountsWithContacts = AccountsSelector.newInstance().selectByIdWithContacts(accountIds);

        // 3. Voer de logica uit
        for (Account acc : accountsWithContacts) {
            if (acc.Contacts != null) {
                for (Contact con : acc.Contacts) {
                    if (con.MailingCountry != acc.ShippingCountry) {
                        con.MailingCountry = acc.ShippingCountry;
                        uow.registerDirty(con);
                    }
                }
            }
        }

        // 4. Commit de database transactie
        uow.commitWork();
    }
}
