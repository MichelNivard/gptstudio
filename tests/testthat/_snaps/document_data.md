# Summarize data works

    Code
      summarize_data(mtcars, "skimr")
    Output
      -- Data Summary ------------------------
                                 Values
      Name                       data  
      Number of rows             32    
      Number of columns          11    
      _______________________          
      Column type frequency:           
        numeric                  11    
      ________________________         
      Group variables            None  
      
      -- Variable type: numeric ------------------------------------------------------
         skim_variable n_missing complete_rate    mean      sd    p0    p25    p50
       1 mpg                   0             1  20.1     6.03  10.4   15.4   19.2 
       2 cyl                   0             1   6.19    1.79   4      4      6   
       3 disp                  0             1 231.    124.    71.1  121.   196.  
       4 hp                    0             1 147.     68.6   52     96.5  123   
       5 drat                  0             1   3.60    0.535  2.76   3.08   3.70
       6 wt                    0             1   3.22    0.978  1.51   2.58   3.32
       7 qsec                  0             1  17.8     1.79  14.5   16.9   17.7 
       8 vs                    0             1   0.438   0.504  0      0      0   
       9 am                    0             1   0.406   0.499  0      0      0   
      10 gear                  0             1   3.69    0.738  3      3      4   
      11 carb                  0             1   2.81    1.62   1      2      2   
            p75   p100
       1  22.8   33.9 
       2   8      8   
       3 326    472   
       4 180    335   
       5   3.92   4.93
       6   3.61   5.42
       7  18.9   22.9 
       8   1      1   
       9   1      1   
      10   4      5   
      11   4      8   

---

    Code
      summarize_data(mtcars, "skimr_lite")
    Output
      -- Data Summary ------------------------
                                 Values
      Name                       data  
      Number of rows             32    
      Number of columns          11    
      _______________________          
      Column type frequency:           
        numeric                  11    
      ________________________         
      Group variables            None  
      
      -- Variable type: numeric ------------------------------------------------------
         skim_variable n_missing complete_rate   min    mean median    max
       1 mpg                   0             1 10.4   20.1    19.2   33.9 
       2 cyl                   0             1  4      6.19    6      8   
       3 disp                  0             1 71.1  231.    196.   472   
       4 hp                    0             1 52    147.    123    335   
       5 drat                  0             1  2.76   3.60    3.70   4.93
       6 wt                    0             1  1.51   3.22    3.32   5.42
       7 qsec                  0             1 14.5   17.8    17.7   22.9 
       8 vs                    0             1  0      0.438   0      1   
       9 am                    0             1  0      0.406   0      1   
      10 gear                  0             1  3      3.69    4      5   
      11 carb                  0             1  1      2.81    2      8   

---

    Code
      summarize_data(mtcars, "column_types")
    Output
         column    type
      1     mpg numeric
      2     cyl numeric
      3    disp numeric
      4      hp numeric
      5    drat numeric
      6      wt numeric
      7    qsec numeric
      8      vs numeric
      9      am numeric
      10   gear numeric
      11   carb numeric

---

    Code
      summarize_data(mtcars, "summary")
    Output
            mpg             cyl             disp             hp       
       Min.   :10.40   Min.   :4.000   Min.   : 71.1   Min.   : 52.0  
       1st Qu.:15.43   1st Qu.:4.000   1st Qu.:120.8   1st Qu.: 96.5  
       Median :19.20   Median :6.000   Median :196.3   Median :123.0  
       Mean   :20.09   Mean   :6.188   Mean   :230.7   Mean   :146.7  
       3rd Qu.:22.80   3rd Qu.:8.000   3rd Qu.:326.0   3rd Qu.:180.0  
       Max.   :33.90   Max.   :8.000   Max.   :472.0   Max.   :335.0  
            drat             wt             qsec             vs        
       Min.   :2.760   Min.   :1.513   Min.   :14.50   Min.   :0.0000  
       1st Qu.:3.080   1st Qu.:2.581   1st Qu.:16.89   1st Qu.:0.0000  
       Median :3.695   Median :3.325   Median :17.71   Median :0.0000  
       Mean   :3.597   Mean   :3.217   Mean   :17.85   Mean   :0.4375  
       3rd Qu.:3.920   3rd Qu.:3.610   3rd Qu.:18.90   3rd Qu.:1.0000  
       Max.   :4.930   Max.   :5.424   Max.   :22.90   Max.   :1.0000  
             am              gear            carb      
       Min.   :0.0000   Min.   :3.000   Min.   :1.000  
       1st Qu.:0.0000   1st Qu.:3.000   1st Qu.:2.000  
       Median :0.0000   Median :4.000   Median :2.000  
       Mean   :0.4062   Mean   :3.688   Mean   :2.812  
       3rd Qu.:1.0000   3rd Qu.:4.000   3rd Qu.:4.000  
       Max.   :1.0000   Max.   :5.000   Max.   :8.000  

