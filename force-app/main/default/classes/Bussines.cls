public class Bussines{

    public void Emp(){
        System.debug('id');
    }
    public Integer Emp (Integer a)
    {
        System.debug('Integer'+a);
        return a;
    }
    public String Emp(string b)
    {
        System.debug('String'+b);
        return b;
    }
    public Decimal Emp(Decimal d)
    { 
        System.debug('Decimal'+d);
        return d;
    }
    public Decimal Emp(Decimal s,Integer i)
    {
        Decimal d =s=+i;       
        System.debug('String,Integer'+d);
        return d;
    }
    public Integer Emp(Integer x,Integer y)
    {
        Integer r = x+y;
            System.debug('Integer,Integer'+r);
            return r;
    }
 }