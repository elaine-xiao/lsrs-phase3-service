package org.gatech.cs6400.team036.lsrsphase3service.controller;

import org.gatech.cs6400.team036.lsrsphase3service.service.LSRSService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController()
@CrossOrigin(origins = "https://localhost:4200")
public class TestController {

    @Autowired
    private LSRSService lsrsService;

    @GetMapping("/")
    public String test() {
        return "hello!";
    }

    @GetMapping("/stores")
    public int getNumStores() {
        return lsrsService.test();
    }
}
