package com.devops_ex.hello_world;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController()
public class HelloWorldControlller {

    @GetMapping()
    public String helloWorld() {
        return "Hello World!!! Hola Hola";
    }
}
