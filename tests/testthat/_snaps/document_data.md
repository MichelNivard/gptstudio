# Summarize mtcars works

    Code
      summarize_data(mtcars, method = "skimr")
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
      summarize_data(mtcars, method = "skimr_lite")
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
      summarize_data(mtcars, method = "column_types")
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
      summarize_data(mtcars, method = "summary")
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

# Summarize airquality works

    Code
      summarize_data(airquality, method = "skimr")
    Output
      -- Data Summary ------------------------
                                 Values
      Name                       data  
      Number of rows             153   
      Number of columns          6     
      _______________________          
      Column type frequency:           
        numeric                  6     
      ________________________         
      Group variables            None  
      
      -- Variable type: numeric ------------------------------------------------------
        skim_variable n_missing complete_rate   mean    sd   p0   p25   p50   p75
      1 Ozone                37         0.758  42.1  33.0   1    18    31.5  63.2
      2 Solar.R               7         0.954 186.   90.1   7   116.  205   259. 
      3 Wind                  0         1       9.96  3.52  1.7   7.4   9.7  11.5
      4 Temp                  0         1      77.9   9.47 56    72    79    85  
      5 Month                 0         1       6.99  1.42  5     6     7     8  
      6 Day                   0         1      15.8   8.86  1     8    16    23  
         p100
      1 168  
      2 334  
      3  20.7
      4  97  
      5   9  
      6  31  

---

    Code
      summarize_data(airquality, method = "skimr_lite")
    Output
      -- Data Summary ------------------------
                                 Values
      Name                       data  
      Number of rows             153   
      Number of columns          6     
      _______________________          
      Column type frequency:           
        numeric                  6     
      ________________________         
      Group variables            None  
      
      -- Variable type: numeric ------------------------------------------------------
        skim_variable n_missing complete_rate  min  mean median  max
      1 Ozone                37         0.758 NA   NA      NA   NA  
      2 Solar.R               7         0.954 NA   NA      NA   NA  
      3 Wind                  0         1      1.7  9.96    9.7 20.7
      4 Temp                  0         1     56   77.9    79   97  
      5 Month                 0         1      5    6.99    7    9  
      6 Day                   0         1      1   15.8    16   31  

---

    Code
      summarize_data(airquality, method = "column_types")
    Output
         column    type
      1   Ozone integer
      2 Solar.R integer
      3    Wind numeric
      4    Temp integer
      5   Month integer
      6     Day integer

---

    Code
      summarize_data(airquality, method = "summary")
    Output
           Ozone           Solar.R           Wind             Temp      
       Min.   :  1.00   Min.   :  7.0   Min.   : 1.700   Min.   :56.00  
       1st Qu.: 18.00   1st Qu.:115.8   1st Qu.: 7.400   1st Qu.:72.00  
       Median : 31.50   Median :205.0   Median : 9.700   Median :79.00  
       Mean   : 42.13   Mean   :185.9   Mean   : 9.958   Mean   :77.88  
       3rd Qu.: 63.25   3rd Qu.:258.8   3rd Qu.:11.500   3rd Qu.:85.00  
       Max.   :168.00   Max.   :334.0   Max.   :20.700   Max.   :97.00  
       NA's   :37       NA's   :7                                       
           Month            Day      
       Min.   :5.000   Min.   : 1.0  
       1st Qu.:6.000   1st Qu.: 8.0  
       Median :7.000   Median :16.0  
       Mean   :6.993   Mean   :15.8  
       3rd Qu.:8.000   3rd Qu.:23.0  
       Max.   :9.000   Max.   :31.0  
                                     

# Collect dataframes works

    Code
      collect_dataframes() %>% as.character()
    Output
      [1] "mtcars"

---

    Code
      collect_column_types(mtcars)
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

