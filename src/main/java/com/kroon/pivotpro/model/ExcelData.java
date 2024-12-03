package com.kroon.pivotpro.model;

import java.util.List;

public class ExcelData {
    private List<List<String>> data;

    public ExcelData(List<List<String>> data) {
        this.data = data;
    }

    public List<List<String>> getData() {
        return data;
    }

    public void setData(List<List<String>> data) {
        this.data = data;
    }
}
