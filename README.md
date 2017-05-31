# mark_tsoutliers
Identify time series outliers using tsoutliers without opening R. For your non-R-centric data pipelines.


## Overview

This script gives you access to some key functionality in the `tsoutliers` package via the command line. Note that it is designed for use with `tsoutliers` version '0.6.6' (May 27, 2017) and above. If you have an older version you may be at risk of running into [these](https://stats.stackexchange.com/questions/281921/na-causes-missed-outliers-with-tso-in-tsoutliers-package) [two](https://stackoverflow.com/questions/44191499/tso-function-in-tsoutliers-fails-with-message-about-xreg-colnames) bugs.

In particular, it takes a csv with a primary key and time series (ignoring other fields) and returns the primary key and series again with a TRUE/FALSE column indicating which observations are outliers. Optionally, you can return more information including the outlier types and even a plot of the series with outliers marked (examples below).

You can choose which types of outliers to look for, which is one of the big advantages of the `tsoutliers` package over many others. You can also set the outlier sensitivity. See below for more options in action.

## Installation

Open R and run this:

```
install.packages('tsoutliers')
```

**Important note**: If you already have the package, please be sure to upgrade to at least version '0.6.6'.

## Examples

Just run `mark_tsoutliers.R` from the command line, specifying the file and the primary key and column of interest. All of the examples below should run from the root of the mark_tsoutliers directory.

```
Rscript mark_tsoutliers.R --input_file data/ts-example-01.csv --primary_key_name date --series_name alpha
```

Since we didn't name it, the output will be called `tsoutliers.csv` and look something like this:
```
> head tsoutliers.csv

"pkey","series","tsoutlier"
"5/23/17",28.5,FALSE
"5/22/17",29.2,FALSE
"5/19/17",29.5,FALSE
"5/18/17",29,FALSE
"5/17/17",29,FALSE
"5/16/17",27.9,FALSE
"5/15/17",28.2,FALSE
"5/14/17",33,TRUE
"5/13/17",29.5,FALSE
```

### Adding a plot

Let's add a plot so we can see if we agree with what the package thinks is an outlier. We don't have to do this, but let's name it and put it in the examples subdirectory:
```
Rscript mark_tsoutliers.R --input_file data/ts-example-01.csv --primary_key_name date --series_name alpha --generate_plot --plot_path examples/first_plot.png
open examples/first_plot.png
```

We should see this:

![first plot](https://github.com/ryninho/mark_tsoutliers/blob/master/examples/first_plot.png "First plot")

That looks good, but it reminds me that the data was generated in descending chronological order. Rather than go back to the source we can just `--reverse` it from now on.
```
Rscript mark_tsoutliers.R --input_file data/ts-example-01.csv --primary_key_name date --series_name alpha --reverse --generate_plot --plot_path examples/reversed_plot.png
open examples/reversed_plot.png
```
![reversed plot](https://github.com/ryninho/mark_tsoutliers/blob/master/examples/reversed_plot.png "Reversed series plot")

### Using indexes instead of column names

Sometimes your headers are long or, even worse, have spaces or special characters. Fixing this at the source may be impractical or tedious but we can just use a column index to specify where to find the primary key and the column of interest. **Important note**: The index here starts at 1, not 0, just like in R.
```
Rscript mark_tsoutliers.R --input_file data/ts-example-01.csv --primary_key_index 1 --series_index 2 --reverse --generate_plot
```

### Short flags

This is starting to feel like a lot of typing. How about doing the same thing with shorter flags?
```
Rscript mark_tsoutliers.R -i data/ts-example-01.csv -p 1 -x 2 -r -g
```

You can see all the short flags by running `Rscript mark_tsoutliers.R --help` or looking at the argparse setup in [the script](https://github.com/ryninho/mark_tsoutliers/blob/master/mark_tsoutliers.R).

For easy readability I'll continue to use the long flags for the rest of the examples.


### Changing the sensitivity

After inspecting the plot or csv you may conclude that you want a stricter or looser definition of an outlier. Let's experiment with the `--critical_value` setting to see the implications of different sensitivities. A *lower* critical value equates to higher sensitivity to outliers. Start with ~3.5 as this is roughly what the `tsoutliers` package uses (though it selects the exact `cval` based on the sample size).

```
Rscript mark_tsoutliers.R --input_file data/ts-example-01.csv --primary_key_name date --series_name alpha --reverse --generate_plot --plot_path examples/medium_sensitivity_plot.png --critical_value 3.5
open examples/medium_sensitivity_plot.png
```
![Medium](https://github.com/ryninho/mark_tsoutliers/blob/master/examples/medium_sensitivity_plot.png "Medium")

```
Rscript mark_tsoutliers.R --input_file data/ts-example-01.csv --primary_key_name date --series_name alpha --reverse --generate_plot --plot_path examples/low_sensitivity_plot.png --critical_value 5.0
open examples/low_sensitivity_plot.png
```
![Low](https://github.com/ryninho/mark_tsoutliers/blob/master/examples/low_sensitivity_plot.png "Low")

```
Rscript mark_tsoutliers.R --input_file data/ts-example-01.csv --primary_key_name date --series_name alpha --reverse --generate_plot --plot_path examples/high_sensitivity_plot.png --critical_value 2.0
open examples/high_sensitivity_plot.png
```
![High](https://github.com/ryninho/mark_tsoutliers/blob/master/examples/high_sensitivity_plot.png "High")

### Looking for different outliers types

This is where `tsoutliers` stands out relative to other packages- you can choose any combination of five flavors of outliers: "AO" additive, "LS" level shifts, "TC" temporary changes, "IO" innovative outliers and "SLS" seasonal level shifts. By default this script will look for additive and temporary change outliers ("AO" and "TC"). **Note**: This differs from the `tsoutliers` package itself in that its default also includes level shifts ("LS").

Let's start with just additive outliers.
```
Rscript mark_tsoutliers.R --input_file data/ts-example-01.csv --primary_key_name date --series_name alpha --reverse --generate_plot --plot_path examples/AO_plot.png --AO
open examples/AO_plot.png
```
![AO](https://github.com/ryninho/mark_tsoutliers/blob/master/examples/AO_plot.png "AO")

Now let's pretend there are no additive outliers and look only for level shifts.
```
Rscript mark_tsoutliers.R --input_file data/ts-example-01.csv --primary_key_name date --series_name alpha --reverse --generate_plot --plot_path examples/LS_plot.png --LS
open examples/LS_plot.png
```
![LS](https://github.com/ryninho/mark_tsoutliers/blob/master/examples/LS_plot.png "LS")

Without additive outliers it thinks the series consists of a few level shifts. Let's add additive outliers back in.
```
Rscript mark_tsoutliers.R --input_file data/ts-example-01.csv --primary_key_name date --series_name alpha --reverse --generate_plot --plot_path examples/AO_LS_plot.png --AO --LS
open examples/AO_LS_plot.png
```
![AO and LS](https://github.com/ryninho/mark_tsoutliers/blob/master/examples/AO_LS_plot.png "AO and LS")

I wonder which is which? (see next section)

### Returning more information

In the last section we didn't know which observations were considered additive outliers and which were considered level shifts. Let's add those to the csv and check it out. We'll also add the t-statistic (higher = more of an outlier).
```
Rscript mark_tsoutliers.R --input_file data/ts-example-01.csv --primary_key_name date --series_name alpha --reverse --AO --LS --return_outlier_type --return_outlier_tstat --output_file examples/AO_LS_outliers.csv
```
We see two of each of "AO" and "LS":
```
> awk -F"\," '$4 != "" { print $0 }' examples/AO_LS_outliers.csv

"pkey","series","tsoutlier","tsoutlier_type","tsoutlier_tstat"
"3/31/17",23.9,TRUE,"LS",6.74376758518038
"4/16/17",39.8,TRUE,"AO",17.0652180026562
"4/20/17",28,TRUE,"LS",9.17522700023507
"5/14/17",33,TRUE,"AO",4.85306325422314
```


## Where to learn more

The `tsoutliers` package documentation can be found [here](https://cran.r-project.org/web/packages/tsoutliers/tsoutliers.pdf).

You can learn much, more about the tsoutliers package- including what on earth an "innovation outlier" is- by reading [this pdf](https://jalobe.com/doc/tsoutliers.pdf) by the package author.
