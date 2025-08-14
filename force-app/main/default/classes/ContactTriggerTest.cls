@isTest
private class ContactTriggerTest {
    @TestSetup
    static void makeData(){
        List<Contact> contacts = new List<Contact>();
        for(Integer i=0; i<5; i++){
            Contact con = new Contact(
                LastName = 'User '+i,
                Phone='123456789'
            );
            contacts.add(con);
        }
        insert contacts;
    }

    @isTest
    static void testContactNoPhoneOrEmailUpdate(){
        Contact c = [SELECT Id, Phone FROM Contact LIMIT 1];
        c.Phone = '';
        Test.startTest();
        Database.SaveResult result = Database.update(c);
        Test.stopTest();
        System.assert(!result.isSuccess());
        System.assert(result.getErrors().size() > 0);
        System.assertEquals('Please provide phone or email value', result.getErrors()[0].getMessage());
    }
}