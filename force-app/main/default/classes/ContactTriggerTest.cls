@isTest
private class ContactTriggerTest {
    @TestSetup
    static void makeData(){
        Account a = new Account(
            Name='testAccount1'
            );
        insert a;
        
        Contact c = new Contact(
            FirstName = 'Test',
        LastName = 'User1',
        Phone='123456789',
        AccountId=a.Id
            );
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
    
    @isTest
    static void testContactHistoryCreationUponContactCreate(){
        Contact_History__c history = [SELECT Id, Name, Action__c, Contact__c FROM Contact_History__c LIMIT 1];
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        System.assertEquals(c.Id, history.Contact__c);
        System.assertEquals('Insert', history.Action__c);
        System.assertEquals('Insert Test User1 '+c.Id, history.Name);
    }
    
    @isTest
    static void testContactHistoryCreationUponContactDelete(){
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        delete c;
        Contact_History__c history = [SELECT Id, Name, Action__c, Contact__c FROM Contact_History__c WHERE Action__c = 'Delete' LIMIT 1];
        System.assertEquals(null, history.Contact__c);
        System.assertEquals('Delete', history.Action__c);
        System.assertEquals('Delete Test User1 '+c.Id, history.Name);
    }
    
    @isTest
    static void testContactSingleFieldUpdate(){
        Contact c = [SELECT Id, Name FROM Contact LIMIT 1];
        c.Lastname = 'changedLastName';
        
        Test.startTest();
        Database.SaveResult result = Database.update(c);
        Test.stopTest();
        
        Contact_History__c history = [
            SELECT Id, Name, Action__c, Contact__c, New_value__c, Old_value__c, Edited_field_name__c
            FROM Contact_History__c
            WHERE Action__c = 'Update'
            LIMIT 1
        ];
        
        System.assertEquals(c.Id, history.Contact__c);
        System.assertEquals('Test User1 '+c.Id+' Update', history.Name);
        System.assertEquals('Update', history.Action__c);
        System.assertEquals('changedLastName', history.New_value__c);
        System.assertEquals('User1', history.Old_value__c);
        System.assertEquals('LastName', history.Edited_field_name__c);
    }

    @isTest
    static void testContactMultipleFieldUpdate(){
        Contact c = [SELECT Id, Name FROM Contact LIMIT 1];
        Map<String, String> changed_fields= new Map<String, String>{
            'FirstName' => 'changedFirstName',
            'LastName' => 'changedLastName',
            'Email' => ''
        };
        Map<String, String> old_fields= new Map<String, String>{
            'FirstName' => 'Test',
            'LastName' => 'User1',
            'Email' => 'changedEmail@example.com'
        };
        c.Firstname = changed_fields.get('FirstName');
        c.Lastname = changed_fields.get('LastName');
        c.Email = changed_fields.get('Email');
        
        Test.startTest();
        Database.SaveResult result = Database.update(c);
        Test.stopTest();
        
        List<Contact_History__c> history = [
            SELECT Id, Name, Action__c, Contact__c, New_value__c, Old_value__c, Edited_field_name__c
            FROM Contact_History__c
            WHERE Action__c = 'Update'
        ];
        System.assertEquals(3, history.size());
        Integer i = 0;
        for(String s : changed_fields.keySet()){
            System.assertEquals(c.Id, history[i].Contact__c);
            System.assertEquals('Test User1 '+c.Id+' Update', history[i].Name);
            System.assertEquals('Update', history[i].Action__c);
            System.assertEquals(changed_fields.get(s), history[i].New_value__c);
            System.assertEquals(old_fields.get(s), history[i].Old_value__c);
            System.assertEquals(s, history[i].Edited_field_name__c);
            i++;
        }
    }
}