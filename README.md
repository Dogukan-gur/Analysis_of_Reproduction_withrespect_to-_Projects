# Analysis_of_Reproduction_withrespect_to-_Projects
Data is collected from live database which is used by the Glass Manufacturing Company and automatically refreshed by PowerBı for an hourly basis.

The company uses several databases (distributed along different servers) but mainly two of them is related to the production and similar fields. Each of this databases contains nearly thousands of different tables.
My first step was examine the all tables and try to found a meaningful data and try to form relations with tables. I have needed two different datasets from two servers;
Firstly, processed square meters of individual orders regarding to their combination (type of units) which is related with Customer Name, Project Name of Customers job, shipping date, quantity and type of unit that order contains. Calculation diagram for this stage is below. In order to reach the real values in my analyzes I need to calculate the processed square meter which is means that : total amount of glasses that are needed to produce finished product. Because some finished products are combination of two or more glass panels but in the database this kind of calculation is not done. It just shows the one glass panels square meters.




![image](https://user-images.githubusercontent.com/117075526/203037467-76f7bfc3-0350-4f50-932f-27210cf53b25.png)






Secondly, calculation and retrieving the data of amount and square meters of reproductions.  Reproductions reports are reported from different stations throughout the factory with reasons and related stations manually by machine operators via a 3rd party program ,which send these reports to database on three different table. These tables are connected and related with the database in order to get Customer Name, , Project Name of Customers job ,type of glass ,reason of breakage , date and time of breakage, which layer will be reproduced and square meters of reported layer.


By combining these two Query, I have achieved to analyze the percent of total reproduction through all projects and any specific projects. Also I can reach the customer level analysis by filtering the related customer and also I can reach the specific job of selected customer.
Additionally, I have achieved to analyze reproduction amount and intensity of glass types and reasons why they break and also all the analyzes that mentioned with respect to different production departments.
Furthermore, with the addition of Date filter I compare the departments monthly reported reproduction on reasons and report stations. 
All these values are refreshed on hourly basis by PowerBı , and this report is shared with related departments and used intensely. Therefore I cannot share the PowerBı report.
