@isTest
private class ContactTriggerTest {
    @TestSetup
    static void makeData(){
        Account a = new Account(
            Name='testAccount1'
        );
        Contact c = new Contact(
            LastName = 'testUser1',
            Phone='123456789',
            AccountId=a.Id
        );
        insert a;
        insert c;
    }
    
    @isTest
    static void testContactNoPhoneOrEmailUpdateNegative(){
        Contact c = [SELECT Id, Phone FROM Contact LIMIT 1];
        c.Phone = null;
        Test.startTest();
        Database.SaveResult result = Database.update(c, false);
        Test.stopTest();
        System.assert(!result.isSuccess());
        System.assert(result.getErrors().size() > 0);
        System.assertEquals('Please provide phone or email value', result.getErrors()[0].getMessage());
    }

    @isTest
    static void testContactNoPhoneOrEmailUpdatePositive(){
        Contact c = [SELECT Id, Phone FROM Contact LIMIT 1];
        c.Email = 'myemail@example.com';
        Test.startTest();
        Database.SaveResult result = Database.update(c);
        Test.stopTest();
        System.assert(result.isSuccess());
        System.assert(result.getErrors().size()==0);
    }

    @isTest
    static void testDeleteAccountIdOfContact(){
        Contact c = [SELECT Id, AccountId FROM Contact LIMIT 1];
        c.AccountId = null;
        Test.startTest();
        Database.SaveResult result = Database.update(c, false);
        Test.stopTest();
        System.assert(!result.isSuccess());
        System.assert(result.getErrors().size() > 0);
        System.assertEquals('Unable to remove account field value', result.getErrors()[0].getMessage());
    }
}