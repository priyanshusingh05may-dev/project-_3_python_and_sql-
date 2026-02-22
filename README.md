#  E-Commerce Data Analytics: Deep Dive into Consumer Behavior

Welcome to my project! This repository is a comprehensive analysis of e-commerce operations, where I've bridged the gap between raw database management and actionable business insights. Using **SQL** for heavy lifting (data extraction) and **Python** for the analytical narrative, I’ve explored how a modern online marketplace breathes.

---

##  Project Objective
The goal was to move beyond basic reporting. I wanted to understand the "Why" behind the numbers:
* Why do certain regions perform better?
* What is the real impact of installment-based payments on order volume?
* How loyal are our customers (Retention Analysis)?

---

##  My Toolbox
* **SQL (MySQL):** Used for complex data retrieval, including Window Functions (RANK, LAG), CTEs, and multi-table Joins.
* **Python (Pandas/NumPy):** For data cleaning and handling the statistical side of the analysis.
* **Visualization:** Matplotlib and Seaborn for spotting trends that numbers alone can't show.
* **Reporting:** Created a structured presentation for stakeholders to explain the technical findings in simple business terms.

---

##  Key Discoveries & Insights

### 1. The Power of Installments
One of the most interesting findings was that **49.42% of all orders** were paid using installments. This suggests that providing financial flexibility is a major driver for sales in this dataset.

### 2. Geographic Hotspots
By analyzing over **4,119 unique cities**, I identified the top revenue-generating hubs. This data is gold for any marketing team looking to optimize their ad spend geographically.

### 3. Customer Retention (The 6-Month Window)
I ran a retention script to see how many customers returned within 180 days. Understanding this "churn vs. loyalty" metric helped identify the health of the customer base.

### 4. Sales Trends & Growth
* **Year-over-Year (YoY) Growth:** Calculated the percentage increase in sales to track business scaling.
* **Top 3 Customers:** Identified the "Whales" (top spenders) for each year using SQL ranking functions.

---

##  What's Inside?
* **`project 3 sql queries.sql`**: The backbone of the project. Contains the database schema and all the analytical queries (Basic to Advanced).
* **`project_3_python_(2).ipynb`**: The analytical playground where I performed data cleaning and visualized correlations (like Price vs. Popularity).
* **`Navigating the Future of Online Shopping.pptx`**: A concise summary of the entire project designed for a business audience.

---

##  Lessons Learned
This project wasn't just about writing code; it was about handling real-world data issues like:
* Managing `NULL` delivery dates without skewing the results.
* Calculating **Moving Averages** to smooth out daily sales fluctuations.
* Realizing that even a weak correlation (like the -0.03 between Price and Popularity) tells a story about market diversity.

