---
title: Employing Machine-Learning Approaches in Predicting Incomes of Recent College Graduates
subtitle: |
  | 
  | Proposal for AEFP 2023
geometry: margin=1in
fontsize: 12pt
bibliography: csc_research.bib
csl: apa.csl
figPrefix:
  - "Figure"
  - "Figures"
tblPrefix:
  - "Table"
  - "Tables"
eqnPrefix:
  - "equation"
  - "equations"
header-includes:
  - \usepackage[T1]{fontenc}
  - \usepackage[utf8]{inputenc}
  - \usepackage{dsfont}
  - \usepackage{amstext}
  - \usepackage{amssymb}
  - \usepackage{amsmath}
  - \usepackage{mathptmx}
  - \usepackage[american]{babel}
  - \usepackage{setspace}
  - \usepackage{appendix}
  - \usepackage{tabularx}
  - \usepackage{booktabs}
  - \usepackage{caption}
  - \captionsetup{singlelinecheck=off,font=small,labelfont=bf}
  - \usepackage[nolists,tablesfirst,nomarkers]{endfloat}
  - \newcommand{\RR}{\raggedright\arraybackslash}
  - \newcommand{\RL}{\raggedleft\arraybackslash}
  - \newcommand{\CC}{\centering\arraybackslash}
  - \setlength{\parindent}{2em}
  - \setlength{\parskip}{0em}
---

<!-- first page settings -->
\thispagestyle{empty}
\newpage
<!-- \doublespacing --> 

# Objective/Background

The publication of the College Scorecard in 2015 presented an
opportunity for families to identify institutions that provided the
best labor outcomes with the least amount of financial burden for
students [@obama_2013]. Though ostensibly underutilized by consumers
[@huntington2016search], @hurwitz_student_2018 show how students'
college decision-making changed after the Scorecard's initial release,
finding that students directed their SAT scores to schools with higher
median earnings for graduates. This signals the continued salience of
future earnings potential for students who are deciding on colleges
and degree programs [@berger_1988, @wiswallzafar_2015].

As future earnings potential universally informs student
college/program choices, it's important to consider how researchers
can make increasingly data-driven earnings predictions
[@Imbens_2004]. Compared to the standard econometric toolkit,
approaches based in data science and machine learning can improve
estimate quality by following structured procedures and computational
algorithms to build, test, and train statistical models
[@Hastie_etal_2016].

In this project, we use machine learning methods and common
institutional/program variables in the College Scorecard to provide
robust predictions of program earnings for recent college
graduates. This work supports future higher education research in two
key ways. First, we offer an example of a principled approach to model
specification based in data science procedure that we believe could be
more widely incorporated in higher education policy research
[@Kuhn_Silge_2022]. Second, we take full advantage of these tools to
fit a large number of institutional data points available through the
College Scorecard, increasing the predictive capacity of our models in
determining program-level earnings.

Our goal is to provide more accurate earnings predictions that will
support the mission of policymakers in growing overall students'
earnings potential.

# Research Questions

1. What institutional/program level variables are most predictive of
          median first-year earnings?
2. What are the patterns of association (positive/negative) for these
          variables?

# Methodology

<!--  to build subsequent models, add models -->
<!-- to built workflow and fit the models to resampled data. We then -->
<!-- perform tuning for both models to ensure maximum predictive capacity. -->

Our process begins with reading in the full College Scorecard data
set, which includes program-specific data elements. Using the Tidy
models framework [@Kuhn_Silge_2022], we perform a pipeline of
preprocessing work that includes (1) dropping privacy
suppressed/missing data elements, (2) recoding categorical data to
dummy-coded indicator variables, and (3) removing zero variance/highly
correlated predictors.

Next, we partition our data into two sets: a training data set which
we use for model building and a testing data set that we use to
produce our results. As part of the model construction process, we
perform k-fold cross validation on the training set
data. Specifically, we recursively split the training data into 20
separate data sets, fitting and tuning the best model each time and
then averaging across all results. After deciding upon the best model,
we use it to predict program-level earnings using the held-out testing
data to mitigate issues of overfitting the data.

For our models, we use two regression-based, machine-learning methods:
elastic net and random forest. Elastic net regularization combines
LASSO and ridge regression penalties to remove non-predictive
coefficients from the model. Random forest regression models average
results from a large number of decision trees fit to a random subset
of observations and covariates [@Hastie_etal_2016]. These models are
particularly useful in our project, as they provide two key
benefits. First, they offer principled predictor selection from a
large set of possible determinants of earnings. Second, they support
the identification of non-linear relationships between predictors,
which means our predictions are not dependent on a
researcher-established functional form in the model. Using these two
modeling approaches we identify variables in the Scorecard data that
are highly predictive indicators of our dependent variable of
interest: median earnings from program graduates after one year.

# Data 

Data for this project originate from the College Scorecard and the
American Community Survey. In addition to our key outcome variable of
interest, median earnings for college graduates one year after
graduation, we take advantage of the large number of variables
available in the College Scorecard data set. These include over 2,000
variables featuring institutional characteristics and program-level
data for 6,700 accredited institutions in the U.S. Using county FIPS
codes, we match each higher education institution with county-level
data from the ACS. The ACS allows us to recover contextual information
lost in the Scorecard due to privacy suppression.

# Preliminary Findings

Across figures 1-3 (please see uploaded files for our figures), we
show median first year earnings for a selection of programs at three
degree levels: Bachelor's, Associate and Certificate/Diploma. Across
the figures, we see generally greater earnings potential for Bachelors
degree holders compared to other degree holders in similar fields of
study. For example, those who earn a Bachelor's degree in computer
programming earn just over $50,000 in their first year compared to
computer programmers with an associate degree or those with a
certificate in computer systems networking and telecommunications who
earn closer to $30,000.

Figure 4 shows predictor estimates from the elastic net model (see
Table 1 for a concordance of variable names with their
descriptions). The length of the bars represent the predictive power
of the variable, with the color of the bars representing the direction
of the association between predictor and outcome. While we identify
some variables typically assumed to be positive predictors of graduate
income like type of school, type of degree/credential, we also find
some unexpected positive and negative predictors of first year
earnings, like outstanding federal loan balance and median debt for
graduated students.

<!-- Both the elastic net and random forest regression models produced -->
<!-- estimates to inform the predictive capabilities of certain -->
<!-- program/institutional characteristics. -->

Figure 5 shows the most important variables (those most predictive) of
median first year earnings from our random forest regression model. As
with our elastic net model results, we see a similar emphasis on the
importance of type of degree credential, specifically
certificate/diploma and Bachelor's degrees. We also see the importance
of median family income and average family income for independent
students. Less expected are the comparative importance---compared to
many thousand predictors---of three-year cohort default rates and the
percentage of students making satisfactory academic progress in
predicting student earnings.


<!-- Ultimately, this project serves not only as a new venture that -->
<!-- coalesces machine learning and higher education research to estimate -->
<!-- student earnings, but has the potential to provide more accurate -->
<!-- estimates of first year program-level earnings than would otherwise be -->
<!-- achieved through typical econometric approaches. -->

# References