---

    Code
      summarize_data(iris, "skimr")
    Output
      -- Data Summary ------------------------
                                 Values
      Name                       data  
      Number of rows             150   
      Number of columns          5     
      _______________________          
      Column type frequency:           
        factor                   1     
        numeric                  4     
      ________________________         
      Group variables            None  
      
      -- Variable type: factor -------------------------------------------------------
        skim_variable n_missing complete_rate ordered n_unique
      1 Species               0             1 FALSE          3
        top_counts               
      1 set: 50, ver: 50, vir: 50
      
      -- Variable type: numeric ------------------------------------------------------
        skim_variable n_missing complete_rate mean    sd  p0 p25  p50 p75 p100
      1 Sepal.Length          0             1 5.84 0.828 4.3 5.1 5.8  6.4  7.9
      2 Sepal.Width           0             1 3.06 0.436 2   2.8 3    3.3  4.4
      3 Petal.Length          0             1 3.76 1.77  1   1.6 4.35 5.1  6.9
      4 Petal.Width           0             1 1.20 0.762 0.1 0.3 1.3  1.8  2.5

---

    Code
      summarize_data(iris, "skimr_lite")
    Output
      -- Data Summary ------------------------
                                 Values
      Name                       data  
      Number of rows             150   
      Number of columns          5     
      _______________________          
      Column type frequency:           
        factor                   1     
        numeric                  4     
      ________________________         
      Group variables            None  
      
      -- Variable type: factor -------------------------------------------------------
        skim_variable n_missing complete_rate ordered n_unique
      1 Species               0             1 FALSE          3
        top_counts               
      1 set: 50, ver: 50, vir: 50
      
      -- Variable type: numeric ------------------------------------------------------
        skim_variable n_missing complete_rate min mean median max
      1 Sepal.Length          0             1 4.3 5.84   5.8  7.9
      2 Sepal.Width           0             1 2   3.06   3    4.4
      3 Petal.Length          0             1 1   3.76   4.35 6.9
      4 Petal.Width           0             1 0.1 1.20   1.3  2.5

---

    Code
      summarize_data(iris, "column_types")
    Output
              column    type
      1 Sepal.Length numeric
      2  Sepal.Width numeric
      3 Petal.Length numeric
      4  Petal.Width numeric
      5      Species  factor

---

    Code
      summarize_data(iris, "summary")
    Output
        Sepal.Length    Sepal.Width     Petal.Length    Petal.Width   
       Min.   :4.300   Min.   :2.000   Min.   :1.000   Min.   :0.100  
       1st Qu.:5.100   1st Qu.:2.800   1st Qu.:1.600   1st Qu.:0.300  
       Median :5.800   Median :3.000   Median :4.350   Median :1.300  
       Mean   :5.843   Mean   :3.057   Mean   :3.758   Mean   :1.199  
       3rd Qu.:6.400   3rd Qu.:3.300   3rd Qu.:5.100   3rd Qu.:1.800  
       Max.   :7.900   Max.   :4.400   Max.   :6.900   Max.   :2.500  
             Species  
       setosa    :50  
       versicolor:50  
       virginica :50  
                      
                      
                      

