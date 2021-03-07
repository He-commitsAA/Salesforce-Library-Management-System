public inherited sharing class TestDataFactory {
    @testVisible private static User createLibrarian() {
        Profile librarianProfile = [SELECT Id FROM Profile WHERE Name='Librarian'];
        return new User(
            ProfileId = librarianProfile.Id,
            FirstName = 'Test',
            LastName = 'Test',
            Alias = 'test',
            Email = 'test@test.com',
            Username = 'test@testasdf.com',
            TimeZoneSidKey = 'GMT',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US'
        );
    }
}
