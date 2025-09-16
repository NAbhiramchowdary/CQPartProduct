//Abstc class ClassName{  
public class Employee{
    //Features --> Data members
    //datatype  name --> 40 data members
    private Integer emp_id;
    private String emp_name;
    private Long emp_sal;
    private String emp_desg;
    
    //Behaviors --> member Methods
    //return_type metd_Name(Dt n1, Dt n2, .....){
    		/*stmts to perform a 
            well defined task*/
    //}
    //create --> Default Constructor --> load the initial values (first values)of data members
    public Employee(){
         emp_id = 0;
        emp_name = 'no name';
        emp_sal = 0;
        emp_desg =  'no job';
    }
    
    //input
    //load values into the data members --> 4 data members
    //Header
    //retun_type metd_name(dt n, dt n, dt n, ....){. }//
    public void setValues(Integer eid,String en, Long es, String ed){//<== calling point input(100,"Mahesh", 75000,"Sw Eng")
       //body
      //loading data members with the supplied values
        emp_id = eid;
        emp_name = en;
        emp_sal = es;
        emp_desg = ed;
        return;
    }
    
    
    //action or process
    
    
    //output
    //display the values in data members
    //header 
    //return_type mtdName(dt n1, dt n2.....){ }
    public void getValues(){
        //display the current  values in the data members
        System.debug('Employee ID : ' + emp_id);
        System.debug('Employee Name :' + emp_name);
        System.debug('Employee Salary : ' + emp_sal);
        System.debug('Employee Desingation : ' + emp_desg);
        return;
    }



}