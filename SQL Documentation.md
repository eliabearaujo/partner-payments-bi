# Partner Performance Insights - Business Case

## Introduction

This project aims to analyze a dataset representing visits and payments to partners, including details on activities, segments, and payment types. To conduct the analysis, I will use **Python** for data preparation, validation, and cleaning due to its flexibility and efficiency. After this stage, the data will be exported in **CSV** format and imported into **SQL Server Management Studio (SSMS)**, where it will be structured and processed to identify key correlations and extract strategic insights.Throughout this document, I will explain the step-by-step process of creating the database, importing CSV spreadsheets, and demonstrating how the queries were structured along with their objectives. For brevity, the queries can also be accessed through [this link](https://github.com/eliabearaujo/partner-payments-bi/tree/5995d325f714914589f45f10df4e0271151b3adc/Assets/SQL%20Queries).

## Understanding the Case

Before starting any analysis, it is essential to clearly define the problem to be solved. The purpose of this phase is to establish the analysis objectives and define key assumptions that will guide the project.

### Objective

The provided data represents visits and payments made to partners. Within this context, I am responsible for developing data-driven insights for the platform that manages these partners. The key objectives include:

- Conducting an exploratory analysis of the provided data.
- Generating strategic insights to enhance partner engagement and operational efficiency.
- Presenting the findings through comprehensive documentation, structured queries, insightful dashboards, and an executive presentation.

There are no restrictions on the tools used; however, it is mandatory that the documentation, queries, dashboard, and presentation be delivered in English.

### Assumptions

During the initial data assessment, the following assumptions were made to ensure consistent calculations and interpretations:

- CAP Adjustment → Upon reviewing the provided datasets, I identified that the CAP value is approximately 10 times the session cost. Based on the case description, which defines the CAP (Maximum Payment Limit) as the maximum amount that can be paid per visit, and considering the provided example where the session cost is close to the CAP value, we adjusted this metric by dividing the reported CAP by 10.

- Classification of Payment Type → The "Retroactive" payment type was classified as completed sessions, which were paid with a certain delay.

- CAP Hit Calculation → To calculate the CAP hit metric, we considered transactions where the CAP is equal to the actual session cost as having reached the payment limit.

## Understanding the Data

After conducting an initial analysis, data cleaning, and correction using **Python**, we will proceed with the creation of the database and the tables that will comprise our dataset. To achieve this, we will utilize **SQL Server Management Studio (SSMS)**, the most widely used database management system currently, as well as **MySQL** for data manipulation, insight development, correlation analysis, and data extraction.

### Initial Setup

The first step is to create a new database, which will be responsible for storing the rules, validations, and data for the tables that will be created in the future.
To create the database, it was necessary to start a local server to simulate a storage environment and follow these steps.

![Database_1.jpg](Assets/img/Database_1.png)

![Database_2.jpg](Assets/img/Database_2.png)

![Database_3.png](Assets/img/Database_3.png)

With the database creation completed, we will now proceed with creating the tables that will store our data.
For this, the following MySQL query was used. It can also be viewed at [this link](https://github.com/eliabearaujo/partner-payments-bi/blob/5995d325f714914589f45f10df4e0271151b3adc/Assets/SQL%20Queries/Tables%20created.sql).

```sql
  CREATE TABLE fact_partners_payout (
    core_partner_id INT IDENTITY(1,1) PRIMARY KEY,
    partner_trade_name VARCHAR(255),
    partner_product_id INT,
    session_considered_at_localtime DATETIME,
	transaction_created_at DATETIME,
	gympass_individual_id INT,
    transaction_cost FLOAT,
    transaction_type VARCHAR(100),
    product_cap FLOAT
);

CREATE TABLE dim_store_partners (
    core_partner_id INT PRIMARY KEY,
    partner_trade_name VARCHAR(255),
    address VARCHAR(255),
    contact_number VARCHAR(50),
    segment_type VARCHAR(100),
    country VARCHAR(100)
);

CREATE TABLE dim_store_partner_products (
    product_id INT PRIMARY KEY,
	activity_name VARCHAR(255),
    product_cost_per_usage FLOAT,
    product_cap_value FLOAT,
    segment_type VARCHAR(100),
	last_price_update DATETIME
);
```

![Tables_1.png](Assets/img/Tables_1.png)

With the execution of the query above, we now have three tables with defined data formats and primary keys, but they still need to be populated. To accomplish this, we will use the corrected CSV files processed through Python. This will be done using an SSMS feature that allows the import of tabular-format files.

This step will be repeated three times to populate each table with one of the documents extracted from Python.

The import process can be completed by following the steps below."

![Data_import_1.png](Assets/img/Data_import_1.png)

![Data_import_2.png](Assets/img/Data_import_2.png)

![Data_import_3.png](Assets/img/Data_import_3.png)

![Data_import_4.png](Assets/img/Data_import_4.png)

![Data_import_5.png](Assets/img/Data_import_5.png)

![Data_import_6.png](Assets/img/Data_import_6.png)

With all the steps completed, we are now ready to proceed with creating the queries and extracting valuable insights. This stage will involve analyzing the data, identifying key patterns, and leveraging the queries to generate actionable results that will support decision-making. By applying the structure we've set up, we can ensure that the insights drawn are both meaningful and aligned with our objectives.

## Data check-up

Before proceeding further, we will create queries to verify the structure of our data. This will allow us to ensure that the data aligns with the expected results, that the number of rows matches the provided base and the figures obtained in Python, and that the data is in the correct formats to be worked with and manipulated effectively.

```sql
  SELECT TOP 10 * FROM fact_partners_payout;
  SELECT TOP 10 * FROM dim_store_partners;
  SELECT TOP 10 * FROM dim_store_partner_products;

  SELECT COUNT(*) FROM fact_partners_payout;
  SELECT COUNT(*) FROM dim_store_partners;
  SELECT COUNT(*) FROM dim_store_partner_products;

  SELECT
	  AVG(transaction_cost) as 'transaction_cost',
	  AVG(product_cap) as 'product_cap'
  FROM fact_partners_payout
```

![Data_check_up.png](Assets/img/Data_check_up.png)

As can be seen, the tables contain data in the same format. Table 1 shows 99 rows, which matches the value verified in Python, as do the row counts for Table 2 and Table 3. To further verify the integrity of the data, we also checked the average values for the 'transaction_cost' and 'product_cap' columns, and both returned the same values obtained when we corrected the CAP and data types in Python.
