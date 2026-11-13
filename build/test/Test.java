package com.test;
public class Test {
    public static void main(String[] args) {
        Runnable r = new Runnable() {
            @Override
            public void run() {
                System.out.println("Java Compatible Working!");
            }
        };
        r.run();
    }
}
