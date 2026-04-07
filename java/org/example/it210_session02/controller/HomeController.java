package org.example.it210_session02.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@org.springframework.stereotype.Controller
@RequestMapping({"/", "hello"})
public class HomeController {

    @GetMapping
    public String home(){
        return "hello";
    }
}
