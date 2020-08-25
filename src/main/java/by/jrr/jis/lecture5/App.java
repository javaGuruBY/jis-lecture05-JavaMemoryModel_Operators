package by.jrr.jis.lecture5;

import java.util.ArrayList;
import java.util.List;

public class App {
    public static void main(String[] args) {
        try {
            Thread.sleep(5000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        System.out.println("hello world");
        List<MyClass> myList = new ArrayList<MyClass>();
        int i = 1;
        int[] aray = new int[1_000_000_000];
        while(true) {
//            myList.add(new MyClass("max" + i, i*2, LocalDateTime.now()));
            try {
                Thread.sleep(0);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            aray[i] = i;
            i++;
//            System.out.println("myList.size() = " + myList.size());
        }

    }
}
