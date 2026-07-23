# NYC Jobs Salary Analysis

## Project Overview

This project analyzes New York City job postings using Python and PostgreSQL to uncover hiring trends, salary distributions, agency activity, and career-level insights.

The project demonstrates the complete data analysis workflow:
- Data cleaning with Python (Pandas)
- Database design with PostgreSQL
- SQL analysis using aggregations, CTEs, window functions, and views
- (Coming Soon) Interactive dashboard in Power BI

---

## Dataset

Source:
NYC Open Data – Jobs NYC Postings

The dataset contains thousands of NYC government job postings, including:

- Agency
- Business Title
- Career Level
- Job Category
- Salary Range
- Work Location
- Posting Dates
- Employment Type

---

## Technologies Used

- Python
- Pandas
- PostgreSQL
- SQL
- Git
- GitHub
- Power BI (planned)

---

## Project Structure

```
nyc-jobs-salary-analysis/
│
├── README.md
├── create_tables.sql
├── salary_analysis.sql
├── salary_analysis.ipynb
├── Jobs_NYC_Postings.csv
└── Jobs_NYC_Postings_Cleaned.csv
```

---

## SQL Skills Demonstrated

This project includes examples of:

- SELECT
- WHERE
- ORDER BY
- GROUP BY
- Aggregate Functions
- CASE Statements
- COALESCE
- Date Functions
- Common Table Expressions (CTEs)
- Window Functions
- Views
- Data Validation
- Salary Analysis

---

## Analysis Performed

The SQL analysis answers questions such as:

- How many job postings exist?
- Which agencies hire the most employees?
- Which job categories are most common?
- Which agencies offer the highest salaries?
- What are the most common career levels?
- How are salaries distributed?
- How do job postings change over time?
- Which locations have the most openings?

---

## Repository Files

### create_tables.sql

Creates the PostgreSQL database table used for the analysis.

### salary_analysis.sql

Contains all SQL queries used throughout the project, including:

- Data validation
- Exploratory analysis
- Salary analysis
- Window functions
- CTEs
- View creation

### salary_analysis.ipynb

Python notebook used to:

- Load the dataset
- Clean missing values
- Remove duplicates
- Export the cleaned dataset

---

## Future Improvements

- Build an interactive Power BI dashboard
- Add geographic visualizations
- Perform salary trend forecasting
- Create additional SQL views
- Add indexes and query optimization

---

## Author

**Javis Foster**

Economics Major | Data Analytics Minor

Currently building projects in Python, SQL, PostgreSQL, and Power BI to develop practical data analytics skills.
