package by.jrr.jis.lecture5;

import java.time.LocalDateTime;

public class MyClass {

    public MyClass() {
        new MyClass();
    }

    String name;
    int age;
    LocalDateTime birth;

    public MyClass(String name, int age, LocalDateTime birth) {
        this.name = name;
        this.age = age;
        this.birth = birth;
    }
}
