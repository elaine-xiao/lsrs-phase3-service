package org.gatech.cs6400.team036.lsrsphase3service.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

@Service
public class LSRSService {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    public int test() {
        String sql = "SELECT count(*) FROM Store";

        int numStores = jdbcTemplate.queryForObject(sql, Integer.class);

        return numStores;
    }
}
