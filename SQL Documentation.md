# Partner Performance Insights - Business Case

## Introduction

This project aims to analyze a dataset representing visits and payments to partners, including details on activities, segments, and payment types. To conduct the analysis, I will use **Python** for data preparation, validation, and cleaning due to its flexibility and efficiency. After this stage, the data will be exported in **CSV** format and imported into **SQL Server Management Studio (SSMS)**, where it will be structured and processed to identify key correlations and extract strategic insights.

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

After conducting an initial analysis, data cleaning, and correction using Python, we will proceed with the creation of the database and the tables that will comprise our dataset. To achieve this, we will utilize SQL Server Management Studio (SSMS), the most widely used database management system currently, as well as MySQL for data manipulation, insight development, correlation analysis, and data extraction.

### Initial Setup

At this stage, we load all the libraries that will be used throughout the project. This approach optimizes the workflow by reducing redundant imports and ensuring better code organization.

At this stage, we will examine each table individually to understand the data they contain and their respective information. This process is essential to ensure a clear understanding of the data structure before proceeding with the analysis.