# Prep data prompt works

    Code
      prep_data_prompt(mtcars, "skimr", prompt = "test")
    Output
      [1] "-- Data Summary ------------------------\n                           Values\nName                       data  \nNumber of rows             32    \nNumber of columns          11    \n_______________________          \nColumn type frequency:           \n  numeric                  11    \n________________________         \nGroup variables            None  \n\n-- Variable type: numeric ------------------------------------------------------\n   skim_variable n_missing complete_rate    mean      sd    p0    p25    p50\n 1 mpg                   0             1  20.1     6.03  10.4   15.4   19.2 \n 2 cyl                   0             1   6.19    1.79   4      4      6   \n 3 disp                  0             1 231.    124.    71.1  121.   196.  \n 4 hp                    0             1 147.     68.6   52     96.5  123   \n 5 drat                  0             1   3.60    0.535  2.76   3.08   3.70\n 6 wt                    0             1   3.22    0.978  1.51   2.58   3.32\n 7 qsec                  0             1  17.8     1.79  14.5   16.9   17.7 \n 8 vs                    0             1   0.438   0.504  0      0      0   \n 9 am                    0             1   0.406   0.499  0      0      0   \n10 gear                  0             1   3.69    0.738  3      3      4   \n11 carb                  0             1   2.81    1.62   1      2      2   \n      p75   p100\n 1  22.8   33.9 \n 2   8      8   \n 3 326    472   \n 4 180    335   \n 5   3.92   4.93\n 6   3.61   5.42\n 7  18.9   22.9 \n 8   1      1   \n 9   1      1   \n10   4      5   \n11   4      8   \ntest"

---

    Code
      prep_data_prompt(mtcars, "skimr_lite", prompt = "test")
    Output
      [1] "-- Data Summary ------------------------\n                           Values\nName                       data  \nNumber of rows             32    \nNumber of columns          11    \n_______________________          \nColumn type frequency:           \n  numeric                  11    \n________________________         \nGroup variables            None  \n\n-- Variable type: numeric ------------------------------------------------------\n   skim_variable n_missing complete_rate   min    mean median    max\n 1 mpg                   0             1 10.4   20.1    19.2   33.9 \n 2 cyl                   0             1  4      6.19    6      8   \n 3 disp                  0             1 71.1  231.    196.   472   \n 4 hp                    0             1 52    147.    123    335   \n 5 drat                  0             1  2.76   3.60    3.70   4.93\n 6 wt                    0             1  1.51   3.22    3.32   5.42\n 7 qsec                  0             1 14.5   17.8    17.7   22.9 \n 8 vs                    0             1  0      0.438   0      1   \n 9 am                    0             1  0      0.406   0      1   \n10 gear                  0             1  3      3.69    4      5   \n11 carb                  0             1  1      2.81    2      8   \ntest"

---

    Code
      prep_data_prompt(mtcars, "column_types", prompt = "test")
    Output
      [1] "   column    type\n1     mpg numeric\n2     cyl numeric\n3    disp numeric\n4      hp numeric\n5    drat numeric\n6      wt numeric\n7    qsec numeric\n8      vs numeric\n9      am numeric\n10   gear numeric\n11   carb numeric\ntest"

---

    Code
      prep_data_prompt(mtcars, "summary", prompt = "test")
    Output
      [1] "      mpg             cyl             disp             hp       \n Min.   :10.40   Min.   :4.000   Min.   : 71.1   Min.   : 52.0  \n 1st Qu.:15.43   1st Qu.:4.000   1st Qu.:120.8   1st Qu.: 96.5  \n Median :19.20   Median :6.000   Median :196.3   Median :123.0  \n Mean   :20.09   Mean   :6.188   Mean   :230.7   Mean   :146.7  \n 3rd Qu.:22.80   3rd Qu.:8.000   3rd Qu.:326.0   3rd Qu.:180.0  \n Max.   :33.90   Max.   :8.000   Max.   :472.0   Max.   :335.0  \n      drat             wt             qsec             vs        \n Min.   :2.760   Min.   :1.513   Min.   :14.50   Min.   :0.0000  \n 1st Qu.:3.080   1st Qu.:2.581   1st Qu.:16.89   1st Qu.:0.0000  \n Median :3.695   Median :3.325   Median :17.71   Median :0.0000  \n Mean   :3.597   Mean   :3.217   Mean   :17.85   Mean   :0.4375  \n 3rd Qu.:3.920   3rd Qu.:3.610   3rd Qu.:18.90   3rd Qu.:1.0000  \n Max.   :4.930   Max.   :5.424   Max.   :22.90   Max.   :1.0000  \n       am              gear            carb      \n Min.   :0.0000   Min.   :3.000   Min.   :1.000  \n 1st Qu.:0.0000   1st Qu.:3.000   1st Qu.:2.000  \n Median :0.0000   Median :4.000   Median :2.000  \n Mean   :0.4062   Mean   :3.688   Mean   :2.812  \n 3rd Qu.:1.0000   3rd Qu.:4.000   3rd Qu.:4.000  \n Max.   :1.0000   Max.   :5.000   Max.   :8.000  \ntest"

