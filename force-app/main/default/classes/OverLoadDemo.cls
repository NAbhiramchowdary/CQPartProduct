public class OverLoadDemo{

    public void walk(){
        System.debug('.....walk..');
    }
    public Integer walk(Integer a){
        System.debug('Integer.....walk..'+a);
        return a;
    }
    public String walk(String s){
        System.debug('String.....walk..'+s);
        return s;
    }
    public Integer walk(Integer a, Integer b){
        Integer c=a+b;
        System.debug('Integer, Integer.....walk..'+c);
        return c;
    }
    public Decimal walk(Integer a, decimal b){
        Decimal c = a+b;
        System.debug('Integer, decimal.....walk..'+c);
        return c;
    }
    public Integer walk(Integer a, Integer b, Integer c){
        Integer d = a+b+c;
        System.debug('Integer, Integer, Integer.....walk..'+d);
        return d;
    }
}