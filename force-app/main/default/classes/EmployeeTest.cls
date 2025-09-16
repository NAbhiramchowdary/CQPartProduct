@isTest
public class EmployeeTest {
     public static @isTest void main(){
        System.debug('This is from main');
        //Create Object
		//ClassName obj_name = new ClassName()
		Employee emp1 = new Employee( );
		Employee emp2 = new Employee( );
        Employee emp3 = new Employee( );
        System.debug('Details of Emp1 before loading ');
        emp1.getValues();//displays emp1 values
        emp1.setValues(100,'Vinod',50000,'Team Lead');
        System.debug('Details of Emp1 After loading');
        emp1.getValues();//displays emp1 values
        emp2.setValues(102,'Savya',65000,'SR Developer');
        System.debug('Details of Emp2');
        emp2.getValues();//displays emp2 values
        emp3.setValues(104,'Krishna',70000,'VP Tech');
        System.debug('Details of Emp3');
        emp3.getValues();
    }
     public static @isTest void gain(){
        System.debug('This is from gain');
        //Create Object
		//ClassName obj_name = new ClassName()
		Employee emp1 = new Employee( );
		Employee emp2 = new Employee( );
        Employee emp3 = new Employee( );
        System.debug('Details of Emp1 before loading ');
        emp1.getValues();//displays emp1 values
        emp1.setValues(100,'Vinod',50000,'Team Lead');
        System.debug('Details of Emp1 After loading');
        emp1.getValues();//displays emp1 values
        emp2.setValues(102,'Savya',65000,'SR Developer');
        System.debug('Details of Emp2');
        emp2.getValues();//displays emp2 values
        emp3.setValues(104,'Krishna',70000,'VP Tech');
        System.debug('Details of Emp3');
        emp3.getValues();
    }
    public static @isTest void vain(){
        System.debug('This is from vain');
        //Create Object
		//ClassName obj_name = new ClassName()
		Employee emp1 = new Employee( );
		Employee emp2 = new Employee( );
        Employee emp3 = new Employee( );
        System.debug('Details of Emp1 before loading ');
        emp1.getValues();//displays emp1 values
        emp1.setValues(100,'Vinod',50000,'Team Lead');
        System.debug('Details of Emp1 After loading');
        emp1.getValues();//displays emp1 values
        emp2.setValues(102,'Savya',65000,'SR Developer');
        System.debug('Details of Emp2');
        emp2.getValues();//displays emp2 values
        emp3.setValues(104,'Krishna',70000,'VP Tech');
        System.debug('Details of Emp3');
        emp3.getValues();
    }


}