public class AccountsService {
    
    private static IAccountsService service() {
        return (IAccountsService) Application.Service.newInstance(IAccountsService.class);
    }

    // Publieke statische methode die overal aangeroepen kan worden
    public static void syncMailingCountryToContacts(Set<Id> accountIds) {
        service().syncMailingCountryToContacts(accountIds);
    }
}